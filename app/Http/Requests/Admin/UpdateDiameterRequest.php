<?php

namespace App\Http\Requests\Admin;

use App\Models\Diameter;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateDiameterRequest extends FormRequest
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
        /** @var Diameter|null $diameter */
        $diameter = $this->route('diameter');

        return [
            'value' => [
                'required',
                'integer',
                'min:1',
                'max:1000',
                Rule::unique('diameters', 'value')
                    ->where(fn ($query) => $query->where(
                        'unit',
                        $this->input('unit', 'mm'),
                    ))
                    ->ignore($diameter?->id),
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
