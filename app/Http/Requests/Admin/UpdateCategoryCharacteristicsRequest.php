<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class UpdateCategoryCharacteristicsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'characteristics' => [
                'array',
            ],

            'characteristics.*.id' => [
                'required',
                'integer',
                'distinct',
                'exists:characteristics,id',
            ],

            'characteristics.*.is_required' => [
                'required',
                'boolean',
            ],

            'characteristics.*.sort_order' => [
                'required',
                'integer',
                'min:0',
            ],
        ];
    }

    protected function prepareForValidation(): void
    {
        $characteristics = collect(
            $this->input('characteristics', [])
        )->map(function (array $characteristic): array {
            return [
                'id' => $characteristic['id'] ?? null,
                'is_required' => filter_var(
                    $characteristic['is_required'] ?? false,
                    FILTER_VALIDATE_BOOLEAN,
                ),
                'sort_order' => (int) ($characteristic['sort_order'] ?? 0),
            ];
        })->values()->all();

        $this->merge([
            'characteristics' => $characteristics,
        ]);
    }
}
