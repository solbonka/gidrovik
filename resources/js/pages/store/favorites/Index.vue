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

    <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-10 lg:py-12">
        <!-- Заголовок -->
        <div class="mb-6 flex items-center gap-4 lg:mb-8">
            <Link
                :href="route('store.catalog.index')"
                class="flex size-10 shrink-0 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-600 transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
                aria-label="Назад в каталог"
            >
                <PhCaretLeft :size="20" weight="bold" />
            </Link>
            <div>
                <p class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400">Магазин</p>
                <h1 class="text-3xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-4xl">Избранное</h1>
                <p class="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
                    {{ items.length }} {{ pluralize(items.length, 'товар', 'товара', 'товаров') }} в избранном
                </p>
            </div>
        </div>

        <!-- Товары -->
        <div v-if="items.length > 0" class="grid grid-cols-2 gap-3 sm:gap-4 md:grid-cols-3 lg:grid-cols-4">
            <div
                v-for="product in items"
                :key="product.id"
                class="transition"
                :class="removingId === product.id ? 'pointer-events-none opacity-50' : ''"
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
            class="flex flex-col items-center rounded-3xl border border-dashed border-zinc-300 bg-white p-10 text-center dark:border-zinc-700 dark:bg-zinc-900 sm:p-16"
        >
            <div class="flex size-16 items-center justify-center rounded-2xl bg-zinc-100 text-zinc-400 dark:bg-zinc-800">
                <PhHeart :size="32" weight="light" />
            </div>
            <h3 class="mt-5 text-xl font-extrabold text-zinc-900 dark:text-zinc-100">В избранном пока пусто</h3>
            <p class="mt-2 max-w-sm text-sm text-zinc-500 dark:text-zinc-400">
                Добавьте товары в избранное, нажав на сердечко в каталоге
            </p>
            <Link
                :href="route('store.catalog.index')"
                class="mt-6 inline-flex h-12 items-center gap-2 rounded-full bg-orange-500 px-7 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/25 transition hover:bg-orange-400"
            >
                Перейти в каталог
                <PhArrowRight :size="16" weight="bold" />
            </Link>
        </div>
    </div>
</template>
