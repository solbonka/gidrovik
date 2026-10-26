<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreWarehouseRequest;
use App\Http\Requests\Admin\UpdateWarehouseRequest;
use App\Models\Location;
use App\Models\StockMovement;
use App\Models\Warehouse;
use App\Services\Admin\WarehouseService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class WarehouseController extends Controller
{
    public function __construct(
        private readonly WarehouseService $warehouseService,
    ) {}

    public function index(): Response
    {
        $warehouses = Warehouse::query()
            ->with([
                'racks' => function ($query) {
                    $query->withCount('locations');
                },
            ])
            ->withCount('racks')
            ->orderBy('name')
            ->get();

        return Inertia::render('admin/warehouses/Index', [
            'warehouses' => $warehouses,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('admin/warehouses/Create');
    }

    public function store(StoreWarehouseRequest $request): RedirectResponse
    {
        $this->warehouseService->create($request->validated());

        return to_route('admin.warehouses.index')
            ->with('success', 'Склад успешно создан.');
    }

    public function edit(Warehouse $warehouse): Response
    {
        return Inertia::render('admin/warehouses/Edit', [
            'warehouse' => $warehouse->load('racks'),
        ]);
    }

    public function update(
        UpdateWarehouseRequest $request,
        Warehouse $warehouse,
    ): RedirectResponse {
        $this->warehouseService->update($warehouse, $request->validated());

        return to_route('admin.warehouses.index')
            ->with('success', 'Склад успешно обновлён.');
    }

    public function destroy(Warehouse $warehouse): RedirectResponse
    {
        return DB::transaction(function () use ($warehouse): RedirectResponse {
            $lockedWarehouse = Warehouse::query()
                ->whereKey($warehouse->id)
                ->lockForUpdate()
                ->firstOrFail();

            $rackIds = $lockedWarehouse->racks()
                ->lockForUpdate()
                ->pluck('id');

            $locationIds = Location::query()
                ->whereIn('rack_id', $rackIds)
                ->lockForUpdate()
                ->pluck('id');

            $hasStock = DB::table('product_location')
                ->whereIn('location_id', $locationIds)
                ->where('quantity', '>', 0)
                ->exists();

            if ($hasStock) {
                return back()->withErrors([
                    'warehouse' => 'Нельзя удалить склад: в его ячейках есть остатки товара.',
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
                    'warehouse' => 'Нельзя удалить склад: его ячейки присутствуют в истории складских движений.',
                ]);
            }

            $lockedWarehouse->delete();

            return back()->with('success', 'Склад успешно удалён.');
        });
    }
}

