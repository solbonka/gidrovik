<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreCountryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'name' => [
                'required',
                'string',
                'max:255',
                'unique:countries,name',
            ],
            'code' => [
                'nullable',
                'string',
                'max:3',
                'unique:countries,code',
            ],
            'is_active' => [
                'boolean',
            ],
        ];
    }

    public function attributes(): array
    {
        return [
            'name' => 'название',
            'code' => 'код',
            'is_active' => 'активность',
        ];
    }
}
