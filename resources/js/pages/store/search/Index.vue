<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import { PhCaretLeft, PhMagnifyingGlass, PhPackage } from '@phosphor-icons/vue'

defineProps<{
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

const metaChipClass = 'rounded-lg bg-zinc-100 px-2 py-0.5 text-[11px] font-medium text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400'

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
        in_stock: 'bg-emerald-500/10 text-emerald-700 ring-emerald-500/20 dark:text-emerald-400',
        out_of_stock: 'bg-rose-500/10 text-rose-700 ring-rose-500/20 dark:text-rose-400',
        backorder: 'bg-amber-500/10 text-amber-700 ring-amber-500/20 dark:text-amber-400',
    }

    return map[status] || 'bg-zinc-500/10 text-zinc-600 ring-zinc-500/20 dark:text-zinc-300'
}
</script>

<template>
    <Head title="Поиск" />

    <div class="mx-auto max-w-7xl px-3 py-5 sm:px-6 sm:py-8 lg:px-10 lg:py-10">
        <!-- Шапка -->
        <header class="relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-orange-50 via-white to-white p-5 dark:border-zinc-800 dark:from-orange-500/10 dark:via-zinc-900 dark:to-zinc-900 sm:p-8">
            <div class="pointer-events-none absolute -right-16 -top-16 size-64 rounded-full bg-orange-400/20 blur-3xl dark:bg-orange-500/15" />
            <div class="pointer-events-none absolute -bottom-24 right-1/3 size-56 rounded-full bg-amber-300/20 blur-3xl dark:bg-amber-500/10" />

            <div class="relative flex flex-wrap items-center justify-between gap-x-6 gap-y-4">
                <div class="flex items-center gap-4">
                    <a
                        :href="route('store.catalog.index')"
                        class="flex size-11 shrink-0 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-600 shadow-sm transition hover:border-orange-400 hover:text-orange-600 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/20 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
                        aria-label="Назад в каталог"
                    >
                        <PhCaretLeft :size="20" weight="bold" />
                    </a>

                    <div class="min-w-0">
                        <p class="inline-flex items-center gap-2 rounded-full bg-orange-500/10 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400 sm:text-xs">
                            <span class="size-1.5 rounded-full bg-orange-500" />
                            Поиск
                        </p>

                        <h1 class="mt-2 text-3xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-4xl">
                            Результаты поиска
                        </h1>

                        <p v-if="query" class="mt-2 truncate text-sm text-zinc-500 dark:text-zinc-400">
                            По запросу
                            <strong class="rounded-md bg-orange-500/10 px-1.5 py-0.5 font-bold text-orange-700 dark:text-orange-300">{{ query }}</strong>
                        </p>
                    </div>
                </div>

                <p
                    v-if="query"
                    class="inline-flex items-baseline gap-1.5 rounded-2xl border border-zinc-200 bg-white/80 px-4 py-2 text-sm text-zinc-500 shadow-sm backdrop-blur dark:border-zinc-700 dark:bg-zinc-800/70 dark:text-zinc-400"
                >
                    Найдено
                    <span class="text-xl font-black text-zinc-900 dark:text-zinc-50">{{ total.toLocaleString('ru-RU') }}</span>
                </p>
            </div>
        </header>

        <!-- Результаты -->
        <div
            v-if="products.length > 0"
            class="mt-6 grid grid-cols-2 gap-2 sm:grid-cols-3 sm:gap-3 md:grid-cols-4 lg:mt-8 lg:grid-cols-5"
        >
            <article
                v-for="product in products"
                :key="product.id"
                class="group flex flex-col overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-sm transition hover:-translate-y-0.5 hover:border-orange-200 hover:shadow-lg dark:border-zinc-800 dark:bg-zinc-900 dark:hover:border-orange-500/30"
            >
                <a
                    :href="route('store.products.show', { product: product.slug })"
                    class="flex aspect-[4/3] items-center justify-center overflow-hidden bg-gradient-to-br from-zinc-100 to-zinc-50 dark:from-zinc-800 dark:to-zinc-900"
                    :aria-label="product.name"
                >
                    <img
                        v-if="product.image_path"
                        :src="product.image_path"
                        :alt="product.name"
                        class="h-full w-full object-cover transition duration-500 group-hover:scale-[1.05]"
                    />

                    <PhPackage v-else :size="32" weight="duotone" class="text-zinc-300 dark:text-zinc-600" />
                </a>

                <div class="flex flex-1 flex-col p-3">
                    <a
                        :href="route('store.products.show', { product: product.slug })"
                        class="line-clamp-2 text-[13px] font-bold leading-snug text-zinc-900 transition hover:text-orange-600 dark:text-zinc-100 dark:hover:text-orange-400"
                    >
                        {{ product.name }}
                    </a>

                    <div class="mt-1.5 flex flex-wrap gap-1">
                        <span v-if="product.code" :class="metaChipClass">{{ product.code }}</span>
                        <span v-if="product.article" :class="metaChipClass">{{ product.article }}</span>
                    </div>

                    <div class="mt-auto flex flex-wrap items-center justify-between gap-x-2 gap-y-1 pt-3">
                        <div class="text-base font-black tracking-tight text-zinc-950 dark:text-white">
                            {{ formatPrice(product.price) }} ₽
                        </div>

                        <span
                            class="rounded-full px-2 py-0.5 text-[10px] font-bold ring-1 ring-inset"
                            :class="stockStatusClass(product.stock_status)"
                        >
                            {{ stockStatusLabel(product.stock_status) }}
                        </span>
                    </div>
                </div>
            </article>
        </div>

        <!-- Ничего не найдено -->
        <div
            v-else-if="query.length >= 2"
            class="mt-6 rounded-3xl border border-dashed border-orange-300/70 bg-gradient-to-b from-orange-50/60 to-white p-8 text-center dark:border-orange-500/30 dark:from-orange-500/5 dark:to-zinc-900 sm:mt-8 sm:p-16"
        >
            <div class="mx-auto mb-5 flex size-20 items-center justify-center rounded-3xl bg-orange-100 text-orange-500 shadow-inner dark:bg-orange-500/15">
                <PhMagnifyingGlass :size="38" weight="duotone" />
            </div>

            <h3 class="text-xl font-extrabold text-zinc-900 dark:text-zinc-100">
                Ничего не найдено
            </h3>

            <p class="mx-auto mt-2 max-w-sm text-sm text-zinc-500 dark:text-zinc-400">
                Попробуйте изменить запрос или перейдите в
                <a
                    :href="route('store.catalog.index')"
                    class="font-semibold text-orange-600 underline-offset-4 hover:underline dark:text-orange-400"
                >каталог</a>
            </p>
        </div>

        <!-- Слишком короткий запрос -->
        <div
            v-else
            class="mt-6 rounded-3xl border border-dashed border-orange-300/70 bg-gradient-to-b from-orange-50/60 to-white p-8 text-center dark:border-orange-500/30 dark:from-orange-500/5 dark:to-zinc-900 sm:mt-8 sm:p-16"
        >
            <div class="mx-auto mb-5 flex size-20 items-center justify-center rounded-3xl bg-orange-100 text-orange-500 shadow-inner dark:bg-orange-500/15">
                <PhMagnifyingGlass :size="38" weight="duotone" />
            </div>

            <p class="text-sm text-zinc-500 dark:text-zinc-400">
                Введите минимум 2 символа для поиска
            </p>
        </div>
    </div>
</template>
