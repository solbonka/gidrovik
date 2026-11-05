<script setup lang="ts">
import { Head, router } from '@inertiajs/vue3'
import {
    PhCaretLeft,
    PhMinus,
    PhPackage,
    PhPlus,
    PhShieldCheck,
    PhShoppingCart,
    PhTrash,
    PhTruck,
} from '@phosphor-icons/vue'
import { ref } from 'vue'

const props = defineProps<{
    items: Array<{
        id: number
        product_id: number
        product_slug: string
        quantity: number
        name: string
        code: string | null
        article: string | null
        price: string
        subtotal: string
        stock_status: string
        image_path?: string | null
    }>
    total: string
    item_count: number
}>()

const loadingItemId = ref<number | null>(null)

const roundBtnClass = 'flex shrink-0 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-600 shadow-sm transition hover:border-orange-400 hover:text-orange-600 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/20 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400'
const metaChipClass = 'rounded-lg bg-zinc-100 px-2 py-0.5 text-[11px] font-medium text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400'
const qtyBtnClass = 'flex size-9 items-center justify-center rounded-full text-zinc-500 transition hover:bg-orange-100 hover:text-orange-600 disabled:opacity-40 dark:text-zinc-400 dark:hover:bg-orange-500/15 dark:hover:text-orange-400'

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}

function pluralItems(n: number): string {
    const mod10 = n % 10
    const mod100 = n % 100

    if (mod10 === 1 && mod100 !== 11) return 'товар'
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'товара'

    return 'товаров'
}

function updateQuantity(itemId: number, newQty: number) {
    if (newQty < 0.001) return
    loadingItemId.value = itemId
    router.patch(
        route('store.cart.update', { itemId }),
        { quantity: newQty },
        {
            preserveState: true,
            preserveScroll: true,
            onFinish: () => { loadingItemId.value = null },
        },
    )
}

function removeItem(itemId: number) {
    loadingItemId.value = itemId
    router.delete(
        route('store.cart.destroy', { itemId }),
        {
            preserveState: true,
            preserveScroll: true,
            onFinish: () => { loadingItemId.value = null },
        },
    )
}
</script>

