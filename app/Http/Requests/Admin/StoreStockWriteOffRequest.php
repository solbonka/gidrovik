<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreStockWriteOffRequest extends FormRequest
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
            'quantity' => [
                'required',
                'integer',
                'min:1',
                'max:2147483647',
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
            'location_id' => 'ячейка хранения',
            'quantity' => 'количество',
            'comment' => 'причина списания',
        ];
    }
}
