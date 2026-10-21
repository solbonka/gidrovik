<?php

namespace App\Http\Requests\Admin;

use App\Enums\Permission;
use App\Enums\UserRole;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateUserRoleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->hasPermission(Permission::USERS_MANAGE) ?? false;
    }

    public function rules(): array
    {
        return [
            'role' => [
                'required',
                Rule::enum(UserRole::class),
            ],
        ];
    }

    public function attributes(): array
    {
        return [
            'role' => 'роль',
        ];
    }
}
