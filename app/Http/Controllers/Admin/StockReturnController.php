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
        $products = Product::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get(['id', 'name', 'sku']);

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
