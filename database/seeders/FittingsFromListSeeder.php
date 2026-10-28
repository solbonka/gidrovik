<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Country;
use App\Models\Diameter;
use App\Models\Product;
use App\Models\ProductType;
use App\Models\Standard;
use App\Models\Thread;
use App\Services\Admin\ProductService;
use Illuminate\Database\Seeder;

class FittingsFromListSeeder extends Seeder
{
    /**
     * Строки в формате: "<название>\t<SKU>".
     *
     * Название фитинга разбирается на связи автоматически:
     *   Фитинг, d-10mm, BSP, Г, 1/2, 0, Italy
     *           |       |   |   |    |   |
     *        диаметр стан. тип рез. угол страна
     *
     * Просто дописывай новые строки в этот массив.
     *
     * @var list<string>
     */
    private array $rows = [
        "Фитинг, d-10mm, BSP, Г, 1/2, 0, Italy\t00-00011734",
        "Фитинг, d-10mm, BSP, Г, 1/2, 0°\t00-00000075",
        "Фитинг, d-10mm, BSP, Г, 1/2, 45°\t00-00003098",
        "Фитинг, d-10mm, BSP, Г, 1/2, 45°, Italy\t00-00003100",
    ];

    /**
     * Обозначение типа из названия -> имя типа товара в справочнике.
     *
     * @var array<string, string>
     */
    private array $typeMap = [
        'Г' => 'Гайка',
        'Ш' => 'Штуцер',
        'Ф' => 'Фланец',
        'гайка' => 'Гайка',
        'штуцер' => 'Штуцер',
        'фланец' => 'Фланец',
    ];

    /**
     * Обозначение страны из названия -> имя страны в справочнике.
     *
     * @var array<string, string>
     */
    private array $countryMap = [
        'Italy' => 'Италия',
        'Италия' => 'Италия',
        'Germany' => 'Германия',
        'Германия' => 'Германия',
    ];

    public function run(ProductService $service): void
    {
        $category = Category::query()->where('slug', 'fittings')->first();

        if (! $category) {
            $this->command?->error('Категория "Фитинги" не найдена.');

            return;
        }

        foreach ($this->rows as $row) {
            $parts = preg_split('/\t+/', trim($row));

            if (count($parts) < 2) {
                $this->command?->warn("Пропущена строка (нет SKU): {$row}");

                continue;
            }

            [$name, $sku] = array_map('trim', $parts);

            $payload = $this->buildPayload($category->id, $name, $sku);

            $existing = Product::query()->where('code', $sku)->first();

            if ($existing) {
                $service->update($existing, $payload);
                $this->command?->info("Обновлён: {$name} ({$sku})");
            } else {
                $service->create($payload);
                $this->command?->info("Создан:   {$name} ({$sku})");
            }
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function buildPayload(int $categoryId, string $name, string $sku): array
    {
        $tokens = array_values(array_filter(
            array_map('trim', explode(', ', $name)),
            fn (string $token): bool => $token !== '',
        ));

        /*
         * Формат: Фитинг, диаметр, стандарт, тип, [резьба...], угол, [страна]
         */
        $diameterToken = $tokens[1] ?? null;
        $standardToken = $tokens[2] ?? null;
        $typeToken = $tokens[3] ?? null;
        $rest = array_slice($tokens, 4);

        // Страна — последний токен, если он распознан.
        $countryName = null;
        if ($rest !== [] && isset($this->countryMap[end($rest)])) {
            $countryName = $this->countryMap[array_pop($rest)];
        }

        // Угол — последний оставшийся токен, если он числовой.
        $angle = null;
        if ($rest !== [] && preg_match('/^(\d+)\s*°?$/u', end($rest), $m) === 1) {
            array_pop($rest);
            $degrees = (int) $m[1];
            $angle = in_array($degrees, [45, 90], true) ? $degrees : null;
        }

        // Всё, что осталось, — резьба.
        $threadName = implode(', ', $rest);

        $standardId = $standardToken !== null
            ? Standard::query()
                ->whereRaw('lower(code) = ?', [mb_strtolower($standardToken)])
                ->value('id')
            : null;

        $diameterId = null;
        if ($diameterToken !== null && preg_match('/^d-(\d+)\s*mm$/iu', $diameterToken, $m) === 1) {
            $diameterId = Diameter::query()->where('value', (int) $m[1])->value('id');
        }

        $threadId = $threadName !== '' ? $this->resolveThreadId($threadName) : null;

        $connections = [];
        if ($standardId || $diameterId || $threadId) {
            $connections[] = [
                'position' => 1,
                'standard_id' => $standardId,
                'diameter_id' => $diameterId,
                'thread_id' => $threadId,
            ];
        }

        return [
            'category_id' => $categoryId,
            'product_type_id' => $this->resolveTypeId($categoryId, $typeToken),
            'name' => $name,
            'code' => $sku,
            'article' => null,
            'angle' => $angle,
            'is_active' => true,
            'unit' => 'шт.',
            'country_id' => $countryName !== null
                ? Country::query()->where('name', $countryName)->value('id')
                : null,
            'characteristics' => [],
            'connections' => $connections,
        ];
    }

    private function resolveTypeId(int $categoryId, ?string $token): ?int
    {
        if ($token === null) {
            return null;
        }

        $typeName = $this->typeMap[$token] ?? $token;

        return ProductType::query()
            ->where('category_id', $categoryId)
            ->where('name', $typeName)
            ->value('id');
    }

    private function resolveThreadId(string $threadName): ?int
    {
        // Точное совпадение обозначения (дюймовые "1/2", "1 1/16" и т.п.).
        $id = Thread::query()->where('designation', $threadName)->value('id');

        if ($id) {
            return $id;
        }

        // Нормализация для метрики: "22*1,5" -> "M22x1.5".
        $normalized = preg_replace('/\s+/', '', $threadName) ?? '';
        $normalized = str_replace(['*', ','], ['x', '.'], $normalized);

        $id = Thread::query()
            ->whereRaw("replace(replace(replace(designation,' ',''),'*','x'),',','.') = ?", [$normalized])
            ->value('id');

        if ($id) {
            return $id;
        }

        $id = Thread::query()->where('designation', 'M'.$normalized)->value('id');

        return $id ?: null;
    }
}
