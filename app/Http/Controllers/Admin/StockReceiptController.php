<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreStockReceiptRequest;
use App\Models\Location;
use App\Models\Product;
use App\Services\Admin\StockMovementService;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class StockReceiptController extends Controller
{
    public function create(): Response
    {
        $products = Product::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get(['id', 'name', 'sku']);

        $locations = Location::query()
            ->with('rack:id,code,name')
            ->orderBy('rack_id')
            ->orderBy('number')
            ->get()
            ->map(fn (Location $location): array => [
                'id' => $location->id,
                'number' => $location->number,
                'code' => $location->code,
                'rack' => [
                    'id' => $location->rack->id,
                    'code' => $location->rack->code,
                    'name' => $location->rack->name,
                ],
            ]);

        return Inertia::render('admin/stock/Receipt', [
            'products' => $products,
            'locations' => $locations,
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
            quantity: (int) $data['quantity'],
            comment: $data['comment'] ?? null,
            userId: $request->user()?->id,
        );

        return to_route('admin.stock.receipt.create')
            ->with('success', 'Поступление товара успешно оформлено.');
    }
}
