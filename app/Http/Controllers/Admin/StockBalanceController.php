<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use App\Models\Rack;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class StockBalanceController extends Controller
{
    public function index(Request $request): Response
    {
        $search = trim((string) $request->input('search', ''));
        $categoryId = $request->input('category_id');
        $rackId = $request->input('rack_id');
        $stock = (string) $request->input('stock', 'all');

        $allowedStockFilters = [
            'all',
            'in_stock',
            'out_of_stock',
            'below_minimum',
        ];

        if (! in_array($stock, $allowedStockFilters, true)) {
            $stock = 'all';
        }

        $productsQuery = Product::query()
            ->with([
                'category:id,name',
                'locations' => function ($query): void {
                    $query
                        ->wherePivot('quantity', '>', 0)
                        ->with('rack:id,code,name');
                },
            ])
            ->addSelect([
                'stock_quantity' => DB::table('product_location as pl')
                    ->selectRaw('COALESCE(SUM(pl.quantity), 0)')
                    ->whereColumn('pl.product_id', 'products.id'),
            ])
            ->addSelect([
                'stock_deficit' => DB::raw(
                    'CASE
                        WHEN products.minimum_stock IS NOT NULL THEN
                            GREATEST(
                                products.minimum_stock - COALESCE(
                                    (
                                        SELECT SUM(pl.quantity)
                                        FROM product_location AS pl
                                        WHERE pl.product_id = products.id
                                    ),
                                    0
                                ),
                                0
                            )
                        ELSE 0
                    END AS stock_deficit'
                ),
            ]);

        if ($search !== '') {
            $words = preg_split(
                '/\s+/u',
                mb_strtolower($search, 'UTF-8'),
                -1,
                PREG_SPLIT_NO_EMPTY,
            );

            $productsQuery->where(function (Builder $query) use ($words): void {
                foreach ($words as $word) {
                    $word = addcslashes($word, '%_\\');

                    $query->where(function (Builder $query) use ($word): void {
                        $query
                            ->where('products.name', 'ilike', "%{$word}%")
                            ->orWhere('products.sku', 'ilike', "%{$word}%");
                    });
                }
            });
        }

        if ($categoryId !== null && $categoryId !== '') {
            $productsQuery->where('products.category_id', $categoryId);
        }

        if ($rackId !== null && $rackId !== '') {
            $productsQuery->whereHas('locations', function (Builder $query) use ($rackId): void {
                $query->where('racks.id', $rackId);
            });
        }

        switch ($stock) {
            case 'in_stock':
                $productsQuery->whereRaw(
                    'COALESCE(
                        (
                            SELECT SUM(pl.quantity)
                            FROM product_location AS pl
                            WHERE pl.product_id = products.id
                        ),
                        0
                    ) > 0'
                );
                break;

            case 'out_of_stock':
                $productsQuery->whereRaw(
                    'COALESCE(
                        (
                            SELECT SUM(pl.quantity)
                            FROM product_location AS pl
                            WHERE pl.product_id = products.id
                        ),
                        0
                    ) <= 0'
                );
                break;

            case 'below_minimum':
                $productsQuery
                    ->where('products.is_active', true)
                    ->whereNotNull('products.minimum_stock')
                    ->whereRaw(
                        'COALESCE(
                            (
                                SELECT SUM(pl.quantity)
                                FROM product_location AS pl
                                WHERE pl.product_id = products.id
                            ),
                            0
                        ) < products.minimum_stock'
                    );

                $productsQuery
                    ->orderByDesc('stock_deficit')
                    ->orderBy('products.name');
                break;

            default:
                $productsQuery->orderBy('products.name');
                break;
        }

        $products = $productsQuery
            ->paginate(20)
            ->withQueryString()
            ->through(function (Product $product): array {
                $locations = $product->locations
                    ->map(fn ($location): array => [
                        'id' => $location->id,
                        'code' => $location->code,
                        'rack_code' => $location->rack?->code,
                        'rack_name' => $location->rack?->name,
                        'quantity' => (string) $location->pivot->quantity,
                    ])
                    ->values()
                    ->all();

                return [
                    'id' => $product->id,
                    'name' => $product->name,
                    'sku' => $product->sku,
                    'category' => $product->category?->name,
                    'unit' => $product->unit,
                    'stock_quantity' => rtrim(
                        rtrim(
                            bcadd(
                                (string) ($product->stock_quantity ?? '0'),
                                '0',
                                3,
                            ),
                            '0'
                        ),
                        '.'
                    ),
                    'minimum_stock' => $product->minimum_stock !== null
                        ? (string) $product->minimum_stock
                        : null,
                    'stock_deficit' => rtrim(
                        rtrim(
                            bcadd(
                                (string) ($product->stock_deficit ?? '0'),
                                '0',
                                3,
                            ),
                            '0'
                        ),
                        '.'
                    ),
                    'locations' => $locations,
                ];
            });

        return Inertia::render('admin/stock/Index', [
            'products' => $products,

            'categories' => Category::query()
                ->where('is_active', true)
                ->orderBy('name')
                ->get(['id', 'name']),

            'racks' => Rack::query()
                ->orderBy('code')
                ->get(['id', 'code', 'name']),

            'filters' => [
                'search' => $search,
                'category_id' => $categoryId !== null
                    ? (string) $categoryId
                    : '',
                'rack_id' => $rackId !== null
                    ? (string) $rackId
                    : '',
                'stock' => $stock,
            ],
        ]);
    }
}
