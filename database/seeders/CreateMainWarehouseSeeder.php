<?php

namespace Database\Seeders;

use App\Models\Rack;
use App\Models\Warehouse;
use Illuminate\Database\Seeder;

class CreateMainWarehouseSeeder extends Seeder
{
    public function run(): void
    {
        $mainWarehouse = Warehouse::query()->firstOrCreate(
            ['name' => 'Большой склад'],
            ['name' => 'Большой склад']
        );

        Rack::query()->whereNull('warehouse_id')->update([
            'warehouse_id' => $mainWarehouse->id,
        ]);

        $this->command->info('Большой склад создан, существующие стеллажи обновлены.');
    }
}
