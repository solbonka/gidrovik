<?php

namespace App\Enums;

enum StockMode: string
{
    case QUANTITY = 'quantity';
    case LENGTH = 'length';

    public function label(): string
    {
        return match ($this) {
            self::QUANTITY => 'По количеству',
            self::LENGTH => 'По отрезкам (мерный)',
        };
    }
}
