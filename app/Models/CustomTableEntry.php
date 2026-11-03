<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomTableEntry extends Model
{
    protected $fillable = [
        "custom_table_id",
        "data",
    ];

    protected function casts(): array
    {
        return [
            "data" => "array",
        ];
    }

    public function customTable(): BelongsTo
    {
        return $this->belongsTo(CustomTable::class);
    }

    public function resolveRouteBinding($value, $field = null)
    {
        return static::where("id", $value)->firstOrFail();
    }
}
