<?php

namespace App\Http\Middleware;

use App\Enums\Permission;
use App\Enums\UserRole;
use App\Models\Cart;
use Illuminate\Http\Request;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    protected $rootView = 'app';

    public function shouldProcessRequest(Request $request): bool
    {
        if ($request->is('login', 'logout', 'register', 'verify-email*', 'forgot-password*', 'reset-password*')) {
            return false;
        }

        if ($request->is('favorites/api')) {
            return false;
        }

        if ($request->is('admin/products/categories/*/characteristics')) {
            return false;
        }

        if ($request->is('admin/locations')) {
            return false;
        }

        if ($request->is('admin/racks/*/products')) {
            return false;
        }

        if ($request->is('stock/operation*', 'stock/inventory/current', 'locations/*/products', 'products/*/locations')) {
            return false;
        }

        return parent::shouldProcessRequest($request);
    }

    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    public function share(Request $request): array
    {
        $user = $request->user();

        $cartCount = 0;
        if ($user) {
            $cart = Cart::where('user_id', $user->id)->first();
            $cartCount = $cart?->items()->count() ?? 0;
        } else {
            $sessionId = $request->session()->get('cart_session_id');
            if ($sessionId) {
                $cart = Cart::where('session_id', $sessionId)->first();
                $cartCount = $cart?->items()->count() ?? 0;
            }
        }

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

            'cartCount' => $cartCount,
        ];
    }
}
