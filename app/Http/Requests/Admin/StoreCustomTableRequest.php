<?php

namespace App\Http\Requests\Admin;

use App\Models\CustomTable;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCustomTableRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        return [
            'name' => [
                'required',
                'string',
                'max:255',
            ],
            'slug' => [
                'required',
                'string',
                'max:100',
                'regex:/^[a-z0-9_]+$/',
                Rule::unique(CustomTable::class, 'slug'),
            ],
            'description' => [
                'nullable',
                'string',
                'max:2000',
            ],
            'columns' => [
                'required',
                'array',
                'min:1',
                'max:50',
            ],
            'columns.*.name' => [
                'required',
                'string',
                'max:100',
            ],
            'columns.*.key' => [
                'required',
                'string',
                'max:50',
                'regex:/^[a-z0-9_]+$/',
            ],
            'columns.*.type' => [
                'required',
                'string',
                'in:string,integer,decimal,boolean,date,text,json',
            ],
        ];
    }

    public function attributes(): array
    {
        return [
            'name' => 'название таблицы',
            'slug' => 'символьный код',
            'description' => 'описание',
            'columns' => 'колонки',
            'columns.*.name' => 'название колонки',
            'columns.*.key' => 'ключ колонки',
            'columns.*.type' => 'тип данных',
        ];
    }

    public function messages(): array
    {
        return [
            'slug.regex' => 'Символьный код может содержать только латинские буквы, цифры и подчёркивание.',
            'columns.*.key.regex' => 'Ключ колонки может содержать только латинские буквы, цифры и подчёркивание.',
            'columns.max' => 'Максимальное количество колонок — :max.',
            'columns.min' => 'Добавьте хотя бы одну колонку.',
        ];
    }
}