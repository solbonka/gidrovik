<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import {
    PhArrowsOut,
    PhCaretLeft,
    PhCaretRight,
    PhCheck,
    PhHeart,
    PhMinus,
    PhPackage,
    PhPlus,
    PhShieldCheck,
    PhShoppingCart,
    PhTruck,
    PhX,
} from '@phosphor-icons/vue'
import { onKeyStroke } from '@vueuse/core'
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'

import ProductCard from '@/components/store/ProductCard.vue'

const props = defineProps<{
    product: {
        id: number
        name: string
        slug: string
        code: string | null
        article: string | null
        description: string | null
        price: string
        stock_status: string
        manufacturer?: string | null
        category?: string | null
        meta_title: string
        meta_description: string | null
        images: Array<{ id: number, path: string, large: string, alt: string | null }>
        characteristics: Array<{
            id: number
            name: string
            value: string
            unit: string | null
        }>
        locations?: Array<{ rack_code: string; location_code: string; quantity: string }>
    }
    related_products: Array<{
        id: number
        name: string
        slug: string
        price: string
        image_path?: string | null
        stock_status: string
    }>
    favorite_product_ids: number[]
}>()

// ---------- Избранное ----------
const isFavorite = ref(props.favorite_product_ids.includes(props.product.id))

// Update favorite status when product changes
watch(() => props.product.id, () => {
    isFavorite.value = props.favorite_product_ids.includes(props.product.id)
})

// Update favorite status when favorite_product_ids prop changes
watch(() => props.favorite_product_ids, (newIds) => {
    isFavorite.value = newIds.includes(props.product.id)
}, { deep: true })

function toggleFavorite() {
    if (isFavorite.value) {
        router.delete(route('store.favorites.destroy'), {
            data: { product_id: props.product.id },
            preserveScroll: true,
            onSuccess: () => { isFavorite.value = false },
        })
    } else {
        router.post(route('store.favorites.store'), {
            product_id: props.product.id,
        }, {
            preserveScroll: true,
            onSuccess: () => { isFavorite.value = true },
        })
    }
}

// ---------- Галерея ----------
const quantity = ref<number>(1)
const showPreview = ref(false)
const previewIndex = ref(0)

const currentImage = computed(() => props.product.images[previewIndex.value] ?? props.product.images[0])

function openPreview() {
    if (props.product.images.length === 0) return
    showPreview.value = true
    document.body.style.overflow = 'hidden'
}

function closePreview() {
    showPreview.value = false
    document.body.style.overflow = ''
}

function prevImage() {
    if (previewIndex.value > 0) previewIndex.value--
}

function nextImage() {
    if (previewIndex.value < props.product.images.length - 1) previewIndex.value++
}

function selectThumbnail(index: number) {
    previewIndex.value = index
}

onKeyStroke('ArrowLeft', (e) => {
    if (!showPreview.value) return
    e.preventDefault()
    prevImage()
})

onKeyStroke('ArrowRight', (e) => {
    if (!showPreview.value) return
    e.preventDefault()
    nextImage()
})

onKeyStroke('Escape', () => {
    if (showPreview.value) closePreview()
})

// ---------- Цена и наличие ----------
function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}

const stock = computed(() => {
    const map: Record<string, { label: string; dot: string; chip: string }> = {
        in_stock: {
            label: 'В наличии',
            dot: 'bg-emerald-500',
            chip: 'bg-emerald-500/10 text-emerald-700 dark:text-emerald-400',
        },
        backorder: {
            label: 'Под заказ',
            dot: 'bg-amber-500',
            chip: 'bg-amber-500/10 text-amber-700 dark:text-amber-400',
        },
        out_of_stock: {
            label: 'Нет в наличии',
            dot: 'bg-rose-500',
            chip: 'bg-rose-500/10 text-rose-700 dark:text-rose-400',
        },
    }
    return map[props.product.stock_status] ?? {
        label: props.product.stock_status,
        dot: 'bg-zinc-400',
        chip: 'bg-zinc-500/10 text-zinc-600 dark:text-zinc-300',
    }
})

const outOfStock = computed(() => props.product.stock_status === 'out_of_stock')

