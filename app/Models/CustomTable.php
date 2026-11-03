<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CustomTable extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'description',
        'columns',
    ];

    protected function casts(): array
    {
        return [
            'columns' => 'array',
        ];
    }

    public function entries(): HasMany
    {
        return $this->hasMany(CustomTableEntry::class);
    }

    /**
     * @return array<int, array{key: string, name: string, type: string}>
     */
    public function columnList(): array
    {
        $columns = $this->columns ?? [];

        return array_values(array_filter(
            array_map(
                fn (array $column): array => [
                    'key' => (string) ($column['key'] ?? ''),
                    'name' => (string) ($column['name'] ?? $column['key'] ?? ''),
                    'type' => (string) ($column['type'] ?? 'string'),
                ],
                is_array($columns) ? $columns : [],
            ),
            fn (array $column): bool => $column['key'] !== '',
        ));
    }

    public function columnKeys(): array
    {
        return array_map(
            fn (array $column): string => $column['key'],
            $this->columnList(),
        );
    }
}