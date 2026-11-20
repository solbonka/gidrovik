<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\Admin\StockMovementService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class StockOperationApiController extends Controller
{
    public function __construct(
        private readonly StockMovementService $stockMovementService,
    ) {}

    public function execute(Request $request): RedirectResponse
    {
        $operation = $request->input('operation');

        $baseRules = [
            'product_id' => ['required', 'integer', 'exists:products,id'],
            'comment' => ['nullable', 'string'],
        ];

        $operationRules = match ($operation) {
            'receipt' => [
                'location_id' => ['required', 'integer', 'exists:locations,id'],
                'quantity' => ['required', 'numeric', 'min:0'],
            ],
            'write_off' => [
                'location_id' => ['required', 'integer', 'exists:locations,id'],
                'quantity' => ['required', 'numeric', 'min:0'],
            ],
            'transfer' => [
                'from_location_id' => ['required', 'integer', 'exists:locations,id'],
                'to_location_id' => ['required', 'integer', 'exists:locations,id'],
                'quantity' => ['required', 'numeric', 'min:0'],
            ],
            'return' => [
                'location_id' => ['required', 'integer', 'exists:locations,id'],
                'quantity' => ['required', 'numeric', 'min:0'],
            ],
            'inventory' => [
                'location_id' => ['required', 'integer', 'exists:locations,id'],
                'actual_quantity' => ['required', 'numeric', 'min:0'],
            ],
            default => throw new \InvalidArgumentException('Unknown operation'),
        };

        $allRules = array_merge($baseRules, $operationRules);

        $validator = Validator::make($request->all(), $allRules);
        $validator->validate();

        $validated = $validator->validated();

        $movement = match ($operation) {
            'receipt' => $this->stockMovementService->receipt(
                productId: (int) $validated['product_id'],
                locationId: (int) $validated['location_id'],
                quantity: (string) $validated['quantity'],
                comment: $validated['comment'] ?? null,
                userId: $request->user()?->id,
            ),
            'write_off' => $this->stockMovementService->writeOff(
                productId: (int) $validated['product_id'],
                locationId: (int) $validated['location_id'],
                quantity: (string) $validated['quantity'],
                comment: $validated['comment'] ?? null,
                userId: $request->user()?->id,
            ),
            'transfer' => $this->stockMovementService->transfer(
                productId: (int) $validated['product_id'],
                fromLocationId: (int) $validated['from_location_id'],
                toLocationId: (int) $validated['to_location_id'],
                quantity: (string) $validated['quantity'],
                comment: $validated['comment'] ?? null,
                userId: $request->user()?->id,
            ),
            'return' => $this->stockMovementService->returnStock(
                productId: (int) $validated['product_id'],
                locationId: (int) $validated['location_id'],
                quantity: (string) $validated['quantity'],
                comment: $validated['comment'] ?? null,
                userId: $request->user()?->id,
            ),
            'inventory' => $this->stockMovementService->inventory(
                productId: (int) $validated['product_id'],
                locationId: (int) $validated['location_id'],
                actualQuantity: (string) $validated['actual_quantity'],
                comment: $validated['comment'] ?? null,
                userId: $request->user()?->id,
            ),
        };

        return redirect()->back()->with('toast', [
            'type' => 'success',
            'message' => 'Операция успешно выполнена.',
        ]);
    }

    public function currentLocationProducts(Request $request): JsonResponse
    {
        $locationId = (int) ($request->route('location') ?? $request->input('location_id'));

        $validator = Validator::make(['location_id' => $locationId], [
            'location_id' => ['required', 'integer', 'exists:locations,id'],
        ]);
        $validator->validate();

        $products = DB::table('product_location')
            ->join('products', 'product_location.product_id', '=', 'products.id')
            ->where('product_location.location_id', $locationId)
            ->where('product_location.quantity', '>', 0)
            ->select([
                'products.id',
                'products.name',
                'products.code',
                'products.article',
                'products.stock_mode',
                'product_location.quantity',
            ])
            ->get();

        // Для товаров с учётом по отрезкам подгружаем физические куски
        $lengthProductIds = $products
            ->filter(fn ($item) => $item->stock_mode === 'length')
            ->pluck('id')
            ->all();

        $segmentsByProduct = [];

        if ($lengthProductIds !== []) {
            $segmentsByProduct = DB::table('product_segments')
                ->where('location_id', $locationId)
                ->whereIn('product_id', $lengthProductIds)
                ->whereIn('status', ['available', 'reserved', 'quarantined'])
                ->orderBy('length_mm')
                ->get(['product_id', 'id', 'length_mm', 'status'])
                ->groupBy('product_id');
        }

        $products = $products->map(function ($item) use ($segmentsByProduct) {
            $segments = ($segmentsByProduct[$item->id] ?? collect())->map(fn ($s) => [
                'id' => $s->id,
                'length_mm' => (float) $s->length_mm,
                'status' => $s->status,
            ])->values();

            return [
                'id' => $item->id,
                'name' => $item->name,
                'code' => $item->code ?? null,
                'article' => $item->article ?? null,
                'quantity' => rtrim(rtrim(bcadd((string) $item->quantity, '0', 3), '0'), '.'),
                'stock_mode' => $item->stock_mode ?? 'quantity',
                'segments' => $segments,
            ];
        });

        return response()->json([
            'products' => $products,
        ]);
    }

    public function productLocation(Request $request): JsonResponse
    {
        $productId = (int) ($request->route('product') ?? $request->input('product_id'));

        $validator = Validator::make(['product_id' => $productId], [
            'product_id' => ['required', 'integer', 'exists:products,id'],
        ]);
        $validator->validate();

        $locations = DB::table('product_location')
            ->join('locations', 'product_location.location_id', '=', 'locations.id')
            ->join('racks', 'locations.rack_id', '=', 'racks.id')
            ->where('product_location.product_id', $productId)
            ->where('product_location.quantity', '>', 0)
            ->select([
                'locations.id',
                'locations.number',
                'racks.code as rack_code',
                'product_location.quantity',
            ])
            ->get()
            ->map(function ($item) {
                return [
                    'id' => $item->id,
                    'number' => $item->number,
                    'code' => $item->rack_code.'-'.$item->number,
                    'quantity' => rtrim(rtrim(bcadd((string) $item->quantity, '0', 3), '0'), '.'),
                ];
            });

        return response()->json([
            'locations' => $locations,
        ]);
    }
}
