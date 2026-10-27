<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Location;
use App\Models\Order;
use App\Models\Product;
use App\Models\Rack;
use App\Models\StockMovement;
use App\Models\Warehouse;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    public function __invoke(): Response
    {
        $statistics = [
            'products' => Product::query()
                ->where('is_active', true)
                ->count(),

            'categories' => Category::query()
                ->where('is_active', true)
                ->count(),

            'warehouses' => Warehouse::query()->count(),

            'racks' => Rack::query()->count(),

            'locations' => Location::query()->count(),

            'products_with_stock' => DB::table('product_location')
                ->where('quantity', '>', 0)
                ->distinct()
                ->count('product_id'),

            'products_below_minimum' => Product::query()
                ->where('is_active', true)
                ->whereNotNull('minimum_stock')
                ->whereRaw(
                    'COALESCE(
                        (
                            SELECT SUM(pl.quantity)
                            FROM product_location AS pl
                            WHERE pl.product_id = products.id
                        ),
                        0
                    ) < products.minimum_stock'
                )
                ->count(),

            // Order statistics
            'total_orders' => Order::query()->count(),
            'new_orders' => Order::query()
                ->where('status', 'new')
                ->count(),
            'orders_today' => Order::query()
                ->whereDate('created_at', today())
                ->count(),
            'revenue_today' => Order::query()
                ->whereDate('created_at', today())
                ->sum('total_amount'),
        ];

        $stockByUnit = DB::table('product_location')
            ->join(
                'products',
                'products.id',
                '=',
                'product_location.product_id',
            )
            ->select('products.unit')
            ->selectRaw('SUM(product_location.quantity) AS quantity')
            ->groupBy('products.unit')
            ->orderBy('products.unit')
            ->get()
            ->map(fn (object $row): array => [
                'unit' => $row->unit,
                'quantity' => bcadd(
                    (string) $row->quantity,
                    '0',
                    3,
                ),
            ])
            ->values();

        $movements = StockMovement::query()
            ->with([
                'product:id,name,sku',
                'fromLocation.rack:id,code',
                'toLocation.rack:id,code',
            ])
            ->latest('created_at')
            ->latest('id')
            ->limit(8)
            ->get()
            ->map(fn (StockMovement $movement): array => [
                'id' => $movement->id,
                'product_name' => $movement->product->name,
                'sku' => $movement->product->sku,
                'type' => $movement->type->value,
                'type_label' => $movement->type->label(),
                'quantity' => $movement->quantity,
                'from_location' => $movement->fromLocation?->code,
                'from_rack' => $movement->fromLocation?->rack?->code,
                'to_location' => $movement->toLocation?->code,
                'to_rack' => $movement->toLocation?->rack?->code,
                'comment' => $movement->comment,
                'created_at' => $movement->created_at?->format('d.m.Y H:i'),
            ]);

        return Inertia::render('admin/Dashboard', [
            'statistics' => [
                ...$statistics,
                'stock_by_unit' => $stockByUnit,
            ],
            'movements' => $movements,
        ]);
    }
}
