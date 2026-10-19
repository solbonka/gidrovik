<?php

namespace App\Http\Requests\Admin;

use App\Rules\ValidStockQuantity;
use Illuminate\Foundation\Http\FormRequest;

class StoreStockReceiptBatchRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'integer', 'exists:products,id'],
            'items.*.location_id' => ['required', 'integer', 'exists:locations,id'],
            'items.*.quantity' => ['required', new ValidStockQuantity],
            'items.*.comment' => ['nullable', 'string', 'max:5000'],
        ];
    }

    public function messages(): array
    {
        return [
            'items.required' => 'Список товаров обязателен',
            'items.min' => 'Добавьте хотя бы один товар',
            'items.*.product_id.required' => 'Выберите товар',
            'items.*.product_id.exists' => 'Товар не найден',
            'items.*.location_id.required' => 'Выберите ячейку',
            'items.*.location_id.exists' => 'Ячейка не найдена',
            'items.*.quantity.required' => 'Укажите количество',
            'items.*.comment.max' => 'Комментарий не должен превышать 5000 символов',
        ];
    }
}
