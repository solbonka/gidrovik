<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreStockTransferRequest;
use App\Models\Location;
use App\Models\Product;
use App\Services\Admin\StockMovementService;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class StockTransferController extends Controller
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
                'code' => $location->code,
                'rack' => [
                    'code' => $location->rack->code,
                    'name' => $location->rack->name,
                ],
            ]);

        return Inertia::render('admin/stock/Transfer', [
            'products' => $products,
            'locations' => $locations,
        ]);
    }

    public function store(
        StoreStockTransferRequest $request,
        StockMovementService $stockMovementService,
    ): RedirectResponse {
        $data = $request->validated();

        $stockMovementService->transfer(
            productId: (int) $data['product_id'],
            fromLocationId: (int) $data['from_location_id'],
            toLocationId: (int) $data['to_location_id'],
            quantity: (string) $data['quantity'],
            comment: $data['comment'] ?? null,
            userId: $request->user()?->id,
        );

        return to_route('admin.stock.transfer.create')
            ->with('success', 'Перемещение товара успешно оформлено.');
    }
}
