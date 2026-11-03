<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreCustomTableRequest;
use App\Http\Requests\Admin\UpdateCustomTableRequest;
use App\Models\CustomTable;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\StreamedResponse;
use Symfony\Component\HttpFoundation\StreamedResponse as SymfonyStreamedResponse;
use Inertia\Inertia;
use Inertia\Response;

class CustomTablesController extends Controller
{
    public function index(Request $request): Response
    {
        $tables = CustomTable::query()
            ->withCount("entries")
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return Inertia::render("admin/custom-tables/Index", [
            "tables" => $tables,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render("admin/custom-tables/Create");
    }

    public function store(StoreCustomTableRequest $request): RedirectResponse
    {
        CustomTable::query()->create($request->validated());

        return to_route("admin.custom-tables.index")
            ->with("success", "Таблица успешно создана.");
    }

    public function edit(CustomTable $customTable): Response
    {
        return Inertia::render("admin/custom-tables/Edit", [
            "table" => [
                "id" => $customTable->id,
                "name" => $customTable->name,
                "slug" => $customTable->slug,
                "description" => $customTable->description,
                "columns" => $customTable->columnList(),
            ],
        ]);
    }

    public function update(
        UpdateCustomTableRequest $request,
        CustomTable $customTable,
    ): RedirectResponse {
        $customTable->update($request->validated());

        return to_route("admin.custom-tables.index")
            ->with("success", "Таблица успешно обновлена.");
    }

    public function destroy(CustomTable $customTable): RedirectResponse
    {
        $customTable->delete();

        return to_route("admin.custom-tables.index")
            ->with("success", "Таблица удалена.");
    }

    public function show(CustomTable $customTable, Request $request): Response
    {
        $search = (string) $request->input("search", "");
        $per_page = (int) $request->input("per_page", 20);
        $per_page = max(1, min($per_page, 100));

        $entries = $customTable->entries()
            ->when($search, function ($query) use ($customTable, $search) {
                $keys = $customTable->columnKeys();

                $query->where(function ($q) use ($keys, $search) {
                    foreach ($keys as $key) {
                        $q->orWhereJsonLike("data->{$key}", "%{$search}%");
                    }
                });
            })
            ->latest()
            ->paginate($per_page)
            ->withQueryString();

        // Build pagination links array manually
        $links = [];
        if ($entries->hasPages()) {
            for ($i = 1; $i <= $entries->lastPage(); $i++) {
                $links[] = [
                    "url" => $i === $entries->currentPage() ? null : $entries->url($i),
                    "label" => (string) $i,
                    "active" => $i === $entries->currentPage(),
                ];
            }
        }

        return Inertia::render("admin/custom-tables/Show", [
            "table" => [
                "id" => $customTable->id,
                "name" => $customTable->name,
                "slug" => $customTable->slug,
                "description" => $customTable->description,
                "columns" => $customTable->columnList(),
            ],
            "entries" => [
                "data" => $entries->map(fn ($e) => [
                    "id" => $e->id,
                    "data" => $e->data,
                    "created_at" => $e->created_at?->toISOString() ?? null,
                    "updated_at" => $e->updated_at?->toISOString() ?? null,
                ]),
                "current_page" => $entries->currentPage(),
                "last_page" => $entries->lastPage(),
                "from" => $entries->firstItem(),
                "to" => $entries->lastItem(),
                "total" => $entries->total(),
                "links" => $links,
            ],
            "filters" => [
                "search" => $search,
                "per_page" => $per_page,
            ],
        ]);
    }

    public function exportCsv(CustomTable $customTable): SymfonyStreamedResponse
    {
        $columns = $customTable->columnList();
        $headers = array_map(
            fn (array $column): string => $column["name"] ?: $column["key"],
            $columns,
        );

        $filename = $customTable->slug . "_" . now()->format("Y-m-d") . ".csv";

        return response()->stream(function () use ($customTable, $columns, $headers) {
            echo "\xEF\xBB\xBF";

            $handle = fopen("php://output", "w");

            fputcsv($handle, $headers, separator: ";");

            $customTable->entries()->chunk(500, function ($entries) use ($handle, $columns) {
                foreach ($entries as $entry) {
                    $row = [];

                    foreach ($columns as $column) {
                        $row[] = $this->formatValue(
                            $entry->data[$column["key"]] ?? null,
                            $column["type"],
                        );
                    }

                    fputcsv($handle, $row, separator: ";");
                }
            });

            fclose($handle);
        }, 200, [
            "Content-Type" => "text/csv; charset=UTF-8",
            "Content-Disposition" => "attachment; filename=\"" . $filename . "\"",
            "Cache-Control" => "no-store, no-cache, must-validate",
        ]);
    }

    public function exportHtml(CustomTable $customTable): \Illuminate\Http\Response
    {
        $columns = $customTable->columnList();
        $rows = $customTable->entries()->get();

        $html = view("admin.custom-tables.export", [
            "table" => $customTable,
            "columns" => $columns,
            "rows" => $rows,
        ])->render();

        return response($html, 200, [
            "Content-Type" => "application/vnd.ms-excel; charset=UTF-8",
            "Content-Disposition" => "attachment; filename=\"" . $customTable->slug . "_" . now()->format("Y-m-d") . ".xls\"",
            "Cache-Control" => "no-store, no-cache, must-validate",
        ]);
    }

    private function formatValue(mixed $value, string $type): string
    {
        if ($value === null) {
            return "";
        }

        return match ($type) {
            "boolean" => (bool) $value ? "да" : "нет",
            "integer" => (string) (int) $value,
            "decimal" => (string) $value,
            "date" => $value instanceof \DateTimeInterface
                ? $value->format("Y-m-d")
                : (string) $value,
            default => (string) $value,
        };
    }
}
