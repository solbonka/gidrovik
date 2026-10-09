<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import { reactive } from 'vue'
import AdminLayout from '@/layouts/AdminLayout.vue'

defineOptions({
    layout: AdminLayout,
})

interface CategoryOption {
    id: number
    name: string
}

interface RackOption {
    id: number
    code: string
    name: string | null
}

interface StockLocation {
    id: number
    code: string
    rack_code: string | null
    rack_name: string | null
    quantity: number
}

interface StockProduct {
    id: number
    name: string
    sku: string | null
    category: string | null
    stock_quantity: number
    locations: StockLocation[]
}

interface PaginationLink {
    url: string | null
    label: string
    active: boolean
}

interface PaginatedProducts {
    data: StockProduct[]
    links: PaginationLink[]
    current_page: number
    last_page: number
    total: number
    from: number | null
    to: number | null
}

interface Filters {
    search: string
    category_id: string
    rack_id: string
    stock: string
}

const props = defineProps<{
    products: PaginatedProducts
    categories: CategoryOption[]
    racks: RackOption[]
    filters: Filters
}>()

const filters = reactive<Filters>({
    ...props.filters,
})

function applyFilters(): void {
    router.get('/admin/stock', {
        search: filters.search || undefined,
        category_id: filters.category_id || undefined,
        rack_id: filters.rack_id || undefined,
        stock: filters.stock === 'all' ? undefined : filters.stock,
    }, {
        preserveState: true,
        preserveScroll: true,
        replace: true,
    })
}

function resetFilters(): void {
    filters.search = ''
    filters.category_id = ''
    filters.rack_id = ''
    filters.stock = 'all'

    applyFilters()
}
</script>

