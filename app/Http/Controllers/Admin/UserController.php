<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\UpdateUserRoleRequest;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Inertia\Inertia;
use Inertia\Response;

class UserController extends Controller
{
    private const PER_PAGE = 20;

    public function index(Request $request): Response
    {
        $search = mb_strtolower(trim((string) $request->string('search')));

        $matched = User::query()
            ->orderBy('name')
            ->get()
            ->when(
                $search !== '',
                fn ($users) => $users->filter(
                    fn (User $user): bool => str_contains(
                        mb_strtolower($user->name.' '.$user->email),
                        $search,
                    ),
                ),
            )
            ->values();

        $page = max(1, (int) $request->integer('page', 1));

        $users = new LengthAwarePaginator(
            $matched->forPage($page, self::PER_PAGE)->values(),
            $matched->count(),
            self::PER_PAGE,
            $page,
            [
                'path' => route('admin.users.index'),
                'query' => $request->query(),
            ],
        );

        return Inertia::render('admin/users/Index', [
            'users' => $users->through(fn (User $user): array => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role->value,
                'is_employee' => $user->is_employee,
                'email_verified_at' => $user->email_verified_at?->toISOString(),
                'created_at' => $user->created_at->toISOString(),
            ]),
            'filters' => [
                'search' => $search,
            ],
            'totalUsers' => User::query()->count(),
            'roleCounts' => User::query()
                ->selectRaw('role, count(*) as total')
                ->groupBy('role')
                ->pluck('total', 'role')
                ->map(fn (mixed $total): int => (int) $total),
            'roles' => collect(UserRole::cases())
                ->map(fn (UserRole $role): array => [
                    'value' => $role->value,
                    'label' => $role->label(),
                    'description' => $role->description(),
                ])
                ->values(),
        ]);
    }

    public function updateRole(UpdateUserRoleRequest $request, User $user): RedirectResponse
    {
        $role = $request->enum('role', UserRole::class);

        if ($user->is($request->user())) {
            return back()->with('error', 'Нельзя изменить собственную роль.');
        }

        $user->update(['role' => $role]);

        return back()->with(
            'success',
            "Роль пользователя «{$user->name}» изменена на «{$role->label()}».",
        );
    }

    public function toggleEmployee(Request $request, User $user): RedirectResponse
    {
        if ($user->is($request->user())) {
            return back()->with('error', 'Нельзя изменить собственный статус сотрудника.');
        }

        $user->update(['is_employee' => ! $user->is_employee]);

        return back()->with('success', $user->is_employee
            ? "Пользователь «{$user->name}» добавлен в сотрудники."
            : "Пользователь «{$user->name}» удалён из сотрудников."
        );
    }

    /** Alias for Wayfinder compatibility */
    public function toggle(Request $request, User $user): RedirectResponse
    {
        return $this->toggleEmployee($request, $user);
    }
}
