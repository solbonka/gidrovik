<?php

namespace App\Enums;

enum StockMovementType: string
{
    case RECEIPT = 'receipt';
    case TRANSFER = 'transfer';
    case WRITE_OFF = 'write_off';
    case RETURN = 'return';
    case INVENTORY = 'inventory';

    public function label(): string
    {
        return match ($this) {
            self::RECEIPT => 'Поступление',
            self::TRANSFER => 'Перемещение',
            self::WRITE_OFF => 'Списание',
            self::RETURN => 'Возврат',
            self::INVENTORY => 'Корректировка инвентаризации',
        };
    }
}
