<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreStandardRequest;
use App\Http\Requests\Admin\UpdateStandardRequest;
use App\Models\Standard;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class StandardController extends Controller
{
    public function index(): Response
    {
        $standards = Standard::query()
            ->withCount('connections')
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('admin/standards/Index', [
            'standards' => $standards,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('admin/standards/Create');
    }

    public function store(StoreStandardRequest $request): RedirectResponse
    {
        Standard::query()->create($request->validated());

        return to_route('admin.standards.index')
            ->with('success', 'Стандарт успешно создан.');
    }

    public function edit(Standard $standard): Response
    {
        return Inertia::render('admin/standards/Edit', [
            'standard' => $standard,
        ]);
    }

    public function update(
        UpdateStandardRequest $request,
        Standard $standard,
    ): RedirectResponse {
        $standard->update($request->validated());

        return to_route('admin.standards.index')
            ->with('success', 'Стандарт успешно обновлён.');
    }

    public function destroy(Standard $standard): RedirectResponse
    {
        if ($standard->connections()->exists()) {
            return to_route('admin.standards.index')
                ->with(
                    'error',
                    'Нельзя удалить стандарт, который используется товарами.',
                );
        }

        $standard->delete();

        return to_route('admin.standards.index')
            ->with('success', 'Стандарт удалён.');
    }
}
