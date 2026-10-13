<?php

namespace App\Http\Requests\Admin;

use App\Models\Rack;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

class UpdateRackRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        /** @var Rack $rack */
        $rack = $this->route('rack');

        return [
            'code' => [
                'required',
                'string',
                'max:10',
                'regex:/^[A-Za-zА-Яа-я0-9_-]+$/u',
                Rule::unique('racks', 'code')->ignore($rack),
            ],
            'name' => [
                'nullable',
                'string',
                'max:255',
            ],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator): void {
            /** @var Rack $rack */
            $rack = $this->route('rack');

            if ($rack === null) {
                return;
            }

            $newCode = strtoupper(trim((string) $this->input('code')));

            if (
                $newCode !== strtoupper($rack->code)
                && $rack->locations()
                    ->where(function ($query) {
                        $query
                            ->whereHas(
                                'incomingMovements'
                            )
                            ->orWhereHas(
                                'outgoingMovements'
                            )
                            ->orWhereHas(
                                'products',
                                fn ($productQuery) => $productQuery->where(
                                    'product_location.quantity',
                                    '>',
                                    0,
                                ),
                            );
                    })
                    ->exists()
            ) {
                $validator->errors()->add(
                    'code',
                    'Код стеллажа нельзя изменить: по его ячейкам уже есть остатки или история складских движений.',
                );
            }
        });
    }

    public function attributes(): array
    {
        return [
            'code' => 'код стеллажа',
            'name' => 'название',
        ];
    }
}
