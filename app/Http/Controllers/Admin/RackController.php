<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreRackRequest;
use App\Http\Requests\Admin\UpdateRackRequest;
use App\Models\Rack;
use App\Models\StockMovement;
use App\Services\Admin\RackService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class RackController extends Controller
{
    public function __construct(
        private readonly RackService $rackService,
    ) {
    }

    public function index(): Response
    {
        $racks = Rack::query()
            ->with([
                'locations' => fn ($query) => $query
                    ->withCount([
                        'incomingMovements',
                        'outgoingMovements',
                    ])
                    ->withSum(
                        'products as stock_quantity',
                        'product_location.quantity',
                    )
                    ->orderBy('number'),
            ])
            ->withCount('locations')
            ->orderBy('code')
            ->get();

        return Inertia::render('admin/racks/Index', [
            'racks' => $racks,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('admin/racks/Create');
    }

    public function store(StoreRackRequest $request): RedirectResponse
    {
        $this->rackService->create($request->validated());

        return to_route('admin.racks.index')
            ->with('success', 'Стеллаж успешно создан.');
    }

    public function edit(Rack $rack): Response
    {
        return Inertia::render('admin/racks/Edit', [
            'rack' => $rack->load('locations'),
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
        $locationIds = $rack->locations()->pluck('id');

        $hasStock = DB::table('product_location')
            ->whereIn('location_id', $locationIds)
            ->where('quantity', '>', 0)
            ->exists();

        $hasHistory = StockMovement::query()
            ->whereIn('from_location_id', $locationIds)
            ->orWhereIn('to_location_id', $locationIds)
            ->exists();

        if ($hasStock || $hasHistory) {
            return back()->withErrors([
                'rack' => $hasStock
                    ? 'Нельзя удалить стеллаж: в его ячейках есть остатки товара.'
                    : 'Нельзя удалить стеллаж: его ячейки присутствуют в истории складских движений.',
            ]);
        }

        $rack->delete();

        return back()->with('success', 'Стеллаж успешно удалён.');
    }
}
