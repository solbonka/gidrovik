<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreProductSegmentsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'segments' => ['required', 'array', 'min:1', 'max:100'],
            'segments.*.location_id' => [
                'required',
                'integer',
                'exists:locations,id',
            ],
            'segments.*.length_mm' => [
                'required',
                'numeric',
                'gt:0',
                'max:999999999.999',
            ],
            'comment' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
