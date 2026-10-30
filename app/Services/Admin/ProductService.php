<?php

namespace App\Services\Admin;

use App\Models\Product;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ProductService
{
    public function create(array $data): Product
    {
        return DB::transaction(function () use ($data): Product {
            $slug = $data['slug'] ?? Str::slug($data['name']);

            $product = Product::query()->create([
                'category_id' => $data['category_id'] ?? null,
                'product_type_id' => $data['product_type_id'] ?? null,
                'name' => $data['name'],
                'code' => $data['code'],
                'article' => $data['article'] ?? null,
                'minimum_stock' => $data['minimum_stock'] ?? '0',
                'angle' => $data['angle'] ?? null,
                'description' => $data['description'] ?? null,
                'is_active' => $data['is_active'] ?? true,
                'unit' => $data['unit'],
                'manufacturer_id' => $data['manufacturer_id'] ?? null,
                'country_id' => $data['country_id'] ?? null,
                'retail_price' => $data['retail_price'] ?? 0,
                'published' => $data['published'] ?? true,
                'meta_title' => $data['meta_title'] ?? null,
                'meta_description' => $data['meta_description'] ?? null,
            ]);

            $this->syncCharacteristics(
                $product,
                $data['characteristics'] ?? [],
            );

            $this->syncConnections(
                $product,
                $data['connections'] ?? [],
            );

            return $product;
        });
    }

    public function update(Product $product, array $data): Product
    {
        return DB::transaction(function () use ($product, $data): Product {
            $updateData = [
                'category_id' => $data['category_id'],
                'product_type_id' => $data['product_type_id'] ?? null,
                'name' => $data['name'],
                'code' => $data['code'],
                'article' => $data['article'] ?? null,
                'minimum_stock' => $data['minimum_stock'] ?? null,
                'angle' => $data['angle'] ?? null,
                'description' => $data['description'] ?? null,
                'retail_price' => $data['retail_price'] ?? 0,
                'published' => $data['published'] ?? false,
                'is_active' => $data['is_active'] ?? true,
                'unit' => $data['unit'] ?? 'шт.',
                'manufacturer_id' => $data['manufacturer_id'] ?? null,
                'country_id' => $data['country_id'] ?? null,
            ];

            // Update slug if name changed
            if (isset($data['name']) && $data['name'] !== $product->name) {
                $updateData['slug'] = $data['slug'] ?? Str::slug($data['name']);
            }

            if (isset($data['meta_title'])) {
                $updateData['meta_title'] = $data['meta_title'];
            }
            if (isset($data['meta_description'])) {
                $updateData['meta_description'] = $data['meta_description'];
            }

            $product->update($updateData);

            $product->characteristicValues()->delete();
            $product->connections()->delete();

            $this->syncCharacteristics(
                $product,
                $data['characteristics'] ?? [],
            );

            $this->syncConnections(
                $product,
                $data['connections'] ?? [],
            );

            return $product->fresh();
        });
    }

    private function syncCharacteristics(
        Product $product,
        array $characteristics,
    ): void {
        foreach ($characteristics as $characteristicId => $value) {
            if ($value === null || $value === '') {
                continue;
            }

            $product->characteristicValues()->create([
                'characteristic_id' => (int) $characteristicId,
                'value' => (string) $value,
            ]);
        }
    }

    private function syncConnections(
        Product $product,
        array $connections,
    ): void {
        $isCoupling = $this->isCouplingCategory($product);

        foreach ($connections as $connection) {
            $standardId = $connection['standard_id'] ?? null;
            $diameterId = $connection['diameter_id'] ?? null;
            $threadId = $connection['thread_id'] ?? null;

            /*
             * Для муфт из подключения значим только диаметр.
             * Стандарт и резьба принудительно сбрасываем.
             */
            if ($isCoupling) {
                $standardId = null;
                $threadId = null;
            }

            $hasValue = filled($standardId)
                || filled($diameterId)
                || filled($threadId);

            if (! $hasValue) {
                continue;
            }

            $product->connections()->create([
                'position' => $connection['position'],
                'standard_id' => $standardId,
                'diameter_id' => $diameterId,
                'thread_id' => $threadId,
            ]);
        }
    }

    private function isCouplingCategory(Product $product): bool
    {
        $category = $product->category;

        if (! $category) {
            return false;
        }

        $slug = mb_strtolower($category->slug);
        $name = mb_strtolower($category->name);

        return str_contains($slug, 'hose')
            || str_contains($slug, 'coupling')
            || str_contains($slug, 'муфт')
            || str_contains($name, 'муфт');
    }
}
