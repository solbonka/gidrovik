<?php

namespace App\Services\Admin;

use App\Models\Rack;
use Illuminate\Support\Facades\DB;

class RackService
{
    public function create(array $data): Rack
    {
        return Rack::query()->create([
            'code' => strtoupper(trim($data['code'])),
            'name' => $data['name'] ?? null,
            'warehouse_id' => $data['warehouse_id'],
        ]);
    }

    public function update(Rack $rack, array $data): Rack
    {
        $rack->update([
            'code' => strtoupper(trim($data['code'])),
            'name' => $data['name'] ?? null,
            'warehouse_id' => $data['warehouse_id'],
        ]);

        return $rack->fresh();
    }

    public function delete(Rack $rack): void
    {
        DB::transaction(function () use ($rack): void {
            $rack->locations()->delete();
            $rack->delete();
        });
    }
}
