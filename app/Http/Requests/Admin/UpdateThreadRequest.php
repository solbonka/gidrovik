<?php

namespace App\Http\Requests\Admin;

use App\Models\Thread;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateThreadRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'system' => strtolower(trim((string) $this->input('system'))),
            'designation' => trim((string) $this->input('designation')),
            'name' => trim((string) $this->input('name')),
            'is_active' => $this->boolean('is_active'),
        ]);
    }

    public function rules(): array
    {
        /** @var Thread|null $thread */
        $thread = $this->route('thread');

        return [
            'system' => [
                'required',
                'string',
                'max:20',
                'alpha_dash',
            ],
            'designation' => [
                'required',
                'string',
                'max:100',
                Rule::unique('threads', 'designation')
                    ->where(fn ($query) => $query->where(
                        'system',
                        $this->input('system'),
                    ))
                    ->ignore($thread?->id),
            ],
            'name' => [
                'required',
                'string',
                'max:255',
            ],
            'is_active' => [
                'required',
                'boolean',
            ],
        ];
    }

    public function attributes(): array
    {
        return [
            'system' => 'система',
            'designation' => 'обозначение',
            'name' => 'название',
            'is_active' => 'активность',
        ];
    }
}
