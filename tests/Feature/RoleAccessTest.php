<?php

namespace Tests\Feature;

use App\Enums\StockMovementType;
use App\Enums\UserRole;
use App\Models\Category;
use App\Models\Product;
use App\Models\StockMovement;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class RoleAccessTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->withoutVite();
    }

    /**
     * @return array<string, array{0: UserRole, 1: string, 2: bool}>
     */
    public static function accessMatrix(): array
    {
        return [
            'администратор открывает дашборд' => [UserRole::ADMIN, 'admin.dashboard', true],
            'администратор открывает справочники' => [UserRole::ADMIN, 'admin.countries.index', true],
            'администратор открывает приход' => [UserRole::ADMIN, 'admin.stock.receipt.create', true],
            'администратор открывает пользователей' => [UserRole::ADMIN, 'admin.users.index', true],

            'менеджер открывает дашборд' => [UserRole::MANAGER, 'admin.dashboard', true],
            'менеджер открывает справочники' => [UserRole::MANAGER, 'admin.countries.index', true],
            'менеджер открывает приход' => [UserRole::MANAGER, 'admin.stock.receipt.create', true],
            'менеджер не открывает пользователей' => [UserRole::MANAGER, 'admin.users.index', false],

            'кладовщик открывает дашборд' => [UserRole::WAREHOUSE, 'admin.dashboard', true],
            'кладовщик открывает остатки' => [UserRole::WAREHOUSE, 'admin.stock.index', true],
            'кладовщик открывает приход' => [UserRole::WAREHOUSE, 'admin.stock.receipt.create', true],
            'кладовщик открывает инвентаризацию' => [UserRole::WAREHOUSE, 'admin.stock.inventory.create', true],
            'кладовщик открывает стеллажи' => [UserRole::WAREHOUSE, 'admin.racks.index', true],
            'кладовщик не открывает справочники' => [UserRole::WAREHOUSE, 'admin.countries.index', false],
            'кладовщик не открывает создание товара' => [UserRole::WAREHOUSE, 'admin.products.create', false],
            'кладовщик не открывает пользователей' => [UserRole::WAREHOUSE, 'admin.users.index', false],

            'наблюдатель открывает дашборд' => [UserRole::VIEWER, 'admin.dashboard', true],
            'наблюдатель открывает остатки' => [UserRole::VIEWER, 'admin.stock.index', true],
            'наблюдатель открывает список товаров' => [UserRole::VIEWER, 'admin.products.index', true],
            'наблюдатель открывает историю движений' => [UserRole::VIEWER, 'admin.stock.movements.index', true],
            'наблюдатель открывает стеллажи' => [UserRole::VIEWER, 'admin.racks.index', true],
            'наблюдатель не открывает приход' => [UserRole::VIEWER, 'admin.stock.receipt.create', false],
            'наблюдатель не открывает справочники' => [UserRole::VIEWER, 'admin.countries.index', false],
            'наблюдатель не открывает пользователей' => [UserRole::VIEWER, 'admin.users.index', false],
        ];
    }

    #[DataProvider('accessMatrix')]
    public function test_access_depends_on_the_role(
        UserRole $role,
        string $routeName,
        bool $allowed,
    ): void {
        $user = User::factory()->withRole($role)->create();

        $response = $this->actingAs($user)->get(route($routeName));

        if ($allowed) {
            $response->assertOk();
        } else {
            $response->assertRedirect(route('admin.dashboard'));
            $response->assertSessionHas('error');
        }
    }

    public function test_guests_are_redirected_to_the_login_page(): void
    {
        $this->get(route('admin.users.index'))->assertRedirect(route('login'));
    }

    public function test_unverified_users_cannot_access_admin(): void
    {
        $user = User::factory()->unverified()->withRole(UserRole::ADMIN)->create();

        $this->actingAs($user)
            ->get(route('admin.dashboard'))
            ->assertRedirect(route('verification.notice'));
    }

    public function test_warehouse_worker_cannot_delete_stock_movements(): void
    {
        $user = User::factory()->withRole(UserRole::WAREHOUSE)->create();
        $movement = $this->createStockMovement();

        $this->actingAs($user)
            ->delete(route('admin.stock.movements.destroy', ['movement' => $movement]))
            ->assertRedirect(route('admin.dashboard'));

        $this->assertDatabaseHas('stock_movements', ['id' => $movement->id]);
    }

    public function test_manager_can_delete_stock_movements(): void
    {
        $user = User::factory()->withRole(UserRole::MANAGER)->create();
        $movement = $this->createStockMovement();

        $this->actingAs($user)
            ->delete(route('admin.stock.movements.destroy', ['movement' => $movement]))
            ->assertRedirect(route('admin.stock.movements.index'));

        $this->assertDatabaseMissing('stock_movements', ['id' => $movement->id]);
    }

    public function test_permissions_are_shared_with_the_frontend(): void
    {
        $user = User::factory()->withRole(UserRole::WAREHOUSE)->create();

        $response = $this->actingAs($user)->get(route('admin.dashboard'));

        $response->assertOk();
        $response->assertInertia(fn ($page) => $page
            ->where('permissions', ['view', 'stock.operate'])
            ->where('auth.user.role', 'warehouse')
        );
    }

    private function createStockMovement(): StockMovement
    {
        $category = Category::query()->create([
            'name' => 'Фитинги',
            'slug' => 'fitingsi',
        ]);

        $product = Product::query()->create([
            'category_id' => $category->id,
            'name' => 'Муфта',
            'sku' => 'SKU-'.uniqid(),
        ]);

        return StockMovement::query()->create([
            'product_id' => $product->id,
            'quantity' => 1,
            'type' => StockMovementType::RECEIPT,
        ]);
    }
}