// ---------- Корзина ----------
const added = ref(false)
let addedTimer: ReturnType<typeof setTimeout> | undefined

function changeQuantity(delta: number) {
    const next = (Number(quantity.value) || 1) + delta
    quantity.value = Math.max(1, Math.round(next * 10) / 10)
}

function addToCart() {
    if (outOfStock.value) return

    router.post(
        route('store.cart.store'),
        { product_id: props.product.id, quantity: Number(quantity.value) || 1 },
        {
            preserveState: true,
            preserveScroll: true,
            only: ['item_count'],
            onSuccess: () => {
                added.value = true
                clearTimeout(addedTimer)
                addedTimer = setTimeout(() => { added.value = false }, 1800)
            },
        },
    )
}

// Переход на другой товар в том же компоненте — сбрасываем локальное состояние
watch(() => props.product.id, () => {
    previewIndex.value = 0
    quantity.value = 1
    isFavorite.value = props.favorite_product_ids.includes(props.product.id)
    closePreview()
})

onBeforeUnmount(() => {
    clearTimeout(addedTimer)
    document.body.style.overflow = ''
})
</script>

<template>
    <Head :title="product.meta_title">
        <meta v-if="product.meta_description" name="description" :content="product.meta_description" />
    </Head>

    <div class="mx-auto max-w-7xl px-4 pb-32 pt-5 sm:px-6 lg:px-10 lg:pb-16 lg:pt-8">
        <!-- Хлебные крошки -->
        <nav class="mb-5 flex items-center gap-1.5 overflow-x-auto whitespace-nowrap text-sm text-zinc-500 dark:text-zinc-400 lg:mb-7">
            <Link :href="route('store.home')" class="transition hover:text-orange-600 dark:hover:text-orange-400">Главная</Link>
            <PhCaretRight :size="12" weight="bold" class="shrink-0 text-zinc-300 dark:text-zinc-600" />
            <Link :href="route('store.catalog.index')" class="transition hover:text-orange-600 dark:hover:text-orange-400">Каталог</Link>
            <template v-if="product.category">
                <PhCaretRight :size="12" weight="bold" class="shrink-0 text-zinc-300 dark:text-zinc-600" />
                <span>{{ product.category }}</span>
            </template>
        </nav>

        <div class="grid gap-8 lg:grid-cols-[minmax(0,1.1fr)_minmax(0,1fr)] lg:gap-12">
            <!-- Галерея -->
            <div class="min-w-0">
                <div
                    class="group relative aspect-square overflow-hidden rounded-3xl border border-zinc-200 bg-zinc-100 dark:border-zinc-800 dark:bg-zinc-900"
                    :class="product.images.length > 0 ? 'cursor-zoom-in' : ''"
                    @click="openPreview"
                >
                    <template v-if="product.images.length > 0">
                        <img
                            :src="currentImage.path"
                            :alt="currentImage.alt ?? product.name"
                            decoding="async"
                            class="h-full w-full object-cover transition duration-500 group-hover:scale-[1.03]"
                        />

                        <div
                            v-if="product.images.length > 1"
                            class="absolute bottom-4 left-4 rounded-full bg-zinc-950/70 px-3 py-1 text-xs font-semibold text-white backdrop-blur"
                        >
                            {{ previewIndex + 1 }} / {{ product.images.length }}
                        </div>

                        <div class="absolute right-4 top-4 flex size-10 items-center justify-center rounded-full bg-white/90 text-zinc-700 opacity-0 backdrop-blur transition group-hover:opacity-100 dark:bg-zinc-900/90 dark:text-zinc-200">
                            <PhArrowsOut :size="18" />
                        </div>

                        <button
                            v-if="product.images.length > 1"
                            type="button"
                            class="absolute left-3 top-1/2 flex size-11 -translate-y-1/2 items-center justify-center rounded-full bg-white/90 text-zinc-800 shadow-lg backdrop-blur transition hover:scale-105 disabled:opacity-0 dark:bg-zinc-900/90 dark:text-zinc-100 sm:opacity-0 sm:group-hover:opacity-100"
                            :disabled="previewIndex === 0"
                            aria-label="Предыдущее фото"
                            @click.stop="prevImage"
                        >
                            <PhCaretLeft :size="20" weight="bold" />
                        </button>
                        <button
                            v-if="product.images.length > 1"
                            type="button"
                            class="absolute right-3 top-1/2 flex size-11 -translate-y-1/2 items-center justify-center rounded-full bg-white/90 text-zinc-800 shadow-lg backdrop-blur transition hover:scale-105 disabled:opacity-0 dark:bg-zinc-900/90 dark:text-zinc-100 sm:opacity-0 sm:group-hover:opacity-100"
                            :disabled="previewIndex === product.images.length - 1"
                            aria-label="Следующее фото"
                            @click.stop="nextImage"
                        >
                            <PhCaretRight :size="20" weight="bold" />
                        </button>
                    </template>
                    <div v-else class="flex h-full items-center justify-center">
                        <PhPackage :size="80" weight="light" class="text-zinc-300 dark:text-zinc-700" />
                    </div>
                </div>

                <div v-if="product.images.length > 1" class="mt-3 flex gap-2.5 overflow-x-auto pb-1">
                    <button
                        v-for="(img, i) in product.images"
                        :key="img.id"
                        type="button"
                        class="relative size-16 shrink-0 overflow-hidden rounded-2xl border-2 transition sm:size-20"
                        :class="i === previewIndex
                            ? 'border-orange-500'
                            : 'border-transparent opacity-70 hover:opacity-100'"
                        @click="selectThumbnail(i)"
                    >
                        <img :src="img.path" :alt="img.alt || product.name" loading="lazy" class="h-full w-full object-cover" />
                    </button>
                </div>
            </div>

            <!-- Информация -->
            <div class="min-w-0 lg:sticky lg:top-28 lg:self-start">
                <p
                    v-if="product.category"
                    class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400"
                >
                    {{ product.category }}
                </p>
                <h1 class="mt-2 text-2xl font-black leading-tight tracking-tight sm:text-4xl">{{ product.name }}</h1>

                <div class="mt-4 flex flex-wrap items-center gap-2">
                    <span
                        v-if="product.article"
                        class="rounded-lg bg-zinc-100 px-2.5 py-1 font-mono text-xs text-zinc-600 dark:bg-zinc-800 dark:text-zinc-300"
                    >
                        арт. {{ product.article }}
                    </span>
                    <span
                        v-if="product.code"
                        class="rounded-lg bg-zinc-100 px-2.5 py-1 font-mono text-xs text-zinc-600 dark:bg-zinc-800 dark:text-zinc-300"
                    >
                        код {{ product.code }}
                    </span>
                    <span
                        v-if="product.manufacturer"
                        class="rounded-lg bg-zinc-100 px-2.5 py-1 text-xs font-semibold text-zinc-600 dark:bg-zinc-800 dark:text-zinc-300"
                    >
                        {{ product.manufacturer }}
                    </span>
                </div>

                <!-- Цена -->
                <div class="mt-6 rounded-3xl border border-zinc-200 bg-white p-5 dark:border-zinc-800 dark:bg-zinc-900 sm:p-6">
                    <div class="flex items-start justify-between gap-3">
                        <div>
                            <div class="text-4xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-5xl">
                                {{ formatPrice(product.price) }}
                                <span class="text-2xl font-bold text-zinc-400">₽</span>
                            </div>
                            <div class="mt-1 text-sm text-zinc-500 dark:text-zinc-400">Розничная цена</div>
                        </div>
                        <span
                            class="inline-flex shrink-0 items-center gap-2 rounded-full px-3 py-1.5 text-xs font-bold"
                            :class="stock.chip"
                        >
                            <span class="size-1.5 rounded-full" :class="stock.dot" />
                            {{ stock.label }}
                        </span>
                    </div>

                    <!-- Покупка: панель внизу экрана на мобильных, блок в карточке на десктопе -->
                    <div
                        class="fixed inset-x-0 bottom-[calc(4rem+env(safe-area-inset-bottom))] z-30 flex items-center gap-2.5 border-t border-zinc-200 bg-white/90 p-3 backdrop-blur-xl dark:border-zinc-800 dark:bg-zinc-950/90 lg:static lg:z-auto lg:mt-6 lg:gap-3 lg:border-0 lg:bg-transparent lg:p-0 lg:backdrop-blur-none dark:lg:bg-transparent"
                    >
                        <div class="flex items-center rounded-full border border-zinc-200 bg-zinc-50 dark:border-zinc-700 dark:bg-zinc-800">
                            <button
                                type="button"
                                class="flex size-11 items-center justify-center rounded-full text-zinc-600 transition hover:text-orange-600 active:scale-90 dark:text-zinc-300 dark:hover:text-orange-400"
                                aria-label="Меньше"
                                @click="changeQuantity(-1)"
                            >
                                <PhMinus :size="16" weight="bold" />
                            </button>
                            <input
                                v-model.number="quantity"
                                type="number"
                                min="1"
                                step="0.1"
                                inputmode="decimal"
                                class="w-12 appearance-none border-none bg-transparent p-0 text-center text-sm font-bold text-zinc-900 outline-none focus:ring-0 dark:text-zinc-100 [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none"
                                aria-label="Количество"
                            />
                            <button
                                type="button"
                                class="flex size-11 items-center justify-center rounded-full text-zinc-600 transition hover:text-orange-600 active:scale-90 dark:text-zinc-300 dark:hover:text-orange-400"
                                aria-label="Больше"
                                @click="changeQuantity(1)"
                            >
                                <PhPlus :size="16" weight="bold" />
                            </button>
                        </div>

                        <button
                            type="button"
                            :disabled="outOfStock"
                            class="flex h-[46px] flex-1 items-center justify-center gap-2 rounded-full px-6 text-sm font-bold transition active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-40 lg:h-12"
                            :class="added
                                ? 'bg-emerald-500 text-white'
                                : 'bg-orange-500 text-zinc-950 shadow-lg shadow-orange-500/25 hover:bg-orange-400'"
                            @click="addToCart"
                        >
                            <PhCheck v-if="added" :size="20" weight="bold" />
                            <PhShoppingCart v-else :size="20" weight="bold" />
                            {{ added ? 'Добавлено' : outOfStock ? 'Нет в наличии' : 'В корзину' }}
                        </button>
                    </div>

                    <button
                        type="button"
                        class="mt-4 inline-flex items-center gap-2 text-sm font-semibold text-zinc-500 transition hover:text-rose-500 dark:text-zinc-400"
                        :class="isFavorite ? 'text-rose-500 dark:text-rose-500' : ''"
                        @click="toggleFavorite"
                    >
                        <PhHeart :size="20" :weight="isFavorite ? 'fill' : 'regular'" />
                        {{ isFavorite ? 'В избранном' : 'Добавить в избранное' }}
                    </button>
                </div>

                <!-- Преимущества -->
                <div class="mt-3 grid grid-cols-2 gap-3">
                    <div class="flex items-center gap-3 rounded-2xl border border-zinc-200 bg-white p-4 dark:border-zinc-800 dark:bg-zinc-900">
                        <PhTruck :size="24" weight="duotone" class="shrink-0 text-orange-500" />
                        <span class="text-xs font-semibold leading-snug sm:text-sm">Отправка по всей России</span>
                    </div>
                    <div class="flex items-center gap-3 rounded-2xl border border-zinc-200 bg-white p-4 dark:border-zinc-800 dark:bg-zinc-900">
                        <PhShieldCheck :size="24" weight="duotone" class="shrink-0 text-orange-500" />
                        <span class="text-xs font-semibold leading-snug sm:text-sm">Гарантия качества</span>
                    </div>
                </div>

                <!-- Описание -->
                <div v-if="product.description" class="mt-8">
                    <h2 class="text-xl font-extrabold tracking-tight">Описание</h2>
                    <p class="mt-3 whitespace-pre-line text-sm leading-7 text-zinc-600 dark:text-zinc-400">
                        {{ product.description }}
                    </p>
                </div>

                <!-- Характеристики -->
                <div v-if="product.characteristics.length > 0" class="mt-8">
                    <h2 class="text-xl font-extrabold tracking-tight">Характеристики</h2>
                    <div class="mt-3 overflow-hidden rounded-2xl border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900">
                        <dl class="divide-y divide-zinc-100 text-sm dark:divide-zinc-800">
                            <div
                                v-for="char in product.characteristics"
                                :key="char.id"
                                class="grid grid-cols-[1fr_1.2fr] gap-4 px-4 py-3 transition hover:bg-zinc-50 dark:hover:bg-zinc-800/50 sm:px-5"
                            >
                                <dt class="text-zinc-500 dark:text-zinc-400">{{ char.name }}</dt>
                                <dd class="font-semibold text-zinc-900 dark:text-zinc-100">
                                    {{ char.value || '—' }}
                                    <span v-if="char.unit" class="font-normal text-zinc-400">({{ char.unit }})</span>
                                </dd>
                            </div>
                        </dl>
                    </div>
                </div>
            </div>
        </div>

        <!-- Похожие товары -->
        <section v-if="related_products.length > 0" class="mt-16 lg:mt-24">
            <p class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400">Смотрите также</p>
            <h2 class="mt-2 text-2xl font-black tracking-tight sm:text-3xl">Похожие товары</h2>
            <div class="mt-6 grid grid-cols-2 gap-3 sm:gap-4 lg:grid-cols-4">
                <ProductCard v-for="rp in related_products" :key="rp.id" :product="rp" />
            </div>
        </section>
    </div>

    <!-- Полноэкранный просмотр -->
    <Transition
        enter-active-class="transition-opacity duration-200"
        leave-active-class="transition-opacity duration-150"
        enter-from-class="opacity-0"
        leave-to-class="opacity-0"
    >
        <div
            v-if="showPreview"
            class="fixed inset-0 z-[70] flex items-center justify-center bg-zinc-950/95 backdrop-blur-sm"
            @click.self="closePreview"
        >
            <button
                type="button"
                class="absolute right-4 top-4 z-10 flex size-11 items-center justify-center rounded-full bg-white/10 text-white transition hover:bg-white/20"
                aria-label="Закрыть"
                @click="closePreview"
            >
                <PhX :size="22" weight="bold" />
            </button>

            <button
                v-if="product.images.length > 1"
                type="button"
                class="absolute left-3 top-1/2 z-10 flex size-12 -translate-y-1/2 items-center justify-center rounded-full bg-white/10 text-white transition hover:bg-white/20 disabled:opacity-20 sm:left-6"
                :disabled="previewIndex === 0"
                aria-label="Предыдущее фото"
                @click.stop="prevImage"
            >
                <PhCaretLeft :size="24" weight="bold" />
            </button>

            <img
                :src="currentImage.large ?? currentImage.path"
                :alt="currentImage.alt ?? product.name"
                decoding="async"
                class="max-h-[78vh] max-w-[92vw] rounded-2xl object-contain"
                @click.stop
            />

            <button
                v-if="product.images.length > 1"
                type="button"
                class="absolute right-3 top-1/2 z-10 flex size-12 -translate-y-1/2 items-center justify-center rounded-full bg-white/10 text-white transition hover:bg-white/20 disabled:opacity-20 sm:right-6"
                :disabled="previewIndex === product.images.length - 1"
                aria-label="Следующее фото"
                @click.stop="nextImage"
            >
                <PhCaretRight :size="24" weight="bold" />
            </button>

            <div
                v-if="product.images.length > 1"
                class="absolute bottom-5 left-1/2 flex max-w-[90vw] -translate-x-1/2 items-center gap-2 overflow-x-auto px-2"
            >
                <button
                    v-for="(img, i) in product.images"
                    :key="img.id"
                    type="button"
                    class="size-14 shrink-0 overflow-hidden rounded-xl border-2 transition"
                    :class="i === previewIndex ? 'border-orange-500' : 'border-white/20 opacity-60 hover:opacity-100'"
                    @click.stop="selectThumbnail(i)"
                >
                    <img :src="img.path" :alt="img.alt || product.name" loading="lazy" class="h-full w-full object-cover" />
                </button>
            </div>
        </div>
    </Transition>
</template>
