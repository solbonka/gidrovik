<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreDiameterRequest;
use App\Http\Requests\Admin\UpdateDiameterRequest;
use App\Models\Diameter;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class DiameterController extends Controller
{
    public function index(): Response
    {
        $diameters = Diameter::query()
            ->withCount('connections')
            ->orderBy('value')
            ->orderBy('unit')
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('admin/diameters/Index', [
            'diameters' => $diameters,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('admin/diameters/Create');
    }

    public function store(StoreDiameterRequest $request): RedirectResponse
    {
        Diameter::query()->create($request->validated());

        return to_route('admin.diameters.index')
            ->with('success', 'Диаметр успешно создан.');
    }

    public function edit(Diameter $diameter): Response
    {
        return Inertia::render('admin/diameters/Edit', [
            'diameter' => $diameter,
        ]);
    }

    public function update(
        UpdateDiameterRequest $request,
        Diameter $diameter,
    ): RedirectResponse {
        $diameter->update($request->validated());

        return to_route('admin.diameters.index')
            ->with('success', 'Диаметр успешно обновлён.');
    }

    public function destroy(Diameter $diameter): RedirectResponse
    {
        if ($diameter->connections()->exists()) {
            return to_route('admin.diameters.index')
                ->with(
                    'error',
                    'Нельзя удалить диаметр, который используется товарами.',
                );
        }

        $diameter->delete();

        return to_route('admin.diameters.index')
            ->with('success', 'Диаметр удалён.');
    }
}
