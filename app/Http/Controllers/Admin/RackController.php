<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreRackRequest;
use App\Http\Requests\Admin\UpdateRackRequest;
use App\Models\Category;
use App\Models\Location;
use App\Models\Product;
use App\Models\Rack;
use App\Models\StockMovement;
use App\Models\Warehouse;
use App\Services\Admin\RackService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class RackController extends Controller
{
    public function __construct(
        private readonly RackService $rackService,
    ) {}

    public function index(): Response
    {
        $warehouseId = request()->integer('warehouse_id');

        $query = Rack::query()
            ->with([
                'locations' => function ($query) {
                    $query
                        ->withCount([
                            'incomingMovements',
                            'outgoingMovements',
                        ])
                        ->orderBy('number');
                },
            ])
            ->withCount('locations')
            ->orderBy('code');

        if ($warehouseId > 0) {
            $query->where('warehouse_id', $warehouseId);
        }

        $racks = $query->get();

        // Get all location IDs for batch query
        $locationIds = $racks->pluck('locations.*.id')->flatten()->filter();

        // Batch load stock quantities
        $locationQuantities = [];
        if ($locationIds->isNotEmpty()) {
            $locationQuantities = DB::table('product_location')
                ->select('location_id', DB::raw('SUM(quantity) as total'))
                ->whereIn('location_id', $locationIds)
                ->groupBy('location_id')
                ->pluck('total', 'location_id')
                ->map(function ($value) {
                    return rtrim(rtrim(bcadd((string) $value, '0', 3), '0'), '.');
                });
        }

        $racks = $racks->map(function ($rack) use ($locationQuantities) {
            $rackCode = $rack->code;

            return [
                'id' => $rack->id,
                'code' => $rack->code,
                'name' => $rack->name,
                'locations_count' => $rack->locations_count,
                'locations' => $rack->locations->map(function ($location) use ($locationQuantities, $rackCode) {
                    return [
                        'id' => $location->id,
                        'number' => $location->number,
                        'code' => "{$rackCode}-{$location->number}",
                        'incoming_movements_count' => $location->incoming_movements_count,
                        'outgoing_movements_count' => $location->outgoing_movements_count,
                        'stock_quantity' => $locationQuantities[$location->id] ?? '0',
                    ];
                }),
            ];
        });

        // Get categories
        $categories = Category::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get(['id', 'name']);

        // Get all products for operations
        $allProducts = Product::query()
            ->where('is_active', true)
            ->with(['characteristicValues.characteristic:id,name'])
            ->orderBy('name')
            ->get(['id', 'name', 'code', 'article', 'unit', 'category_id'])
            ->map(function ($product) {
                $characteristics = $product->characteristicValues->map(function ($cv) {
                    return $cv->characteristic->name.': '.$cv->value;
                })->implode(', ');

                return [
                    'id' => $product->id,
                    'name' => $product->name,
                    'code' => $product->code,
                    'article' => $product->article,
                    'unit' => $product->unit,
                    'characteristics' => $characteristics,
                    'category_id' => $product->category_id,
                ];
            });

        // Get all locations for transfer operations
        $allLocations = Location::query()
            ->with('rack:id,code,name')
            ->orderBy('rack_id')
            ->orderBy('number')
            ->get()
            ->map(fn ($location) => [
                'id' => $location->id,
                'code' => $location->code,
                'rack_name' => $location->rack->name,
            ]);

        // Get warehouses for filter
        $warehouses = Warehouse::query()
            ->orderBy('name')
            ->get(['id', 'name']);

        $selectedWarehouse = $warehouseId > 0
            ? Warehouse::query()->find($warehouseId, ['id', 'name'])
            : null;

        return Inertia::render('admin/racks/Index', [
            'racks' => $racks,
            'allProducts' => $allProducts,
            'allLocations' => $allLocations,
            'categories' => $categories,
            'warehouses' => $warehouses,
            'selectedWarehouse' => $selectedWarehouse,
        ]);
    }

    public function create(): Response
    {
        $warehouses = Warehouse::query()
            ->orderBy('name')
            ->get(['id', 'name']);

        return Inertia::render('admin/racks/Create', [
            'warehouses' => $warehouses,
        ]);
    }

    public function store(StoreRackRequest $request): RedirectResponse
    {
        $this->rackService->create($request->validated());

        return to_route('admin.racks.index')
            ->with('success', 'Стеллаж успешно создан.');
    }

    public function edit(Rack $rack): Response
    {
        $warehouses = Warehouse::query()
            ->orderBy('name')
            ->get(['id', 'name']);

        return Inertia::render('admin/racks/Edit', [
            'rack' => $rack->load('locations'),
            'warehouses' => $warehouses,
        ]);
    }

    public function update(
        UpdateRackRequest $request,
        Rack $rack,
    ): RedirectResponse {
        $this->rackService->update(
            $rack,
            $request->validated(),
        );

        return to_route('admin.racks.index')
            ->with('success', 'Стеллаж успешно обновлён.');
    }

    public function destroy(Rack $rack): RedirectResponse
    {
        return DB::transaction(function () use ($rack): RedirectResponse {
            $lockedRack = Rack::query()
                ->whereKey($rack->id)
                ->lockForUpdate()
                ->firstOrFail();

            $locationIds = $lockedRack->locations()
                ->lockForUpdate()
                ->pluck('id');

            $hasStock = DB::table('product_location')
                ->whereIn('location_id', $locationIds)
                ->where('quantity', '>', 0)
                ->exists();

            if ($hasStock) {
                return back()->withErrors([
                    'rack' => 'Нельзя удалить стеллаж: в его ячейках есть остатки товара.',
                ]);
            }

            $hasHistory = StockMovement::query()
                ->where(function ($query) use ($locationIds): void {
                    $query
                        ->whereIn('from_location_id', $locationIds)
                        ->orWhereIn('to_location_id', $locationIds);
                })
                ->exists();

            if ($hasHistory) {
                return back()->withErrors([
                    'rack' => 'Нельзя удалить стеллаж: его ячейки присутствуют в истории складских движений.',
                ]);
            }

            $lockedRack->delete();

            return back()->with('success', 'Стеллаж успешно удалён.');
        });
    }

    public function getLocationProducts(Location $location): JsonResponse
    {
        $products = DB::table('product_location')
            ->join('products', 'product_location.product_id', '=', 'products.id')
            ->where('product_location.location_id', $location->id)
            ->where('product_location.quantity', '>', 0)
            ->select([
                'products.id',
                'products.name',
                'products.code',
                'products.article',
                'product_location.quantity',
            ])
            ->get()
            ->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                    'code' => $item->code ?? null,
                    'article' => $item->article ?? null,
                    'quantity' => rtrim(rtrim(bcadd((string) $item->quantity, '0', 3), '0'), '.'),
                ];
            });

        return response()->json($products);
    }
}
