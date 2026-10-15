<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\ProductController;
use App\Http\Controllers\Admin\ProductCreateController;
use App\Http\Controllers\Admin\ProductTypeController;
use App\Http\Controllers\Admin\CharacteristicController;
use App\Http\Controllers\Admin\StandardController;
use App\Http\Controllers\Admin\DiameterController;
use App\Http\Controllers\Admin\ThreadController;
use App\Http\Controllers\Admin\LocationController;
use App\Http\Controllers\Admin\RackController;
use App\Http\Controllers\Admin\StockReceiptController;
use App\Http\Controllers\Admin\StockTransferController;
use App\Http\Controllers\Admin\StockMovementController;
use App\Http\Controllers\Admin\StockWriteOffController;
use App\Http\Controllers\Admin\StockReturnController;
use App\Http\Controllers\Admin\StockInventoryController;
use App\Http\Controllers\Admin\StockBalanceController;

Route::inertia('/', 'Welcome')->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::inertia('dashboard', 'Dashboard')->name('dashboard');
});

require __DIR__.'/settings.php';

Route::middleware('auth')
    ->prefix('admin')
    ->name('admin.')
    ->group(function () {
        Route::get('/', DashboardController::class)
            ->name('dashboard');

        Route::resource('categories', CategoryController::class)
            ->except(['show']);

        Route::resource('product-types', ProductTypeController::class)
            ->except(['show']);

        Route::resource('characteristics', CharacteristicController::class)
            ->except(['show']);

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

        Route::resource('racks', RackController::class)
            ->except(['show']);

        Route::scopeBindings()->group(function () {
            Route::resource('racks.locations', LocationController::class)
                ->only([
                    'store',
                    'update',
                    'destroy',
                ]);
        });

        Route::get("/locations", [LocationController::class, "getLocationsWithProduct"])->name("admin.locations.with-product");

        Route::get('/locations/{location}/products', [
            RackController::class,
            'getLocationProducts',
        ])->name('locations.products');

        Route::get('/stock/receipt', [
            StockReceiptController::class,
            'create',
        ])->name('stock.receipt.create');

        Route::post('/stock/receipt', [
            StockReceiptController::class,
            'store',
        ])->name('stock.receipt.store');

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

        Route::get('/stock/movements', [
            StockMovementController::class,
            'index',
        ])->name('stock.movements.index');

        Route::get('/stock/return', [StockReturnController::class, 'create'])
            ->name('stock.return.create');

        Route::post('/stock/return', [StockReturnController::class, 'store'])
            ->name('stock.return.store');

        Route::get('/stock/inventory', [StockInventoryController::class, 'create'])
            ->name('stock.inventory.create');

        Route::get('/stock/inventory/current', [StockInventoryController::class, 'current'])
            ->name('stock.inventory.current');

        Route::post('/stock/inventory', [StockInventoryController::class, 'store'])
            ->name('stock.inventory.store');

        Route::get('/stock', [StockBalanceController::class, 'index'])
            ->name('stock.index');

        Route::get('/products', [
            ProductController::class,
            'index',
        ])->name('products.index');

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

        Route::put('/products/{product}', [
            ProductController::class,
            'update',
        ])->name('products.update');

        Route::delete('/products/{product}', [
            ProductController::class,
            'destroy',
        ])->name('products.destroy');

        Route::get('/products/categories/{category}/characteristics', [
            ProductCreateController::class,
            'characteristics',
        ])->name('products.categories.characteristics');

        Route::get('/products/{product}', [
            ProductController::class,
            'show',
        ])->name('products.show');
    });
