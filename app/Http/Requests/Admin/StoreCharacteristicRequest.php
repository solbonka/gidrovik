<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCharacteristicRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'is_active' => $this->boolean('is_active'),
        ]);
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'slug' => [
                'required',
                'string',
                'max:255',
                'alpha_dash',
                Rule::unique('characteristics', 'slug'),
            ],
            'type' => [
                'required',
                'string',
                Rule::in([
                    'text',
                    'number',
                    'select',
                    'boolean',
                ]),
            ],
            'unit' => ['nullable', 'string', 'max:50'],
            'is_active' => ['required', 'boolean'],
        ];
    }

    public function attributes(): array
    {
        return [
            'name' => 'название',
            'slug' => 'slug',
            'type' => 'тип',
            'unit' => 'единица измерения',
            'is_active' => 'активность',
        ];
    }
}
