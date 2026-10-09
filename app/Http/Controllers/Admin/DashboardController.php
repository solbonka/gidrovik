<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Location;
use App\Models\Product;
use App\Models\Rack;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    public function __invoke(): Response
    {
        $productsCount = Product::query()
            ->where('is_active', true)
            ->count();

        $categoriesCount = Category::query()
            ->where('is_active', true)
            ->count();

        $racksCount = Rack::query()->count();

        $locationsCount = Location::query()->count();

        $stockQuantity = DB::table('product_location')
            ->sum('quantity');

        $productsWithStockCount = DB::table('product_location')
            ->where('quantity', '>', 0)
            ->distinct('product_id')
            ->count('product_id');

        return Inertia::render('admin/Dashboard', [
            'statistics' => [
                'products' => $productsCount,
                'categories' => $categoriesCount,
                'racks' => $racksCount,
                'locations' => $locationsCount,
                'stock_quantity' => (int) $stockQuantity,
                'products_with_stock' => $productsWithStockCount,
            ],
        ]);
    }
}
