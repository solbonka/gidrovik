<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreCharacteristicRequest;
use App\Http\Requests\Admin\UpdateCharacteristicRequest;
use App\Models\Characteristic;
use App\Models\ProductCharacteristicValue;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Log;
use Inertia\Inertia;
use Inertia\Response;

class CharacteristicController extends Controller
{
    public function index(): Response
    {
        $characteristics = Characteristic::query()
            ->withCount('categories')
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('admin/characteristics/Index', [
            'characteristics' => $characteristics,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('admin/characteristics/Create');
    }

    public function store(
        StoreCharacteristicRequest $request,
    ): RedirectResponse {
        $data = $request->validated();
        $characteristic = Characteristic::query()->create($data);

        if ($data['type'] === 'select' && $request->has('values')) {
            $values = $request->input('values', []);
            foreach ($values as $i => $value) {
                if (trim($value)) {
                    $characteristic->values()->create([
                        'value' => trim($value),
                        'sort_order' => $i + 1,
                    ]);
                }
            }
        }

        return to_route('admin.characteristics.index')
            ->with('success', 'Характеристика успешно создана.');
    }

    public function edit(Characteristic $characteristic): Response
    {
        return Inertia::render('admin/characteristics/Edit', [
            'characteristic' => $characteristic->load('values'),
        ]);
    }

    public function update(
        UpdateCharacteristicRequest $request,
        Characteristic $characteristic,
    ): RedirectResponse {
        $data = $request->validated();
        $characteristic->update($data);

        if ($data['type'] === 'select') {
            $characteristic->values()->delete();
            $values = $request->input('values', []);
            Log::info('Saving characteristic values', ['id' => $characteristic->id, 'values' => $values]);
            foreach ($values as $i => $value) {
                if (trim($value)) {
                    $characteristic->values()->create([
                        'value' => trim($value),
                        'sort_order' => $i + 1,
                    ]);
                }
            }
        } else {
            $characteristic->values()->delete();
        }

        return to_route('admin.characteristics.index')
            ->with('success', 'Характеристика успешно обновлена.');
    }

    public function destroy(
        Characteristic $characteristic,
    ): RedirectResponse {
        if ($characteristic->categories()->exists()) {
            return to_route('admin.characteristics.index')
                ->withErrors([
                    'delete' => 'Нельзя удалить характеристику, которая назначена категориям. Сначала отвяжите её от категорий.',
                ]);
        }

        if (ProductCharacteristicValue::query()
            ->where('characteristic_id', $characteristic->id)
            ->exists()) {
            return to_route('admin.characteristics.index')
                ->withErrors([
                    'delete' => 'Нельзя удалить характеристику, которая используется товарами. Сначала удалите её значения у товаров.',
                ]);
        }

        $characteristic->delete();

        return to_route('admin.characteristics.index')
            ->with('success', 'Характеристика удалена.');
    }
}