<template>
    <Head title="Корзина" />

    <div class="mx-auto max-w-7xl px-3 py-5 sm:px-6 sm:py-8 lg:px-10 lg:py-10">
        <!-- Шапка -->
        <header class="relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-orange-50 via-white to-white p-5 dark:border-zinc-800 dark:from-orange-500/10 dark:via-zinc-900 dark:to-zinc-900 sm:p-8">
            <div class="pointer-events-none absolute -right-16 -top-16 size-64 rounded-full bg-orange-400/20 blur-3xl dark:bg-orange-500/15" />
            <div class="pointer-events-none absolute -bottom-24 right-1/3 size-56 rounded-full bg-amber-300/20 blur-3xl dark:bg-amber-500/10" />

            <div class="relative flex flex-wrap items-center justify-between gap-x-6 gap-y-4">
                <div class="flex items-center gap-4">
                    <a
                        :href="route('store.catalog.index')"
                        :class="roundBtnClass"
                        class="size-11"
                        aria-label="В каталог"
                    >
                        <PhCaretLeft :size="20" weight="bold" />
                    </a>

                    <div>
                        <p class="inline-flex items-center gap-2 rounded-full bg-orange-500/10 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400 sm:text-xs">
                            <span class="size-1.5 rounded-full bg-orange-500" />
                            Магазин
                        </p>

                        <h1 class="mt-2 text-3xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-4xl">
                            Корзина
                        </h1>
                    </div>
                </div>

                <p class="inline-flex items-baseline gap-1.5 rounded-2xl border border-zinc-200 bg-white/80 px-4 py-2 text-sm text-zinc-500 shadow-sm backdrop-blur dark:border-zinc-700 dark:bg-zinc-800/70 dark:text-zinc-400">
                    В корзине
                    <span class="text-xl font-black text-zinc-900 dark:text-zinc-50">{{ item_count }}</span>
                    {{ pluralItems(item_count) }}
                </p>
            </div>
        </header>

        <div v-if="items.length > 0" class="mt-6 grid gap-6 lg:mt-8 lg:grid-cols-[1fr_380px] lg:items-start lg:gap-8">
            <!-- Товары -->
            <div class="space-y-3">
                <article
                    v-for="item in items"
                    :key="item.id"
                    class="flex gap-4 rounded-3xl border border-zinc-200 bg-white p-4 shadow-sm transition hover:border-orange-200 hover:shadow-md dark:border-zinc-800 dark:bg-zinc-900 dark:hover:border-orange-500/30 sm:p-5"
                    :class="loadingItemId === item.id ? 'opacity-60' : ''"
                >
                    <!-- Фото -->
                    <div class="hidden size-28 shrink-0 overflow-hidden rounded-2xl bg-gradient-to-br from-zinc-100 to-zinc-50 dark:from-zinc-800 dark:to-zinc-900 sm:flex">
                        <img
                            v-if="item.image_path"
                            :src="item.image_path"
                            :alt="item.name"
                            class="h-full w-full object-cover"
                        />

                        <div v-else class="flex h-full w-full items-center justify-center text-zinc-300 dark:text-zinc-600">
                            <PhPackage :size="36" weight="duotone" />
                        </div>
                    </div>

                    <!-- Информация -->
                    <div class="flex min-w-0 flex-1 flex-col justify-between gap-3">
                        <div class="flex items-start justify-between gap-3">
                            <div class="min-w-0">
                                <a
                                    :href="route('store.products.show', { product: item.product_slug })"
                                    class="line-clamp-2 text-sm font-bold text-zinc-900 transition hover:text-orange-600 dark:text-zinc-100 dark:hover:text-orange-400 sm:text-base"
                                >
                                    {{ item.name }}
                                </a>

                                <div class="mt-1.5 flex flex-wrap gap-1.5">
                                    <span v-if="item.code" :class="metaChipClass">Код: {{ item.code }}</span>
                                    <span v-if="item.article" :class="metaChipClass">Артикул: {{ item.article }}</span>
                                </div>
                            </div>

                            <button
                                type="button"
                                :disabled="loadingItemId === item.id"
                                class="flex size-9 shrink-0 items-center justify-center rounded-full text-zinc-400 transition hover:bg-rose-50 hover:text-rose-600 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-rose-500/20 disabled:opacity-40 dark:hover:bg-rose-500/10 dark:hover:text-rose-400"
                                aria-label="Удалить из корзины"
                                @click="removeItem(item.id)"
                            >
                                <PhTrash :size="18" weight="bold" />
                            </button>
                        </div>

                        <div class="flex flex-wrap items-end justify-between gap-3">
                            <!-- Количество -->
                            <div class="flex items-center rounded-full border border-zinc-200 bg-zinc-50 p-0.5 dark:border-zinc-700 dark:bg-zinc-800">
                                <button
                                    type="button"
                                    :disabled="loadingItemId === item.id"
                                    :class="qtyBtnClass"
                                    aria-label="Уменьшить количество"
                                    @click="updateQuantity(item.id, item.quantity - 1)"
                                >
                                    <PhMinus :size="14" weight="bold" />
                                </button>

                                <input
                                    type="number"
                                    :value="item.quantity"
                                    min="0.001"
                                    step="0.1"
                                    aria-label="Количество"
                                    class="w-14 border-none bg-transparent text-center text-sm font-bold text-zinc-900 focus:ring-0 dark:text-zinc-100 [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none"
                                    @change="updateQuantity(item.id, parseFloat(($event.target as HTMLInputElement).value) || 1)"
                                />

                                <button
                                    type="button"
                                    :disabled="loadingItemId === item.id"
                                    :class="qtyBtnClass"
                                    aria-label="Увеличить количество"
                                    @click="updateQuantity(item.id, item.quantity + 1)"
                                >
                                    <PhPlus :size="14" weight="bold" />
                                </button>
                            </div>

                            <!-- Цена -->
                            <div class="text-right">
                                <div class="text-xl font-black tracking-tight text-zinc-950 dark:text-white">
                                    {{ formatPrice(item.subtotal) }} ₽
                                </div>

                                <div class="text-xs text-zinc-400">
                                    {{ formatPrice(item.price) }} ₽ × {{ item.quantity }}
                                </div>
                            </div>
                        </div>
                    </div>
                </article>
            </div>

            <!-- Итого -->
            <aside class="lg:sticky lg:top-28">
                <div class="overflow-hidden rounded-3xl border border-zinc-200 bg-white shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                    <div class="relative overflow-hidden bg-gradient-to-br from-orange-50 to-white px-6 py-5 dark:from-orange-500/10 dark:to-zinc-900">
                        <div class="pointer-events-none absolute -right-10 -top-10 size-32 rounded-full bg-orange-400/20 blur-2xl" />

                        <h2 class="relative flex items-center gap-2 text-lg font-extrabold text-zinc-950 dark:text-white">
                            <PhShoppingCart :size="20" weight="duotone" class="text-orange-500" />
                            Итого
                        </h2>
                    </div>

                    <div class="p-6">
                        <div class="space-y-3 text-sm">
                            <div class="flex items-center justify-between">
                                <span class="flex items-center gap-2 text-zinc-500 dark:text-zinc-400">
                                    <PhTruck :size="16" weight="duotone" />
                                    Доставка
                                </span>
                                <span class="font-semibold text-emerald-600 dark:text-emerald-400">Бесплатно</span>
                            </div>

                            <div class="flex items-center justify-between">
                                <span class="flex items-center gap-2 text-zinc-500 dark:text-zinc-400">
                                    <PhShieldCheck :size="16" weight="duotone" />
                                    НДС
                                </span>
                                <span class="font-semibold text-zinc-900 dark:text-zinc-100">Включён</span>
                            </div>
                        </div>

                        <div class="mt-5 border-t border-dashed border-zinc-200 pt-5 dark:border-zinc-700">
                            <div class="flex items-baseline justify-between gap-3">
                                <span class="text-base font-bold text-zinc-950 dark:text-white">К оплате</span>
                                <span class="text-3xl font-black tracking-tight text-zinc-950 dark:text-white">
                                    {{ formatPrice(total) }} ₽
                                </span>
                            </div>
                        </div>

                        <div class="mt-6 flex flex-col gap-3">
                            <a
                                :href="route('store.checkout.create')"
                                class="flex h-13 items-center justify-center rounded-full bg-orange-500 px-6 py-3.5 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/30 transition hover:-translate-y-0.5 hover:bg-orange-400 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/30"
                            >
                                Оформить заказ
                            </a>

                            <a
                                :href="route('store.catalog.index')"
                                class="flex items-center justify-center rounded-full border border-zinc-200 bg-white px-6 py-3 text-sm font-semibold text-zinc-700 transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
                            >
                                <PhCaretLeft :size="16" class="mr-2" />
                                Продолжить покупки
                            </a>
                        </div>
                    </div>
                </div>
            </aside>
        </div>

        <!-- Пустая корзина -->
        <div
            v-else
            class="mt-6 rounded-3xl border border-dashed border-orange-300/70 bg-gradient-to-b from-orange-50/60 to-white p-8 text-center dark:border-orange-500/30 dark:from-orange-500/5 dark:to-zinc-900 sm:mt-8 sm:p-16"
        >
            <div class="mx-auto mb-5 flex size-20 items-center justify-center rounded-3xl bg-orange-100 text-orange-500 shadow-inner dark:bg-orange-500/15">
                <PhShoppingCart :size="38" weight="duotone" />
            </div>

            <h3 class="text-xl font-extrabold text-zinc-900 dark:text-zinc-100">
                Корзина пуста
            </h3>

            <p class="mx-auto mt-2 max-w-sm text-sm text-zinc-500 dark:text-zinc-400">
                Добавьте товары из каталога — они появятся здесь.
            </p>

            <a
                :href="route('store.catalog.index')"
                class="mt-6 inline-flex h-12 items-center rounded-full bg-orange-500 px-8 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/30 transition hover:-translate-y-0.5 hover:bg-orange-400"
            >
                Перейти в каталог
            </a>
        </div>
    </div>
</template>
