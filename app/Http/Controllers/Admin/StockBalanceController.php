<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use App\Models\Rack;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class StockBalanceController extends Controller
{
    public function index(Request $request): Response
    {
        $validated = $request->validate([
            'search' => ['nullable', 'string', 'max:255'],
            'category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'rack_id' => ['nullable', 'integer', 'exists:racks,id'],
            'stock' => ['nullable', 'in:all,in_stock,out_of_stock'],
        ]);

        $search = trim((string) ($validated['search'] ?? ''));
        $categoryId = $validated['category_id'] ?? null;
        $rackId = $validated['rack_id'] ?? null;
        $stockFilter = $validated['stock'] ?? 'all';

        $products = Product::query()
            ->with([
                'category:id,name',
                'locations' => fn (Builder $query) => $query
                    ->with('rack:id,code,name')
                    ->wherePivot('quantity', '>', 0)
                    ->orderBy('rack_id')
                    ->orderBy('number'),
            ])
            ->withSum('locations as stock_quantity', 'product_location.quantity')
            ->when($search !== '', function (Builder $query) use ($search): void {
                $query->where(function (Builder $query) use ($search): void {
                    $query
                        ->where('name', 'like', "%{$search}%")
                        ->orWhere('sku', 'like', "%{$search}%");
                });
            })
            ->when($categoryId, fn (Builder $query) => $query
                ->where('category_id', $categoryId))
            ->when($rackId, fn (Builder $query) => $query
                ->whereHas('locations', fn (Builder $query) => $query
                    ->where('rack_id', $rackId)
                    ->where('product_location.quantity', '>', 0)))
            ->when($stockFilter === 'in_stock', fn (Builder $query) => $query
                ->whereHas('locations', fn (Builder $query) => $query
                    ->where('product_location.quantity', '>', 0)))
            ->when($stockFilter === 'out_of_stock', fn (Builder $query) => $query
                ->whereDoesntHave('locations', fn (Builder $query) => $query
                    ->where('product_location.quantity', '>', 0)))
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString()
            ->through(fn (Product $product): array => [
                'id' => $product->id,
                'name' => $product->name,
                'sku' => $product->sku,
                'category' => $product->category?->name,
                'stock_quantity' => (int) ($product->stock_quantity ?? 0),
                'locations' => $product->locations
                    ->map(fn ($location): array => [
                        'id' => $location->id,
                        'code' => $location->code,
                        'rack_code' => $location->rack?->code,
                        'rack_name' => $location->rack?->name,
                        'quantity' => (int) $location->pivot->quantity,
                    ])
                    ->values(),
            ]);

        return Inertia::render('admin/stock/Index', [
            'products' => $products,
            'categories' => Category::query()
                ->orderBy('name')
                ->get(['id', 'name']),
            'racks' => Rack::query()
                ->orderBy('code')
                ->get(['id', 'code', 'name']),
            'filters' => [
                'search' => $search,
                'category_id' => $categoryId ? (string) $categoryId : '',
                'rack_id' => $rackId ? (string) $rackId : '',
                'stock' => $stockFilter,
            ],
        ]);
    }
}
