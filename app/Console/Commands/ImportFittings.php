<?php

namespace App\Console\Commands;

use App\Models\Category;
use App\Models\Country;
use App\Models\Diameter;
use App\Models\Product;
use App\Models\ProductType;
use App\Models\Standard;
use App\Models\Thread;
use App\Services\Admin\ProductService;
use Illuminate\Console\Command;

class ImportFittings extends Command
{
    protected $signature = 'products:import-fittings
        {file : Путь к файлу; строки вида "имя<TAB>sku"}
        {--dry-run : Только разбор, без записи в БД}
        {--show=20 : Сколько примеров разбора показать}';

    protected $description = 'Импорт фитингов из списка "имя<TAB>sku" (пропускает уже существующие SKU)';

    /**
     * Слова стран (в нижнем регистре) -> имя страны в справочнике.
     *
     * @var array<string, string>
     */
    private array $countryWords = [
        'italy' => 'Италия',
        'италия' => 'Италия',
        'germany' => 'Германия',
        'германия' => 'Германия',
    ];

    public function handle(ProductService $service): int
    {
        $path = (string) $this->argument('file');

        if (! is_file($path)) {
            $this->error("Файл не найден: {$path}");

            return self::FAILURE;
        }

        $category = Category::query()->where('slug', 'fittings')->first();

        if ($category === null) {
            $this->error('Категория "Фитинги" не найдена.');

            return self::FAILURE;
        }

        $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];

        $ref = [
            'category_id' => $category->id,
            'standards' => Standard::query()
                ->get(['id', 'code'])
                ->mapWithKeys(fn ($s): array => [mb_strtoupper($s->code) => $s->id])
                ->all(),
            'diameters' => Diameter::query()->pluck('id', 'value')->all(),
            'threads_inch' => Thread::query()->where('system', 'inch')->pluck('id', 'designation')->all(),
            'threads_metric' => Thread::query()->where('system', 'metric')->pluck('id', 'designation')->all(),
            'threads_other' => Thread::query()->where('system', 'other')->pluck('id', 'designation')->all(),
            'countries' => Country::query()->pluck('id', 'name')->all(),
            'types' => ProductType::query()->where('category_id', $category->id)->pluck('id', 'name')->all(),
        ];

        $existing = Product::query()->pluck('id', 'code')->all();

        $dry = (bool) $this->option('dry-run');
        $show = (int) $this->option('show');

        $created = $skipped = $invalid = 0;
        $seen = [];

        foreach ($lines as $i => $line) {
            $line = trim($line);

            if ($line === '') {
                continue;
            }

            // Заголовки групп вида "DK" / "BSP" (без SKU) пропускаем.
            $parts = preg_split('/\t+/', $line);

            if (count($parts) < 2 || trim($parts[1] ?? '') === '') {
                $invalid++;

                continue;
            }

            $name = trim($parts[0]);
            $sku = trim($parts[1]);

            if ($name === '' || $sku === '') {
                $invalid++;

                continue;
            }

            // Уже есть в БД или дубль внутри файла — пропускаем.
            if (isset($existing[$sku]) || isset($seen[$sku])) {
                $skipped++;

                continue;
            }

            $payload = $this->buildPayload($name, $sku, $ref);

            if ($show > 0 && $created < $show) {
                $d = $payload['_debug'];
                $this->line(sprintf(
                    '  • %s (%s) | std=%s dia=%s thr=%s type=%s angle=%s country=%s',
                    $name,
                    $sku,
                    $d['std'] ?? '-',
                    $d['dia'] ?? '-',
                    $d['thr'] ?? '-',
                    $d['type'] ?? '-',
                    $payload['angle'] ?? '-',
                    $d['country'] ?? '-',
                ));
            }

            if (! $dry) {
                unset($payload['_debug']);
                $service->create($payload);
            }

            $seen[$sku] = 1;
            $created++;
        }

