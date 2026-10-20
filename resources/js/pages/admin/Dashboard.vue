<script setup lang="ts">
import { Link } from '@inertiajs/vue3';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import {
    ArrowDownToLine,
    ArrowLeftRight,
    Boxes,
    ClipboardCheck,
    LayoutDashboard,
    Package,
    PackageMinus,
    PackagePlus,
    RotateCcw,
    Tags,
    History,
    Grid2X2,
    AlertTriangle,
    ArrowRight,
} from '@lucide/vue';

defineOptions({
    layout: AdminLayout,
});

interface StockByUnit {
    unit: string;
    quantity: string;
}

interface Statistics {
    products: number;
    categories: number;
    racks: number;
    locations: number;
    products_with_stock: number;
    stock_by_unit: StockByUnit[];
    products_below_minimum: number;
}

interface Movement {
    id: number;
    product_name: string;
    sku: string | null;
    type: string;
    type_label: string;
    quantity: number;
    from_location: string | null;
    from_rack: string | null;
    to_location: string | null;
    to_rack: string | null;
    comment: string | null;
    created_at: string | null;
}

interface Props {
    statistics: Statistics;
    movements: Movement[];
}

defineProps<Props>();

interface StatisticCard {
    key: Exclude<keyof Statistics, 'stock_by_unit'>;
    title: string;
    description: string;
    icon: typeof LayoutDashboard;
}

const statisticCards: StatisticCard[] = [
    {
        key: 'products',
        title: 'Товары',
        description: 'Активных товаров',
        icon: Package,
    },
    {
        key: 'categories',
        title: 'Категории',
        description: 'Активных категорий',
        icon: Tags,
    },
    {
        key: 'racks',
        title: 'Стеллажи',
        description: 'Всего стеллажей',
        icon: Grid2X2,
    },
    {
        key: 'locations',
        title: 'Места хранения',
        description: 'Всего мест',
        icon: Boxes,
    },
    {
        key: 'products_with_stock',
        title: 'Товары на складе',
        description: 'Позиций с ненулевым остатком',
        icon: Boxes,
    },
];

const quickActions = [
    {
        title: 'Добавить товар',
        description: 'Создать товар в каталоге',
        href: '/admin/products/create',
        icon: PackagePlus,
    },
    {
        title: 'Приход товара',
        description: 'Поступление на склад',
        href: '/admin/stock/receipt',
        icon: ArrowDownToLine,
    },
    {
        title: 'Перемещение',
        description: 'Переместить между ячейками',
        href: '/admin/stock/transfer',
        icon: ArrowLeftRight,
    },
    {
        title: 'Списание',
        description: 'Списать товар с остатка',
        href: '/admin/stock/write-off',
        icon: PackageMinus,
    },
    {
        title: 'Возврат',
        description: 'Оформить возврат товара',
        href: '/admin/stock/return',
        icon: RotateCcw,
    },
    {
        title: 'Инвентаризация',
        description: 'Сверить фактический остаток',
        href: '/admin/stock/inventory',
        icon: ClipboardCheck,
    },
];

function formatNumber(value: number | string): string {
    return Number(value).toLocaleString('ru-RU', {
        maximumFractionDigits: 3,
    });
}

function movementLocation(movement: Movement): string {
    if (movement.from_location && movement.to_location) {
        return `${movement.from_location} → ${movement.to_location}`;
    }

    if (movement.to_location) {
        return `→ ${movement.to_location}`;
    }

    if (movement.from_location) {
        return `${movement.from_location} → списание`;
    }

    return 'Место не указано';
}
</script>

