<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import type { Component } from 'vue';
import { computed } from 'vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { Button } from '@/components/ui/button';
import {
    AlertTriangle,
    ArrowDownToLine,
    ArrowLeftRight,
    ArrowRight,
    ArrowUpFromLine,
    Boxes,
    Building2,
    ClipboardCheck,
    Grid2X2,
    History,
    LayoutDashboard,
    MapPin,
    Package,
    PackageMinus,
    PackagePlus,
    RotateCcw,
    Tags,
    Undo2,
    Warehouse,
} from '@lucide/vue';

defineOptions({
    layout: AdminLayout,
});

interface Statistics {
    products: number;
    categories: number;
    warehouses: number;
    racks: number;
    locations: number;
    products_with_stock: number;
    products_below_minimum: number;
}

interface Movement {
    id: number;
    product_name: string;
    sku: string | null;
    type: string;
    type_label: string;
    quantity: number | string;
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

const props = defineProps<Props>();

/* ---------- Форматирование ---------- */

const numberFormat = new Intl.NumberFormat('ru-RU', {
    maximumFractionDigits: 3,
});

function formatNumber(value: number | string | null | undefined): string {
    if (value === null || value === undefined || value === '') return '—';

    const number = Number(value);

    return Number.isNaN(number) ? String(value) : numberFormat.format(number);
}

/* ---------- Карточки показателей ---------- */

interface StatisticCard {
    key: 'products' | 'categories' | 'warehouses' | 'racks' | 'locations';
    title: string;
    description: string;
    icon: Component;
    tone: string;
    href: string;
}

const statisticCards: StatisticCard[] = [
    {
        key: 'products',
        title: 'Товары',
        description: 'Активных в каталоге',
        icon: Package,
        tone: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400',
        href: '/admin/products',
    },
    {
        key: 'categories',
        title: 'Категории',
        description: 'Активных категорий',
        icon: Tags,
        tone: 'bg-violet-500/10 text-violet-600 dark:text-violet-400',
        href: '/admin/categories',
    },
    {
        key: 'warehouses',
        title: 'Склады',
        description: 'Всего складов',
        icon: Building2,
        tone: 'bg-blue-500/10 text-blue-600 dark:text-blue-400',
        href: '/admin/warehouses',
    },
    {
        key: 'racks',
        title: 'Стеллажи',
        description: 'Всего стеллажей',
        icon: Grid2X2,
        tone: 'bg-sky-500/10 text-sky-600 dark:text-sky-400',
        href: '/admin/racks',
    },
    {
        key: 'locations',
        title: 'Места хранения',
        description: 'Всего ячеек',
        icon: Boxes,
        tone: 'bg-amber-500/10 text-amber-600 dark:text-amber-400',
        href: '/admin/locations',
    },
];

const stockCoverage = computed(() => {
    const { products, products_with_stock } = props.statistics;

    if (!products) return 0;

    return Math.min(100, Math.round((products_with_stock / products) * 100));
});

/* ---------- Быстрые действия ---------- */

const quickActions = [
    {
        title: 'Добавить товар',
        description: 'Создать товар в каталоге',
        href: '/admin/products/create',
        icon: PackagePlus,
        tone: 'bg-primary/10 text-primary',
    },
    {
        title: 'Добавить склад',
        description: 'Создать новый склад',
        href: '/admin/warehouses/create',
        icon: Building2,
        tone: 'bg-blue-500/10 text-blue-600 dark:text-blue-400',
    },
    {
        title: 'Приход товара',
        description: 'Поступление на склад',
        href: '/admin/stock/receipt',
        icon: ArrowDownToLine,
        tone: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400',
    },
    {
        title: 'Перемещение',
        description: 'Между ячейками и стеллажами',
        href: '/admin/stock/transfer',
        icon: ArrowLeftRight,
        tone: 'bg-sky-500/10 text-sky-600 dark:text-sky-400',
    },
    {
        title: 'Списание',
        description: 'Списать товар с остатка',
        href: '/admin/stock/write-off',
        icon: PackageMinus,
        tone: 'bg-rose-500/10 text-rose-600 dark:text-rose-400',
    },
    {
        title: 'Возврат',
        description: 'Оформить возврат товара',
        href: '/admin/stock/return',
        icon: RotateCcw,
        tone: 'bg-violet-500/10 text-violet-600 dark:text-violet-400',
    },
    {
        title: 'Инвентаризация',
        description: 'Сверить фактический остаток',
        href: '/admin/stock/inventory',
        icon: ClipboardCheck,
        tone: 'bg-amber-500/10 text-amber-600 dark:text-amber-400',
    },
];

/* ---------- Движения ---------- */

type MovementKind = 'receipt' | 'transfer' | 'writeoff' | 'return' | 'other';

const movementStyles: Record<
    MovementKind,
    { tone: string; icon: Component }
> = {
    receipt: {
        tone: 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400',
        icon: ArrowDownToLine,
    },
    transfer: {
        tone: 'bg-sky-500/10 text-sky-700 ring-sky-600/20 dark:text-sky-400',
        icon: ArrowLeftRight,
    },
    writeoff: {
        tone: 'bg-rose-500/10 text-rose-700 ring-rose-600/20 dark:text-rose-400',
        icon: ArrowUpFromLine,
    },
    return: {
        tone: 'bg-violet-500/10 text-violet-700 ring-violet-600/20 dark:text-violet-400',
        icon: Undo2,
    },
    other: {
        tone: 'bg-muted text-muted-foreground ring-border',
        icon: ArrowLeftRight,
    },
};

function movementKind(movement: Movement): MovementKind {
    const text = `${movement.type} ${movement.type_label}`.toLowerCase();

    if (/receipt|income|приход|поступ/.test(text)) return 'receipt';
    if (/transfer|перемещ/.test(text)) return 'transfer';
    if (/write|issue|спис|расход/.test(text)) return 'writeoff';
    if (/return|возврат/.test(text)) return 'return';

    return 'other';
}

const style = (movement: Movement) => movementStyles[movementKind(movement)];

function place(rack: string | null, location: string | null): string | null {
    const parts = [rack, location].filter(Boolean);

    return parts.length ? parts.join(' · ') : null;
}

function route(movement: Movement): { from: string; to: string } {
    const kind = movementKind(movement);

    return {
        from:
            place(movement.from_rack, movement.from_location) ??
            (kind === 'receipt' ? 'Поступление' : '—'),
        to:
            place(movement.to_rack, movement.to_location) ??
            (kind === 'writeoff' ? 'Списание' : '—'),
    };
}
</script>

<template>
    <Head title="Обзор склада" />

