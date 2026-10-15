<?php

namespace App\Http\Requests\Admin;

use App\Enums\UnitType;
use App\Models\Category;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        $product = $this->route('product');

        return [
            'category_id' => [
                'required',
                'integer',
                'exists:categories,id',
            ],

            'product_type_id' => [
                'nullable',
                'integer',
                'exists:product_types,id',
            ],

            'name' => [
                'required',
                'string',
                'max:255',
            ],

            'sku' => [
                'required',
                'string',
                'max:255',
                Rule::unique('products', 'sku')->ignore($product),
            ],

            'minimum_stock' => [
                'nullable',
                'numeric',
                'min:0',
            ],

            'angle' => [
                'nullable',
                'integer',
                Rule::in([45, 90]),
            ],

            'description' => [
                'nullable',
                'string',
            ],

            'is_active' => [
                'boolean',
            ],

            'characteristics' => [
                'nullable',
                'array',
            ],

            'characteristics.*' => [
                'nullable',
                'string',
                'max:5000',
            ],

            'connections' => [
                'nullable',
                'array',
                'max:3',
            ],

            'connections.*.position' => [
                'required',
                'integer',
                'between:1,3',
            ],

            'connections.*.standard_id' => [
                'nullable',
                'integer',
                'exists:standards,id',
            ],

            'connections.*.diameter_id' => [
                'nullable',
                'integer',
                'exists:diameters,id',
            ],

            'connections.*.thread_id' => [
                'nullable',
                'integer',
                'exists:threads,id',
            ],

            'unit' => [
                'nullable',
                'string',
                'max:20',
                'in:' . implode(',', UnitType::getAll()),
            ],

            'manufacturer_id' => [
                'nullable',
                'integer',
                'exists:manufacturers,id',
            ],

            'country_id' => [
                'nullable',
                'integer',
                'exists:countries,id',
            ],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator): void {
            $categoryId = $this->integer('category_id');

            if (!$categoryId) {
                return;
            }

            $category = Category::query()
                ->with('characteristics')
                ->find($categoryId);

            if (!$category) {
                return;
            }

            $allowedCharacteristicIds = $category
                ->characteristics
                ->pluck('id')
                ->map(fn ($id) => (string) $id)
                ->all();

            foreach (array_keys($this->input('characteristics', [])) as $characteristicId) {
                if (!in_array(
                    (string) $characteristicId,
                    $allowedCharacteristicIds,
                    true
                )) {
                    $validator->errors()->add(
                        "characteristics.{$characteristicId}",
                        'Эта характеристика недоступна для выбранной категории.'
                    );
                }
            }

            if ($this->filled('product_type_id')) {
                $productTypeBelongsToCategory = $category
                    ->productTypes()
                    ->whereKey($this->integer('product_type_id'))
                    ->exists();

                if (!$productTypeBelongsToCategory) {
                    $validator->errors()->add(
                        'product_type_id',
                        'Выбранный тип товара не относится к выбранной категории.'
                    );
                }
            }
        });
    }
}
