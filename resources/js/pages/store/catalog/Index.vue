<script setup lang="ts">
import { Head, router } from '@inertiajs/vue3'
import {
    ChevronDown,
    ChevronUp,
    Filter,
    Package,
    SortAsc,
    SortDesc,
} from '@lucide/vue'
import { computed, ref } from 'vue'

const props = defineProps<{
    products: {
        data: Array<{
            id: number
            name: string
            slug: string
            sku: string | null
            price: string
            image_path?: string | null
            stock_status: string
            category?: string
        }>
        current_page: number
        last_page: number
        per_page: number
        total: number
        links: Array<{ url: string | null, label: string, active: boolean }>
    }
    categories: Array<{ id: number, name: string, slug: string }>
    manufacturers: Array<{ id: number, name: string }>
    characteristics: Array<{
        id: number
        name: string
        slug: string
        type: string
        unit: string | null
    }>
    characteristic_values: Record<string, string[]>
    filters: {
        category?: string | null
        manufacturer?: string | null
        characteristics: Array<{ id: number }>
        sort: string
        direction: string
    }
}>()

const item_count = computed(() => props.products.total)

// Filter state
const showFilters = ref(false)
const sortDropdown = ref(false)
const searchQuery = ref(props.filters.category ? '' : '')

function goCatalog(params: Record<string, string | number | undefined>) {
    router.get(route('store.catalog.index'), params, {
        preserveState: true,
        preserveScroll: true,
        only: ['products', 'filters'],
    })
}

function applyFilters() {
    const params: Record<string, string | number | undefined> = {}

    if (props.filters.category) {
        params.category = props.filters.category
    }
    if (props.filters.manufacturer) {
        params.manufacturer = props.filters.manufacturer
    }
    params.sort = props.filters.sort
    params.direction = props.filters.direction

    router.get(route('store.catalog.index'), params, {
        preserveState: true,
        preserveScroll: true,
    })
}

function clearFilters() {
    router.get(route('store.catalog.index'), {}, {
        preserveState: true,
        preserveScroll: true,
    })
}

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}

function stockStatusLabel(status: string): string {
    const map: Record<string, string> = {
        in_stock: 'В наличии',
        out_of_stock: 'Нет в наличии',
        backorder: 'Под заказ',
    }
    return map[status] || status
}

function stockStatusClass(status: string): string {
    const map: Record<string, string> = {
        in_stock: 'bg-emerald-100 text-emerald-700',
        out_of_stock: 'bg-rose-100 text-rose-700',
        backorder: 'bg-amber-100 text-amber-700',
    }
    return map[status] || 'bg-slate-100 text-slate-700'
}

const sortOptions = [
    { value: 'created_at', label: 'Новизна' },
    { value: 'name', label: 'Название' },
    { value: 'price', label: 'Цена' },
]
</script>

