<?php

namespace Database\Seeders;

use App\Models\Warehouse;
use Illuminate\Database\Seeder;

class CreateSleevesWarehouseSeeder extends Seeder
{
    public function run(): void
    {
        Warehouse::query()->firstOrCreate(
            ['name' => 'Рукава'],
            ['name' => 'Рукава']
        );

        $this->command->info('Склад "Рукава" создан.');
    }
}
