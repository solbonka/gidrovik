<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreLocationRequest;
use App\Http\Requests\Admin\UpdateLocationRequest;
use App\Models\Location;
use App\Models\Rack;
use App\Models\StockMovement;
use App\Services\Admin\LocationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LocationController extends Controller
{
    public function __construct(
        private readonly LocationService $locationService,
    ) {}

    public function store(
        StoreLocationRequest $request,
        Rack $rack,
    ): RedirectResponse {
        $this->locationService->create($rack, $request->validated());

        return back()->with('success', 'Ячейка успешно создана.');
    }

    public function update(
        UpdateLocationRequest $request,
        Rack $rack,
        Location $location,
    ): RedirectResponse {
        $this->locationService->update($location, $request->validated());

        return back()->with('success', 'Ячейка успешно обновлена.');
    }

    public function destroy(Rack $rack, Location $location): RedirectResponse
    {
        abort_unless((int) $location->rack_id === (int) $rack->id, 404);

        return DB::transaction(function () use ($rack, $location): RedirectResponse {
            $lockedLocation = Location::query()
                ->whereKey($location->id)
                ->where('rack_id', $rack->id)
                ->lockForUpdate()
                ->firstOrFail();

            $hasStock = DB::table('product_location')
                ->where('location_id', $lockedLocation->id)
                ->where('quantity', '>', 0)
                ->exists();

            if ($hasStock) {
                return back()->withErrors([
                    'location' => 'Нельзя удалить ячейку: в ней есть остатки товара.',
                ]);
            }

            $hasHistory = StockMovement::query()
                ->where(function ($query) use ($lockedLocation): void {
                    $query
                        ->where('from_location_id', $lockedLocation->id)
                        ->orWhere('to_location_id', $lockedLocation->id);
                })
                ->exists();

            if ($hasHistory) {
                return back()->withErrors([
                    'location' => 'Нельзя удалить ячейку: она присутствует в истории складских движений.',
                ]);
            }

            $lockedLocation->delete();

            return back()->with('success', 'Ячейка успешно удалена.');
        });
    }

    public function getLocationsWithProduct(Request $request): JsonResponse
    {
        $productId = $request->integer('product_id');

        abort_if($productId <= 0, 404);

        $locations = Location::query()
            ->join('product_location', 'locations.id', '=', 'product_location.location_id')
            ->where('product_location.product_id', $productId)
            ->select([
                'locations.id',
                'locations.rack_id', // Required for eager-loading the rack relation.
                'locations.number',
                'product_location.quantity',
            ])
            ->with([
                'rack' => function ($query): void {
                    $query->select('id', 'code');
                },
            ])
            ->orderBy('locations.rack_id')
            ->orderBy('locations.number')
            ->get()
            ->map(function (Location $location): array {
                return [
                    'id' => $location->id,
                    'number' => $location->number,
                    'code' => $location->rack
                        ? $location->rack->code.'-'.$location->number
                        : 'Ячейка №'.$location->number,
                    'quantity' => $location->quantity,
                ];
            });

        return response()->json(['locations' => $locations]);
    }
}
