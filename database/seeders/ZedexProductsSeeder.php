<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Services\Admin\ProductService;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;
use PhpOffice\PhpSpreadsheet\IOFactory;

class ZedexProductsSeeder extends Seeder
{
    private const CATEGORY_ID = 9; // Полимеры

    private const PRODUCT_TYPE_ID = 23; // ZEDEX

    private const FILE = 'Номенклатура и цены.xls';

    public function run(): void
    {
        $path = base_path(self::FILE);

        if (! is_file($path)) {
            $this->command?->warn('Файл '.self::FILE.' не найден, пропускаем импорт.');

            return;
        }

        $reader = IOFactory::createReader('Xls');
        $reader->setReadDataOnly(true);
        $sheet = $reader->load($path)->getSheet(0);

        $usedSlugs = Product::query()->pluck('slug')->filter()->all();
        $service = app(ProductService::class);

        $created = 0;
        $skipped = 0;

        foreach ($sheet->getRowIterator() as $row) {
            $r = $row->getRowIndex();

            if ($r < 2) {
                continue;
            }

            $name = $this->normalizeName($sheet->getCell("A{$r}")->getValue());

            if ($name === null || ! $this->isZedexBar($name)) {
                continue;
            }

            $code = trim((string) $sheet->getCell("E{$r}")->getValue());

            if ($code === '' || Product::query()->where('code', $code)->exists()) {
                $skipped++;

                continue;
            }

            $article = trim((string) $sheet->getCell("C{$r}")->getValue());
            $price = $sheet->getCell("H{$r}")->getValue();

            $slug = $this->uniqueSlug(Str::slug($name), $usedSlugs);
            $usedSlugs[] = $slug;

            $service->create([
                'category_id' => self::CATEGORY_ID,
                'product_type_id' => self::PRODUCT_TYPE_ID,
                'name' => $name,
                'slug' => $slug,
                'code' => $code,
                'article' => $article !== '' ? $article : null,
                'unit' => 'м',
                'retail_price' => is_numeric($price) ? $price : 0,
                'published' => true,
                'is_active' => true,
                'stock_mode' => 'length',
                'allow_cutting' => true,
                'cut_width_mm' => 3,
                'min_remainder_mm' => 100,
                'min_sale_length_mm' => 100,
            ]);

            $created++;
        }

        $this->command?->info("ZEDEX импортировано: {$created}, пропущено: {$skipped}");
    }

    private function isZedexBar(string $name): bool
    {
        return (bool) preg_match('/^(пруток|труба)\s+zedex\b/iu', $name)
            && str_contains($name, 'ZX-');
    }

    private function normalizeName(mixed $value): ?string
    {
        $name = trim((string) $value);
        $name = preg_replace('/\s+/u', ' ', $name) ?? $name;

        if ($name === '') {
            return null;
        }

        // кириллическая «х»/«Х» и знак «×» в размерах -> латинская x
        return str_replace(['х', 'Х', '×'], ['x', 'X', 'x'], $name);
    }

    private function uniqueSlug(string $base, array $used): string
    {
        $slug = $base;
        $suffix = 1;

        while (in_array($slug, $used, true)) {
            $slug = $base.'-'.$suffix;
            $suffix++;
        }

        return $slug;
    }
}
