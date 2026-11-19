<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class WriteOffProductSegmentsRequest extends FormRequest
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
            'segment_ids' => ['required', 'array', 'min:1'],
            'segment_ids.*' => ['integer', 'distinct', 'min:1'],
            'comment' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
