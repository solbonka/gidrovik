<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreThreadRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'system' => strtolower(trim((string) $this->input('system'))),
            'designation' => trim((string) $this->input('designation')),
            'name' => trim((string) $this->input('name')),
            'is_active' => $this->boolean('is_active'),
        ]);
    }

    public function rules(): array
    {
        return [
            'system' => [
                'required',
                'string',
                'max:20',
                'alpha_dash',
            ],
            'designation' => [
                'required',
                'string',
                'max:100',
            ],
            'name' => [
                'required',
                'string',
                'max:255',
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
            'system' => 'система',
            'designation' => 'обозначение',
            'name' => 'название',
            'is_active' => 'активность',
        ];
    }
}
