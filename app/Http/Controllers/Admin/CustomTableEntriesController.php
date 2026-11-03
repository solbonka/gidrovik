<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreCustomTableEntryRequest;
use App\Http\Requests\Admin\UpdateCustomTableEntryRequest;
use App\Models\CustomTable;
use App\Models\CustomTableEntry;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class CustomTableEntriesController extends Controller
{
    /**
     * Показать форму добавления строки в таблицу.
     */
    public function create(CustomTable $customTable): Response
    {
        return Inertia::render('admin/custom-tables/EntryForm', [
            'table' => [
                'id' => $customTable->id,
                'name' => $customTable->name,
                'columns' => $customTable->columnList(),
            ],
            'mode' => 'create',
        ]);
    }

    /**
     * Создать строку в таблице.
     */
    public function store(
        StoreCustomTableEntryRequest $request,
        CustomTable $customTable,
    ): RedirectResponse {
        // validated() returns flat key=>value for each column
        $data = $request->validated();

        CustomTableEntry::query()->create([
            'custom_table_id' => $customTable->id,
            'data' => $data,
        ]);

        return to_route('admin.custom-tables.show', $customTable)
            ->with('success', 'Строка успешно добавлена.');
    }

    /**
     * Показать форму редактирования строки.
     */
    public function edit(
        CustomTable $customTable,
        CustomTableEntry $entry,
    ): Response {
        return Inertia::render('admin/custom-tables/EntryForm', [
            'table' => [
                'id' => $customTable->id,
                'name' => $customTable->name,
                'columns' => $customTable->columnList(),
            ],
            'entry' => [
                'id' => $entry->id,
                'data' => $entry->data,
            ],
            'mode' => 'edit',
        ]);
    }

    /**
     * Обновить строку.
     */
    public function update(
        UpdateCustomTableEntryRequest $request,
        CustomTable $customTable,
        CustomTableEntry $entry,
    ): RedirectResponse {
        // validated() returns flat key=>value, wrap in 'data' key
        $validated = $request->validated();
        $data = is_array($validated) ? $validated : [];

        $entry->update([
            'data' => $data,
        ]);

        return to_route('admin.custom-tables.show', $customTable)
            ->with('success', 'Строка успешно обновлена.');
    }

    /**
     * Удалить строку.
     */
    public function destroy(
        CustomTable $customTable,
        CustomTableEntry $entry,
    ): \Illuminate\Http\RedirectResponse {
        $entry->delete();

        return to_route('admin.custom-tables.show', $customTable)
            ->with('success', 'Строка удалена.');
    }

    /**
     * AJAX-поиск строк для селектов/фильтров.
     */
    public function search(
        CustomTable $customTable,
        Request $request,
    ): JsonResponse {
        $query = (string) $request->input('q', '');
        $limit = (int) $request->input('limit', 10);

        $entries = $customTable->entries()
            ->when($query, function ($q) use ($customTable, $query) {
                $keys = $customTable->columnKeys();

                $q->where(function ($inner) use ($keys, $query) {
                    foreach ($keys as $key) {
                        $inner->orWhereJsonLike("data->{$key}", "%{$query}%");
                    }
                });
            })
            ->limit($limit)
            ->get()
            ->map(function (CustomTableEntry $entry) use ($customTable) {
                $label = $customTable->columnList();

                $first = null;

                foreach ($customTable->columnList() as $column) {
                    $value = $entry->data[$column['key']] ?? null;

                    if ($value !== null && $value !== '') {
                        $first = (string) $value;
                        break;
                    }
                }

                return [
                    'id' => $entry->id,
                    'label' => $first ?? ('#' . $entry->id),
                ];
            });

        return response()->json($entries);
    }
}
