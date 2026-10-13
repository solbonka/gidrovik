<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreDiameterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'unit' => $this->input('unit', 'mm'),
            'is_active' => $this->boolean('is_active'),
        ]);
    }

    public function rules(): array
    {
        return [
            'value' => [
                'required',
                'integer',
                'min:1',
                'max:1000',
            ],
            'unit' => [
                'required',
                'string',
                'max:10',
            ],
            'is_active' => [
                'required',
                'boolean',
            ],
        ];
    }

    public function attributes(): array
    {
        return [
            'value' => 'диаметр',
            'unit' => 'единица измерения',
            'is_active' => 'активность',
        ];
    }
}
