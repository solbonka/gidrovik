<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    PhPackage,
    PhMagnifyingGlass,
    PhCaretLeft,
} from '@phosphor-icons/vue'

const props = defineProps<{
    query: string
    products: Array<{
        id: number
        name: string
        slug: string
        code: string | null
        article: string | null
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
        in_stock: 'bg-emerald-500/10 text-emerald-700 dark:text-emerald-400',
        out_of_stock: 'bg-rose-500/10 text-rose-700 dark:text-rose-400',
        backorder: 'bg-amber-500/10 text-amber-700 dark:text-amber-400',
    }
    return map[status] || 'bg-zinc-500/10 text-zinc-600 dark:text-zinc-300'
}
</script>

<template>
    <Head title="Поиск" />

    <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-10 lg:py-12">
        <!-- Header -->
        <div class="mb-8 flex items-center gap-4">
            <a
                :href="route('store.catalog.index')"
                class="flex size-10 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-600 transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
            >
                <PhCaretLeft :size="20" weight="bold" />
            </a>
            <div>
                <p class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400">Поиск</p>
                <h1 class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-3xl">
                    Результаты поиска
                </h1>
                <p v-if="query" class="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
                    По запросу: <strong class="text-zinc-900 dark:text-zinc-100">{{ query }}</strong> · Найдено: {{ total }}
                </p>
            </div>
        </div>

        <div v-if="products.length > 0" class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <div
                v-for="product in products"
                :key="product.id"
                class="group overflow-hidden rounded-2xl border border-zinc-200 bg-white transition hover:shadow-lg dark:border-zinc-800 dark:bg-zinc-900"
            >
                <a
                    :href="route('store.products.show', { product: product.slug })"
                    class="aspect-square bg-zinc-100 flex items-center justify-center dark:bg-zinc-800"
                >
                    <div v-if="product.image_path" class="h-full w-full overflow-hidden">
                        <img :src="product.image_path" :alt="product.name" class="h-full w-full object-cover transition duration-500 group-hover:scale-[1.03]" />
                    </div>
                    <div v-else class="text-zinc-300 dark:text-zinc-600">
                        <PhPackage :size="40" weight="light" />
                    </div>
                </a>

                <div class="p-4">
                    <a
                        :href="route('store.products.show', { product: product.slug })"
                        class="text-sm font-semibold text-zinc-900 line-clamp-2 transition hover:text-orange-600 dark:text-zinc-100 dark:hover:text-orange-400"
                    >
                        {{ product.name }}
                    </a>

                    <div class="mt-1 flex flex-wrap gap-1.5">
                        <span v-if="product.code" class="rounded-md bg-zinc-100 px-2 py-0.5 text-[11px] font-medium text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400">
                            Код: {{ product.code }}
                        </span>
                        <span v-if="product.article" class="rounded-md bg-zinc-100 px-2 py-0.5 text-[11px] font-medium text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400">
                            Артикул: {{ product.article }}
                        </span>
                    </div>

                    <div class="mt-3 flex items-center justify-between">
                        <div class="text-lg font-black tracking-tight text-zinc-950 dark:text-white">
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
        <div v-else-if="query.length >= 2" class="rounded-3xl border border-dashed border-zinc-300 bg-white p-16 text-center dark:border-zinc-700 dark:bg-zinc-900">
            <div class="mx-auto mb-4 flex size-16 items-center justify-center rounded-2xl bg-zinc-100 text-zinc-400 dark:bg-zinc-800">
                <PhMagnifyingGlass :size="32" weight="light" />
            </div>
            <h3 class="text-xl font-extrabold text-zinc-900 dark:text-zinc-100">Ничего не найдено</h3>
            <p class="mt-2 text-sm text-zinc-500 dark:text-zinc-400">
                Попробуйте изменить запрос или перейдите в <a :href="route('store.catalog.index')" class="font-semibold text-orange-600 underline-offset-4 hover:underline dark:text-orange-400">каталог</a>
            </p>
        </div>

        <div v-else class="rounded-3xl border border-dashed border-zinc-300 bg-white p-16 text-center dark:border-zinc-700 dark:bg-zinc-900">
            <p class="text-sm text-zinc-500 dark:text-zinc-400">Введите минимум 2 символа для поиска</p>
        </div>
    </div>
</template>
