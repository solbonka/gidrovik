<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import { PhArrowRight, PhCaretLeft, PhHeart } from '@phosphor-icons/vue'
import { computed, ref } from 'vue'

import ProductCard from '@/components/store/ProductCard.vue'

const props = defineProps<{
    products: Array<{
        id: number
        name: string
        slug: string
        code: string | null
        article: string | null
        price: string
        image_path?: string | null
        stock_status: string
        category?: string
    }> | null
}>()

// Реактивный список: после удаления Inertia обновит props, и карточка пропадёт без перезагрузки страницы
const items = computed(() => props.products ?? [])

const removingId = ref<number | null>(null)

function removeFavorite(productId: number) {
    removingId.value = productId

    router.delete(route('store.favorites.destroy'), {
        data: { product_id: productId },
        preserveScroll: true,
        // На случай, если сервер отвечает редиректом без свежих данных
        onSuccess: () => router.reload({ only: ['products'] }),
        onFinish: () => {
            removingId.value = null
        },
    })
}

function pluralize(n: number, one: string, few: string, many: string): string {
    const m10 = n % 10
    const m100 = n % 100

    if (m10 === 1 && m100 !== 11) return one
    if (m10 >= 2 && m10 <= 4 && (m100 < 10 || m100 >= 20)) return few

    return many
}
</script>

<template>
    <Head title="Избранное" />

    <div class="mx-auto max-w-7xl px-3 py-5 sm:px-6 sm:py-8 lg:px-10 lg:py-10">
        <!-- Шапка -->
        <header class="relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-orange-50 via-white to-white p-5 dark:border-zinc-800 dark:from-orange-500/10 dark:via-zinc-900 dark:to-zinc-900 sm:p-8">
            <div class="pointer-events-none absolute -right-16 -top-16 size-64 rounded-full bg-orange-400/20 blur-3xl dark:bg-orange-500/15" />
            <div class="pointer-events-none absolute -bottom-24 right-1/3 size-56 rounded-full bg-amber-300/20 blur-3xl dark:bg-amber-500/10" />

            <div class="relative flex flex-wrap items-center justify-between gap-x-6 gap-y-4">
                <div class="flex items-center gap-4">
                    <Link
                        :href="route('store.catalog.index')"
                        class="flex size-11 shrink-0 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-600 shadow-sm transition hover:border-orange-400 hover:text-orange-600 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/20 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
                        aria-label="Назад в каталог"
                    >
                        <PhCaretLeft :size="20" weight="bold" />
                    </Link>

                    <div>
                        <p class="inline-flex items-center gap-2 rounded-full bg-orange-500/10 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400 sm:text-xs">
                            <span class="size-1.5 rounded-full bg-orange-500" />
                            Магазин
                        </p>

                        <h1 class="mt-2 text-3xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-4xl">
                            Избранное
                        </h1>
                    </div>
                </div>

                <p class="inline-flex items-baseline gap-1.5 rounded-2xl border border-zinc-200 bg-white/80 px-4 py-2 text-sm text-zinc-500 shadow-sm backdrop-blur dark:border-zinc-700 dark:bg-zinc-800/70 dark:text-zinc-400">
                    <PhHeart :size="16" weight="fill" class="self-center text-orange-500" />
                    <span class="text-xl font-black text-zinc-900 dark:text-zinc-50">{{ items.length }}</span>
                    {{ pluralize(items.length, 'товар', 'товара', 'товаров') }}
                </p>
            </div>
        </header>

        <!-- Товары -->
        <div
            v-if="items.length > 0"
            class="mt-6 grid grid-cols-2 gap-2 sm:grid-cols-3 sm:gap-3 md:grid-cols-4 lg:mt-8 lg:grid-cols-5"
        >
            <div
                v-for="product in items"
                :key="product.id"
                class="transition duration-200"
                :class="removingId === product.id ? 'pointer-events-none scale-95 opacity-50' : ''"
            >
                <ProductCard
                    :product="product"
                    show-favorite
                    favorite
                    @toggle-favorite="removeFavorite"
                />
            </div>
        </div>

        <!-- Пусто -->
        <div
            v-else
            class="mt-6 flex flex-col items-center rounded-3xl border border-dashed border-orange-300/70 bg-gradient-to-b from-orange-50/60 to-white p-8 text-center dark:border-orange-500/30 dark:from-orange-500/5 dark:to-zinc-900 sm:mt-8 sm:p-16"
        >
            <div class="flex size-20 items-center justify-center rounded-3xl bg-orange-100 text-orange-500 shadow-inner dark:bg-orange-500/15">
                <PhHeart :size="38" weight="duotone" />
            </div>

            <h3 class="mt-5 text-xl font-extrabold text-zinc-900 dark:text-zinc-100">
                В избранном пока пусто
            </h3>

            <p class="mt-2 max-w-sm text-sm text-zinc-500 dark:text-zinc-400">
                Добавьте товары в избранное, нажав на сердечко в каталоге
            </p>

            <Link
                :href="route('store.catalog.index')"
                class="mt-6 inline-flex h-12 items-center gap-2 rounded-full bg-orange-500 px-7 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/30 transition hover:-translate-y-0.5 hover:bg-orange-400 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/30"
            >
                Перейти в каталог
                <PhArrowRight :size="16" weight="bold" />
            </Link>
        </div>
    </div>
</template>
