<script setup lang="ts">
import { Package, Search } from '@lucide/vue'

const props = defineProps<{
    query: string
    products: Array<{
        id: number
        name: string
        slug: string
        sku: string | null
        price: string
        image_path?: string | null
        stock_status: string
        category?: string | null
    }>
    total: number
}>()

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
</script>

<template>
    <div class="mx-auto max-w-7xl px-5 py-8 lg:px-10">
            <h1 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">
                Результаты поиска
            </h1>

            <p v-if="query" class="mt-2 text-sm text-slate-500">
                По запросу: <strong>{{ query }}</strong> · Найдено: {{ total }}
            </p>

            <div v-if="products.length > 0" class="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                <div
                    v-for="product in products"
                    :key="product.id"
                    class="rounded-2xl border border-slate-200 bg-white overflow-hidden transition hover:border-emerald-200"
                >
                    <a
                        :href="route('store.products.show', { product: product.slug })"
                        class="aspect-square bg-slate-100 flex items-center justify-center"
                    >
                        <div v-if="product.image_path" class="h-full w-full overflow-hidden">
                            <img :src="product.image_path" :alt="product.name" class="h-full w-full object-cover" />
                        </div>
                        <div v-else class="text-slate-300">
                            <Package :size="40" />
                        </div>
                    </a>

                    <div class="p-4">
                        <a
                            :href="route('store.products.show', { product: product.slug })"
                            class="text-sm font-semibold text-slate-900 line-clamp-2 hover:text-emerald-700"
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
                    </div>
                </div>
            </div>

            <!-- Empty state -->
            <div v-else-if="query.length >= 2" class="mt-8 rounded-2xl border border-slate-200 bg-white p-16 text-center">
                <div class="mx-auto flex size-16 items-center justify-center rounded-2xl bg-slate-100 text-slate-400">
                    <Search :size="32" />
                </div>
                <h3 class="mt-4 text-lg font-bold text-slate-900">Ничего не найдено</h3>
                <p class="mt-2 text-sm text-slate-500">
                    Попробуйте изменить запрос или перейдите в <a :href="route('store.catalog.index')" class="text-emerald-700 hover:underline">каталог</a>
                </p>
            </div>

            <div v-else class="mt-8 rounded-2xl border border-slate-200 bg-white p-16 text-center">
                <p class="text-sm text-slate-500">Введите минимум 2 символа для поиска</p>
            </div>
        </div>
</template>
