<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class CorrectProductSegmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'length_mm' => ['required', 'numeric', 'gt:0', 'max:999999999.999'],
            'comment' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
