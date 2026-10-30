<?php

use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\CharacteristicController;
use App\Http\Controllers\Admin\CharacteristicValueController;
use App\Http\Controllers\Admin\CountryController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DiameterController;
use App\Http\Controllers\Admin\LocationController;
use App\Http\Controllers\Admin\ManufacturerController;
use App\Http\Controllers\Admin\OrderController as AdminOrderController;
use App\Http\Controllers\Admin\ProductController;
use App\Http\Controllers\Admin\ProductCreateController;
use App\Http\Controllers\Admin\ProductImageController;
use App\Http\Controllers\Admin\ProductTypeController;
use App\Http\Controllers\Admin\RackController;
use App\Http\Controllers\Admin\StandardController;
use App\Http\Controllers\Admin\StockBalanceController;
use App\Http\Controllers\Admin\StockInventoryController;
use App\Http\Controllers\Admin\StockMovementController;
use App\Http\Controllers\Admin\StockOperationApiController;
use App\Http\Controllers\Admin\StockReceiptController;
use App\Http\Controllers\Admin\StockReturnController;
use App\Http\Controllers\Admin\StockTransferController;
use App\Http\Controllers\Admin\StockWriteOffController;
use App\Http\Controllers\Admin\ThreadController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\WarehouseController;
use App\Http\Controllers\Store\StoreHomeController;
use Illuminate\Support\Facades\Route;

Route::get('/', StoreHomeController::class)->name('store.home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('dashboard', fn () => redirect('/admin'))
        ->name('dashboard');
});

require __DIR__.'/store.php';
require __DIR__.'/seo.php';
require __DIR__.'/settings.php';

