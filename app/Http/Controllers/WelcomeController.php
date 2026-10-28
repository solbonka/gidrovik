<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\StockMovement;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class WelcomeController extends Controller
{
    public function __invoke(Request $request): Response
    {
        $activeProducts = Product::query()->where('is_active', true)->count();

        $totalQuantity = \App\Models\ProductLocation::query()
            ->sum('quantity');

        $lowStockCount = Product::query()
            ->where('is_active', true)
            ->whereNotNull('minimum_stock')
            ->whereRaw('COALESCE((
                SELECT SUM(pl.quantity)
                FROM product_location AS pl
                WHERE pl.product_id = products.id
            ), 0) < products.minimum_stock')
            ->count();

        $recentMovements = StockMovement::query()
            ->with([
                'product:id,name,code,article',
                'fromLocation.rack:id,code',
                'toLocation.rack:id,code',
            ])
            ->latest('created_at')
            ->latest('id')
            ->limit(8)
            ->get()
            ->map(fn (\App\Models\StockMovement $movement): array => [
                'id' => $movement->id,
                'product_name' => $movement->product->name,
                'code' => $movement->product->code,
                'article' => $movement->product->article,
                'type' => $movement->type->value,
                'type_label' => $movement->type->label(),
                'quantity' => $movement->quantity,
                'from_location' => $movement->fromLocation?->code,
                'to_location' => $movement->toLocation?->code,
                'created_at' => $movement->created_at?->format('d.m.Y H:i'),
            ]);

        $lowStockProducts = Product::query()
            ->with(['locations' => fn ($q) => $q->wherePivot('quantity', '>', 0)->with('rack:id,code')])
            ->where('is_active', true)
            ->whereNotNull('minimum_stock')
            ->whereRaw('COALESCE((
                SELECT SUM(pl.quantity)
                FROM product_location AS pl
                WHERE pl.product_id = products.id
            ), 0) < products.minimum_stock')
            ->limit(5)
            ->get()
            ->map(fn (\App\Models\Product $product): array => [
                'id' => $product->id,
                'name' => $product->name,
                'code' => $product->code,
                'article' => $product->article,
                'unit' => $product->unit,
                'quantity' => (string) $product->getTotalQuantity(),
                'minimum_stock' => $product->minimum_stock,
                'locations' => $product->locations->map(fn ($location) => [
                    'code' => $location->pivot->quantity > 0 ? $location->code : null,
                    'rack_code' => $location->rack?->code,
                ])->filter(),
            ]);

        return Inertia::render('Welcome', [
            'statistics' => [
                'products' => $activeProducts,
                'total_quantity' => (string) $totalQuantity,
                'low_stock' => $lowStockCount,
            ],
            'recent_movements' => $recentMovements,
            'low_stock_products' => $lowStockProducts,
        ]);
    }
}