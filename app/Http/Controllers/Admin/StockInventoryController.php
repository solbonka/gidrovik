<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreStockInventoryRequest;
use App\Models\Location;
use App\Models\Product;
use App\Services\Admin\StockMovementService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;
use Illuminate\Support\Facades\DB;

class StockInventoryController extends Controller
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
            ->get(['id', 'name', 'sku', 'category_id']);

        $products = $products->map(function (Product $product) {
            $characteristics = $product->characteristicValues->map(function ($cv) {
                return $cv->characteristic->name . ': ' . $cv->value;
            })->implode(', ');

            return [
                'id' => $product->id,
                'name' => $product->name,
                'sku' => $product->sku,
                'characteristics' => $characteristics,
                'category_id' => $product->category_id,
            ];
        });

        $locations = Location::query()
            ->with('rack:id,code,name')
            ->orderBy('rack_id')
            ->orderBy('number')
            ->get()
            ->map(fn (Location $location): array => [
                'id' => $location->id,
                'number' => $location->number,
                'code' => $location->code,
                'rack' => $location->rack ? [
                    'id' => $location->rack->id,
                    'code' => $location->rack->code,
                    'name' => $location->rack->name,
                ] : null,
            ]);

        return Inertia::render('admin/stock/Inventory', [
            'products' => $products,
            'locations' => $locations,
            'categories' => $categories,
        ]);
    }

    public function current(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => ['required', 'integer', 'exists:products,id'],
            'location_id' => ['required', 'integer', 'exists:locations,id'],
        ]);

        $quantity = DB::table('product_location')
            ->where('product_id', (int) $validated['product_id'])
            ->where('location_id', (int) $validated['location_id'])
            ->value('quantity');

        return response()->json([
            'quantity' => bcadd(
                (string) ($quantity ?? '0'),
                '0',
                3,
            ),
        ]);
    }

    public function store(
        StoreStockInventoryRequest $request,
    ): RedirectResponse {
        $validated = $request->validated();

        $movement = $this->stockMovementService->inventory(
            productId: (int) $validated['product_id'],
            locationId: (int) $validated['location_id'],
            actualQuantity: (string) $validated['actual_quantity'],
            comment: $validated['comment'],
            userId: $request->user()?->id,
        );

        return to_route('admin.stock.inventory.create')
            ->with(
                'success',
                $movement
                    ? 'Инвентаризация завершена. Остаток скорректирован.'
                    : 'Инвентаризация завершена. Расхождений не обнаружено.',
            );
    }
}
