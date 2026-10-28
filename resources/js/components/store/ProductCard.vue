<script setup lang="ts">
import { Link, router } from '@inertiajs/vue3'
import { PhCheck, PhHeart, PhPackage, PhShoppingCart } from '@phosphor-icons/vue'
import { computed, onBeforeUnmount, ref } from 'vue'

type Product = {
    id: number
    name: string
    slug: string
    code?: string | null
    article?: string | null
    price: string
    image_path?: string | null
    stock_status: string
    category?: string | null
}

const props = withDefaults(defineProps<{
    product: Product
    favorite?: boolean
    showFavorite?: boolean
}>(), {
    favorite: false,
    showFavorite: false,
})

const emit = defineEmits<{
    (e: 'toggle-favorite', id: number): void
}>()

const price = computed(() => new Intl.NumberFormat('ru-RU').format(parseFloat(props.product.price)))
const outOfStock = computed(() => props.product.stock_status === 'out_of_stock')

const stock = computed(() => {
    const map: Record<string, { label: string; dot: string; text: string }> = {
        in_stock: { label: 'В наличии', dot: 'bg-emerald-500', text: 'text-emerald-700 dark:text-emerald-400' },
        backorder: { label: 'Под заказ', dot: 'bg-amber-500', text: 'text-amber-700 dark:text-amber-400' },
        out_of_stock: { label: 'Нет в наличии', dot: 'bg-rose-500', text: 'text-rose-700 dark:text-rose-400' },
    }
    return map[props.product.stock_status] ?? { label: props.product.stock_status, dot: 'bg-zinc-400', text: 'text-zinc-500' }
})

// Быстрое добавление в корзину
const added = ref(false)
let timer: ReturnType<typeof setTimeout> | undefined

function addToCart() {
    if (outOfStock.value) return

    router.post(
        route('store.cart.store'),
        { product_id: props.product.id, quantity: 1 },
        {
            preserveScroll: true,
            preserveState: true,
            onSuccess: () => {
                added.value = true
                clearTimeout(timer)
                timer = setTimeout(() => { added.value = false }, 1600)
            },
        },
    )
}

onBeforeUnmount(() => clearTimeout(timer))
</script>

<template>
    <article
        class="group relative flex flex-col overflow-hidden rounded-2xl border border-zinc-200 bg-white transition duration-300 hover:-translate-y-0.5 hover:border-zinc-300 hover:shadow-xl hover:shadow-zinc-900/[0.06] dark:border-zinc-800 dark:bg-zinc-900 dark:hover:border-zinc-700 dark:hover:shadow-black/40"
    >
        <!-- Фото -->
        <Link
            :href="route('store.products.show', { product: product.slug })"
            class="relative block aspect-square overflow-hidden bg-zinc-100 dark:bg-zinc-800/60"
        >
            <img
                v-if="product.image_path"
                :src="product.image_path"
                :alt="product.name"
                loading="lazy"
                decoding="async"
                class="h-full w-full object-cover transition duration-500 group-hover:scale-105"
                :class="outOfStock ? 'opacity-60 grayscale' : ''"
            />
            <div v-else class="flex h-full w-full items-center justify-center">
                <PhPackage :size="48" weight="light" class="text-zinc-300 dark:text-zinc-600" />
            </div>

            <span
                class="absolute left-2.5 top-2.5 inline-flex items-center gap-1.5 rounded-full bg-white/90 px-2.5 py-1 text-[11px] font-semibold backdrop-blur dark:bg-zinc-900/85"
                :class="stock.text"
            >
                <span class="size-1.5 rounded-full" :class="stock.dot" />
                {{ stock.label }}
            </span>
        </Link>

        <!-- Избранное -->
        <button
            v-if="showFavorite"
            type="button"
            class="absolute right-2.5 top-2.5 flex size-9 items-center justify-center rounded-full bg-white/90 text-zinc-500 backdrop-blur transition hover:scale-110 hover:text-rose-500 active:scale-95 dark:bg-zinc-900/85 dark:text-zinc-400"
            :class="favorite ? 'text-rose-500 dark:text-rose-500' : ''"
            :aria-label="favorite ? 'Убрать из избранного' : 'В избранное'"
            @click.prevent="emit('toggle-favorite', product.id)"
        >
            <PhHeart :size="19" :weight="favorite ? 'fill' : 'regular'" />
        </button>

        <!-- Описание -->
        <div class="flex flex-1 flex-col p-3.5 sm:p-4">
            <p
                v-if="product.category"
                class="text-[11px] font-bold uppercase tracking-wider text-orange-600 dark:text-orange-400"
            >
                {{ product.category }}
            </p>

            <Link
                :href="route('store.products.show', { product: product.slug })"
                class="mt-1 line-clamp-2 text-sm font-semibold leading-snug text-zinc-900 transition hover:text-orange-600 dark:text-zinc-100 dark:hover:text-orange-400 sm:text-[15px]"
            >
                {{ product.name }}
            </Link>

            <div v-if="product.article || product.code" class="mt-2 flex flex-wrap gap-1.5">
                <span
                    v-if="product.article"
                    class="rounded-md bg-zinc-100 px-1.5 py-0.5 font-mono text-[10px] text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400"
                >
                    арт. {{ product.article }}
                </span>
                <span
                    v-if="product.code"
                    class="rounded-md bg-zinc-100 px-1.5 py-0.5 font-mono text-[10px] text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400"
                >
                    код {{ product.code }}
                </span>
            </div>

            <div class="mt-auto flex items-end justify-between gap-2 pt-4">
                <div class="text-lg font-extrabold tracking-tight text-zinc-950 dark:text-white sm:text-xl">
                    {{ price }}
                    <span class="text-sm font-bold text-zinc-400">₽</span>
                </div>

                <button
                    type="button"
                    :disabled="outOfStock"
                    class="flex size-10 shrink-0 items-center justify-center rounded-full transition active:scale-90 disabled:cursor-not-allowed disabled:opacity-30"
                    :class="added
                        ? 'bg-emerald-500 text-white'
                        : 'bg-zinc-950 text-white hover:bg-orange-500 hover:text-zinc-950 dark:bg-white dark:text-zinc-950 dark:hover:bg-orange-500'"
                    :aria-label="added ? 'Добавлено в корзину' : 'В корзину'"
                    @click="addToCart"
                >
                    <PhCheck v-if="added" :size="20" weight="bold" />
                    <PhShoppingCart v-else :size="19" weight="bold" />
                </button>
            </div>
        </div>
    </article>
</template>
