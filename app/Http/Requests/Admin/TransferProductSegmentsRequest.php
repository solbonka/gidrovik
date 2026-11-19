<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class TransferProductSegmentsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'segment_ids' => ['required', 'array', 'min:1', 'max:500'],
            'segment_ids.*' => ['integer', 'exists:product_segments,id'],
            'to_location_id' => [
                'required',
                'integer',
                'exists:locations,id',
            ],
            'comment' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
