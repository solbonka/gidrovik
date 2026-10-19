<?php

namespace App\Enums;

enum UnitType: string
{
    case PIECE = 'шт.';
    case PACKAGE = 'упаковка';
    case KIT = 'комплект';
    case METER = 'м';
    case LITER = 'л';

    public function isInteger(): bool
    {
        return in_array($this, [self::PIECE, self::PACKAGE, self::KIT], true);
    }

    public function isDecimal(): bool
    {
        return in_array($this, [self::METER, self::LITER], true);
    }

    public static function getAllInteger(): array
    {
        return [
            self::PIECE->value,
            self::PACKAGE->value,
            self::KIT->value,
        ];
    }

    public static function getAllDecimal(): array
    {
        return [
            self::METER->value,
            self::LITER->value,
        ];
    }

    public static function getAll(): array
    {
        return [
            ...self::getAllInteger(),
            ...self::getAllDecimal(),
        ];
    }

    public static function isValid(string $unit): bool
    {
        return in_array($unit, self::getAll(), true);
    }
}
