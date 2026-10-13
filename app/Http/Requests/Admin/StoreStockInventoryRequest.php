<?php

namespace App\Http\Requests\Admin;

use App\Rules\ValidStockQuantity;
use Illuminate\Foundation\Http\FormRequest;

class StoreStockInventoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'product_id' => [
                'required',
                'integer',
                'exists:products,id',
            ],
            'location_id' => [
                'required',
                'integer',
                'exists:locations,id',
            ],
            'actual_quantity' => [
                'required',
                new ValidStockQuantity(allowZero: true),
            ],
            'comment' => [
                'required',
                'string',
                'max:5000',
            ],
        ];
    }

    public function attributes(): array
    {
        return [
            'product_id' => 'товар',
            'location_id' => 'ячейка',
            'actual_quantity' => 'фактическое количество',
            'comment' => 'комментарий',
        ];
    }
}
