<script setup lang="ts">
import AdminLayout from '@/layouts/AdminLayout.vue'

interface Statistics {
    products: number
    categories: number
    racks: number
    locations: number
    stock_quantity: number
    products_with_stock: number
}

interface Props {
    statistics: Statistics
}

defineProps<Props>()

interface StatisticCard {
    key: keyof Statistics
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
        key: 'stock_quantity',
        title: 'Остаток',
        description: 'Единиц товара на складе',
    },
    {
        key: 'products_with_stock',
        title: 'Товары на складе',
        description: 'Товаров с остатком',
    },
]
</script>

<template>
    <AdminLayout>
        <div>
            <div class="mb-6">
                <h1 class="text-2xl font-bold text-gray-900">
                    Dashboard
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    Общая информация по складу
                </p>
            </div>

            <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
                <div
                    v-for="card in statisticCards"
                    :key="card.key"
                    class="rounded-xl border border-gray-200 bg-white p-5 shadow-sm"
                >
                    <div class="flex items-start justify-between">
                        <div>
                            <div class="text-sm font-medium text-gray-500">
                                {{ card.title }}
                            </div>

                            <div class="mt-2 text-3xl font-bold text-gray-900">
                                {{ statistics[card.key].toLocaleString('ru-RU') }}
                            </div>

                            <div class="mt-1 text-xs text-gray-400">
                                {{ card.description }}
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-6 grid gap-6 lg:grid-cols-2">
                <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
                    <h2 class="text-lg font-semibold text-gray-900">
                        Склад
                    </h2>

                    <p class="mt-2 text-sm text-gray-500">
                        На складе сейчас
                        <span class="font-semibold text-gray-900">
                            {{ statistics.stock_quantity.toLocaleString('ru-RU') }}
                        </span>
                        единиц товара.
                    </p>
                </div>

                <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
                    <h2 class="text-lg font-semibold text-gray-900">
                        Размещение
                    </h2>

                    <p class="mt-2 text-sm text-gray-500">
                        Используется
                        <span class="font-semibold text-gray-900">
                            {{ statistics.products_with_stock.toLocaleString('ru-RU') }}
                        </span>
                        товарных позиций.
                    </p>
                </div>
            </div>
        </div>
    </AdminLayout>
</template>
