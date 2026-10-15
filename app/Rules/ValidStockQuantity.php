<?php

namespace App\Rules;

use App\Models\Product;
use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class ValidStockQuantity implements ValidationRule
{
    public function __construct(
        private readonly ?string $productField = null,
        private readonly bool $allowZero = false,
    ) {}

    public function validate(
        string $attribute,
        mixed $value,
        Closure $fail,
    ): void {
        if (! is_scalar($value) || ! preg_match('/^\d+(?:\.\d{1,3})?$/', (string) $value)) {
            $fail('Введите корректное количество максимум с тремя знаками после запятой.');

            return;
        }

        $quantity = (string) $value;

        if (bccomp($quantity, '0', 3) < 0) {
            $fail('Количество не может быть отрицательным.');

            return;
        }

        if (! $this->allowZero && bccomp($quantity, '0', 3) === 0) {
            $fail('Количество должно быть больше нуля.');

            return;
        }

        if (bccomp($quantity, '999999999.999', 3) > 0) {
            $fail('Количество превышает допустимое значение.');

            return;
        }

        // Автоматически определяем путь к product_id на основе атрибута
        $productField = $this->productField ?? str_replace('quantity', 'product_id', $attribute);
        $productId = request()->input($productField);

        if (! is_numeric($productId)) {
            $fail('Необходимо выбрать товар.');

            return;
        }

        $unit = Product::query()
            ->whereKey((int) $productId)
            ->value('unit');

        if (! $unit) {
            $fail('Выбранный товар не найден или у него не задана единица измерения.');

            return;
        }

        if (
            in_array($unit, ['шт.', 'упаковка', 'комплект'], true)
            && str_contains($quantity, '.')
        ) {
            $fail("Для единицы измерения «{$unit}» допускаются только целые количества.");

            return;
        }

        if (! in_array($unit, ['шт.', 'упаковка', 'комплект', 'м', 'л'], true)) {
            $fail("Единица измерения «{$unit}» не поддерживается.");
        }
    }
}
