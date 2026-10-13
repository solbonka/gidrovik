<?php

namespace App\Services\Admin;

use App\Models\Product;
use Illuminate\Support\Facades\DB;

class ProductService
{
    public function create(array $data): Product
    {
        return DB::transaction(function () use ($data): Product {
            $product = Product::query()->create([
                'category_id' => $data['category_id'],
                'product_type_id' => $data['product_type_id'] ?? null,
                'name' => $data['name'],
                'sku' => $data['sku'],
                'minimum_stock' => $data['minimum_stock'] ?? null,
                'angle' => $data['angle'] ?? null,
                'description' => $data['description'] ?? null,
                'is_active' => $data['is_active'] ?? true,
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
            $product->update([
                'category_id' => $data['category_id'],
                'product_type_id' => $data['product_type_id'] ?? null,
                'name' => $data['name'],
                'sku' => $data['sku'],
                'minimum_stock' => $data['minimum_stock'] ?? null,
                'angle' => $data['angle'] ?? null,
                'description' => $data['description'] ?? null,
                'is_active' => $data['is_active'] ?? true,
            ]);

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
        foreach ($connections as $connection) {
            $hasValue = filled($connection['standard_id'] ?? null)
                || filled($connection['diameter_id'] ?? null)
                || filled($connection['thread_id'] ?? null);

            if (!$hasValue) {
                continue;
            }

            $product->connections()->create([
                'position' => $connection['position'],
                'standard_id' => $connection['standard_id'] ?? null,
                'diameter_id' => $connection['diameter_id'] ?? null,
                'thread_id' => $connection['thread_id'] ?? null,
            ]);
        }
    }
}