        $this->newLine();
        $this->info(($dry ? '[DRY-RUN] ' : '')."Создано: {$created}, пропущено (уже есть): {$skipped}, невалидных строк: {$invalid}");

        return self::SUCCESS;
    }

    /**
     * @return array<string, mixed>
     */
    private function buildPayload(string $name, string $sku, array $ref): array
    {
        $tokens = array_values(array_filter(
            array_map('trim', explode(', ', $name)),
            fn (string $t): bool => $t !== '',
        ));

        /*
         * Фиксированные позиции:
         *   0 = "Фитинг..." (может быть "Фитинг Интерлок")
         *   1 = диаметр (d-10mm)
         *   2 = стандарт (BSP)
         *   3 = тип (Г/Ш/Ф) — не всегда есть
         * Далее: резьба..., угол, [страна]
         */
        $diameterId = null;
        $standardId = null;
        $typeId = null;
        $threadId = null;
        $angle = null;
        $countryId = null;
        $hasInterlock = false;
        $hasORing = false;

        $rest = $tokens;

        // "Фитинг Интерлок" — интерлок указывается прямо в первом токене.
        if (isset($rest[0])) {
            $first = mb_strtolower($rest[0]);
            if (str_contains($first, 'интерлок') || str_contains($first, 'interlock')) {
                $hasInterlock = true;
            }
            array_shift($rest);
        }

        // Диаметр.
        if (isset($rest[0]) && preg_match('/^d-?(\d+)\s*mm$/iu', $rest[0], $m) === 1) {
            $value = (int) $m[1];
            $diameterId = $ref['diameters'][$value] ?? null;
            array_shift($rest);
        }

        // Стандарт (нормализуем спец-варианты к коду справочника).
        if (isset($rest[0])) {
            $standardId = $this->resolveStandard($rest[0], $ref['standards']);
            array_shift($rest);
        }

        // Тип (Г/Ш/Ф или слово). Не у всех фитингов есть.
        if (isset($rest[0])) {
            $typeId = $this->resolveType($rest[0], $ref['types']);
            if ($typeId !== null) {
                array_shift($rest);
            }
        }

        /*
         * Хвост: [<резьба>, <угол>?, <o-ring>?, <страна>?, <прочие пометки>...]
         * Резьба всегда идёт сразу после типа; всё, что после — метаданные,
         * которые сканируем на угол / o-ring / страну (остальное игнорируем,
         * полное название сохраняется в products.name).
         */
        $threadRaw = (string) ($rest[0] ?? '');
        $meta = array_slice($rest, 1);

        foreach ($meta as $token) {
            // Угол: "45°", "0° S=17", "90°", или чистое "45"/"0".
            if (preg_match('/^(\d{1,3})\s*(°|град|grad)/u', $token, $m) === 1
                || preg_match('/^(\d{1,3})$/u', $token, $m) === 1) {
                $degrees = (int) $m[1];
                if (in_array($degrees, [45, 90], true)) {
                    $angle = $degrees;
                }

                continue;
            }

            // O-Ring / страна — ищем по словам (напр. "o-ring Italy").
            foreach (preg_split('/\s+/u', $token) ?: [] as $word) {
                $lw = mb_strtolower($word);

                if ($lw === 'o-ring' || $lw === 'oring') {
                    $hasORing = true;
                } elseif (isset($this->countryWords[$lw])) {
                    $countryId = $ref['countries'][$this->countryWords[$lw]] ?? $countryId;
                }
            }
        }

        $threadId = $threadRaw !== '' ? $this->resolveThread($threadRaw, $ref) : null;

        $connections = [];
        if ($standardId || $diameterId || $threadId) {
            $connections[] = [
                'position' => 1,
                'standard_id' => $standardId,
                'diameter_id' => $diameterId,
                'thread_id' => $threadId,
            ];
        }

        $characteristics = [];
        if ($hasORing) {
            $characteristics[2] = '1';
        }
        if ($hasInterlock) {
            $characteristics[3] = '1';
        }

        return [
            'category_id' => $ref['category_id'],
            'product_type_id' => $typeId,
            'name' => $name,
                'code' => $sku,
                'article' => null,
            'angle' => $angle,
            'is_active' => true,
            'unit' => 'шт.',
            'country_id' => $countryId,
            'characteristics' => $characteristics,
            'connections' => $connections,
            '_debug' => [
                'std' => $standardId ? 'id'.$standardId : '-',
                'dia' => $diameterId ? 'id'.$diameterId : '-',
                'thr' => $threadId ? 'id'.$threadId : ($threadRaw ?: '-'),
                'type' => $typeId ? 'id'.$typeId : '-',
                'country' => $countryId ? 'id'.$countryId : '-',
            ],
        ];
    }

    /**
     * @param  array<string, int>  $standards
     */
    private function resolveStandard(string $token, array $standards): ?int
    {
        // Сначала заменяем кириллицу, похожую на латиницу, затем приводим к верхнему регистру.
        $normalized = str_replace(['с', 'С', 'х', 'Х', 'а', 'А'], ['c', 'C', 'x', 'X', 'a', 'A'], $token);
        $code = mb_strtoupper(trim($normalized));

        if (isset($standards[$code])) {
            return $standards[$code];
        }

        $map = [
            'BSPF' => 'BSP',
            'BSPT' => 'BSP',
            'BSPP' => 'BSP',
            'BSP-L' => 'BSP',
            'JIS BSP' => 'JIS',
            'JISMETRIC' => 'JISMetric',
            'JIS METRIC' => 'JISMetric',
            'SFCAT' => 'SF',
            'SF CAT' => 'SF',
            'DK-L' => 'DK',
            'DKOL-L' => 'DKOL',
        ];

        if (isset($map[$code]) && isset($standards[$map[$code]])) {
            return $standards[$map[$code]];
        }

        return null;
    }

    /**
     * @param  array<string, int>  $types
     */
    private function resolveType(string $token, array $types): ?int
    {
        $map = [
            'Г' => 'Гайка',
            'Ш' => 'Штуцер',
            'Ф' => 'Фланец',
            'гайка' => 'Гайка',
            'штуцер' => 'Штуцер',
            'фланец' => 'Фланец',
        ];

        $name = $map[trim($token)] ?? null;

        return $name !== null ? ($types[$name] ?? null) : null;
    }

    /**
     * @param  array<string, mixed>  $ref
     */
    private function resolveThread(string $raw, array $ref): ?int
    {
        $needle = trim($raw);

        if ($needle === '') {
            return null;
        }

        // Дюймы: точное совпадение либо "1,1/4" -> "1 1/4".
        $inchVariants = [
            $needle,
            str_replace(',', ' ', $needle),
        ];
        foreach ($inchVariants as $variant) {
            if (isset($ref['threads_inch'][$variant])) {
                return $ref['threads_inch'][$variant];
            }
        }

        // Метрика: "22*1,5" -> "M22x1.5".
        $metric = str_replace(['*', ',', 'х', 'Х'], ['x', '.', 'x', 'x'], $needle);
        $metric = preg_replace('/\s+/', '', $metric) ?? '';
        foreach (['M'.$metric, $metric] as $variant) {
            if (isset($ref['threads_metric'][$variant])) {
                return $ref['threads_metric'][$variant];
            }
        }

        // Прочее: WEO/SF и т.п. — точное совпадение либо замена "," на ".".
        if (isset($ref['threads_other'][$needle])) {
            return $ref['threads_other'][$needle];
        }
        $dotVariant = str_replace(',', '.', $needle);
        if ($dotVariant !== $needle && isset($ref['threads_other'][$dotVariant])) {
            return $ref['threads_other'][$dotVariant];
        }

        return null;
    }
}
