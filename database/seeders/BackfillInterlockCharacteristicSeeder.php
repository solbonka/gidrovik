<?php

namespace Database\Seeders;

use App\Models\Characteristic;
use App\Models\Product;
use App\Models\ProductCharacteristicValue;
use Illuminate\Database\Seeder;

class BackfillInterlockCharacteristicSeeder extends Seeder
{
    /**
     * Proставляет характеристику "Interlock" всем товарам, в названии
     * которых есть "Interlock" или "Интерлок", если она ещё не указана.
     *
     * Седер идемпотентен — существующие значения не дублируются.
     */
    public function run(): void
    {
        $characteristic = Characteristic::query()
            ->where('slug', 'interlock')
            ->first();

        if (! $characteristic) {
            $this->command?->warn('Характеристика "Interlock" не найдена — пропуск.');

            return;
        }

        $products = Product::query()
            ->whereRaw("name ILIKE '%interlock%' OR name ILIKE '%интерлок%'")
            ->whereDoesntHave('characteristicValues', function ($q) use ($characteristic) {
                $q->where('characteristic_id', $characteristic->id);
            })
            ->get();

        $count = 0;

        foreach ($products as $product) {
            ProductCharacteristicValue::create([
                'product_id' => $product->id,
                'characteristic_id' => $characteristic->id,
                'value' => '1',
            ]);

            $count++;
        }

        $this->command?->info(
            "Характеристика \"{$characteristic->name}\" проставлена {$count} товарам."
        );
    }
}
