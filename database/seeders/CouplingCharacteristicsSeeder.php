<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Characteristic;
use Illuminate\Database\Seeder;

class CouplingCharacteristicsSeeder extends Seeder
{
    /**
     * Привязывает характеристику "Interlock" (boolean) к категории "Муфты".
     *
     * Seeder идемпотентен — его можно запускать многократно:
     * существующие связи не дублируются, характеристика создаётся
     * только если её ещё нет.
     */
    public function run(): void
    {
        $category = Category::query()
            ->where('slug', 'hoses')
            ->orWhere('name', 'Муфты')
            ->first();

        if (! $category) {
            $this->command?->warn('Категория "Муфты" не найдена — пропуск.');

            return;
        }

        $characteristic = Characteristic::query()->firstOrCreate(
            ['slug' => 'interlock'],
            [
                'name' => 'Interlock',
                'type' => 'boolean',
                'unit' => null,
                'is_active' => true,
            ],
        );

        $category->characteristics()->syncWithoutDetaching([
            $characteristic->id => [
                'is_required' => false,
                'sort_order' => 0,
            ],
        ]);

        $this->command?->info(
            "Характеристика \"{$characteristic->name}\" привязана к категории \"{$category->name}\".",
        );
    }
}