    <div class="space-y-8">
        <!-- Заголовок -->
        <header
            class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between"
        >
            <div class="flex items-center gap-4">
                <div
                    class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                >
                    <LayoutDashboard :size="24" />
                </div>
                <div>
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Обзор склада
                    </h1>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Показатели, быстрые операции и последние движения товара
                    </p>
                </div>
            </div>

            <Button as-child class="w-full sm:w-auto">
                <Link href="/admin/stock/receipt">
                    <PackagePlus :size="18" class="mr-2" />
                    Оформить приход
                </Link>
            </Button>
        </header>

        <!-- Предупреждение об остатках -->
        <Link
            v-if="statistics.products_below_minimum > 0"
            href="/admin/stock?stock=below_minimum"
            class="group flex items-center gap-4 rounded-2xl border border-amber-500/30 bg-amber-500/10 p-4 transition hover:border-amber-500/50 hover:bg-amber-500/15 sm:p-5"
        >
            <div
                class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-amber-500 text-white shadow-sm"
            >
                <AlertTriangle :size="24" />
            </div>

            <div class="min-w-0 flex-1">
                <h2 class="font-semibold text-amber-900 dark:text-amber-200">
                    Ниже минимального остатка:
                    {{ formatNumber(statistics.products_below_minimum) }}
                </h2>
                <p class="mt-0.5 text-sm text-amber-800/80 dark:text-amber-300/80">
                    Эти товары нужно пополнить, чтобы не остаться без запаса.
                </p>
            </div>

            <span
                class="hidden shrink-0 items-center gap-1 text-sm font-medium text-amber-900 group-hover:underline sm:inline-flex dark:text-amber-200"
            >
                Посмотреть
                <ArrowRight :size="16" />
            </span>
        </Link>

        <!-- Показатели -->
        <section aria-labelledby="stats-title">
            <div class="mb-4 flex items-center justify-between gap-4">
                <h2 id="stats-title" class="text-lg font-semibold">
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

