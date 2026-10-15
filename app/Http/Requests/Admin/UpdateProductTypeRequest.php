<?php

namespace App\Http\Requests\Admin;

use App\Models\Category;
use App\Models\ProductType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProductTypeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->check();
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'is_active' => $this->boolean('is_active'),
        ]);
    }

    public function rules(): array
    {
        /** @var ProductType $productType */
        $productType = $this->route('product_type');

        return [
            'category_id' => [
                'required',
                'integer',
                Rule::exists(Category::class, 'id')
                    ->where('is_active', true),
            ],
            'name' => ['required', 'string', 'max:255'],
            'slug' => [
                'required',
                'string',
                'max:255',
                'alpha_dash',
                Rule::unique('product_types', 'slug')
                    ->where(
                        fn ($query) => $query->where(
                            'category_id',
                            $this->integer('category_id'),
                        ),
                    )
                    ->ignore($productType?->id),
            ],
            'is_active' => ['required', 'boolean'],
        ];
    }

    public function attributes(): array
    {
        return [
            'category_id' => 'категория',
            'name' => 'название',
            'slug' => 'slug',
            'is_active' => 'активность',
        ];
    }
}
