<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, onBeforeUnmount, reactive, watch } from 'vue';
import type { Component } from 'vue';
import {
    ArrowLeftRight,
    ArrowRight,
    ChevronLeft,
    ChevronRight,
    ClipboardCheck,
    Eye,
    History,
    MapPin,
    Package,
    PackageMinus,
    PackagePlus,
    RotateCcw,
    Search,
    Warehouse,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { Button } from '@/components/ui/button';
import { show } from '@/routes/admin/products';

defineOptions({
    layout: AdminLayout,
});

interface CategoryOption {
    id: number;
    name: string;
}

interface RackOption {
    id: number;
    code: string;
    name: string | null;
}

interface StockLocation {
    id: number;
    code: string;
    rack_code: string | null;
    rack_name: string | null;
    quantity: number | string;
}

interface StockProduct {
    id: number;
    name: string;
    code: string | null;
    article: string | null;
    category: string | null;
    unit: string;
    stock_quantity: number | string;
    minimum_stock: number | string | null;
    stock_deficit: number | string;
    locations: StockLocation[];
}

interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

interface PaginatedProducts {
    data: StockProduct[];
    links: PaginationLink[];
    current_page: number;
    last_page: number;
    total: number;
    from: number | null;
    to: number | null;
}

interface Filters {
    search: string;
    category_id: string;
    rack_id: string;
    stock: string;
}

const props = defineProps<{
    products: PaginatedProducts;
    categories: CategoryOption[];
    racks: RackOption[];
    filters: Filters;
}>();

/* ---------- Форматирование ---------- */

const numberFormat = new Intl.NumberFormat('ru-RU', {
    maximumFractionDigits: 3,
});

function formatNumber(value: number | string | null | undefined): string {
    if (value === null || value === undefined || value === '') {
        return '—';
    }

    const number = Number(value);

    return Number.isNaN(number) ? String(value) : numberFormat.format(number);
}

/* ---------- Быстрые переходы ---------- */

interface QuickLink {
    label: string;
    href: string;
    icon: Component;
    tone: string;
}

const quickLinks: QuickLink[] = [
    {
        label: 'Перемещение',
        href: '/admin/stock/transfer',
        icon: ArrowLeftRight,
        tone: 'bg-sky-500/10 text-sky-600 dark:text-sky-400',
    },
    {
        label: 'Возврат',
        href: '/admin/stock/return',
        icon: RotateCcw,
        tone: 'bg-violet-500/10 text-violet-600 dark:text-violet-400',
    },
    {
        label: 'Списание',
        href: '/admin/stock/write-off',
        icon: PackageMinus,
        tone: 'bg-rose-500/10 text-rose-600 dark:text-rose-400',
    },
    {
        label: 'Инвентаризация',
        href: '/admin/stock/inventory',
        icon: ClipboardCheck,
        tone: 'bg-amber-500/10 text-amber-600 dark:text-amber-400',
    },
    {
        label: 'Журнал операций',
        href: '/admin/stock/movements',
        icon: History,
        tone: 'bg-muted text-muted-foreground',
    },
];

/* ---------- Фильтры ---------- */

const stockOptions = [
    { value: 'all', label: 'Все товары' },
    { value: 'in_stock', label: 'Есть остаток' },
    { value: 'out_of_stock', label: 'Нет остатка' },
    { value: 'below_minimum', label: 'Ниже минимума' },
];

const fieldClass =
    'w-full rounded-xl border border-input bg-background px-3 py-2.5 text-sm shadow-xs outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30';

const filters = reactive<Filters>({
    ...props.filters,
    stock: props.filters.stock || 'all',
});

const activeFiltersCount = computed(
    () =>
        [
            filters.search,
            filters.category_id,
            filters.rack_id,
            filters.stock !== 'all' ? filters.stock : '',
        ].filter(Boolean).length,
);

let debounceTimer: ReturnType<typeof setTimeout> | undefined;

function applyFilters(): void {
    clearTimeout(debounceTimer);

    router.get(
        '/admin/stock',
        {
            search: filters.search || undefined,
            category_id: filters.category_id || undefined,
            rack_id: filters.rack_id || undefined,
            stock: filters.stock === 'all' ? undefined : filters.stock,
        },
        {
            preserveState: true,
            preserveScroll: true,
            replace: true,
        },
    );
}

// Применяем фильтры автоматически, с небольшой задержкой для поиска
watch(filters, () => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(applyFilters, 350);
});

onBeforeUnmount(() => clearTimeout(debounceTimer));

