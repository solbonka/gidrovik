<?php

namespace App\Enums;

use Illuminate\Support\Facades\DB;

enum OrderStatus: string
{
    case New = 'new';
    case Confirmed = 'confirmed';
    case Picking = 'picking';
    case Ready = 'ready';
    case Shipped = 'shipped';
    case Completed = 'completed';
    case Cancelled = 'cancelled';

    public function label(): string
    {
        return match ($this) {
            self::New => 'Новый',
            self::Confirmed => 'Подтверждён',
            self::Picking => 'Комплектуется',
            self::Ready => 'Готов к выдаче',
            self::Shipped => 'Передан в доставку',
            self::Completed => 'Выполнен',
            self::Cancelled => 'Отменён',
        };
    }

    public function color(): string
    {
        return match ($this) {
            self::New => 'bg-blue-100 text-blue-800',
            self::Confirmed => 'bg-emerald-100 text-emerald-800',
            self::Picking => 'bg-amber-100 text-amber-800',
            self::Ready => 'bg-cyan-100 text-cyan-800',
            self::Shipped => 'bg-purple-100 text-purple-800',
            self::Completed => 'bg-emerald-100 text-emerald-800',
            self::Cancelled => 'bg-rose-100 text-rose-800',
        };
    }

    public function isFinal(): bool
    {
        return in_array($this, [self::Completed, self::Cancelled]);
    }
}
