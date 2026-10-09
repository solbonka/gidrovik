<?php

namespace App\Services\Admin;

use App\Enums\StockMovementType;
use App\Models\Location;
use App\Models\Product;
use App\Models\StockMovement;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class StockMovementService
{
    public function receipt(
        int $productId,
        int $locationId,
        int $quantity,
        ?string $comment,
        ?int $userId,
    ): StockMovement {
        return DB::transaction(function () use (
            $productId,
            $locationId,
            $quantity,
            $comment,
            $userId,
        ): StockMovement {
            /*
             * Блокируем товар. Все будущие операции с остатками
             * должны соблюдать тот же порядок блокировок.
             */
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            $location = Location::query()
                ->whereKey($locationId)
                ->lockForUpdate()
                ->firstOrFail();

            if ($quantity < 1) {
                throw ValidationException::withMessages([
                    'quantity' => 'Количество должно быть больше нуля.',
                ]);
            }

            /*
             * Не создаём остаток для несуществующей пары вслепую:
             * блокировка товара сериализует складские операции
             * по одному товару, если все операции используют этот сервис.
             */
            $stock = DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $location->id)
                ->lockForUpdate()
                ->first();

            if ($stock === null) {
                DB::table('product_location')->insert([
                    'product_id' => $product->id,
                    'location_id' => $location->id,
                    'quantity' => $quantity,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            } else {
                DB::table('product_location')
                    ->where('product_id', $product->id)
                    ->where('location_id', $location->id)
                    ->increment('quantity', $quantity, [
                        'updated_at' => now(),
                    ]);
            }

            return StockMovement::query()->create([
                'product_id' => $product->id,
                'from_location_id' => null,
                'to_location_id' => $location->id,
                'quantity' => $quantity,
                'type' => StockMovementType::RECEIPT,
                'comment' => $comment,
                'user_id' => $userId,
            ]);
        }, attempts: 3);
    }

    public function transfer(
        int $productId,
        int $fromLocationId,
        int $toLocationId,
        int $quantity,
        ?string $comment,
        ?int $userId,
    ): StockMovement {
        if ($fromLocationId === $toLocationId) {
            throw ValidationException::withMessages([
                'to_location_id' => 'Исходная и целевая ячейки должны отличаться.',
            ]);
        }

        if ($quantity < 1) {
            throw ValidationException::withMessages([
                'quantity' => 'Количество должно быть больше нуля.',
            ]);
        }

        return DB::transaction(function () use (
            $productId,
            $fromLocationId,
            $toLocationId,
            $quantity,
            $comment,
            $userId,
        ): StockMovement {
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            /*
             * Всегда блокируем ячейки в порядке возрастания ID,
             * чтобы уменьшить риск взаимных блокировок.
             */
            $locations = Location::query()
                ->whereIn('id', [$fromLocationId, $toLocationId])
                ->orderBy('id')
                ->lockForUpdate()
                ->get()
                ->keyBy('id');

            if (
                !$locations->has($fromLocationId)
                || !$locations->has($toLocationId)
            ) {
                throw ValidationException::withMessages([
                    'location_id' => 'Одна из выбранных ячеек не существует.',
                ]);
            }

            $sourceStock = DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $fromLocationId)
                ->lockForUpdate()
                ->first();

            $availableQuantity = (int) ($sourceStock->quantity ?? 0);

            if ($availableQuantity < $quantity) {
                throw ValidationException::withMessages([
                    'quantity' => sprintf(
                        'Недостаточно товара в исходной ячейке. Доступно: %d.',
                        $availableQuantity,
                    ),
                ]);
            }

            $now = now();

            DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $fromLocationId)
                ->decrement('quantity', $quantity, [
                    'updated_at' => $now,
                ]);

            $destinationStock = DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $toLocationId)
                ->lockForUpdate()
                ->first();

            if ($destinationStock === null) {
                DB::table('product_location')->insert([
                    'product_id' => $product->id,
                    'location_id' => $toLocationId,
                    'quantity' => $quantity,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            } else {
                DB::table('product_location')
                    ->where('product_id', $product->id)
                    ->where('location_id', $toLocationId)
                    ->increment('quantity', $quantity, [
                        'updated_at' => $now,
                    ]);
            }

            return StockMovement::query()->create([
                'product_id' => $product->id,
                'from_location_id' => $fromLocationId,
                'to_location_id' => $toLocationId,
                'quantity' => $quantity,
                'type' => StockMovementType::TRANSFER,
                'comment' => $comment,
                'user_id' => $userId,
            ]);
        }, attempts: 3);
    }

    public function writeOff(
        int $productId,
        int $locationId,
        int $quantity,
        string $comment,
        ?int $userId,
    ): StockMovement {
        if ($quantity < 1) {
            throw ValidationException::withMessages([
                'quantity' => 'Количество должно быть больше нуля.',
            ]);
        }

        return DB::transaction(function () use (
            $productId,
            $locationId,
            $quantity,
            $comment,
            $userId,
        ): StockMovement {
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            Location::query()
                ->whereKey($locationId)
                ->lockForUpdate()
                ->firstOrFail();

            $stock = DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $locationId)
                ->lockForUpdate()
                ->first();

            $availableQuantity = (int) ($stock->quantity ?? 0);

            if ($availableQuantity < $quantity) {
                throw ValidationException::withMessages([
                    'quantity' => sprintf(
                        'Недостаточно товара для списания. Доступно: %d.',
                        $availableQuantity,
                    ),
                ]);
            }

            DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $locationId)
                ->decrement('quantity', $quantity, [
                    'updated_at' => now(),
                ]);

            return StockMovement::query()->create([
                'product_id' => $product->id,
                'from_location_id' => $locationId,
                'to_location_id' => null,
                'quantity' => $quantity,
                'type' => StockMovementType::WRITE_OFF,
                'comment' => $comment,
                'user_id' => $userId,
            ]);
        }, attempts: 3);
    }

    public function returnStock(
        int $productId,
        int $locationId,
        int $quantity,
        string $comment,
        ?int $userId,
    ): StockMovement {
        if ($quantity < 1) {
            throw \Illuminate\Validation\ValidationException::withMessages([
                'quantity' => 'Количество должно быть больше нуля.',
            ]);
        }

        return DB::transaction(function () use (
            $productId,
            $locationId,
            $quantity,
            $comment,
            $userId,
        ): StockMovement {
            // Сначала блокируем товар: это сериализует складские
            // операции над одним товаром при использовании того же порядка блокировок.
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            $location = Location::query()
                ->whereKey($locationId)
                ->lockForUpdate()
                ->firstOrFail();

            // Блокируем существующую запись остатка, если она есть.
            $stock = DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $location->id)
                ->lockForUpdate()
                ->first();

            $currentQuantity = (int) ($stock->quantity ?? 0);
            $newQuantity = $currentQuantity + $quantity;

            if ($newQuantity > 2147483647) {
                throw \Illuminate\Validation\ValidationException::withMessages([
                    'quantity' => 'Итоговый остаток превышает допустимое значение.',
                ]);
            }

            if ($stock !== null) {
                DB::table('product_location')
                    ->where('product_id', $product->id)
                    ->where('location_id', $location->id)
                    ->update([
                        'quantity' => $newQuantity,
                        'updated_at' => now(),
                    ]);
            } else {
                DB::table('product_location')->insert([
                    'product_id' => $product->id,
                    'location_id' => $location->id,
                    'quantity' => $quantity,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            return StockMovement::query()->create([
                'product_id' => $product->id,
                'from_location_id' => null,
                'to_location_id' => $location->id,
                'quantity' => $quantity,
                'type' => StockMovementType::RETURN,
                'comment' => $comment,
                'user_id' => $userId,
            ]);
        }, attempts: 3);
    }

    public function inventory(
        int $productId,
        int $locationId,
        int $actualQuantity,
        string $comment,
        ?int $userId,
    ): ?StockMovement {
        if ($actualQuantity < 0 || $actualQuantity > 2147483647) {
            throw ValidationException::withMessages([
                'actual_quantity' => 'Укажите допустимое фактическое количество.',
            ]);
        }

        return DB::transaction(function () use (
            $productId,
            $locationId,
            $actualQuantity,
            $comment,
            $userId,
        ): ?StockMovement {
            // Блокируем товар, чтобы складские операции над ним
            // выполнялись последовательно.
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            $location = Location::query()
                ->whereKey($locationId)
                ->lockForUpdate()
                ->firstOrFail();

            $stock = DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $location->id)
                ->lockForUpdate()
                ->first();

            $currentQuantity = (int) ($stock->quantity ?? 0);

            // Расхождений нет — остаток и журнал не меняем.
            if ($currentQuantity === $actualQuantity) {
                return null;
            }

            $difference = abs($actualQuantity - $currentQuantity);

            if ($difference > 2147483647) {
                throw ValidationException::withMessages([
                    'actual_quantity' => 'Разница превышает допустимое значение.',
                ]);
            }

            if ($stock !== null) {
                DB::table('product_location')
                    ->where('product_id', $product->id)
                    ->where('location_id', $location->id)
                    ->update([
                        'quantity' => $actualQuantity,
                        'updated_at' => now(),
                    ]);
            } else {
                // Если фактический остаток равен нулю, создаём запись
                // движения, но не создаём ненужную запись остатка.
                if ($actualQuantity > 0) {
                    DB::table('product_location')->insert([
                        'product_id' => $product->id,
                        'location_id' => $location->id,
                        'quantity' => $actualQuantity,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }

            $isIncrease = $actualQuantity > $currentQuantity;

            return StockMovement::query()->create([
                'product_id' => $product->id,
                'from_location_id' => $isIncrease ? null : $location->id,
                'to_location_id' => $isIncrease ? $location->id : null,
                'quantity' => $difference,
                'type' => StockMovementType::INVENTORY,
                'comment' => sprintf(
                    '%s Учётный остаток: %d; фактический остаток: %d. %s',
                    $isIncrease ? 'Излишек.' : 'Недостача.',
                    $currentQuantity,
                    $actualQuantity,
                    trim($comment),
                ),
                'user_id' => $userId,
            ]);
        }, attempts: 3);
    }
}
