<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreLocationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $rack = $this->route('rack');

        return [
            'number' => [
                'required',
                'integer',
                'min:1',
                'max:999999',
                Rule::unique('locations', 'number')
                    ->where(
                        fn ($query) => $query->where(
                            'rack_id',
                            $rack->id,
                        ),
                    ),
            ],
        ];
    }

    public function attributes(): array
    {
        return [
            'number' => 'номер ячейки',
        ];
    }
}
