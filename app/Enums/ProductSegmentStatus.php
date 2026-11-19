<?php

namespace App\Enums;

enum ProductSegmentStatus: string
{
    case AVAILABLE = 'available';
    case RESERVED = 'reserved';
    case CONSUMED = 'consumed';
    case SCRAPPED = 'scrapped';
    case QUARANTINED = 'quarantined';

    public function label(): string
    {
        return match ($this) {
            self::AVAILABLE => 'Доступен',
            self::RESERVED => 'Зарезервирован',
            self::CONSUMED => 'Использован',
            self::SCRAPPED => 'Списан',
            self::QUARANTINED => 'Карантин',
        };
    }

    /**
     * Статусы, которые учитываются в агрегированном остатке product_location.
     *
     * @return list<self>
     */
    public static function stockCounting(): array
    {
        return [self::AVAILABLE, self::RESERVED, self::QUARANTINED];
    }

    public function countsInStock(): bool
    {
        return in_array($this, self::stockCounting(), true);
    }
}
