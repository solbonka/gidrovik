<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreStockReturnRequest;
use App\Models\Location;
use App\Models\Product;
use App\Services\Admin\StockMovementService;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class StockReturnController extends Controller
{
    public function __construct(
        private readonly StockMovementService $stockMovementService,
    ) {}

    public function create(): Response
    {
        $categories = \App\Models\Category::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get(['id', 'name']);

        $products = Product::query()
            ->where('is_active', true)
            ->with(['characteristicValues.characteristic:id,name'])
            ->orderBy('name')
            ->get(['id', 'name', 'sku', 'unit', 'minimum_stock', 'category_id']);

        $stockQuantities = \DB::table('product_location')
            ->select('product_id', \DB::raw('SUM(quantity) as total_quantity'))
            ->where('quantity', '>', 0)
            ->groupBy('product_id')
            ->pluck('total_quantity', 'product_id');

        $products = $products->map(function (Product $product) use ($stockQuantities) {
            $characteristics = $product->characteristicValues->map(function ($cv) {
                return $cv->characteristic->name . ': ' . $cv->value;
            })->implode(', ');

            return [
                'id' => $product->id,
                'name' => $product->name,
                'sku' => $product->sku,
                'unit' => $product->unit,
                'minimum_stock' => $product->minimum_stock,
                'stock_quantity' => $stockQuantities->get($product->id, 0),
                'characteristics' => $characteristics,
                'category_id' => $product->category_id,
            ];
        });

        $locations = Location::query()
            ->with('rack:id,code')
            ->orderBy('rack_id')
            ->orderBy('number')
            ->get()
            ->map(fn (Location $location): array => [
                'id' => $location->id,
                'number' => $location->number,
                'code' => $location->code,
                'rack_name' => $location->rack?->code,
            ]);

        return Inertia::render('admin/stock/Return', [
            'products' => $products,
            'locations' => $locations,
            'categories' => $categories,
        ]);
    }

    public function store(
        StoreStockReturnRequest $request,
    ): RedirectResponse {
        $validated = $request->validated();

        $this->stockMovementService->returnStock(
            productId: (int) $validated['product_id'],
            locationId: (int) $validated['location_id'],
            quantity: (string) $validated['quantity'],
            comment: $validated['comment'],
            userId: $request->user()?->id,
        );

        return to_route('admin.stock.return.create')
            ->with('success', 'Возврат товара успешно оформлен.');
    }
}
