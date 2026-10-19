<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreStockReceiptBatchRequest;
use App\Http\Requests\Admin\StoreStockReceiptRequest;
use App\Models\Category;
use App\Models\Location;
use App\Models\Product;
use App\Services\Admin\StockMovementService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class StockReceiptController extends Controller
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

        $locations = Location::query()
            ->with('rack:id,code,name')
            ->orderBy('rack_id')
            ->orderBy('number')
            ->get()
            ->map(function (Location $location): array {
                return [
                    'id' => $location->id,
                    'number' => $location->number,
                    'code' => $location->code,
                    'rack' => $location->rack ? [
                        'id' => $location->rack->id,
                        'code' => $location->rack->code,
                        'name' => $location->rack->name,
                    ] : null,
                ];
            });

        return Inertia::render('admin/stock/Receipt', [
            'products' => $products,
            'locations' => $locations,
            'categories' => $categories,
        ]);
    }

    public function store(
        StoreStockReceiptRequest $request,
        StockMovementService $stockMovementService,
    ): RedirectResponse {
        $data = $request->validated();

        $stockMovementService->receipt(
            productId: (int) $data['product_id'],
            locationId: (int) $data['location_id'],
            quantity: (string) $data['quantity'],
            comment: $data['comment'] ?? null,
            userId: $request->user()?->id,
        );

        return to_route('admin.stock.receipt.create')
            ->with('success', 'Поступление товара успешно оформлено.');
    }

    public function storeBatch(
        StoreStockReceiptBatchRequest $request,
        StockMovementService $stockMovementService,
    ): RedirectResponse {
        $data = $request->validated();

        DB::transaction(function () use ($data, $stockMovementService, $request): void {
            foreach ($data['items'] as $item) {
                $stockMovementService->receipt(
                    productId: (int) $item['product_id'],
                    locationId: (int) $item['location_id'],
                    quantity: (string) $item['quantity'],
                    comment: $item['comment'] ?? null,
                    userId: $request->user()?->id,
                );
            }
        });

        return to_route('admin.stock.receipt.create')
            ->with('success', 'Поступление товаров успешно оформлено.');
    }
}
