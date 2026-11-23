<?php

namespace Database\Seeders;

use App\Models\SiteSetting;
use Illuminate\Database\Seeder;

class SiteSettingSeeder extends Seeder
{
    public function run(): void
    {
        SiteSetting::query()->firstOrCreate([], [
            'organization_name' => 'ООО «Гидровик РВД»',
            'inn' => null,
            'phone' => null,
            'email' => null,
            'city' => null,
            'address' => null,
        ]);
    }
}
