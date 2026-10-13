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
    private const MAX_QUANTITY = '999999999.999';

    private const INTEGER_UNITS = [
        'шт.',
        'упаковка',
        'комплект',
    ];

    private const DECIMAL_UNITS = [
        'м',
        'л',
    ];

    public function receipt(
        int $productId,
        int $locationId,
        string|int|float $quantity,
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
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            $quantity = $this->normalizeQuantity(
                $quantity,
                $product->unit,
            );

            $location = Location::query()
                ->whereKey($locationId)
                ->lockForUpdate()
                ->firstOrFail();

            $stock = DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $location->id)
                ->lockForUpdate()
                ->first();

            $currentQuantity = (string) ($stock->quantity ?? '0');

            $this->assertMaximumQuantity(
                bcadd($currentQuantity, $quantity, 3),
                'quantity',
            );

            $now = now();

            if ($stock === null) {
                DB::table('product_location')->insert([
                    'product_id' => $product->id,
                    'location_id' => $location->id,
                    'quantity' => $quantity,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            } else {
                DB::table('product_location')
                    ->where('product_id', $product->id)
                    ->where('location_id', $location->id)
                    ->increment('quantity', $quantity, [
                        'updated_at' => $now,
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
        string|int|float $quantity,
        ?string $comment,
        ?int $userId,
    ): StockMovement {
        if ($fromLocationId === $toLocationId) {
            throw ValidationException::withMessages([
                'to_location_id' => 'Исходная и целевая ячейки должны отличаться.',
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

            $quantity = $this->normalizeQuantity(
                $quantity,
                $product->unit,
            );

            $locations = Location::query()
                ->whereIn('id', [$fromLocationId, $toLocationId])
                ->orderBy('id')
                ->lockForUpdate()
                ->get()
                ->keyBy('id');

            if (
                ! $locations->has($fromLocationId)
                || ! $locations->has($toLocationId)
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

            $availableQuantity = (string) ($sourceStock->quantity ?? '0');

            if (bccomp($availableQuantity, $quantity, 3) < 0) {
                throw ValidationException::withMessages([
                    'quantity' => sprintf(
                        'Недостаточно товара в исходной ячейке. Доступно: %s.',
                        $this->formatQuantity($availableQuantity),
                    ),
                ]);
            }

            $destinationStock = DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $toLocationId)
                ->lockForUpdate()
                ->first();

            $destinationQuantity = (string) ($destinationStock->quantity ?? '0');

            $this->assertMaximumQuantity(
                bcadd($destinationQuantity, $quantity, 3),
                'quantity',
            );

            $now = now();

            DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $fromLocationId)
                ->decrement('quantity', $quantity, [
                    'updated_at' => $now,
                ]);

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
        string|int|float $quantity,
        string $comment,
        ?int $userId,
    ): StockMovement {
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

            $quantity = $this->normalizeQuantity(
                $quantity,
                $product->unit,
            );

            $location = Location::query()
                ->whereKey($locationId)
                ->lockForUpdate()
                ->firstOrFail();

            $stock = DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $location->id)
                ->lockForUpdate()
                ->first();

            $currentQuantity = (string) ($stock->quantity ?? '0');

            if (bccomp($currentQuantity, $quantity, 3) < 0) {
                throw ValidationException::withMessages([
                    'quantity' => 'Недостаточно товара в выбранной ячейке.',
                ]);
            }

            $now = now();

            DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $location->id)
                ->decrement('quantity', $quantity, [
                    'updated_at' => $now,
                ]);

            return StockMovement::query()->create([
                'product_id' => $product->id,
                'from_location_id' => $location->id,
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
        string|int|float $quantity,
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
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            $quantity = $this->normalizeQuantity(
                $quantity,
                $product->unit,
            );

            $location = Location::query()
                ->whereKey($locationId)
                ->lockForUpdate()
                ->firstOrFail();

            $stock = DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $location->id)
                ->lockForUpdate()
                ->first();

            $currentQuantity = (string) ($stock->quantity ?? '0');

            $this->assertMaximumQuantity(
                bcadd($currentQuantity, $quantity, 3),
                'quantity',
            );

            $now = now();

            if ($stock === null) {
                DB::table('product_location')->insert([
                    'product_id' => $product->id,
                    'location_id' => $location->id,
                    'quantity' => $quantity,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            } else {
                DB::table('product_location')
                    ->where('product_id', $product->id)
                    ->where('location_id', $location->id)
                    ->increment('quantity', $quantity, [
                        'updated_at' => $now,
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
        string|int|float $actualQuantity,
        ?string $comment,
        ?int $userId,
    ): ?StockMovement {
        return DB::transaction(function () use (
            $productId,
            $locationId,
            $actualQuantity,
            $comment,
            $userId,
        ): ?StockMovement {
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            $actualQuantity = $this->normalizeQuantity(
                $actualQuantity,
                $product->unit,
                allowZero: true,
            );

            $location = Location::query()
                ->whereKey($locationId)
                ->lockForUpdate()
                ->firstOrFail();

            $stock = DB::table('product_location')
                ->where('product_id', $product->id)
                ->where('location_id', $location->id)
                ->lockForUpdate()
                ->first();

            $currentQuantity = (string) ($stock->quantity ?? '0');

            if (bccomp($currentQuantity, $actualQuantity, 3) === 0) {
                return null;
            }

            $difference = bccomp($actualQuantity, $currentQuantity, 3) < 0
                ? bcsub($currentQuantity, $actualQuantity, 3)
                : bcsub($actualQuantity, $currentQuantity, 3);

            $now = now();

            if ($stock === null) {
                DB::table('product_location')->insert([
                    'product_id' => $product->id,
                    'location_id' => $location->id,
                    'quantity' => $actualQuantity,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            } else {
                DB::table('product_location')
                    ->where('product_id', $product->id)
                    ->where('location_id', $location->id)
                    ->update([
                        'quantity' => $actualQuantity,
                        'updated_at' => $now,
                    ]);
            }

            $isShortage = bccomp($actualQuantity, $currentQuantity, 3) < 0;

            $movementComment = trim(
                ($comment ?? '')
                . ' Инвентаризация: было '
                . $this->formatQuantity($currentQuantity)
                . ', стало '
                . $this->formatQuantity($actualQuantity)
                . '. '
                . ($isShortage ? 'Недостача.' : 'Излишек.')
            );

            return StockMovement::query()->create([
                'product_id' => $product->id,
                'from_location_id' => $isShortage ? $location->id : null,
                'to_location_id' => $isShortage ? null : $location->id,
                'quantity' => $difference,
                'type' => StockMovementType::INVENTORY,
                'comment' => $movementComment,
                'user_id' => $userId,
            ]);
        }, attempts: 3);
    }

    private function normalizeQuantity(
        string|int|float $quantity,
        string $unit,
        bool $allowZero = false,
    ): string {
        $value = trim((string) $quantity);

        if (! preg_match('/^\d+(?:\.\d{1,3})?$/', $value)) {
            throw ValidationException::withMessages([
                $allowZero ? 'actual_quantity' : 'quantity' =>
                    'Введите корректное количество максимум с тремя знаками после запятой.',
            ]);
        }

        if (
            ! in_array($unit, self::INTEGER_UNITS, true)
            && ! in_array($unit, self::DECIMAL_UNITS, true)
        ) {
            throw ValidationException::withMessages([
                $allowZero ? 'actual_quantity' : 'quantity' =>
                    "Неподдерживаемая единица измерения: {$unit}.",
            ]);
        }

        if (
            in_array($unit, self::INTEGER_UNITS, true)
            && str_contains($value, '.')
        ) {
            throw ValidationException::withMessages([
                $allowZero ? 'actual_quantity' : 'quantity' =>
                    "Для единицы измерения «{$unit}» допускаются только целые количества.",
            ]);
        }

        if (
            bccomp($value, '0', 3) < 0
            || (! $allowZero && bccomp($value, '0', 3) === 0)
        ) {
            throw ValidationException::withMessages([
                $allowZero ? 'actual_quantity' : 'quantity' =>
                    $allowZero
                        ? 'Фактическое количество не может быть отрицательным.'
                        : 'Количество должно быть больше нуля.',
            ]);
        }

        $normalized = bcadd($value, '0', 3);

        $this->assertMaximumQuantity(
            $normalized,
            $allowZero ? 'actual_quantity' : 'quantity',
        );

        return $normalized;
    }

    private function assertMaximumQuantity(
        string $quantity,
        string $field,
    ): void {
        if (bccomp($quantity, self::MAX_QUANTITY, 3) > 0) {
            throw ValidationException::withMessages([
                $field => 'Количество превышает максимально допустимое значение 999999999.999.',
            ]);
        }
    }

    private function formatQuantity(string $quantity): string
    {
        return rtrim(rtrim($quantity, '0'), '.');
    }
}
