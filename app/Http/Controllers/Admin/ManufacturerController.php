<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreManufacturerRequest;
use App\Http\Requests\Admin\UpdateManufacturerRequest;
use App\Models\Manufacturer;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class ManufacturerController extends Controller
{
    public function index(): Response
    {
        $manufacturers = Manufacturer::query()
            ->withCount('products')
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('admin/manufacturers/Index', [
            'manufacturers' => $manufacturers,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('admin/manufacturers/Create');
    }

    public function store(StoreManufacturerRequest $request): RedirectResponse
    {
        Manufacturer::query()->create($request->validated());

        return to_route('admin.manufacturers.index')
            ->with('success', 'Производитель успешно создан.');
    }

    public function edit(Manufacturer $manufacturer): Response
    {
        return Inertia::render('admin/manufacturers/Edit', [
            'manufacturer' => $manufacturer,
        ]);
    }

    public function update(
        UpdateManufacturerRequest $request,
        Manufacturer $manufacturer,
    ): RedirectResponse {
        $manufacturer->update($request->validated());

        return to_route('admin.manufacturers.index')
            ->with('success', 'Производитель успешно обновлён.');
    }

    public function destroy(Manufacturer $manufacturer): RedirectResponse
    {
        if ($manufacturer->products()->exists()) {
            return back()->with(
                'error',
                'Нельзя удалить производителя, который используется в товарах.',
            );
        }

        $manufacturer->delete();

        return to_route('admin.manufacturers.index')
            ->with('success', 'Производитель удалён.');
    }
}
