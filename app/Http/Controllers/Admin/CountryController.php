<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreCountryRequest;
use App\Http\Requests\Admin\UpdateCountryRequest;
use App\Models\Country;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class CountryController extends Controller
{
    public function index(): Response
    {
        $countries = Country::query()
            ->withCount('products')
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('admin/countries/Index', [
            'countries' => $countries,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('admin/countries/Create');
    }

    public function store(StoreCountryRequest $request): RedirectResponse
    {
        Country::query()->create($request->validated());

        return to_route('admin.countries.index')
            ->with('success', 'Страна успешно создана.');
    }

    public function edit(Country $country): Response
    {
        return Inertia::render('admin/countries/Edit', [
            'country' => $country,
        ]);
    }

    public function update(
        UpdateCountryRequest $request,
        Country $country,
    ): RedirectResponse {
        $country->update($request->validated());

        return to_route('admin.countries.index')
            ->with('success', 'Страна успешно обновлена.');
    }

    public function destroy(Country $country): RedirectResponse
    {
        if ($country->products()->exists()) {
            return back()->with(
                'error',
                'Нельзя удалить страну, которая используется в товарах.',
            );
        }

        $country->delete();

        return to_route('admin.countries.index')
            ->with('success', 'Страна удалена.');
    }
}
