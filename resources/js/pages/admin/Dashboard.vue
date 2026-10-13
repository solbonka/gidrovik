<script setup lang="ts">
import { Link } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'

interface StockByUnit {
    unit: string
    quantity: string
}

interface Statistics {
    products: number
    categories: number
    racks: number
    locations: number
    products_with_stock: number
    stock_by_unit: StockByUnit[]
    products_below_minimum: number
}

interface Movement {
    id: number
    product_name: string
    sku: string | null
    type: string
    type_label: string
    quantity: number
    from_location: string | null
    from_rack: string | null
    to_location: string | null
    to_rack: string | null
    comment: string | null
    created_at: string | null
}

interface Props {
    statistics: Statistics
    movements: Movement[]
}

defineProps<Props>()

interface StatisticCard {
    key: Exclude<keyof Statistics, 'stock_by_unit'>
    title: string
    description: string
}

const statisticCards: StatisticCard[] = [
    {
        key: 'products',
        title: 'Товары',
        description: 'Активных товаров',
    },
    {
        key: 'categories',
        title: 'Категории',
        description: 'Активных категорий',
    },
    {
        key: 'racks',
        title: 'Стеллажи',
        description: 'Всего стеллажей',
    },
    {
        key: 'locations',
        title: 'Места хранения',
        description: 'Всего мест',
    },
    {
        key: 'products_with_stock',
        title: 'Товары на складе',
        description: 'Позиций с ненулевым остатком',
    },
]

const quickActions = [
    {
        title: 'Добавить товар',
        description: 'Создать товар в каталоге',
        href: '/admin/products/create',
        icon: '+',
    },
    {
        title: 'Приход товара',
        description: 'Поступление на склад',
        href: '/admin/stock/receipt',
        icon: '↓',
    },
    {
        title: 'Перемещение',
        description: 'Переместить между ячейками',
        href: '/admin/stock/transfer',
        icon: '↔',
    },
    {
        title: 'Списание',
        description: 'Списать товар с остатка',
        href: '/admin/stock/write-off',
        icon: '−',
    },
    {
        title: 'Возврат',
        description: 'Оформить возврат товара',
        href: '/admin/stock/return',
        icon: '↶',
    },
    {
        title: 'Инвентаризация',
        description: 'Сверить фактический остаток',
        href: '/admin/stock/inventory',
        icon: '✓',
    },
]

function formatNumber(value: number | string): string {
    return Number(value).toLocaleString('ru-RU', {
        maximumFractionDigits: 3,
    })
}

function movementLocation(movement: Movement): string {
    if (movement.from_location && movement.to_location) {
        return `${movement.from_location} → ${movement.to_location}`
    }

    if (movement.to_location) {
        return `→ ${movement.to_location}`
    }

    if (movement.from_location) {
        return `${movement.from_location} → списание`
    }

    return 'Место не указано'
}
</script>

