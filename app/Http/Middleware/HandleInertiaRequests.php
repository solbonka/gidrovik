<?php

namespace App\Http\Middleware;

use App\Enums\Permission;
use App\Enums\UserRole;
use Illuminate\Http\Request;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    /**
     * The root template that's loaded on the first page visit.
     *
     * @var string
     */
    protected $rootView = 'app';

    /**
     * Determine if the request should pass through Inertia middleware.
     */
    public function shouldProcessRequest(Request $request): bool
    {
        // Exclude only true API endpoints (not Inertia page requests)
        if ($request->is('favorites/api')) {
            return false;
        }

        // Exclude product characteristics API endpoint
        if ($request->is('admin/products/categories/*/characteristics')) {
            return false;
        }

        // Exclude locations API endpoint
        if ($request->is('admin/locations')) {
            return false;
        }

        // Exclude rack products API endpoint
        if ($request->is('admin/racks/*/products')) {
            return false;
        }

        // Exclude stock operation API endpoints
        if ($request->is('stock/operation*', 'stock/inventory/current', 'locations/*/products', 'products/*/locations')) {
            return false;
        }

        return parent::shouldProcessRequest($request);
    }

    /**
     * Determines the current asset version.
     */
    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    /**
     * Define the props that are shared by default.
     *
     * @return array<string, mixed>
     */
    public function share(Request $request): array
    {
        $user = $request->user();

        return [
            ...parent::share($request),

            'name' => config('app.name'),

            'auth' => [
                'user' => $user?->only(['id', 'name', 'email', 'role', 'is_employee']),
            ],

            'permissions' => $user
                ? array_map(
                    fn (Permission $permission): string => $permission->value,
                    $user->role->permissions(),
                )
                : [],

            'roles' => collect(UserRole::cases())
                ->mapWithKeys(fn (UserRole $role): array => [$role->value => $role->label()])
                ->all(),

            'sidebarOpen' => ! $request->hasCookie('sidebar_state')
                || $request->cookie('sidebar_state') === 'true',

            'flash' => [
                'success' => fn () => $request->session()->get('success'),
                'error' => fn () => $request->session()->get('error'),
                'toast' => fn () => $request->session()->get('toast'),
            ],
        ];
    }
}