function resetFilters(): void {
    filters.search = '';
    filters.category_id = '';
    filters.rack_id = '';
    filters.stock = 'all';
}

/* ---------- Статус остатка ---------- */

function stockState(product: StockProduct) {
    const quantity = Number(product.stock_quantity);

    if (!(quantity > 0)) {
        return {
            label: 'Нет в наличии',
            badge: 'bg-rose-500/10 text-rose-700 ring-rose-600/20 dark:text-rose-400',
            value: 'text-rose-700 dark:text-rose-400',
            bar: 'bg-rose-500',
        };
    }

    if (Number(product.stock_deficit) > 0) {
        return {
            label: 'Ниже минимума',
            badge: 'bg-amber-500/10 text-amber-700 ring-amber-600/20 dark:text-amber-400',
            value: 'text-amber-700 dark:text-amber-400',
            bar: 'bg-amber-500',
        };
    }

    return {
        label: 'В наличии',
        badge: 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400',
        value: 'text-foreground',
        bar: 'bg-emerald-500',
    };
}

function stockPercent(product: StockProduct): number | null {
    const quantity = Number(product.stock_quantity);
    const minimum = Number(product.minimum_stock);

    if (product.minimum_stock === null || !(minimum > 0)) {
        return null;
    }

    return Math.max(0, Math.min(100, (quantity / minimum) * 100));
}

/* ---------- Пагинация ---------- */

const prevLink = computed(() => props.products.links[0] ?? null);
const nextLink = computed(
    () => props.products.links[props.products.links.length - 1] ?? null,
);
const pageLinks = computed(() => props.products.links.slice(1, -1));
const hasPagination = computed(() => props.products.links.length > 3);

const pageButtonBase =
    'inline-flex h-9 min-w-9 items-center justify-center rounded-xl border px-3 text-sm font-medium transition';
</script>