            <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5">
                <Link
                    v-for="card in statisticCards"
                    :key="card.key"
                    :href="card.href"
                    class="group block rounded-2xl border bg-card p-5 text-card-foreground shadow-sm transition hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-md focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
                >
                    <div class="flex items-start justify-between gap-3">
                        <div>
                            <p class="text-sm font-medium text-muted-foreground">
                                {{ card.title }}
                            </p>
                            <p
                                class="mt-2 text-3xl font-bold tracking-tight tabular-nums"
                            >
                                {{ formatNumber(statistics[card.key]) }}
                            </p>
                        </div>
                        <div
                            class="flex size-10 shrink-0 items-center justify-center rounded-xl"
                            :class="card.tone"
                        >
                            <component :is="card.icon" :size="20" />
                        </div>
                    </div>
                    <div class="mt-3 flex items-center justify-between gap-2">
                        <p class="text-xs text-muted-foreground">
                            {{ card.description }}
                        </p>
                        <ArrowRight :size="15" class="shrink-0 text-muted-foreground transition group-hover:translate-x-0.5 group-hover:text-primary" />
                    </div>
                </Link>
            </div>

            <div class="mt-4">
                <!-- Товары с остатком -->
                <Link href="/admin/stock" class="group block rounded-2xl border bg-card p-5 shadow-sm transition hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-md focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none">
                    <div class="flex items-center gap-3">
                        <div
                            class="flex size-10 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400"
                        >
                            <Warehouse :size="20" />
                        </div>
                        <div>
                            <p class="text-sm font-medium text-muted-foreground">
                                Товары на складе
                            </p>
                            <p class="text-2xl font-bold tabular-nums">
                                {{ formatNumber(statistics.products_with_stock) }}
                                <span class="text-sm font-medium text-muted-foreground">
                                    из {{ formatNumber(statistics.products) }}
                                </span>
                            </p>
                        </div>
                    </div>

                    <div
                        class="mt-4 h-2 overflow-hidden rounded-full bg-muted"
                        role="progressbar"
                        aria-label="Доля товаров с ненулевым остатком"
                        aria-valuemin="0"
                        aria-valuemax="100"
                        :aria-valuenow="stockCoverage"
                    >
                        <div
                            class="h-full rounded-full bg-emerald-500 transition-[width] duration-500"
                            :style="{ width: `${stockCoverage}%` }"
                        />
                    </div>
                    <div class="mt-2 flex items-center justify-between gap-2">
                        <p class="text-xs text-muted-foreground">
                            {{ stockCoverage }}% позиций с ненулевым остатком
                        </p>
                        <ArrowRight :size="15" class="shrink-0 text-muted-foreground transition group-hover:translate-x-0.5 group-hover:text-primary" />
                    </div>
                </Link>
            </div>
        </section>

        <!-- Быстрые действия -->
        <section aria-labelledby="actions-title">
            <h2 id="actions-title" class="mb-4 text-lg font-semibold">
                Быстрые действия
            </h2>

            <div class="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                <Link
                    v-for="action in quickActions"
                    :key="action.href"
                    :href="action.href"
                    class="group flex items-center gap-4 rounded-2xl border bg-card p-4 shadow-sm transition hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-md"
                >
                    <span
                        class="flex size-12 shrink-0 items-center justify-center rounded-xl transition group-hover:scale-105"
                        :class="action.tone"
                    >
                        <component :is="action.icon" :size="22" />
                    </span>

                    <span class="min-w-0 flex-1">
                        <span class="block font-semibold">
                            {{ action.title }}
                        </span>
                        <span class="mt-0.5 block text-sm text-muted-foreground">
                            {{ action.description }}
                        </span>
                    </span>

                    <ArrowRight
                        :size="18"
                        class="shrink-0 text-muted-foreground transition group-hover:translate-x-0.5 group-hover:text-primary"
                    />
                </Link>
            </div>
        </section>

        <!-- Последние движения -->
        <section
            aria-labelledby="movements-title"
            class="overflow-hidden rounded-2xl border bg-card shadow-sm"
        >
            <div
                class="flex flex-wrap items-center justify-between gap-3 border-b px-5 py-4 sm:px-6"
            >
                <div>
                    <h2 id="movements-title" class="text-lg font-semibold">
                        Последние движения
                    </h2>
                    <p class="mt-0.5 text-sm text-muted-foreground">
                        Последние операции с товарами на складе
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
                    class="mx-auto mb-4 flex size-16 items-center justify-center rounded-full bg-muted"
                >
                    <History :size="30" class="text-muted-foreground" />
                </div>
                <p class="font-medium">Движений пока нет</p>
                <p class="mt-1 text-sm text-muted-foreground">
                    После первой складской операции она появится здесь.
                </p>
            </div>

