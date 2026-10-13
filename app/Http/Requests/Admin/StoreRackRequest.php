<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreRackRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'code' => [
                'required',
                'string',
                'max:10',
                'regex:/^[A-Za-zА-Яа-я0-9_-]+$/u',
                Rule::unique('racks', 'code'),
            ],
            'name' => [
                'nullable',
                'string',
                'max:255',
            ],
        ];
    }

    public function attributes(): array
    {
        return [
            'code' => 'код стеллажа',
            'name' => 'название',
        ];
    }
}
