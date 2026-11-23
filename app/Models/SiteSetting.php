<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SiteSetting extends Model
{
    protected $fillable = [
        'organization_name',
        'inn',
        'phone',
        'email',
        'city',
        'address',
        'latitude',
        'longitude',
    ];

    public static function current(): self
    {
        return static::query()->first() ?? new static;
    }

    public function phoneHref(): ?string
    {
        if (! $this->phone) {
            return null;
        }

        $digits = preg_replace('/[^\d+]/', '', $this->phone);

        return $digits !== '' ? 'tel:'.$digits : null;
    }

    public function locationLabel(): ?string
    {
        $parts = array_filter([
            $this->city ? 'г. '.$this->city : null,
            $this->address,
        ]);

        return $parts !== [] ? implode(', ', $parts) : null;
    }
}
