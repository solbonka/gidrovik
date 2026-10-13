<?php

namespace App\Services\Admin;

use App\Models\Location;
use App\Models\Rack;

class LocationService
{
    public function create(Rack $rack, array $data): Location
    {
        return $rack->locations()->create([
            'number' => (int) $data['number'],
        ]);
    }

    public function update(
        Location $location,
        array $data,
    ): Location {
        $location->update([
            'number' => (int) $data['number'],
        ]);

        return $location->fresh('rack');
    }

    public function delete(Location $location): void
    {
        $location->delete();
    }
}