            <template v-else>
                <!-- Мобильные карточки -->
                <ul class="divide-y md:hidden">
                    <li v-for="movement in movements" :key="movement.id" class="p-4">
                        <div class="flex items-start justify-between gap-3">
                            <div class="min-w-0">
                                <p class="break-words text-sm font-semibold">
                                    {{ movement.product_name }}
                                </p>
                                <p class="mt-0.5 text-xs text-muted-foreground">
                                    {{ movement.sku || 'Без артикула' }}
                                </p>
                            </div>
                            <p class="shrink-0 text-base font-bold tabular-nums">
                                {{ formatNumber(movement.quantity) }}
                            </p>
                        </div>

                        <div class="mt-3 flex flex-wrap items-center gap-2">
                            <span
                                class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset"
                                :class="style(movement).tone"
                            >
                                <component :is="style(movement).icon" :size="13" />
                                {{ movement.type_label }}
                            </span>
                            <span class="text-xs text-muted-foreground">
                                {{ movement.created_at ?? '—' }}
                            </span>
                        </div>

                        <div class="mt-3 flex items-center gap-2 text-xs">
                            <span class="max-w-[42%] truncate rounded-md bg-muted px-2 py-1">
                                {{ route(movement).from }}
                            </span>
                            <ArrowRight :size="13" class="shrink-0 text-muted-foreground" />
                            <span class="max-w-[42%] truncate rounded-md bg-muted px-2 py-1">
                                {{ route(movement).to }}
                            </span>
                        </div>

                        <p
                            v-if="movement.comment"
                            class="mt-3 text-xs text-muted-foreground"
                        >
                            {{ movement.comment }}
                        </p>
                    </li>
                </ul>

                <!-- Таблица -->
                <div class="hidden overflow-x-auto md:block">
                    <table class="min-w-full text-sm">
                        <thead>
                        <tr class="border-b bg-muted/40">
                            <th
                                v-for="title in ['Дата', 'Товар', 'Операция', 'Количество', 'Размещение']"
                                :key="title"
                                scope="col"
                                class="px-6 py-3.5 text-left text-xs font-semibold tracking-wider text-muted-foreground uppercase first:pl-6"
                                :class="title === 'Количество' ? 'text-right' : ''"
                            >
                                {{ title }}
                            </th>
                        </tr>
                        </thead>

                        <tbody class="divide-y">
                        <tr
                            v-for="movement in movements"
                            :key="movement.id"
                            class="transition-colors hover:bg-muted/40"
                        >
                            <td class="px-6 py-4 text-xs whitespace-nowrap text-muted-foreground">
                                {{ movement.created_at ?? '—' }}
                            </td>

                            <td class="px-6 py-4">
                                <div class="font-medium">
                                    {{ movement.product_name }}
                                </div>
                                <div class="mt-0.5 text-xs text-muted-foreground">
                                    Артикул: {{ movement.sku || '—' }}
                                </div>
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap">
                                    <span
                                        class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset"
                                        :class="style(movement).tone"
                                    >
                                        <component :is="style(movement).icon" :size="13" />
                                        {{ movement.type_label }}
                                    </span>
                            </td>

                            <td class="px-6 py-4 text-right font-semibold whitespace-nowrap tabular-nums">
                                {{ formatNumber(movement.quantity) }}
                            </td>

                            <td class="px-6 py-4">
                                <div class="flex items-center gap-2 text-xs">
                                    <MapPin :size="14" class="shrink-0 text-muted-foreground" />
                                    <span class="max-w-36 truncate rounded-md bg-muted px-2 py-1">
                                            {{ route(movement).from }}
                                        </span>
                                    <ArrowRight :size="13" class="shrink-0 text-muted-foreground" />
                                    <span class="max-w-36 truncate rounded-md bg-muted px-2 py-1">
                                            {{ route(movement).to }}
                                        </span>
                                </div>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </template>
        </section>
    </div>
</template>
