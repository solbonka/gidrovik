<?php

namespace App\Http\Requests\Admin;

use App\Rules\ValidStockQuantity;
use Illuminate\Foundation\Http\FormRequest;

class StoreStockTransferRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'product_id' => [
                'required',
                'integer',
                'exists:products,id',
            ],
            'from_location_id' => [
                'required',
                'integer',
                'exists:locations,id',
                'different:to_location_id',
            ],
            'to_location_id' => [
                'required',
                'integer',
                'exists:locations,id',
                'different:from_location_id',
            ],
            'quantity' => [
                'required',
                new ValidStockQuantity,
            ],
            'comment' => [
                'nullable',
                'string',
                'max:5000',
            ],
        ];
    }

    public function attributes(): array
    {
        return [
            'product_id' => 'товар',
            'from_location_id' => 'исходная ячейка',
            'to_location_id' => 'целевая ячейка',
            'quantity' => 'количество',
            'comment' => 'комментарий',
        ];
    }
}
