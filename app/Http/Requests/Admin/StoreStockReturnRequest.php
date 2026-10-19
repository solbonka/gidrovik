<?php

namespace App\Http\Requests\Admin;

use App\Rules\ValidStockQuantity;
use Illuminate\Foundation\Http\FormRequest;

class StoreStockReturnRequest extends FormRequest
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
            'location_id' => [
                'required',
                'integer',
                'exists:locations,id',
            ],
            'quantity' => [
                'required',
                new ValidStockQuantity,
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
            'quantity' => 'количество',
            'comment' => 'причина возврата',
        ];
    }
}
