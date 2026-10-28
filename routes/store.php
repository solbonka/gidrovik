<?php

use App\Http\Controllers\Store\CartController;
use App\Http\Controllers\Store\CatalogController;
use App\Http\Controllers\Store\CheckoutController;
use App\Http\Controllers\Store\FavoriteController;
use App\Http\Controllers\Store\OrderController;
use App\Http\Controllers\Store\ProductController as StoreProductController;
use App\Http\Controllers\Store\SearchController;
use App\Http\Controllers\Store\StaticPageController;
use App\Http\Controllers\Store\StoreHomeController;
use Illuminate\Support\Facades\Route;

/* |--------------------------------------------------------------------------
| Store (Public) Routes
|-------------------------------------------------------------------------- */

Route::get('/', StoreHomeController::class)->name('store.home');

// Catalog
Route::get('/catalog', [CatalogController::class, 'index'])->name('store.catalog.index');

// Product
Route::get('/products/{product:slug}', StoreProductController::class)->name('store.products.show');

// Search
Route::get('/search', SearchController::class)->name('store.search.index');

// Favorites (auth only)
Route::middleware('auth')->group(function () {
    Route::get('/favorites', [FavoriteController::class, 'index'])->name('store.favorites.index');
    Route::get('/favorites/api', [FavoriteController::class, 'getFavorites'])->name('store.favorites.api');
    Route::post('/favorites', [FavoriteController::class, 'store'])->name('store.favorites.store');
    Route::delete('/favorites', [FavoriteController::class, 'destroy'])->name('store.favorites.destroy');
    Route::post('/favorites/toggle', [FavoriteController::class, 'toggle'])->name('store.favorites.toggle');
});

// Cart (public + auth)
Route::get('/cart', [CartController::class, 'index'])->name('store.cart.index');
Route::post('/cart/items', [CartController::class, 'store'])->name('store.cart.store');
Route::patch('/cart/items/{itemId}', [CartController::class, 'update'])->name('store.cart.update');
Route::delete('/cart/items/{itemId}', [CartController::class, 'destroy'])->name('store.cart.destroy');

// Checkout (public)
Route::get('/checkout', [CheckoutController::class, 'create'])->name('store.checkout.create');
Route::post('/checkout', [CheckoutController::class, 'store'])
    ->middleware('throttle:3,1') // 3 orders per minute
    ->name('store.checkout.store');

// Orders (auth only)
Route::middleware('auth')->group(function () {
    Route::get('/orders', [OrderController::class, 'index'])->name('store.orders.index');
    Route::get('/orders/{order:number}', [OrderController::class, 'show'])->name('store.orders.show');
});

// Static pages
Route::get('/delivery', [StaticPageController::class, 'delivery'])->name('store.pages.delivery');
Route::get('/payment', [StaticPageController::class, 'payment'])->name('store.pages.payment');
Route::get('/returns', [StaticPageController::class, 'returns'])->name('store.pages.returns');
Route::get('/privacy', [StaticPageController::class, 'privacy'])->name('store.pages.privacy');
