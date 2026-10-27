<?php

namespace App\Enums;

enum Permission: string
{
    case VIEW = 'view';
    case CATALOG_MANAGE = 'catalog.manage';
    case STOCK_OPERATE = 'stock.operate';
    case STOCK_CORRECT = 'stock.correct';
    case USERS_MANAGE = 'users.manage';
    case ORDERS_MANAGE = 'orders.manage';

    public function label(): string
    {
        return match ($this) {
            self::VIEW => 'Просмотр',
            self::CATALOG_MANAGE => 'Управление каталогом',
            self::STOCK_OPERATE => 'Складские операции',
            self::STOCK_CORRECT => 'Корректировка движений',
            self::USERS_MANAGE => 'Управление пользователями',
            self::ORDERS_MANAGE => 'Управление заказами',
        };
    }
}
