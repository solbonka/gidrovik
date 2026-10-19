<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreStockWriteOffRequest;
use App\Models\Category;
use App\Models\Location;
use App\Models\Product;
use App\Services\Admin\StockMovementService;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class StockWriteOffController extends Controller
{
    public function create(): Response
    {
        $categories = Category::query()
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
                return $cv->characteristic->name.': '.$cv->value;
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

        return Inertia::render('admin/stock/WriteOff', [
            'products' => $products,
            'categories' => $categories,
            'locations' => Location::query()
                ->with('rack:id,code,name')
                ->orderBy('rack_id')
                ->orderBy('number')
                ->get()
                ->map(fn (Location $location): array => [
                    'id' => $location->id,
                    'code' => $location->code,
                    'rack_name' => $location->rack->name,
                ]),
        ]);
    }

    public function store(
        StoreStockWriteOffRequest $request,
        StockMovementService $stockMovementService,
    ): RedirectResponse {
        $data = $request->validated();

        $stockMovementService->writeOff(
            productId: (int) $data['product_id'],
            locationId: (int) $data['location_id'],
            quantity: (string) $data['quantity'],
            comment: $data['comment'],
            userId: $request->user()?->id,
        );

        return to_route('admin.stock.write-off.create')
            ->with('success', 'Списание товара успешно оформлено.');
    }
}