<template>
    <Head title="Каталог товаров" />

        <div class="mx-auto max-w-7xl px-5 py-8 lg:px-10">
            <!-- Header -->
            <div class="mb-6 flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
                <div>
                    <h1 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">Каталог товаров</h1>
                    <p class="mt-1 text-sm text-slate-500">
                        Найдено товаров: {{ products.total }}
                    </p>
                </div>

                <div class="flex items-center gap-2">
                    <!-- Mobile filter button -->
                    <button
                        @click="showFilters = !showFilters"
                        class="inline-flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-sm font-medium text-slate-700 hover:border-emerald-300 sm:hidden"
                    >
                        <Filter :size="16" />
                        Фильтры
                    </button>

                    <!-- Sort -->
                    <div class="relative hidden sm:block">
                        <select
                            v-model="filters.sort"
                            @change="applyFilters"
                            class="rounded-lg border border-slate-200 px-3 py-2 text-sm text-slate-700 focus:border-emerald-400"
                        >
                            <option
                                v-for="opt in sortOptions"
                                :key="opt.value"
                                :value="opt.value"
                            >
                                {{ opt.label }}
                            </option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="flex gap-8">
                <!-- Sidebar filters -->
                <aside
                    class="w-64 shrink-0"
                    :class="showFilters ? 'block sm:hidden' : 'hidden sm:block'"
                >
                    <div class="sticky top-24 space-y-6">
                        <!-- Category filter -->
                        <div>
                            <h3 class="mb-3 text-sm font-bold text-slate-900">Категории</h3>
                            <div class="space-y-1">
                                <label
                                    v-for="cat in categories"
                                    :key="cat.id"
                                    class="flex cursor-pointer items-center gap-2 text-sm text-slate-600 hover:text-emerald-700"
                                >
                                    <input
                                        type="radio"
                                        :value="cat.slug"
                                        :checked="filters.category === cat.slug"
                                        @change="goCatalog({ category: cat.slug })"
                                        class="accent-emerald-600"
                                    />
                                    {{ cat.name }}
                                </label>
                            </div>
                        </div>

                        <!-- Manufacturer filter -->
                        <div v-if="manufacturers.length > 0">
                            <h3 class="mb-3 text-sm font-bold text-slate-900">Производители</h3>
                            <div class="space-y-1">
                                <label
                                    v-for="mfr in manufacturers"
                                    :key="mfr.id"
                                    class="flex cursor-pointer items-center gap-2 text-sm text-slate-600 hover:text-emerald-700"
                                >
                                    <input
                                        type="radio"
                                        :value="mfr.id"
                                        :checked="filters.manufacturer == String(mfr.id)"
                                        @change="goCatalog({ manufacturer: mfr.id })"
                                        class="accent-emerald-600"
                                    />
                                    {{ mfr.name }}
                                </label>
                            </div>
                        </div>

                        <!-- Clear filters -->
                        <button
                            @click="clearFilters"
                            class="text-sm font-medium text-emerald-700 hover:text-emerald-800"
                        >
                            Сбросить фильтры
                        </button>
                    </div>
                </aside>

                <!-- Product grid -->
                <div class="flex-1">
                    <div v-if="products.data.length > 0" class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                        <div
                            v-for="product in products.data"
                            :key="product.id"
                            class="group rounded-2xl border border-slate-200 bg-white overflow-hidden transition hover:border-emerald-200 hover:shadow-lg hover:shadow-slate-900/[0.04]"
                        >
                            <!-- Image -->
                            <a
                                :href="route('store.products.show', { product: product.slug })"
                                class="aspect-square bg-slate-100 flex items-center justify-center overflow-hidden"
                            >
                                <div v-if="product.image_path" class="h-full w-full object-cover">
                                    <img
                                        :src="product.image_path"
                                        :alt="product.name"
                                        loading="lazy"
                                        decoding="async"
                                        class="h-full w-full object-cover"
                                    />
                                </div>
                                <div v-else class="text-slate-300">
                                    <Package :size="40" />
                                </div>
                            </a>

                            <div class="p-4">
                                <a
                                    :href="route('store.products.show', { product: product.slug })"
                                    class="text-sm font-semibold text-slate-900 hover:text-emerald-700 line-clamp-2"
                                >
                                    {{ product.name }}
                                </a>

                                <p v-if="product.sku" class="mt-0.5 text-xs text-slate-400">
                                    Арт: {{ product.sku }}
                                </p>

                                <div class="mt-3 flex items-center justify-between">
                                    <div class="text-lg font-extrabold text-slate-900">
                                        {{ formatPrice(product.price) }} ₽
                                    </div>
                                    <span
                                        class="rounded-full px-2 py-0.5 text-[10px] font-bold"
                                        :class="stockStatusClass(product.stock_status)"
                                    >
                                        {{ stockStatusLabel(product.stock_status) }}
                                    </span>
                                </div>

                                <a
                                    :href="route('store.products.show', { product: product.slug })"
                                    class="mt-3 block text-center rounded-lg bg-emerald-600 py-2 text-sm font-semibold text-white transition group-hover:bg-emerald-700"
                                >
                                    Подробнее
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Empty state -->
                    <div v-else class="rounded-2xl border border-slate-200 bg-white p-16 text-center">
                        <div class="mx-auto flex size-16 items-center justify-center rounded-2xl bg-slate-100 text-slate-400">
                            <Package :size="32" />
                        </div>
                        <h3 class="mt-4 text-lg font-bold text-slate-900">Товары не найдены</h3>
                        <p class="mt-2 text-sm text-slate-500">Попробуйте изменить параметры поиска</p>
                        <button
                            @click="clearFilters"
                            class="mt-4 rounded-lg bg-emerald-600 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-700"
                        >
                            Показать все товары
                        </button>
                    </div>

                    <!-- Pagination -->
                    <div v-if="products.data.length > 0" class="mt-8 flex justify-center">
                        <nav class="flex items-center gap-1">
                            <template v-for="(link, i) in products.links" :key="i">
                                <button
                                    v-if="link.url"
                                    :disabled="!link.url"
                                    :class="[
                                        'rounded-lg px-3 py-2 text-sm font-medium transition',
                                        link.active
                                            ? 'bg-emerald-600 text-white'
                                            : 'text-slate-600 hover:bg-slate-100'
                                    ]"
                                    @click="goCatalog({ page: link.label.replace('&laquo;', '1').replace('&raquo;', '1') })"
                                    v-html="link.label"
                                />
                                <span v-else class="px-2 text-slate-400">…</span>
                            </template>
                        </nav>
                    </div>
                </div>
            </div>
        </div>
</template>