<template>
    <Head title="Остатки на складе" />

    <div class="space-y-6">
        <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
                <h1 class="text-2xl font-semibold text-gray-900">
                    Остатки на складе
                </h1>
                <p class="mt-1 text-sm text-gray-500">
                    Текущие запасы товаров и их расположение по ячейкам.
                </p>
            </div>

            <Link
                href="/admin/stock/receipt"
                class="inline-flex items-center justify-center rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800"
            >
                + Поступление товара
            </Link>
        </div>

        <!-- Быстрые переходы -->
        <div class="flex flex-wrap gap-2">
            <Link
                href="/admin/stock/transfer"
                class="rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-700 hover:bg-gray-50"
            >
                Перемещение
            </Link>

            <Link
                href="/admin/stock/return"
                class="rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-700 hover:bg-gray-50"
            >
                Возврат
            </Link>

            <Link
                href="/admin/stock/write-off"
                class="rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-700 hover:bg-gray-50"
            >
                Списание
            </Link>

            <Link
                href="/admin/stock/inventory"
                class="rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-700 hover:bg-gray-50"
            >
                Инвентаризация
            </Link>

            <Link
                href="/admin/stock/movements"
                class="rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-700 hover:bg-gray-50"
            >
                Журнал операций
            </Link>
        </div>

        <!-- Фильтры -->
        <form
            class="space-y-4 rounded-xl border border-gray-200 bg-white p-4 shadow-sm"
            @submit.prevent="applyFilters"
        >
            <div class="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-4">
                <div>
                    <label
                        for="search"
                        class="mb-1.5 block text-sm font-medium text-gray-700"
                    >
                        Поиск товара
                    </label>
                    <input
                        id="search"
                        v-model="filters.search"
                        type="search"
                        placeholder="Название или артикул"
                        class="block w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm focus:border-gray-500 focus:outline-none focus:ring-1 focus:ring-gray-500"
                    />
                </div>

                <div>
                    <label
                        for="category_id"
                        class="mb-1.5 block text-sm font-medium text-gray-700"
                    >
                        Категория
                    </label>
                    <select
                        id="category_id"
                        v-model="filters.category_id"
                        class="block w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm focus:border-gray-500 focus:outline-none focus:ring-1 focus:ring-gray-500"
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
                        class="mb-1.5 block text-sm font-medium text-gray-700"
                    >
                        Стеллаж
                    </label>
                    <select
                        id="rack_id"
                        v-model="filters.rack_id"
                        class="block w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm focus:border-gray-500 focus:outline-none focus:ring-1 focus:ring-gray-500"
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
                        class="mb-1.5 block text-sm font-medium text-gray-700"
                    >
                        Наличие
                    </label>
                    <select
                        id="stock"
                        v-model="filters.stock"
                        class="block w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm focus:border-gray-500 focus:outline-none focus:ring-1 focus:ring-gray-500"
                    >
                        <option value="all">Все товары</option>
                        <option value="in_stock">Есть остаток</option>
                        <option value="out_of_stock">Нет остатка</option>
                    </select>
                </div>
            </div>

            <div class="flex flex-wrap justify-end gap-2 border-t border-gray-100 pt-4">
                <button
                    type="button"
                    class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
                    @click="resetFilters"
                >
                    Сбросить
                </button>

                <button
                    type="submit"
                    class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800"
                >
                    Применить фильтры
                </button>
            </div>
        </form>

        <!-- Таблица -->
        <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm">
            <div class="flex flex-col gap-1 border-b border-gray-200 px-4 py-3 sm:flex-row sm:items-center sm:justify-between">
                <h2 class="font-semibold text-gray-900">
                    Складские запасы
                </h2>
                <p class="text-sm text-gray-500">
                    Найдено товаров: {{ props.products.total }}
                </p>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full min-w-[850px] divide-y divide-gray-200 text-sm">
                    <thead class="bg-gray-50 text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
                    <tr>
                        <th class="px-4 py-3">Товар</th>
                        <th class="px-4 py-3">Категория</th>
                        <th class="px-4 py-3">Расположение</th>
                        <th class="px-4 py-3 text-right">Всего</th>
                        <th class="px-4 py-3 text-right">Действия</th>
                    </tr>
                    </thead>

                    <tbody class="divide-y divide-gray-100">
                    <tr
                        v-for="product in props.products.data"
                        :key="product.id"
                        class="align-top hover:bg-gray-50"
                    >
                        <td class="px-4 py-4">
                            <div class="font-medium text-gray-900">
                                {{ product.name }}
                            </div>
                            <div class="mt-1 text-xs text-gray-500">
                                Артикул: {{ product.sku || '—' }}
                            </div>
                        </td>

                        <td class="px-4 py-4 text-gray-600">
                            {{ product.category || '—' }}
                        </td>

                        <td class="px-4 py-4">
                            <div
                                v-if="product.locations.length"
                                class="flex flex-wrap gap-1.5"
                            >
                                    <span
                                        v-for="location in product.locations"
                                        :key="location.id"
                                        class="inline-flex items-center gap-1 rounded-md border border-gray-200 bg-gray-50 px-2 py-1 text-xs text-gray-700"
                                    >
                                        <span class="font-semibold">
                                            {{ location.code }}
                                        </span>
                                        <span class="text-gray-500">
                                            · {{ location.quantity }} шт.
                                        </span>
                                    </span>
                            </div>

                            <span
                                v-else
                                class="text-gray-400"
                            >
                                    Не размещён
                                </span>
                        </td>

                        <td class="px-4 py-4 text-right">
                                <span
                                    class="inline-flex min-w-12 justify-center rounded-lg px-2.5 py-1 font-semibold"
                                    :class="
                                        product.stock_quantity > 0
                                            ? 'bg-green-50 text-green-700'
                                            : 'bg-gray-100 text-gray-500'
                                    "
                                >
                                    {{ product.stock_quantity }}
                                </span>
                        </td>

                        <td class="px-4 py-4 text-right">
                            <Link
                                :href="`/admin/products/${product.id}`"
                                class="font-medium text-gray-700 underline decoration-gray-300 underline-offset-4 hover:text-gray-950"
                            >
                                Открыть
                            </Link>
                        </td>
                    </tr>

                    <tr v-if="props.products.data.length === 0">
                        <td
                            colspan="5"
                            class="px-4 py-12 text-center"
                        >
                            <p class="font-medium text-gray-900">
                                Товары не найдены
                            </p>
                            <p class="mt-1 text-sm text-gray-500">
                                Измените параметры поиска или сбросьте фильтры.
                            </p>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <!-- Пагинация -->
            <div class="flex flex-col gap-3 border-t border-gray-200 px-4 py-3 sm:flex-row sm:items-center sm:justify-between">
                <p class="text-sm text-gray-500">
                    Показано {{ props.products.from ?? 0 }}–{{ props.products.to ?? 0 }}
                    из {{ props.products.total }}
                </p>

                <div class="flex flex-wrap gap-1">
                    <template
                        v-for="(link, index) in props.products.links"
                        :key="index"
                    >
                        <button
                            v-if="link.url"
                            type="button"
                            class="rounded-lg border px-3 py-1.5 text-sm"
                            :class="
                                link.active
                                    ? 'border-gray-900 bg-gray-900 text-white'
                                    : 'border-gray-200 bg-white text-gray-700 hover:bg-gray-50'
                            "
                            @click="router.visit(link.url)"
                            v-html="link.label"
                        />

                        <span
                            v-else
                            class="rounded-lg border border-gray-100 px-3 py-1.5 text-sm text-gray-300"
                            v-html="link.label"
                        />
                    </template>
                </div>
            </div>
        </div>
    </div>
</template>
