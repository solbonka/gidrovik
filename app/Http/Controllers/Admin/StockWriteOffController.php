<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreStockWriteOffRequest;
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
        return Inertia::render('admin/stock/WriteOff', [
            'products' => Product::query()
                ->where('is_active', true)
                ->orderBy('name')
                ->get(['id', 'name', 'sku']),

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
            quantity: (int) $data['quantity'],
            comment: $data['comment'],
            userId: $request->user()?->id,
        );

        return to_route('admin.stock.write-off.create')
            ->with('success', 'Списание товара успешно оформлено.');
    }
}
