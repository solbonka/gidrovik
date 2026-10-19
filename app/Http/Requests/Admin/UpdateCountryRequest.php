<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateCountryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        $country = $this->route('country');

        return [
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('countries', 'name')->ignore($country),
            ],
            'code' => [
                'nullable',
                'string',
                'max:3',
                Rule::unique('countries', 'code')->ignore($country),
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