Route::middleware(['auth', 'verified', 'employee'])
    ->prefix('admin')
    ->name('admin.')
    ->group(function () {
        Route::middleware('permission:catalog.manage')->group(function () {
            Route::resource('categories', CategoryController::class)
                ->except(['show']);

            Route::resource('product-types', ProductTypeController::class)
                ->except(['show']);

            Route::resource('characteristics', CharacteristicController::class)
                ->except(['show']);

            // Characteristic values management
            Route::get('/characteristics/{characteristic}/values', [
                CharacteristicValueController::class,
                'index',
            ])->name('characteristics.values');

            Route::post('/characteristics/{characteristic}/values', [
                CharacteristicValueController::class,
                'store',
            ])->name('characteristics.values.store');

            Route::patch('/characteristics/{characteristic}/values/{value}', [
                CharacteristicValueController::class,
                'update',
            ])->name('characteristics.values.update');

            Route::delete('/characteristics/{characteristic}/values/{value}', [
                CharacteristicValueController::class,
                'destroy',
            ])->name('characteristics.values.destroy');

            Route::post('/characteristics/{characteristic}/values/reorder', [
                CharacteristicValueController::class,
                'reorder',
            ])->name('characteristics.values.reorder');

            Route::get('/categories/{category}/characteristics', [
                CategoryController::class,
                'characteristics',
            ])->name('categories.characteristics');

            Route::put('/categories/{category}/characteristics', [
                CategoryController::class,
                'updateCharacteristics',
            ])->name('categories.characteristics.update');

            Route::resource('standards', StandardController::class)
                ->except(['show']);

            Route::resource('diameters', DiameterController::class)
                ->except(['show']);

            Route::resource('threads', ThreadController::class)
                ->except(['show']);

            Route::resource('manufacturers', ManufacturerController::class)
                ->except(['show']);

            Route::resource('countries', CountryController::class)
                ->except(['show']);

            Route::resource('warehouses', WarehouseController::class)
                ->except(['show']);

            Route::resource('racks', RackController::class)
                ->except(['index', 'show']);

            Route::scopeBindings()->group(function () {
                Route::resource('racks.locations', LocationController::class)
                    ->only([
                        'store',
                        'update',
                        'destroy',
                    ]);
            });

            Route::get('/products/create', [
                ProductCreateController::class,
                'create',
            ])->name('products.create');

            Route::post('/products', [
                ProductController::class,
                'store',
            ])->name('products.store');

            Route::get('/products/{product}/edit', [
                ProductController::class,
                'edit',
            ])->name('products.edit');

            Route::put('/products/{product}/toggle-published', [
                ProductController::class,
                'togglePublished',
            ])->name('products.toggle-published');

            Route::delete('/products/{product}', [
                ProductController::class,
                'destroy',
            ])->name('products.destroy');

            Route::get('/products/categories/{category}/characteristics', [
                ProductCreateController::class,
                'characteristics',
            ])->name('products.categories.characteristics');

            // Product images
            Route::get('/products/{product}/images', [
                ProductImageController::class,
                'index',
            ])->name('products.images');

            Route::post('/products/{product}/images', [
                ProductImageController::class,
                'store',
            ])->name('products.images.store');

            Route::patch('/products/{product}/images/{imageId}', [
                ProductImageController::class,
                'update',
            ])->name('products.images.update');

            Route::post('/products/{product}/images/reorder', [
                ProductImageController::class,
                'reorder',
            ])->name('products.images.reorder');

            Route::delete('/products/{product}/images/{imageId}', [
                ProductImageController::class,
                'destroy',
            ])->name('products.images.destroy');
        });

        Route::middleware('permission:view')->group(function () {
            Route::get('/', DashboardController::class)
                ->name('dashboard');

            Route::get('/products', [
                ProductController::class,
                'index',
            ])->name('products.index');

            Route::get('/products/{product}', [
                ProductController::class,
                'show',
            ])->name('products.show');

            Route::get('/locations', [LocationController::class, 'getLocationsWithProduct'])->name('admin.locations.with-product');

            Route::get('/racks', [RackController::class, 'index'])
                ->name('racks.index');

            // Stock operation API endpoints (for Inertia router)
            Route::post('/stock/operation', [StockOperationApiController::class, 'execute'])->name('stock.operation.execute');
            Route::get('/locations/{location}/products', [StockOperationApiController::class, 'currentLocationProducts'])->name('locations.products.api');
            Route::get('/products/{product}/locations', [StockOperationApiController::class, 'productLocation'])->name('products.locations.api');

            // Inventory API endpoint
            Route::get('/stock/inventory/current', [StockInventoryController::class, 'current'])->name('stock.inventory.current.api');

            Route::get('/stock', [StockBalanceController::class, 'index'])
                ->name('stock.index');

            Route::get('/stock/movements', [
                StockMovementController::class,
                'index',
            ])->name('stock.movements.index');
        });

        Route::middleware('permission:stock.operate')->group(function () {
            Route::get('/stock/receipt', [
                StockReceiptController::class,
                'create',
            ])->name('stock.receipt.create');

            Route::post('/stock/receipt', [
                StockReceiptController::class,
                'store',
            ])->name('stock.receipt.store');

            Route::post('/stock/receipt/batch', [
                StockReceiptController::class,
                'storeBatch',
            ])->name('stock.receipt.batch');

            Route::get('/stock/transfer', [
                StockTransferController::class,
                'create',
            ])->name('stock.transfer.create');

            Route::post('/stock/transfer', [
                StockTransferController::class,
                'store',
            ])->name('stock.transfer.store');

            Route::get('/stock/write-off', [
                StockWriteOffController::class,
                'create',
            ])->name('stock.write-off.create');

            Route::post('/stock/write-off', [
                StockWriteOffController::class,
                'store',
            ])->name('stock.write-off.store');

            Route::get('/stock/return', [StockReturnController::class, 'create'])
                ->name('stock.return.create');

            Route::post('/stock/return', [
                StockReturnController::class,
                'store',
            ])->name('stock.return.store');

            Route::get('/stock/inventory', [StockInventoryController::class, 'create'])
                ->name('stock.inventory.create');

            Route::get('/stock/inventory/current', [StockInventoryController::class, 'current'])
                ->name('stock.inventory.current');

            Route::post('/stock/inventory', [
                StockInventoryController::class,
                'store',
            ])->name('stock.inventory.store');
        });

        Route::middleware('permission:stock.correct')->group(function () {
            Route::delete('/stock/movements/{movement}', [
                StockMovementController::class,
                'destroy',
            ])->name('stock.movements.destroy');
        });

        Route::middleware('permission:users.manage')->group(function () {
            Route::get('/users', [UserController::class, 'index'])
                ->name('users.index');

            Route::put('/users/{user}/role', [UserController::class, 'updateRole'])
                ->name('users.role.update');

            Route::put('/users/{user}/employee', [UserController::class, 'toggleEmployee'])
                ->name('users.employee.toggle');
        });

        // Orders
        Route::middleware('permission:orders.manage')->group(function () {
            Route::get('/orders', [AdminOrderController::class, 'index'])
                ->name('orders.index');

            Route::get('/orders/{order}', [AdminOrderController::class, 'show'])
                ->name('orders.show');

            Route::put('/orders/{order}/status', [AdminOrderController::class, 'updateStatus'])
                ->name('orders.status.update');

            Route::post('/orders/{order}/complete', [AdminOrderController::class, 'markAsCompleted'])
                ->name('orders.complete');

            Route::post('/orders/{order}/cancel', [AdminOrderController::class, 'markAsCancelled'])
                ->name('orders.cancel');
        });
    });
