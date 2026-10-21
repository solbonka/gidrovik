<?php

namespace App\Enums;

enum UserRole: string
{
    case ADMIN = 'admin';
    case MANAGER = 'manager';
    case WAREHOUSE = 'warehouse';
    case VIEWER = 'viewer';

    public function label(): string
    {
        return match ($this) {
            self::ADMIN => 'Администратор',
            self::MANAGER => 'Менеджер склада',
            self::WAREHOUSE => 'Кладовщик',
            self::VIEWER => 'Наблюдатель',
        };
    }

    public function description(): string
    {
        return match ($this) {
            self::ADMIN => 'Полный доступ ко всем разделам, справочникам и пользователям.',
            self::MANAGER => 'Управление каталогом и складскими операциями без доступа к пользователям.',
            self::WAREHOUSE => 'Приём, перемещение, списание, возврат и инвентаризация товара.',
            self::VIEWER => 'Просмотр остатков, товаров и истории движений без изменений.',
        };
    }

    /**
     * @return array<int, Permission>
     */
    public function permissions(): array
    {
        return match ($this) {
            self::ADMIN => Permission::cases(),
            self::MANAGER => [
                Permission::VIEW,
                Permission::CATALOG_MANAGE,
                Permission::STOCK_OPERATE,
                Permission::STOCK_CORRECT,
            ],
            self::WAREHOUSE => [
                Permission::VIEW,
                Permission::STOCK_OPERATE,
            ],
            self::VIEWER => [
                Permission::VIEW,
            ],
        };
    }
}