<template>
    <AdminLayout>
        <div class="space-y-8">
            <header>
                <h1 class="text-2xl font-bold text-gray-900">
                    Обзор склада
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    Основные показатели, операции и последние движения товара.
                </p>
            </header>

            <section>
                <div class="mb-4 flex items-center justify-between gap-4">
                    <h2 class="text-lg font-semibold text-gray-900">
                        Показатели склада
                    </h2>

                    <Link
                        href="/admin/stock"
                        class="text-sm font-medium text-indigo-600 hover:text-indigo-800"
                    >
                        Все остатки →
                    </Link>
                </div>

                <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
                    <div
                        v-for="card in statisticCards"
                        :key="card.key"
                        class="rounded-xl border border-gray-200 bg-white p-5 shadow-sm"
                    >
                        <p class="text-sm font-medium text-gray-500">
                            {{ card.title }}
                        </p>

                        <p class="mt-2 text-3xl font-bold text-gray-900">
                            {{ formatNumber(statistics[card.key]) }}
                        </p>

                        <p class="mt-1 text-xs text-gray-400">
                            {{ card.description }}
                        </p>
                    </div>
                </div>
                <div
                    class="mt-4 rounded-xl border border-gray-200 bg-white p-5 shadow-sm"
                >
                    <h3 class="text-sm font-semibold text-gray-900">
                        Остатки по единицам измерения
                    </h3>

                    <div
                        v-if="statistics.stock_by_unit.length === 0"
                        class="mt-3 text-sm text-gray-500"
                    >
                        На складе пока нет учтённых остатков.
                    </div>

                    <div v-else class="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-5">
                        <div
                            v-for="stock in statistics.stock_by_unit"
                            :key="stock.unit"
                            class="rounded-lg bg-gray-50 p-4"
                        >
                            <p class="text-sm text-gray-500">
                                {{ stock.unit }}
                            </p>

                            <p class="mt-1 text-2xl font-bold text-gray-900">
                                {{ formatNumber(stock.quantity) }}
                            </p>
                        </div>
                    </div>
                </div>
            </section>
            <Link
                href="/admin/stock?stock=below_minimum"
                class="group flex items-center justify-between gap-4 rounded-xl border border-red-200 bg-red-50 p-5 shadow-sm transition hover:border-red-300 hover:bg-red-100"
            >
                <div>
                    <h3 class="font-semibold text-red-800">
                        Товары ниже минимального остатка
                    </h3>

                    <p class="mt-1 text-sm text-red-600">
                        Товары, требующие пополнения
                    </p>

                    <span
                        class="mt-3 inline-block text-sm font-medium text-red-700 group-hover:underline"
                    >
                        Посмотреть товары →
                    </span>
                </div>

                <div class="shrink-0 text-3xl font-bold text-red-800">
                    {{ formatNumber(statistics.products_below_minimum) }}
                </div>
            </Link>
            <section>
                <h2 class="mb-4 text-lg font-semibold text-gray-900">
                    Быстрые действия
                </h2>

                <div class="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
                    <Link
                        v-for="action in quickActions"
                        :key="action.href"
                        :href="action.href"
                        class="group flex items-start gap-4 rounded-xl border border-gray-200 bg-white p-4 shadow-sm transition hover:border-indigo-300 hover:bg-indigo-50/50"
                    >
                        <span
                            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-indigo-100 text-xl font-semibold text-indigo-700 transition group-hover:bg-indigo-200"
                        >
                            {{ action.icon }}
                        </span>

                        <span>
                            <span class="block font-semibold text-gray-900">
                                {{ action.title }}
                            </span>

                            <span class="mt-1 block text-sm text-gray-500">
                                {{ action.description }}
                            </span>
                        </span>
                    </Link>
                </div>
            </section>

            <section class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm">
                <div class="flex flex-wrap items-center justify-between gap-3 border-b border-gray-200 px-5 py-4">
                    <div>
                        <h2 class="text-lg font-semibold text-gray-900">
                            Последние движения
                        </h2>

                        <p class="mt-1 text-sm text-gray-500">
                            Последние операции с товарами на складе.
                        </p>
                    </div>

                    <Link
                        href="/admin/stock/movements"
                        class="text-sm font-medium text-indigo-600 hover:text-indigo-800"
                    >
                        Вся история →
                    </Link>
                </div>

                <div
                    v-if="movements.length === 0"
                    class="px-5 py-12 text-center"
                >
                    <p class="font-medium text-gray-700">
                        Движений пока нет
                    </p>

                    <p class="mt-1 text-sm text-gray-500">
                        После первой складской операции она появится здесь.
                    </p>
                </div>

                <div v-else class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                        <tr>
                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-500">
                                Дата
                            </th>

                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-500">
                                Товар
                            </th>

                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-500">
                                Операция
                            </th>

                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-500">
                                Количество
                            </th>

                            <th class="px-5 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-500">
                                Размещение
                            </th>
                        </tr>
                        </thead>

                        <tbody class="divide-y divide-gray-100">
                        <tr
                            v-for="movement in movements"
                            :key="movement.id"
                            class="hover:bg-gray-50"
                        >
                            <td class="whitespace-nowrap px-5 py-4 text-sm text-gray-500">
                                {{ movement.created_at ?? '—' }}
                            </td>

                            <td class="px-5 py-4">
                                <div class="font-medium text-gray-900">
                                    {{ movement.product_name }}
                                </div>

                                <div class="mt-1 text-xs text-gray-500">
                                    Артикул: {{ movement.sku || '—' }}
                                </div>
                            </td>

                            <td class="whitespace-nowrap px-5 py-4">
                                    <span class="inline-flex rounded-full bg-gray-100 px-2.5 py-1 text-xs font-medium text-gray-700">
                                        {{ movement.type_label }}
                                    </span>
                            </td>

                            <td class="whitespace-nowrap px-5 py-4 text-sm font-semibold text-gray-900">
                                {{ formatNumber(movement.quantity) }}
                            </td>

                            <td class="whitespace-nowrap px-5 py-4 text-sm text-gray-600">
                                {{ movementLocation(movement) }}
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </AdminLayout>
</template>
