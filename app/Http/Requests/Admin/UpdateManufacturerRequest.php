<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateManufacturerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        $manufacturer = $this->route('manufacturer');

        return [
            'name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('manufacturers', 'name')->ignore($manufacturer),
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
            'is_active' => 'активность',
        ];
    }
}
