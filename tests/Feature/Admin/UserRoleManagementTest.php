<?php

namespace Tests\Feature\Admin;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserRoleManagementTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->withoutVite();
    }

    public function test_admin_can_open_the_users_page(): void
    {
        $admin = User::factory()->withRole(UserRole::ADMIN)->create();

        $response = $this->actingAs($admin)->get(route('admin.users.index'));

        $response->assertOk();
        $response->assertInertia(fn ($page) => $page
            ->component('admin/users/Index')
            ->where('totalUsers', 1)
            ->where('roleCounts.admin', 1)
            ->where('roles.0.value', 'admin')
            ->where('roles.0.label', 'Администратор')
        );
    }

    public function test_non_admin_users_cannot_open_the_users_page(): void
    {
        $user = User::factory()->withRole(UserRole::MANAGER)->create();

        $this->actingAs($user)
            ->get(route('admin.users.index'))
            ->assertRedirect(route('admin.dashboard'));
    }

    public function test_admin_can_change_the_role_of_a_user(): void
    {
        $admin = User::factory()->withRole(UserRole::ADMIN)->create();
        $user = User::factory()->withRole(UserRole::VIEWER)->create();

        $response = $this->actingAs($admin)->put(
            route('admin.users.role.update', ['user' => $user]),
            ['role' => UserRole::WAREHOUSE->value],
        );

        $response->assertRedirect();
        $response->assertSessionHas('success');

        $this->assertSame(UserRole::WAREHOUSE, $user->fresh()->role);
    }

    public function test_role_change_rejects_unknown_values(): void
    {
        $admin = User::factory()->withRole(UserRole::ADMIN)->create();
        $user = User::factory()->withRole(UserRole::VIEWER)->create();

        $this->actingAs($admin)->put(
            route('admin.users.role.update', ['user' => $user]),
            ['role' => 'superuser'],
        )->assertSessionHasErrors('role');

        $this->assertSame(UserRole::VIEWER, $user->fresh()->role);
    }

    public function test_admin_cannot_change_their_own_role(): void
    {
        $admin = User::factory()->withRole(UserRole::ADMIN)->create();

        $this->actingAs($admin)->put(
            route('admin.users.role.update', ['user' => $admin]),
            ['role' => UserRole::VIEWER->value],
        )->assertSessionHas('error');

        $this->assertSame(UserRole::ADMIN, $admin->fresh()->role);
    }

    public function test_admin_can_change_the_role_of_another_administrator(): void
    {
        $admin = User::factory()->withRole(UserRole::ADMIN)->create();
        $user = User::factory()->withRole(UserRole::ADMIN)->create();

        $this->actingAs($admin)->put(
            route('admin.users.role.update', ['user' => $user]),
            ['role' => UserRole::VIEWER->value],
        )->assertSessionHas('success');

        $this->assertSame(UserRole::VIEWER, $user->fresh()->role);
    }

    public function test_users_page_can_be_searched(): void
    {
        $admin = User::factory()->withRole(UserRole::ADMIN)->create(['name' => 'Иван Иванов']);
        User::factory()->withRole(UserRole::VIEWER)->create(['name' => 'Пётр Петров']);

        $response = $this->actingAs($admin)->get(
            route('admin.users.index', ['search' => 'иван']),
        );

        $response->assertOk();
        $response->assertInertia(fn ($page) => $page
            ->where('filters.search', 'иван')
            ->has('users.data', 1)
            ->where('users.data.0.id', $admin->id)
        );
    }
}
