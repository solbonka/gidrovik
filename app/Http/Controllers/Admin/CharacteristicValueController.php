<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Characteristic;
use App\Models\CharacteristicValue;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class CharacteristicValueController extends Controller
{
    public function index(Characteristic $characteristic): Response
    {
        $characteristic->loadMissing(['categories']);

        $values = $characteristic
            ->values()
            ->orderBy('sort_order')
            ->orderBy('value')
            ->get();

        return Inertia::render('admin/characteristics/Values', [
            'characteristic' => $characteristic,
            'values' => $values,
        ]);
    }

    public function store(
        Request $request,
        Characteristic $characteristic,
    ): RedirectResponse {
        $validated = $request->validate([
            'value' => [
                'required',
                'string',
                'max:255',
                // @phpstan-ignore-next-line
                \Illuminate\Validation\Rule::unique('characteristic_values')->where(function ($query) use ($characteristic) {
                    return $query->where('characteristic_id', $characteristic->id);
                }),
            ],
        ]);

        $maxOrder = CharacteristicValue::where('characteristic_id', $characteristic->id)->max('sort_order') ?? 0;

        CharacteristicValue::create([
            'characteristic_id' => $characteristic->id,
            'value' => $validated['value'],
            'sort_order' => $maxOrder + 1,
        ]);

        return back()->with('success', 'Значение добавлено.');
    }

    public function update(
        Request $request,
        Characteristic $characteristic,
        CharacteristicValue $value,
    ): RedirectResponse {
        $this->ensureBelongsToCharacteristic($value, $characteristic);

        $validated = $request->validate([
            'value' => [
                'required',
                'string',
                'max:255',
                // @phpstan-ignore-next-line
                \Illuminate\Validation\Rule::unique('characteristic_values')->where(function ($query) use ($characteristic, $value) {
                    return $query->where('characteristic_id', $characteristic->id)->where('id', '!=', $value->id);
                }),
            ],
        ]);

        $value->update($validated);

        return back()->with('success', 'Значение обновлено.');
    }

    public function destroy(
        Request $request,
        Characteristic $characteristic,
        CharacteristicValue $value,
    ): RedirectResponse {
        $this->ensureBelongsToCharacteristic($value, $characteristic);

        $value->delete();

        return back()->with('success', 'Значение удалено.');
    }

    public function reorder(Request $request, Characteristic $characteristic): RedirectResponse
    {
        $validated = $request->validate([
            'values' => 'required|array|min:1',
            'values.*.id' => 'required|integer|exists:characteristic_values,id',
            'values.*.sort_order' => 'required|integer|min:0',
        ]);

        // Verify all values belong to the characteristic
        $ids = collect($validated['values'])->pluck('id')->toArray();
        $count = CharacteristicValue::whereIn('id', $ids)
            ->where('characteristic_id', $characteristic->id)
            ->count();

        if ($count !== count($ids)) {
            return back()->withErrors(['values' => 'Некоторые значения не найдены.']);
        }

        CharacteristicValue::whereIn('id', $ids)->each(function ($value) use ($validated) {
            $item = collect($validated['values'])->firstWhere('id', $value->id);
            if ($item) {
                $value->update(['sort_order' => $item['sort_order']]);
            }
        });

        return back()->with('success', 'Порядок обновлён.');
    }

    private function ensureBelongsToCharacteristic(CharacteristicValue $value, Characteristic $characteristic): void
    {
        if ($value->characteristic_id !== $characteristic->id) {
            abort(403, 'Значение не принадлежит этой характеристике.');
        }
    }
}