<template>
    <Head title="Остатки на складе" />

    <div class="space-y-6">
        <!-- Заголовок -->
        <header
            class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between"
        >
            <div class="flex items-center gap-4">
                <div
                    class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                >
                    <Warehouse :size="24" />
                </div>
                <div>
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Остатки на складе
                    </h1>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Текущие запасы товаров и их расположение по ячейкам
                    </p>
                </div>
            </div>

            <Button as-child class="w-full sm:w-auto">
                <Link href="/admin/stock/receipt">
                    <PackagePlus :size="18" class="mr-2" />
                    Поступление товара
                </Link>
            </Button>
        </header>

        <!-- Быстрые переходы -->
        <nav class="flex flex-wrap gap-2" aria-label="Складские операции">
            <Link
                v-for="item in quickLinks"
                :key="item.href"
                :href="item.href"
                class="group inline-flex items-center gap-2.5 rounded-xl border bg-card py-2 pr-4 pl-2 text-sm font-medium shadow-xs transition hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-sm"
            >
                <span
                    class="flex size-7 items-center justify-center rounded-lg"
                    :class="item.tone"
                >
                    <component :is="item.icon" :size="15" />
                </span>
                {{ item.label }}
            </Link>
        </nav>

        <!-- Фильтры -->
        <form
            class="rounded-2xl border bg-card p-4 shadow-sm sm:p-5"
            @submit.prevent="applyFilters"
        >
            <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-[2fr_1fr_1fr]">
                <div class="space-y-1.5">
                    <label for="search" class="text-sm font-medium">
                        Поиск товара
                    </label>
                    <div class="relative">
                        <Search
                            :size="16"
                            class="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-muted-foreground"
                        />
                        <input
                            id="search"
                            v-model="filters.search"
                            type="search"
                            placeholder="Название или артикул"
                            class="pl-9"
                            :class="fieldClass"
                        />
                    </div>
                </div>

                <div class="space-y-1.5">
                    <label for="category_id" class="text-sm font-medium">
                        Категория
                    </label>
                    <select
                        id="category_id"
                        v-model="filters.category_id"
                        :class="fieldClass"
                    >
                        <option value="">Все категории</option>
                        <option
                            v-for="category in categories"
                            :key="category.id"
                            :value="String(category.id)"
                        >
                            {{ category.name }}
                        </option>
                    </select>
                </div>

                <div class="space-y-1.5">
                    <label for="rack_id" class="text-sm font-medium">
                        Стеллаж
                    </label>
                    <select
                        id="rack_id"
                        v-model="filters.rack_id"
                        :class="fieldClass"
                    >
                        <option value="">Все стеллажи</option>
                        <option
                            v-for="rack in racks"
                            :key="rack.id"
                            :value="String(rack.id)"
                        >
                            {{ rack.code }}{{ rack.name ? ` — ${rack.name}` : '' }}
                        </option>
                    </select>
                </div>
            </div>

            <div
                class="mt-4 flex flex-col gap-3 border-t pt-4 sm:flex-row sm:items-center sm:justify-between"
            >
                <div
                    class="flex flex-wrap gap-2"
                    role="group"
                    aria-label="Наличие"
                >
                    <button
                        v-for="option in stockOptions"
                        :key="option.value"
                        type="button"
                        class="rounded-full border px-3.5 py-1.5 text-sm font-medium transition focus-visible:ring-[3px] focus-visible:ring-ring/40 focus-visible:outline-none"
                        :class="
                            filters.stock === option.value
                                ? 'border-primary bg-primary text-primary-foreground shadow-xs'
                                : 'bg-background text-muted-foreground hover:border-primary/30 hover:text-foreground'
                        "
                        :aria-pressed="filters.stock === option.value"
                        @click="filters.stock = option.value"
                    >
                        {{ option.label }}
                    </button>
                </div>

                <Button
                    v-if="activeFiltersCount"
                    type="button"
                    variant="ghost"
                    size="sm"
                    class="self-start text-muted-foreground sm:self-auto"
                    @click="resetFilters"
                >
                    <X :size="15" class="mr-1.5" />
                    Сбросить ({{ activeFiltersCount }})
                </Button>
            </div>
        </form>

        <!-- Остатки -->
        <section
            class="overflow-hidden rounded-2xl border bg-card shadow-sm"
            aria-labelledby="stock-title"
        >
            <div
                class="flex flex-col gap-1 border-b px-5 py-4 sm:flex-row sm:items-center sm:justify-between"
            >
                <h2 id="stock-title" class="font-semibold">Складские запасы</h2>
                <p class="text-sm text-muted-foreground">
                    Найдено товаров:
                    <span class="font-medium text-foreground tabular-nums">
                        {{ products.total }}
                    </span>
                </p>
            </div>

            <!-- Пустое состояние -->
            <div
                v-if="products.data.length === 0"
                class="flex flex-col items-center px-6 py-16 text-center"
            >
                <div
                    class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted"
                >
                    <Package :size="30" class="text-muted-foreground" />
                </div>
                <p class="font-medium">Товары не найдены</p>
                <p class="mt-1 max-w-sm text-sm text-muted-foreground">
                    Попробуйте изменить параметры поиска или сбросить фильтры.
                </p>
                <Button
                    v-if="activeFiltersCount"
                    variant="outline"
                    class="mt-5"
                    @click="resetFilters"
                >
                    Сбросить фильтры
                </Button>
            </div>

            <template v-else>
                <!-- Мобильные карточки -->
                <ul class="divide-y md:hidden">
                    <li
                        v-for="product in products.data"
                        :key="product.id"
                        class="space-y-3 p-4"
                    >
                        <div class="flex items-start justify-between gap-3">
                            <div class="min-w-0">
                                <h3 class="break-words text-sm font-semibold">
                                    {{ product.name }}
                                </h3>
                                <p class="mt-0.5 text-xs text-muted-foreground">
                                    {{ product.code || product.article || 'Без кода/артикула' }}
                                    <template v-if="product.category">
                                        · {{ product.category }}
                                    </template>
                                </p>
                            </div>
                            <span
                                class="shrink-0 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset"
                                :class="stockState(product).badge"
                            >
                                {{ stockState(product).label }}
                            </span>
                        </div>

                        <div class="grid grid-cols-3 gap-2 text-center">
                            <div class="rounded-lg bg-muted/50 px-2 py-2">
                                <p class="text-[11px] text-muted-foreground">Всего</p>
                                <p
                                    class="mt-0.5 text-sm font-bold tabular-nums"
                                    :class="stockState(product).value"
                                >
                                    {{ formatNumber(product.stock_quantity) }}
                                    <span class="text-[10px] font-medium text-muted-foreground">
                                        {{ product.unit }}
                                    </span>
                                </p>
                            </div>
                            <div class="rounded-lg bg-muted/50 px-2 py-2">
                                <p class="text-[11px] text-muted-foreground">Минимум</p>
                                <p class="mt-0.5 text-sm font-bold tabular-nums">
                                    {{ formatNumber(product.minimum_stock) }}
                                </p>
                            </div>
                            <div class="rounded-lg bg-muted/50 px-2 py-2">
                                <p class="text-[11px] text-muted-foreground">Не хватает</p>
                                <p
                                    class="mt-0.5 text-sm font-bold tabular-nums"
                                    :class="
                                        Number(product.stock_deficit) > 0
                                            ? 'text-rose-600 dark:text-rose-400'
                                            : 'text-muted-foreground'
                                    "
                                >
                                    {{
                                        Number(product.stock_deficit) > 0
                                            ? formatNumber(product.stock_deficit)
                                            : '—'
                                    }}
                                </p>
                            </div>
                        </div>

                        <div class="flex items-start gap-2">
                            <MapPin :size="15" class="mt-1 shrink-0 text-muted-foreground" />
                            <div
                                v-if="product.locations.length"
                                class="flex flex-wrap gap-1.5"
                            >
                                <span
                                    v-for="location in product.locations"
                                    :key="location.id"
                                    class="inline-flex items-center gap-1 rounded-md border bg-muted/40 px-2 py-1 text-xs"
                                >
                                    <span class="font-semibold">{{ location.code }}</span>
                                    <span v-if="location.rack_code" class="text-muted-foreground">
                                        ({{ location.rack_code }})
                                    </span>
                                    <span class="text-muted-foreground tabular-nums">
                                        · {{ formatNumber(location.quantity) }}
                                    </span>
                                </span>
                            </div>
                            <span v-else class="text-xs text-muted-foreground">
                                Не размещён
                            </span>
                        </div>

                        <Button as-child variant="outline" size="sm" class="w-full">
                            <Link :href="show(product.id).url">
                                <Eye :size="15" class="mr-2" />
                                Открыть товар
                            </Link>
                        </Button>
                    </li>
                </ul>

                <!-- Таблица -->
                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full min-w-[960px] text-sm">
                        <thead>
                        <tr class="border-b bg-muted/40 text-left">
                            <th
                                scope="col"
                                class="px-5 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                            >
                                Товар
                            </th>
                            <th
                                scope="col"
                                class="px-5 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                            >
                                Расположение
                            </th>
                            <th
                                scope="col"
                                class="px-5 py-3.5 text-right text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                            >
                                Остаток
                            </th>
                            <th
                                scope="col"
                                class="px-5 py-3.5 text-right text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                            >
                                Минимум
                            </th>
                            <th
                                scope="col"
                                class="px-5 py-3.5 text-right text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                            >
                                Не хватает
                            </th>
                            <th scope="col" class="px-5 py-3.5">
                                <span class="sr-only">Действия</span>
                            </th>
                        </tr>
                        </thead>

                        <tbody class="divide-y">
                        <tr
                            v-for="product in products.data"
                            :key="product.id"
                            class="align-top transition-colors hover:bg-muted/40"
                        >
                            <td class="px-5 py-4">
                                <div class="font-medium">
                                    {{ product.name }}
                                </div>
                                <div class="mt-1 text-xs text-muted-foreground">
                                    {{ product.code || product.article || 'Без кода/артикула' }}
                                    <template v-if="product.category">
                                        · {{ product.category }}
                                    </template>
                                </div>
                            </td>

                            <td class="px-5 py-4">
                                <div
                                    v-if="product.locations.length"
                                    class="flex flex-wrap gap-1.5"
                                >
                                        <span
                                            v-for="location in product.locations"
                                            :key="location.id"
                                            class="inline-flex items-center gap-1 rounded-md border bg-muted/40 px-2 py-1 text-xs"
                                        >
                                            <span class="font-semibold">
                                                {{ location.code }}
                                            </span>
                                            <span
                                                v-if="location.rack_code"
                                                class="text-muted-foreground"
                                            >
                                                ({{ location.rack_code }})
                                            </span>
                                            <span class="text-muted-foreground tabular-nums">
                                                · {{ formatNumber(location.quantity) }}
                                                {{ product.unit }}
                                            </span>
                                        </span>
                                </div>
                                <span v-else class="text-muted-foreground">
                                        Не размещён
                                    </span>
                            </td>

                            <td class="px-5 py-4 text-right">
                                <div
                                    class="font-bold whitespace-nowrap tabular-nums"
                                    :class="stockState(product).value"
                                >
                                    {{ formatNumber(product.stock_quantity) }}
                                    <span class="text-xs font-medium text-muted-foreground">
                                            {{ product.unit }}
                                        </span>
                                </div>

                                <span
                                    class="mt-1.5 inline-flex rounded-full px-2 py-0.5 text-[11px] font-semibold ring-1 ring-inset"
                                    :class="stockState(product).badge"
                                >
                                        {{ stockState(product).label }}
                                    </span>

                                <div
                                    v-if="stockPercent(product) !== null"
                                    class="mt-2 ml-auto h-1 w-24 overflow-hidden rounded-full bg-muted"
                                    role="progressbar"
                                    aria-label="Остаток относительно минимума"
                                    aria-valuemin="0"
                                    aria-valuemax="100"
                                    :aria-valuenow="Math.round(stockPercent(product) ?? 0)"
                                >
                                    <div
                                        class="h-full rounded-full"
                                        :class="stockState(product).bar"
                                        :style="{ width: `${stockPercent(product)}%` }"
                                    />
                                </div>
                            </td>

                            <td class="px-5 py-4 text-right whitespace-nowrap tabular-nums">
                                <template v-if="product.minimum_stock !== null">
                                    {{ formatNumber(product.minimum_stock) }}
                                    <span class="text-xs text-muted-foreground">
                                            {{ product.unit }}
                                        </span>
                                </template>
                                <span v-else class="text-muted-foreground">
                                        Не задан
                                    </span>
                            </td>

                            <td class="px-5 py-4 text-right whitespace-nowrap">
                                    <span
                                        v-if="Number(product.stock_deficit) > 0"
                                        class="inline-flex rounded-lg bg-rose-500/10 px-2.5 py-1 font-semibold text-rose-700 tabular-nums dark:text-rose-400"
                                    >
                                        {{ formatNumber(product.stock_deficit) }}
                                        {{ product.unit }}
                                    </span>
                                <span v-else class="text-muted-foreground">—</span>
                            </td>

                            <td class="px-5 py-4 text-right">
                                <Button
                                    as-child
                                    variant="ghost"
                                    size="sm"
                                    class="text-primary hover:text-primary"
                                >
                                    <Link :href="show(product.id).url">
                                        Открыть
                                        <ArrowRight :size="15" class="ml-1.5" />
                                    </Link>
                                </Button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </template>

            <!-- Пагинация -->
            <div
                v-if="hasPagination"
                class="flex flex-col gap-4 border-t px-5 py-4 sm:flex-row sm:items-center sm:justify-between"
            >
                <p class="text-sm text-muted-foreground">
                    Показано {{ products.from ?? 0 }}–{{ products.to ?? 0 }} из
                    {{ products.total }}
                </p>

                <nav
                    class="flex flex-wrap items-center justify-center gap-1"
                    aria-label="Навигация по страницам"
                >
                    <Link
                        v-if="prevLink?.url"
                        :href="prevLink.url"
                        preserve-scroll
                        preserve-state
                        :class="[pageButtonBase, 'gap-1 text-muted-foreground hover:border-primary/30 hover:text-primary']"
                    >
                        <ChevronLeft :size="16" />
                        Назад
                    </Link>
                    <span
                        v-else
                        :class="[pageButtonBase, 'cursor-not-allowed gap-1 border-transparent text-muted-foreground/40']"
                    >
                        <ChevronLeft :size="16" />
                        Назад
                    </span>

                    <template
                        v-for="(link, index) in pageLinks"
                        :key="`${index}-${link.label}`"
                    >
                        <Link
                            v-if="link.url"
                            :href="link.url"
                            preserve-scroll
                            preserve-state
                            :class="[
                                pageButtonBase,
                                link.active
                                    ? 'border-primary bg-primary text-primary-foreground shadow-xs'
                                    : 'text-muted-foreground hover:border-primary/30 hover:text-primary',
                            ]"
                            :aria-current="link.active ? 'page' : undefined"
                        >
                            {{ link.label }}
                        </Link>
                        <span
                            v-else
                            class="inline-flex h-9 min-w-9 items-center justify-center px-2 text-sm text-muted-foreground"
                        >
                            {{ link.label }}
                        </span>
                    </template>

                    <Link
                        v-if="nextLink?.url"
                        :href="nextLink.url"
                        preserve-scroll
                        preserve-state
                        :class="[pageButtonBase, 'gap-1 text-muted-foreground hover:border-primary/30 hover:text-primary']"
                    >
                        Далее
                        <ChevronRight :size="16" />
                    </Link>
                    <span
                        v-else
                        :class="[pageButtonBase, 'cursor-not-allowed gap-1 border-transparent text-muted-foreground/40']"
                    >
                        Далее
                        <ChevronRight :size="16" />
                    </span>
                </nav>
            </div>
        </section>
    </div>
</template>
