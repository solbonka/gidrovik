<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreLocationRequest;
use App\Http\Requests\Admin\UpdateLocationRequest;
use App\Models\Location;
use App\Models\Rack;
use App\Models\StockMovement;
use App\Services\Admin\LocationService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;

class LocationController extends Controller
{
    public function __construct(
        private readonly LocationService $locationService,
    ) {
    }

    public function store(
        StoreLocationRequest $request,
        Rack $rack,
    ): RedirectResponse {
        $this->locationService->create(
            $rack,
            $request->validated(),
        );

        return back()->with(
            'success',
            'Ячейка успешно создана.',
        );
    }

    public function update(
        UpdateLocationRequest $request,
        Rack $rack,
        Location $location,
    ): RedirectResponse {
        $this->locationService->update(
            $location,
            $request->validated(),
        );

        return back()->with(
            'success',
            'Ячейка успешно обновлена.',
        );
    }

    public function destroy(
        Rack $rack,
        Location $location,
    ): RedirectResponse {
        abort_unless((int) $location->rack_id === (int) $rack->id, 404);

        $hasStock = DB::table('product_location')
            ->where('location_id', $location->id)
            ->where('quantity', '>', 0)
            ->exists();

        $hasHistory = StockMovement::query()
            ->where('from_location_id', $location->id)
            ->orWhere('to_location_id', $location->id)
            ->exists();

        if ($hasStock || $hasHistory) {
            return back()->withErrors([
                'location' => $hasStock
                    ? 'Нельзя удалить ячейку: в ней есть остатки товара.'
                    : 'Нельзя удалить ячейку: она присутствует в истории складских движений.',
            ]);
        }

        $location->delete();

        return back()->with('success', 'Ячейка успешно удалена.');
    }
}
