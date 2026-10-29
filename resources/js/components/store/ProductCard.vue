<script setup lang="ts">
import { Link, router } from '@inertiajs/vue3'
import {
    PhCheck,
    PhHeart,
    PhMinus,
    PhPackage,
    PhPlus,
    PhShoppingCart,
    PhSpinner,
    PhX,
} from '@phosphor-icons/vue'
import { onKeyStroke } from '@vueuse/core'
import { computed, onBeforeUnmount, ref, watch } from 'vue'

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

// ---------- Выбор количества и добавление в корзину ----------
const showQuantityPicker = ref(false)
const quantity = ref<number>(1)
const processing = ref(false)
const added = ref(false)
let timer: ReturnType<typeof setTimeout> | undefined

const total = computed(() => {
    const q = Number(quantity.value) || 0
    return new Intl.NumberFormat('ru-RU', { maximumFractionDigits: 2 }).format(parseFloat(props.product.price) * q)
})

function openQuantityPicker() {
    if (outOfStock.value) return
    quantity.value = 1
    showQuantityPicker.value = true
}

function closePicker() {
    if (processing.value) return
    showQuantityPicker.value = false
}

function changeQuantity(delta: number) {
    const next = (Number(quantity.value) || 1) + delta
    quantity.value = Math.max(1, Math.round(next * 10) / 10)
}

function normalizeQuantity() {
    const q = Number(quantity.value)
    quantity.value = Number.isFinite(q) && q >= 1 ? Math.round(q * 10) / 10 : 1
}

function selectOnFocus(e: FocusEvent) {
    (e.target as HTMLInputElement).select()
}

function addToCart() {
    if (outOfStock.value || processing.value) return
    normalizeQuantity()

    router.post(
        route('store.cart.store'),
        { product_id: props.product.id, quantity: quantity.value },
        {
            preserveScroll: true,
            preserveState: true,
            onStart: () => { processing.value = true },
            onSuccess: () => {
                showQuantityPicker.value = false
                added.value = true
                clearTimeout(timer)
                timer = setTimeout(() => { added.value = false }, 1600)
            },
            onFinish: () => { processing.value = false },
        },
    )
}

// Блокируем прокрутку страницы, пока открыта модалка
watch(showQuantityPicker, (open) => {
    document.body.style.overflow = open ? 'hidden' : ''
})

// Escape слушаем на всём документе: у div без фокуса @keydown.escape не срабатывает
onKeyStroke('Escape', () => {
    if (showQuantityPicker.value) closePicker()
})

