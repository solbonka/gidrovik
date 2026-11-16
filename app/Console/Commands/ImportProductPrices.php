<?php

namespace App\Console\Commands;

use App\Models\Product;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use PhpOffice\PhpSpreadsheet\IOFactory;

class ImportProductPrices extends Command
{
    protected $signature = 'products:import-prices
        {file : Путь к файлу .xls/.xlsx/.csv с колонками "Код" и "Розничная"}
        {--dry-run : Только разбор, без записи в БД}
        {--sheet= : Имя листа (по умолчанию — первый непустой)}';

    protected $description = 'Импорт розничных цен из файла номенклатуры (сопоставление по коду товара)';

    public function handle(): int
    {
        // Большие файлы номенклатуры могут не влезать в дефолтные 128M
        ini_set('memory_limit', '1G');

        $path = (string) $this->argument('file');

        if (! is_file($path)) {
            $this->error("Файл не найден: {$path}");

            return self::FAILURE;
        }

        $rows = $this->readPrices($path);

        if ($rows === null) {
            return self::FAILURE;
        }

        [$prices, $skipped] = $rows;

        $this->info(sprintf('Прочитано цен: %d (пропущено без цены/кода: %d)', count($prices), $skipped));

        $codes = array_keys($prices);
        $existing = Product::query()
            ->whereIn('code', $codes)
            ->pluck('id', 'code');

        $matched = $existing->count();
        $unmatched = count($codes) - $matched;

        $this->info(sprintf('Совпало с товарами: %d, не найдено в каталоге: %d', $matched, $unmatched));

        if ($unmatched > 0) {
            $missing = array_diff($codes, $existing->keys()->all());
            $this->warn('Примеры несовпавших кодов: '.implode(', ', array_slice($missing, 0, 10)));
        }

        if ($this->option('dry-run')) {
            $this->comment('Dry-run: запись не выполнялась.');

            return self::SUCCESS;
        }

        $updated = 0;

        DB::transaction(function () use ($prices, $existing, &$updated): void {
            foreach ($prices as $code => $price) {
                $id = $existing[$code] ?? null;

                if ($id === null) {
                    continue;
                }

                $updated += Product::query()
                    ->whereKey($id)
                    ->where('retail_price', '!=', $price)
                    ->update(['retail_price' => $price, 'updated_at' => now()]);
            }
        });

        $this->info("Обновлено цен: {$updated}");

        return self::SUCCESS;
    }

    /**
     * @return array{0: array<string, float>, 1: int}|null
     */
    private function readPrices(string $path): ?array
    {
        $extension = strtolower(pathinfo($path, PATHINFO_EXTENSION));

        if (in_array($extension, ['xls', 'xlsx'], true)) {
            return $this->readSpreadsheet($path);
        }

        if (in_array($extension, ['csv', 'txt', 'tsv'], true)) {
            return $this->readCsv($path);
        }

        $this->error("Неподдерживаемый формат: {$extension}. Ожидается .xls, .xlsx или .csv");

        return null;
    }

    /**
     * @return array{0: array<string, float>, 1: int}|null
     */
    private function readSpreadsheet(string $path): ?array
    {
        try {
            $spreadsheet = IOFactory::load($path);
        } catch (\Throwable $e) {
            $this->error("Не удалось прочитать файл: {$e->getMessage()}");

            return null;
        }

        $sheetName = $this->option('sheet');

        if (is_string($sheetName) && $sheetName !== '') {
            $sheet = $spreadsheet->getSheetByName($sheetName);

            if ($sheet === null) {
                $this->error("Лист '{$sheetName}' не найден. Доступные: ".implode(', ', $spreadsheet->getSheetNames()));

                return null;
            }
        } else {
            $sheet = null;

            foreach ($spreadsheet->getAllSheets() as $candidate) {
                if ($candidate->getHighestDataRow() > 1) {
                    $sheet = $candidate;
                    break;
                }
            }

            $sheet ??= $spreadsheet->getSheet(0);
        }

        $highestRow = $sheet->getHighestDataRow();
        $highestColumn = $sheet->getHighestDataColumn();

        $rows = $sheet->rangeToArray("A1:{$highestColumn}{$highestRow}", null, true, true, false);

        return $this->extractPrices($rows);
    }

    /**
     * @return array{0: array<string, float>, 1: int}
     */
    private function readCsv(string $path): array
    {
        $content = file_get_contents($path);

        if ($content === false) {
            $this->error("Не удалось прочитать файл: {$path}");

            return [[], 0];
        }

        // Определяем разделитель по первой строке
        $firstLine = strtok($content, "\n") ?: '';
        $delimiter = substr_count($firstLine, ';') > substr_count($firstLine, ',')
            ? ';'
            : (substr_count($firstLine, "\t") > 0 ? "\t" : ',');

        $rows = [];
        $handle = fopen('php://temp', 'r+');
        fwrite($handle, $content);
        rewind($handle);

        while (($row = fgetcsv($handle, 0, $delimiter)) !== false) {
            $rows[] = $row;
        }

        fclose($handle);

        return $this->extractPrices($rows);
    }

    /**
     * Ищет колонки «Код» и «Розничная» по заголовку, затем собирает цены.
     *
     * @param  array<int, array<int, mixed>>  $rows
     * @return array{0: array<string, float>, 1: int}
     */
    private function extractPrices(array $rows): array
    {
        $codeColumn = null;
        $priceColumn = null;

        foreach ($rows as $index => $row) {
            foreach ($row as $colIndex => $cell) {
                $header = mb_strtolower(trim((string) $cell));

                if ($codeColumn === null && (str_contains($header, 'код') && ! str_contains($header, 'штрих') && ! str_contains($header, 'артикул'))) {
                    $codeColumn = $colIndex;
                }

                if ($priceColumn === null && str_contains($header, 'рознич')) {
                    $priceColumn = $colIndex;
                }
            }

            // Заголовок обычно в первых строках
            if ($index > 10) {
                break;
            }
        }

        if ($codeColumn === null || $priceColumn === null) {
            $this->error('Не найдены колонки «Код» и/или «Розничная» в заголовке файла.');

            return [[], 0];
        }

        $prices = [];
        $skipped = 0;

        foreach ($rows as $row) {
            $code = trim((string) ($row[$codeColumn] ?? ''));
            $rawPrice = $row[$priceColumn] ?? null;

            if ($code === '' || $rawPrice === null || $rawPrice === '') {
                if ($code !== '') {
                    $skipped++;
                }

                continue;
            }

            $price = $this->parsePrice($rawPrice);

            if ($price === null || $price <= 0) {
                $skipped++;

                continue;
            }

            $prices[$code] = $price;
        }

        return [$prices, $skipped];
    }

    private function parsePrice(mixed $value): ?float
    {
        if (is_int($value) || is_float($value)) {
            return (float) $value;
        }

        $string = trim((string) $value);

        if ($string === '') {
            return null;
        }

        // Русский формат: "1 252,50" — пробелы как разделитель тысяч, запятая — дробная часть
        $normalized = str_replace(["\xc2\xa0", ' '], '', $string);
        $normalized = str_replace(',', '.', $normalized);

        if (! is_numeric($normalized)) {
            return null;
        }

        return (float) $normalized;
    }
}
