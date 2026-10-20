<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { reactive } from 'vue';
import {
    ArrowLeft,
    ArrowRight,
    ArrowUpDown,
    Box,
    ChevronLeft,
    ChevronRight,
    FileText,
    Filter,
    Plus,
    Search,
    Warehouse,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
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
    sku: string | null;
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

const filters = reactive<Filters>({
    ...props.filters,
});

function formatNumber(value: number | string | null): string {
    if (value === null) {
        return '—';
    }

    return Number(value).toLocaleString('ru-RU', {
        maximumFractionDigits: 3,
    });
}

function applyFilters(): void {
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

function resetFilters(): void {
    filters.search = '';
    filters.category_id = '';
    filters.rack_id = '';
    filters.stock = 'all';

    applyFilters();
}

function goToPage(url: string | null): void {
    if (!url) {
        return;
    }

    router.visit(url, {
        preserveScroll: true,
        preserveState: true,
    });
}
</script>

<template>
    <Head title="Остатки на складе" />

    <div class="space-y-6 p-4 sm:p-6">
        <!-- Заголовок -->
        <div
            class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-indigo-950 to-violet-900 p-6 text-white shadow-lg sm:p-8"
        >
            <div
                class="pointer-events-none absolute -top-16 -right-12 h-56 w-56 rounded-full bg-violet-400/20 blur-3xl"
            />
            <div
                class="pointer-events-none absolute right-1/3 -bottom-20 h-48 w-48 rounded-full bg-blue-400/10 blur-3xl"
            />

            <div
                class="relative flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between"
            >
                <div>
                    <div
                        class="mb-3 flex items-center gap-2 text-sm text-indigo-200"
                    >
                        <Warehouse class="h-4 w-4" />
                        <span>Склад</span>
                    </div>

                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Остатки на складе
                    </h1>

                    <p
                        class="mt-2 max-w-xl text-sm text-slate-300 sm:text-base"
                    >
                        Текущие запасы товаров и их расположение по ячейкам.
                    </p>
                </div>

                <Link
                    href="/admin/stock/receipt"
                    class="inline-flex shrink-0 items-center justify-center gap-2 rounded-xl bg-white px-5 py-3 text-sm font-semibold text-slate-900 shadow-lg transition hover:bg-indigo-50 focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-2 focus-visible:ring-offset-indigo-950 focus-visible:outline-none"
                >
                    <Plus class="h-5 w-5" />
                    Поступление товара
                </Link>
            </div>
        </div>

        <!-- Быстрые переходы -->
        <div class="flex flex-wrap gap-2">
            <Link
                href="/admin/stock/transfer"
                class="inline-flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-medium text-slate-700 transition hover:border-slate-300 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
            >
                <Box class="h-4 w-4" />
                Перемещение
            </Link>

            <Link
                href="/admin/stock/return"
                class="inline-flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-medium text-slate-700 transition hover:border-slate-300 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
            >
                <ArrowLeft class="h-4 w-4" />
                Возврат
            </Link>

            <Link
                href="/admin/stock/write-off"
                class="inline-flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-medium text-slate-700 transition hover:border-slate-300 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
            >
                <X class="h-4 w-4" />
                Списание
            </Link>

            <Link
                href="/admin/stock/inventory"
                class="inline-flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-medium text-slate-700 transition hover:border-slate-300 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
            >
                <FileText class="h-4 w-4" />
                Инвентаризация
            </Link>

            <Link
                href="/admin/stock/movements"
                class="inline-flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-medium text-slate-700 transition hover:border-slate-300 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
            >
                <ArrowUpDown class="h-4 w-4" />
                Журнал операций
            </Link>
        </div>

        <!-- Фильтры -->
        <form
            class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900"
            @submit.prevent="applyFilters"
        >
            <div
                class="border-b border-slate-200 px-5 py-4 sm:px-6 dark:border-slate-800"
            >
                <div class="flex items-center gap-3">
                    <div
                        class="rounded-xl bg-indigo-50 p-2.5 dark:bg-indigo-500/10"
                    >
                        <Filter
                            class="h-5 w-5 text-indigo-600 dark:text-indigo-400"
                        />
                    </div>

                    <div>
                        <h2
                            class="font-semibold text-slate-900 dark:text-white"
                        >
                            Фильтры
                        </h2>
                        <p
                            class="mt-1 text-sm text-slate-500 dark:text-slate-400"
                        >
                            Настройте параметры поиска товаров
                        </p>
                    </div>
                </div>
            </div>

            <div class="space-y-4 p-5 sm:p-6">
                <div
                    class="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4"
                >
                    <div>
                        <label
                            for="search"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Поиск товара
                        </label>

                        <div class="relative">
                            <Search
                                class="pointer-events-none absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-slate-400"
                            />

                            <input
                                id="search"
                                v-model="filters.search"
                                type="search"
                                placeholder="Название или артикул"
                                class="w-full rounded-xl border border-slate-200 bg-slate-50 py-2.5 pr-4 pl-9 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 dark:border-slate-700 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                            />
                        </div>
                    </div>

                    <div>
                        <label
                            for="category_id"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Категория
                        </label>

                        <select
                            id="category_id"
                            v-model="filters.category_id"
                            class="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-2.5 text-sm text-slate-900 transition outline-none focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 dark:border-slate-700 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                        >
                            <option value="">Все категории</option>

                            <option
                                v-for="category in props.categories"
                                :key="category.id"
                                :value="String(category.id)"
                            >
                                {{ category.name }}
                            </option>
                        </select>
                    </div>

                    <div>
                        <label
                            for="rack_id"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Стеллаж
                        </label>

                        <select
                            id="rack_id"
                            v-model="filters.rack_id"
                            class="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-2.5 text-sm text-slate-900 transition outline-none focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 dark:border-slate-700 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                        >
                            <option value="">Все стеллажи</option>

                            <option
                                v-for="rack in props.racks"
                                :key="rack.id"
                                :value="String(rack.id)"
                            >
                                {{ rack.code }}
                                <template v-if="rack.name">
                                    — {{ rack.name }}
                                </template>
                            </option>
                        </select>
                    </div>

                    <div>
                        <label
                            for="stock"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Наличие
                        </label>

                        <select
                            id="stock"
                            v-model="filters.stock"
                            class="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-2.5 text-sm text-slate-900 transition outline-none focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 dark:border-slate-700 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                        >
                            <option value="all">Все товары</option>
                            <option value="in_stock">Есть остаток</option>
                            <option value="out_of_stock">Нет остатка</option>
                            <option value="below_minimum">
                                Ниже минимального остатка
                            </option>
                        </select>
                    </div>
                </div>

                <div
                    class="flex flex-wrap justify-end gap-3 border-t border-slate-100 pt-4 dark:border-slate-800"
                >
                    <button
                        type="button"
                        class="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-medium text-slate-700 transition hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                        @click="resetFilters"
                    >
                        <X class="h-4 w-4" />
                        Сбросить
                    </button>

                    <button
                        type="submit"
                        class="inline-flex items-center justify-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 focus-visible:outline-none dark:focus-visible:ring-offset-slate-900"
                    >
                        <Filter class="h-4 w-4" />
                        Применить фильтры
                    </button>
                </div>
            </div>
        </form>

        <!-- Таблица остатков -->
        <div
            class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900"
        >
            <div
                class="flex flex-col gap-1 border-b border-slate-200 px-5 py-4 sm:flex-row sm:items-center sm:justify-between dark:border-slate-800"
            >
                <h2 class="font-semibold text-slate-900 dark:text-white">
                    Складские запасы
                </h2>

                <p class="text-sm text-slate-500 dark:text-slate-400">
                    Найдено товаров: {{ props.products.total }}
                </p>
            </div>

            <!-- Карточки на мобильных -->
            <div class="space-y-2 p-3 md:hidden">
                <div
                    v-for="product in props.products.data"
                    :key="product.id"
                    class="rounded-lg border border-slate-200 bg-white p-3 shadow-sm transition-colors hover:border-indigo-200 dark:border-slate-700 dark:bg-slate-900 dark:hover:border-indigo-500/40"
                    :class="Number(product.stock_deficit) > 0 ? 'bg-rose-50/50 dark:bg-rose-500/5' : ''"
                >
                    <h3 class="font-semibold text-slate-900 dark:text-white break-words text-xs">{{ product.name }}</h3>
                    <p class="mt-0.5 text-[10px] text-slate-500 dark:text-slate-400">Артикул: {{ product.sku || '—' }}</p>
                    <div class="mt-2 grid grid-cols-2 gap-1.5 text-xs">
                        <div><p class="text-[10px] text-slate-500 dark:text-slate-400">Категория</p><p class="text-slate-700 dark:text-slate-300 truncate text-[10px]">{{ product.category || '—' }}</p></div>
                        <div><p class="text-[10px] text-slate-500 dark:text-slate-400">Всего</p><p class="font-semibold" :class="Number(product.stock_quantity) > 0 ? 'text-emerald-700 dark:text-emerald-400' : 'text-slate-500 dark:text-slate-400'">{{ formatNumber(product.stock_quantity) }} {{ product.unit }}</p></div>
                    </div>
                    <div class="mt-2 text-xs">
                        <p class="text-[10px] text-slate-500 dark:text-slate-400">Не хватает</p>
                        <p class="font-semibold" :class="Number(product.stock_deficit) > 0 ? 'text-rose-700 dark:text-rose-400' : 'text-slate-500 dark:text-slate-400'">{{ formatNumber(product.stock_deficit) }} {{ product.unit }}</p>
                    </div>
                    <div class="mt-2 text-xs">
                        <p class="text-[10px] text-slate-500 dark:text-slate-400">Расположение</p>
                        <p class="font-semibold text-slate-700 dark:text-slate-300 truncate text-[10px]">
                            <span v-if="product.locations.length">
                                <span v-for="location in product.locations" :key="location.id" class="mr-1.5">
                                    {{ location.code }}
                                    <span v-if="location.rack_code" class="text-slate-500 dark:text-slate-400 text-[9px]">({{ location.rack_code }})</span>
                                </span>
                            </span>
                            <span v-else>Не размещён</span>
                        </p>
                    </div>
                    <div class="mt-3 flex items-center gap-1.5 border-t border-slate-200 pt-2 dark:border-slate-700">
                        <Link :href="show(product.id).url" class="flex-1 inline-flex items-center justify-center gap-1 rounded-md border border-slate-200 px-2 py-1.5 text-xs font-medium text-slate-600 transition hover:border-indigo-200 hover:bg-indigo-50 hover:text-indigo-700 dark:border-slate-700 dark:text-slate-300 dark:hover:border-indigo-500/40 dark:hover:bg-indigo-500/10 dark:hover:text-indigo-300"><Eye class="h-3 w-3" />Просмотр</Link>
                    </div>
                </div>
                <div v-if="props.products.data.length === 0" class="rounded-lg border border-slate-200 bg-white p-6 text-center dark:border-slate-700 dark:bg-slate-900">
                    <div class="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-xl bg-slate-100 text-slate-400 dark:bg-slate-800 dark:text-slate-500"><Package class="h-6 w-6" /></div>
                    <p class="font-semibold text-slate-900 dark:text-white text-xs">Товары не найдены</p>
                </div>
            </div>
            <div class="hidden overflow-x-auto md:block">
                <table
                    class="w-full min-w-[1050px] divide-y divide-slate-100 text-sm dark:divide-slate-800"
                >
                    <thead
                        class="bg-slate-50 text-left text-xs font-semibold tracking-wide text-slate-500 uppercase dark:bg-slate-950/60 dark:text-slate-400"
                    >
                        <tr>
                            <th class="px-5 py-4">Товар</th>
                            <th class="px-5 py-4">Категория</th>
                            <th class="px-5 py-4">Расположение</th>
                            <th class="px-5 py-4 text-right">Всего</th>
                            <th class="px-5 py-4 text-right">Минимум</th>
                            <th class="px-5 py-4 text-right">Не хватает</th>
                            <th class="px-5 py-4 text-right">Действия</th>
                        </tr>
                    </thead>

                    <tbody
                        class="divide-y divide-slate-100 dark:divide-slate-800"
                    >
                        <tr
                            v-for="product in props.products.data"
                            :key="product.id"
                            class="align-top transition hover:bg-slate-50/80 dark:hover:bg-slate-800/40"
                            :class="
                                Number(product.stock_deficit) > 0
                                    ? 'bg-rose-50/50 dark:bg-rose-500/5'
                                    : ''
                            "
                        >
                            <td class="px-5 py-4">
                                <div
                                    class="font-medium text-slate-900 dark:text-white"
                                >
                                    {{ product.name }}
                                </div>

                                <div
                                    class="mt-1 text-xs text-slate-500 dark:text-slate-400"
                                >
                                    Артикул: {{ product.sku || '—' }}
                                </div>
                            </td>

                            <td
                                class="px-5 py-4 text-slate-600 dark:text-slate-400"
                            >
                                {{ product.category || '—' }}
                            </td>

                            <td class="px-5 py-4">
                                <div
                                    v-if="product.locations.length"
                                    class="flex flex-wrap gap-1.5"
                                >
                                    <span
                                        v-for="location in product.locations"
                                        :key="location.id"
                                        class="inline-flex items-center gap-1 rounded-md border border-slate-200 bg-slate-50 px-2 py-1 text-xs text-slate-700 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300"
                                    >
                                        <span class="font-semibold">
                                            {{ location.code }}
                                        </span>

                                        <span
                                            v-if="location.rack_code"
                                            class="text-slate-500 dark:text-slate-400"
                                        >
                                            ({{ location.rack_code }})
                                        </span>

                                        <span
                                            class="text-slate-500 dark:text-slate-400"
                                        >
                                            ·
                                            {{
                                                formatNumber(location.quantity)
                                            }}
                                            {{ product.unit }}
                                        </span>
                                    </span>
                                </div>

                                <span
                                    v-else
                                    class="text-slate-400 dark:text-slate-500"
                                >
                                    Не размещён
                                </span>
                            </td>

                            <td class="px-5 py-4 text-right">
                                <span
                                    class="inline-flex min-w-12 justify-center rounded-lg px-2.5 py-1 font-semibold"
                                    :class="
                                        Number(product.stock_quantity) > 0
                                            ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400'
                                            : 'bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400'
                                    "
                                >
                                    {{ formatNumber(product.stock_quantity) }}
                                    {{ product.unit }}
                                </span>
                            </td>

                            <td class="px-5 py-4 text-right">
                                <span
                                    v-if="product.minimum_stock !== null"
                                    class="text-slate-700 dark:text-slate-300"
                                >
                                    {{ formatNumber(product.minimum_stock) }}
                                    {{ product.unit }}
                                </span>

                                <span
                                    v-else
                                    class="text-slate-400 dark:text-slate-500"
                                >
                                    Не задан
                                </span>
                            </td>

                            <td class="px-5 py-4 text-right">
                                <span
                                    v-if="Number(product.stock_deficit) > 0"
                                    class="inline-flex min-w-16 justify-center rounded-lg bg-rose-100 px-2.5 py-1 font-semibold text-rose-700 dark:bg-rose-500/10 dark:text-rose-400"
                                >
                                    {{ formatNumber(product.stock_deficit) }}
                                    {{ product.unit }}
                                </span>

                                <span
                                    v-else
                                    class="text-slate-400 dark:text-slate-500"
                                >
                                    —
                                </span>
                            </td>

                            <td class="px-5 py-4 text-right">
                                <Link
                                    :href="`/admin/products/${product.id}`"
                                    class="font-medium text-slate-700 underline decoration-slate-300 underline-offset-4 hover:text-slate-950 dark:text-slate-300 dark:decoration-slate-600 dark:hover:text-white"
                                >
                                    Открыть
                                </Link>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Пагинация -->
            <div
                v-if="props.products.links.length > 3"
                class="flex flex-col gap-4 border-t border-slate-200 px-5 py-5 sm:flex-row sm:items-center sm:justify-between dark:border-slate-800"
            >
                <p class="text-sm text-slate-500 dark:text-slate-400">
                    Показано {{ props.products.from ?? 0 }}–{{
                        props.products.to ?? 0
                    }}
                    из {{ props.products.total }}
                </p>

                <nav
                    v-if="props.products.total > 0"
                    class="flex flex-wrap items-center justify-center gap-1"
                    aria-label="Навигация по страницам"
                >
                    <template
                        v-for="(link, index) in props.products.links"
                        :key="`${index}-${link.label}`"
                    >
                        <!-- Назад -->
                        <Link
                            v-if="index === 0 && link.url"
                            :href="link.url"
                            preserve-scroll
                            class="inline-flex h-9 items-center gap-2 rounded-xl border border-slate-200 px-3 text-sm font-medium text-slate-600 transition hover:border-indigo-500/30 hover:bg-indigo-500/5 hover:text-indigo-600 dark:border-slate-700 dark:text-slate-300"
                        >
                            <ChevronLeft class="h-4 w-4" />
                            <span>Назад</span>
                        </Link>

                        <span
                            v-else-if="index === 0"
                            class="inline-flex h-9 cursor-not-allowed items-center gap-2 rounded-xl border border-slate-100 px-3 text-sm text-slate-300 dark:border-slate-800 dark:text-slate-600"
                        >
                            <ChevronLeft class="h-4 w-4" />
                            <span>Назад</span>
                        </span>

                        <!-- Номера страниц -->
                        <Link
                            v-else-if="
                                index !== props.products.links.length - 1 &&
                                link.url
                            "
                            :href="link.url"
                            preserve-scroll
                            class="inline-flex h-9 min-w-9 items-center justify-center rounded-xl border px-3 text-sm font-medium transition"
                            :class="
                                link.active
                                    ? 'border-indigo-600 bg-gradient-to-r from-indigo-600 to-violet-600 text-white shadow-sm'
                                    : 'border-slate-200 text-slate-600 hover:border-indigo-500/30 hover:bg-indigo-500/5 hover:text-indigo-600 dark:border-slate-700 dark:text-slate-300'
                            "
                            v-html="link.label"
                        />

                        <span
                            v-else-if="
                                index !== props.products.links.length - 1
                            "
                            class="inline-flex h-9 min-w-9 items-center justify-center px-2 text-sm text-slate-400"
                            v-html="link.label"
                        />

                        <!-- Далее -->
                        <Link
                            v-else-if="link.url"
                            :href="link.url"
                            preserve-scroll
                            class="inline-flex h-9 items-center gap-2 rounded-xl border border-slate-200 px-3 text-sm font-medium text-slate-600 transition hover:border-indigo-500/30 hover:bg-indigo-500/5 hover:text-indigo-600 dark:border-slate-700 dark:text-slate-300"
                        >
                            <span>Далее</span>
                            <ChevronRight class="h-4 w-4" />
                        </Link>

                        <span
                            v-else
                            class="inline-flex h-9 cursor-not-allowed items-center gap-2 rounded-xl border border-slate-100 px-3 text-sm text-slate-300 dark:border-slate-800 dark:text-slate-600"
                        >
                            <span>Далее</span>
                            <ChevronRight class="h-4 w-4" />
                        </span>
                    </template>
                </nav>
            </div>
        </div>
    </div>
</template>