<template>
    <div class="space-y-8">
        <header class="mb-8">
            <div class="mb-2 flex items-center gap-3">
                <div
                    class="flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-primary to-indigo-600 text-white shadow-lg"
                >
                    <LayoutDashboard :size="24" />
                </div>
                <div>
                    <h1
                        class="bg-gradient-to-r from-foreground to-muted-foreground bg-clip-text text-3xl font-bold text-transparent"
                    >
                        Обзор склада
                    </h1>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Основные показатели, операции и последние движения
                        товара.
                    </p>
                </div>
            </div>
        </header>

        <section>
            <div class="mb-6 flex items-center justify-between gap-4">
                <h2 class="text-xl font-semibold text-foreground">
                    Показатели склада
                </h2>

                <Link
                    href="/admin/stock"
                    class="inline-flex items-center gap-1 text-sm font-medium text-primary transition-colors hover:text-primary/80"
                >
                    Все остатки
                    <ArrowRight :size="16" />
                </Link>
            </div>

            <div
                class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5"
            >
                <div
                    v-for="card in statisticCards"
                    :key="card.key"
                    class="group relative overflow-hidden rounded-2xl border border-border/10 bg-gradient-to-br from-white to-muted/30 p-6 shadow-sm transition-all duration-300 hover:shadow-md"
                >
                    <div
                        class="absolute top-0 right-0 h-32 w-32 translate-x-1/2 -translate-y-1/2 rounded-full bg-gradient-to-br from-primary/5 to-indigo-500/5 transition-transform duration-500 group-hover:scale-110"
                    />
                    <div class="relative">
                        <div
                            class="mb-4 flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary/10 to-indigo-500/10 text-primary"
                        >
                            <component :is="card.icon" :size="20" />
                        </div>
                        <p class="text-sm font-medium text-muted-foreground">
                            {{ card.title }}
                        </p>

                        <p
                            class="mt-2 bg-gradient-to-r from-foreground to-muted-foreground bg-clip-text text-3xl font-bold text-transparent"
                        >
                            {{ formatNumber(statistics[card.key]) }}
                        </p>

                        <p class="mt-1 text-xs text-muted-foreground/70">
                            {{ card.description }}
                        </p>
                    </div>
                </div>
            </div>

            <div
                class="mt-6 rounded-2xl border border-border/10 bg-gradient-to-br from-white to-muted/30 p-6 shadow-sm"
            >
                <h3 class="mb-4 text-sm font-semibold text-foreground">
                    Остатки по единицам измерения
                </h3>

                <div
                    v-if="statistics.stock_by_unit.length === 0"
                    class="rounded-xl bg-muted/30 p-8 text-center"
                >
                    <div
                        class="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-muted/50"
                    >
                        <Package :size="24" class="text-muted-foreground/50" />
                    </div>
                    <p class="text-sm text-muted-foreground">
                        На складе пока нет учтённых остатков.
                    </p>
                </div>

                <div
                    v-else
                    class="grid gap-3 sm:grid-cols-2 lg:grid-cols-4 xl:grid-cols-5"
                >
                    <div
                        v-for="stock in statistics.stock_by_unit"
                        :key="stock.unit"
                        class="group relative overflow-hidden rounded-xl bg-gradient-to-br from-muted/50 to-muted/30 p-4 transition-all duration-300 hover:from-muted/60 hover:to-muted/40"
                    >
                        <div
                            class="absolute top-0 right-0 h-16 w-16 translate-x-1/2 -translate-y-1/2 rounded-full bg-gradient-to-br from-primary/5 to-indigo-500/5"
                        />
                        <p
                            class="relative text-sm font-medium text-muted-foreground"
                        >
                            {{ stock.unit }}
                        </p>

                        <p
                            class="relative mt-2 text-2xl font-bold text-foreground"
                        >
                            {{ formatNumber(stock.quantity) }}
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <Link
            v-if="statistics.products_below_minimum > 0"
            href="/admin/stock?stock=below_minimum"
            class="group relative flex items-center justify-between gap-4 overflow-hidden rounded-2xl border border-red-200/50 bg-gradient-to-r from-red-50 to-orange-50 p-6 shadow-sm transition-all duration-300 hover:shadow-md"
        >
            <div
                class="absolute inset-0 bg-gradient-to-r from-red-500/5 to-orange-500/5 opacity-0 transition-opacity duration-300 group-hover:opacity-100"
            />
            <div class="relative">
                <div class="mb-1 flex items-center gap-2">
                    <AlertTriangle :size="20" class="text-red-600" />
                    <h3 class="font-semibold text-red-800">
                        Товары ниже минимального остатка
                    </h3>
                </div>

                <p class="text-sm text-red-600/80">
                    Товары, требующие пополнения
                </p>

                <span
                    class="mt-3 inline-flex items-center gap-1 text-sm font-medium text-red-700 group-hover:underline"
                >
                    Посмотреть товары
                    <ArrowRight :size="16" />
                </span>
            </div>

            <div
                class="relative flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-red-500 to-orange-500 text-white shadow-lg"
            >
                <span class="text-2xl font-bold">
                    {{ formatNumber(statistics.products_below_minimum) }}
                </span>
            </div>
        </Link>

        <section>
            <h2 class="mb-6 text-xl font-semibold text-foreground">
                Быстрые действия
            </h2>

            <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                <Link
                    v-for="action in quickActions"
                    :key="action.href"
                    :href="action.href"
                    class="group relative flex items-start gap-4 overflow-hidden rounded-2xl border border-border/10 bg-gradient-to-br from-white to-muted/30 p-5 shadow-sm transition-all duration-300 hover:border-primary/20 hover:shadow-md"
                >
                    <div
                        class="absolute inset-0 bg-gradient-to-br from-primary/5 to-indigo-500/5 opacity-0 transition-opacity duration-300 group-hover:opacity-100"
                    />
                    <span
                        class="relative flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-primary/10 to-indigo-500/10 text-primary transition duration-300 group-hover:scale-110 group-hover:from-primary/20 group-hover:to-indigo-500/20"
                    >
                        <component :is="action.icon" :size="22" />
                    </span>

                    <span class="relative">
                        <span
                            class="block font-semibold text-foreground transition-colors group-hover:text-primary"
                        >
                            {{ action.title }}
                        </span>

                        <span class="mt-1 block text-sm text-muted-foreground">
                            {{ action.description }}
                        </span>
                    </span>
                </Link>
            </div>
        </section>

        <section
            class="overflow-hidden rounded-2xl border border-border/10 bg-gradient-to-br from-white to-muted/30 shadow-sm"
        >
            <div
                class="flex flex-wrap items-center justify-between gap-3 border-b border-border/10 bg-white/50 px-6 py-5"
            >
                <div>
                    <h2 class="text-lg font-semibold text-foreground">
                        Последние движения
                    </h2>

                    <p class="mt-1 text-sm text-muted-foreground">
                        Последние операции с товарами на складе.
                    </p>
                </div>

                <Link
                    href="/admin/stock/movements"
                    class="inline-flex items-center gap-1 text-sm font-medium text-primary transition-colors hover:text-primary/80"
                >
                    Вся история
                    <ArrowRight :size="16" />
                </Link>
            </div>

            <div v-if="movements.length === 0" class="px-6 py-16 text-center">
                <div
                    class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-muted/50"
                >
                    <History :size="32" class="text-muted-foreground/50" />
                </div>
                <p class="font-medium text-foreground">Движений пока нет</p>

                <p class="mt-1 text-sm text-muted-foreground">
                    После первой складской опер��ции она появится здесь.
                </p>
            </div>

            <div v-else>
                <!-- Карточки на мобильных -->
                <div class="space-y-2 p-3 md:hidden">
                    <div v-for="movement in movements" :key="movement.id" class="rounded-lg border border-border/50 bg-white p-3 shadow-sm dark:border-border dark:bg-card">
                        <div class="flex items-start justify-between gap-2">
                            <div class="min-w-0 flex-1">
                                <h3 class="font-semibold text-foreground break-words text-xs">{{ movement.product_name }}</h3>
                                <p class="mt-0.5 text-[10px] text-muted-foreground">{{ movement.created_at ?? '—' }}</p>
                            </div>
                            <span class="inline-flex items-center rounded-full bg-muted px-1.5 py-0.5 text-[10px] font-medium text-muted-foreground">{{ movement.type_label }}</span>
                        </div>
                        <div class="mt-2 grid grid-cols-2 gap-1.5 text-xs">
                            <div><p class="text-[10px] text-muted-foreground">Количество</p><p class="font-semibold text-foreground">{{ movement.quantity }}</p></div>
                            <div><p class="text-[10px] text-muted-foreground">Размещение</p><p class="text-foreground truncate text-[10px]">{{ movementLocation(movement) }}</p></div>
                        </div>
                    </div>
                </div>
                <div class="hidden overflow-x-auto md:block">
                    <table class="min-w-full divide-y divide-border/10">
                    <thead class="bg-muted/30">
                        <tr>
                            <th
                                class="px-6 py-4 text-left text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                            >
                                Дата
                            </th>

                            <th
                                class="px-6 py-4 text-left text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                            >
                                Товар
                            </th>

                            <th
                                class="px-6 py-4 text-left text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                            >
                                Операция
                            </th>

                            <th
                                class="px-6 py-4 text-left text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                            >
                                Количество
                            </th>

                            <th
                                class="px-6 py-4 text-left text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                            >
                                Размещение
                            </th>
                        </tr>
                    </thead>

                    <tbody class="divide-y divide-border/10">
                        <tr
                            v-for="movement in movements"
                            :key="movement.id"
                            class="transition-colors hover:bg-muted/30"
                        >
                            <td
                                class="px-6 py-4 text-sm whitespace-nowrap text-muted-foreground"
                            >
                                {{ movement.created_at ?? '—' }}
                            </td>

                            <td class="px-6 py-4">
                                <div class="font-medium text-foreground">
                                    {{ movement.product_name }}
                                </div>

                                <div class="mt-1 text-xs text-muted-foreground">
                                    Артикул: {{ movement.sku || '—' }}
                                </div>
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap">
                                <span
                                    class="inline-flex rounded-full border border-primary/20 bg-gradient-to-r from-primary/10 to-indigo-500/10 px-3 py-1.5 text-xs font-medium text-primary"
                                >
                                    {{ movement.type_label }}
                                </span>
                            </td>

                            <td
                                class="px-6 py-4 text-sm font-semibold whitespace-nowrap text-foreground"
                            >
                                {{ formatNumber(movement.quantity) }}
                            </td>

                            <td
                                class="px-6 py-4 text-sm whitespace-nowrap text-muted-foreground"
                            >
                                {{ movementLocation(movement) }}
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            </div>
        </section>
    </div>
</template>
