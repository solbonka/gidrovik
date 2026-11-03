<?php

namespace App\Services\Admin;

use App\Models\Warehouse;
use Illuminate\Support\Facades\DB;

class WarehouseService
{
    public function create(array $data): Warehouse
    {
        return Warehouse::query()->create([
            'name' => $data['name'],
        ]);
    }

    public function update(Warehouse $warehouse, array $data): Warehouse
    {
        $warehouse->update([
            'name' => $data['name'],
        ]);

        return $warehouse->fresh();
    }

    public function delete(Warehouse $warehouse): void
    {
        DB::transaction(function () use ($warehouse): void {
            $warehouse->racks()->delete();
            $warehouse->delete();
        });
    }
}
