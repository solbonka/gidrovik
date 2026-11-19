<?php

namespace App\Enums;

enum SegmentMovementType: string
{
    case RECEIPT = 'receipt';
    case TRANSFER = 'transfer';
    case WRITE_OFF = 'write_off';
    case RETURN = 'return';
    case INVENTORY = 'inventory';
    case SPLIT = 'split';
    case RESERVE = 'reserve';
    case RELEASE = 'release';
    case CONSUME = 'consume';
    case SCRAP = 'scrap';

    public function label(): string
    {
        return match ($this) {
            self::RECEIPT => 'Поступление',
            self::TRANSFER => 'Перемещение',
            self::WRITE_OFF => 'Списание',
            self::RETURN => 'Возврат',
            self::INVENTORY => 'Корректировка инвентаризации',
            self::SPLIT => 'Отрезание',
            self::RESERVE => 'Резервирование',
            self::RELEASE => 'Снятие резерва',
            self::CONSUME => 'Продажа / использование',
            self::SCRAP => 'Списание отхода',
        };
    }
}