onBeforeUnmount(() => {
    clearTimeout(timer)
    if (showQuantityPicker.value) document.body.style.overflow = ''
})
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
                    @click="openQuantityPicker"
                >
                    <PhCheck v-if="added" :size="20" weight="bold" />
                    <PhShoppingCart v-else :size="19" weight="bold" />
                </button>
            </div>
        </div>

        <!-- Модалка выбора количества.
             Вынесена в body: у карточки есть transform и overflow-hidden,
             из-за них position: fixed внутри неё обрезался и съезжал. -->
        <Teleport to="body">
            <Transition
                enter-active-class="transition-opacity duration-200"
                leave-active-class="transition-opacity duration-150"
                enter-from-class="opacity-0"
                leave-to-class="opacity-0"
            >
                <div
                    v-if="showQuantityPicker"
                    class="fixed inset-0 z-[80] flex items-end justify-center bg-zinc-950/60 backdrop-blur-sm sm:items-center sm:p-4"
                    @click.self="closePicker"
                >
                    <div
                        role="dialog"
                        aria-modal="true"
                        :aria-label="`Добавить в корзину: ${product.name}`"
                        class="w-full max-w-md overflow-hidden rounded-t-[28px] border border-zinc-200 bg-white shadow-2xl dark:border-zinc-800 dark:bg-zinc-900 sm:rounded-[28px]"
                    >
                        <!-- Шапка -->
                        <div class="flex items-start gap-4 p-5 pb-0 sm:p-6 sm:pb-0">
                            <div class="size-16 shrink-0 overflow-hidden rounded-2xl bg-zinc-100 dark:bg-zinc-800 sm:size-20">
                                <img
                                    v-if="product.image_path"
                                    :src="product.image_path"
                                    :alt="product.name"
                                    class="h-full w-full object-cover"
                                />
                                <div v-else class="flex h-full w-full items-center justify-center">
                                    <PhPackage :size="28" weight="light" class="text-zinc-300 dark:text-zinc-600" />
                                </div>
                            </div>

                            <div class="min-w-0 flex-1">
                                <p class="text-[11px] font-bold uppercase tracking-[0.18em] text-orange-600 dark:text-orange-400">
                                    Добавить в корзину
                                </p>
                                <h3 class="mt-1 line-clamp-2 text-base font-extrabold leading-snug text-zinc-950 dark:text-white">
                                    {{ product.name }}
                                </h3>
                                <p class="mt-1 text-sm text-zinc-500 dark:text-zinc-400">{{ price }} ₽ за единицу</p>
                            </div>

                            <button
                                type="button"
                                class="-mr-1 -mt-1 flex size-9 shrink-0 items-center justify-center rounded-full text-zinc-400 transition hover:bg-zinc-100 hover:text-zinc-700 dark:hover:bg-zinc-800 dark:hover:text-zinc-200"
                                aria-label="Закрыть"
                                @click="closePicker"
                            >
                                <PhX :size="18" weight="bold" />
                            </button>
                        </div>

                        <form class="p-5 sm:p-6" @submit.prevent="addToCart">
                            <!-- Количество -->
                            <div class="flex items-center justify-between rounded-2xl bg-zinc-100 p-1.5 dark:bg-zinc-800">
                                <button
                                    type="button"
                                    class="flex size-12 items-center justify-center rounded-xl bg-white text-zinc-700 shadow-sm transition hover:text-orange-600 active:scale-90 disabled:opacity-40 dark:bg-zinc-900 dark:text-zinc-200 dark:hover:text-orange-400"
                                    :disabled="Number(quantity) <= 1"
                                    aria-label="Меньше"
                                    @click="changeQuantity(-1)"
                                >
                                    <PhMinus :size="18" weight="bold" />
                                </button>

                                <input
                                    v-model.number="quantity"
                                    type="number"
                                    min="1"
                                    step="0.1"
                                    inputmode="decimal"
                                    class="w-24 appearance-none border-none bg-transparent p-0 text-center text-2xl font-black tracking-tight text-zinc-950 outline-none focus:ring-0 dark:text-white [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none"
                                    aria-label="Количество"
                                    @blur="normalizeQuantity"
                                    @focus="selectOnFocus"
                                />

                                <button
                                    type="button"
                                    class="flex size-12 items-center justify-center rounded-xl bg-white text-zinc-700 shadow-sm transition hover:text-orange-600 active:scale-90 dark:bg-zinc-900 dark:text-zinc-200 dark:hover:text-orange-400"
                                    aria-label="Больше"
                                    @click="changeQuantity(1)"
                                >
                                    <PhPlus :size="18" weight="bold" />
                                </button>
                            </div>

                            <!-- Итого -->
                            <div class="mt-4 flex items-baseline justify-between px-1">
                                <span class="text-sm text-zinc-500 dark:text-zinc-400">Итого</span>
                                <span class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                                {{ total }} <span class="text-base font-bold text-zinc-400">₽</span>
                            </span>
                            </div>

                            <!-- Действия -->
                            <div class="mt-5 flex gap-2.5 pb-[env(safe-area-inset-bottom)]">
                                <button
                                    type="button"
                                    class="h-12 flex-1 rounded-full border border-zinc-200 text-sm font-semibold text-zinc-700 transition hover:bg-zinc-50 disabled:opacity-50 dark:border-zinc-700 dark:text-zinc-300 dark:hover:bg-zinc-800"
                                    :disabled="processing"
                                    @click="closePicker"
                                >
                                    Отмена
                                </button>
                                <button
                                    type="submit"
                                    class="flex h-12 flex-[1.6] items-center justify-center gap-2 rounded-full bg-orange-500 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/25 transition hover:bg-orange-400 active:scale-[0.98] disabled:opacity-60"
                                    :disabled="processing"
                                >
                                    <PhSpinner v-if="processing" :size="18" weight="bold" class="animate-spin" />
                                    <PhShoppingCart v-else :size="18" weight="bold" />
                                    {{ processing ? 'Добавляем…' : 'В корзину' }}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </Transition>
        </Teleport>
    </article>
</template>
