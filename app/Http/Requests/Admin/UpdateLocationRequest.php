<?php

namespace App\Http\Requests\Admin;

use App\Models\Location;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

class UpdateLocationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        $rack = $this->route('rack');
        $location = $this->route('location');

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
                    )
                    ->ignore($location->id),
            ],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator): void {
            /** @var Location $location */
            $location = $this->route('location');

            if ($location === null) {
                return;
            }

            $newNumber = (int) $this->input('number');

            if ($newNumber === $location->number) {
                return;
            }

            $hasStock = $location->products()
                ->wherePivot('quantity', '>', 0)
                ->exists();

            if ($hasStock) {
                $validator->errors()->add(
                    'number',
                    'Номер ячейки нельзя изменить: в ячейке есть остаток.',
                );

                return;
            }

            $hasMovements = $location->incomingMovements()->exists()
                || $location->outgoingMovements()->exists();

            if ($hasMovements) {
                $validator->errors()->add(
                    'number',
                    'Номер ячейки нельзя изменить: по ячейке есть история складских движений.',
                );
            }
        });
    }

    public function attributes(): array
    {
        return [
            'number' => 'номер ячейки',
        ];
    }
}
