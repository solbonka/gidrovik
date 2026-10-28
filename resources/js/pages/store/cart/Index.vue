<script setup lang="ts">
import { Head, router } from '@inertiajs/vue3'
import {
    PhCaretLeft,
    PhShoppingCart,
    PhMinus,
    PhPlus,
    PhTrash,
    PhPackage,
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

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
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
        }
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
        }
    )
}
</script>

<template>
    <Head title="Корзина" />

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
                <h1 class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-3xl">Корзина</h1>
                <p class="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
                    {{ item_count }} {{ item_count === 1 ? 'товар' : item_count < 5 ? 'товара' : 'товаров' }}
                </p>
            </div>
        </div>

        <div v-if="items.length > 0" class="grid gap-8 lg:grid-cols-[1fr_380px]">
            <!-- Items -->
            <div class="space-y-3">
                <div
                    v-for="item in items"
                    :key="item.id"
                    class="flex gap-4 rounded-2xl border border-zinc-200 bg-white p-4 transition hover:shadow-md dark:border-zinc-800 dark:bg-zinc-900"
                >
                    <!-- Image -->
                    <div class="hidden size-24 shrink-0 overflow-hidden rounded-xl bg-zinc-100 sm:flex">
                        <div v-if="item.image_path" class="h-full w-full">
                            <img :src="item.image_path" :alt="item.name" class="h-full w-full object-cover" />
                        </div>
                        <div v-else class="flex h-full w-full items-center justify-center text-zinc-300">
                            <PhPackage :size="32" weight="light" />
                        </div>
                    </div>

                    <!-- Info -->
                    <div class="flex flex-1 flex-col justify-between">
                        <div>
                            <a
                                :href="route('store.products.show', { product: item.product_slug })"
                                class="text-sm font-semibold text-zinc-900 transition hover:text-orange-600 dark:text-zinc-100 dark:hover:text-orange-400"
                            >
                                {{ item.name }}
                            </a>
                            <div class="mt-1 flex flex-wrap gap-2">
                                <span v-if="item.code" class="rounded-md bg-zinc-100 px-2 py-0.5 text-[11px] font-medium text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400">
                                    Код: {{ item.code }}
                                </span>
                                <span v-if="item.article" class="rounded-md bg-zinc-100 px-2 py-0.5 text-[11px] font-medium text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400">
                                    Артикул: {{ item.article }}
                                </span>
                            </div>
                        </div>

                        <div class="mt-3 flex items-end justify-between">
                            <!-- Quantity controls -->
                            <div class="flex items-center rounded-full border border-zinc-200 bg-zinc-50 dark:border-zinc-700 dark:bg-zinc-800">
                                <button
                                    @click="updateQuantity(item.id, item.quantity - 1)"
                                    :disabled="loadingItemId === item.id"
                                    class="flex size-8 items-center justify-center rounded-full text-zinc-500 transition hover:bg-zinc-200 hover:text-orange-600 disabled:opacity-50 dark:text-zinc-400 dark:hover:bg-zinc-700"
                                >
                                    <PhMinus :size="14" weight="bold" />
                                </button>
                                <input
                                    type="number"
                                    :value="item.quantity"
                                    min="0.001"
                                    step="0.1"
                                    @change="updateQuantity(item.id, parseFloat(($event.target as HTMLInputElement).value) || 1)"
                                    class="w-12 border-none bg-transparent text-center text-sm font-semibold text-zinc-900 focus:ring-0 dark:text-zinc-100 [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none"
                                />
                                <button
                                    @click="updateQuantity(item.id, item.quantity + 1)"
                                    :disabled="loadingItemId === item.id"
                                    class="flex size-8 items-center justify-center rounded-full text-zinc-500 transition hover:bg-zinc-200 hover:text-orange-600 disabled:opacity-50 dark:text-zinc-400 dark:hover:bg-zinc-700"
                                >
                                    <PhPlus :size="14" weight="bold" />
                                </button>
                            </div>

                            <!-- Price -->
                            <div class="text-right">
                                <div class="text-lg font-black tracking-tight text-zinc-950 dark:text-white">
                                    {{ formatPrice(item.subtotal) }} ₽
                                </div>
                                <div class="text-xs text-zinc-400">
                                    {{ formatPrice(item.price) }} ₽ × {{ item.quantity }}
                                </div>
                            </div>

                            <!-- Remove -->
                            <button
                                @click="removeItem(item.id)"
                                :disabled="loadingItemId === item.id"
                                class="ml-3 flex size-8 items-center justify-center rounded-full text-zinc-400 transition hover:bg-rose-50 hover:text-rose-600 disabled:opacity-50 dark:hover:bg-rose-500/10 dark:hover:text-rose-400"
                            >
                                <PhTrash :size="18" weight="bold" />
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Summary -->
            <div class="lg:sticky lg:top-28">
                <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                    <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Итого</h2>
                    <div class="mt-4 flex items-baseline justify-between">
                        <span class="text-sm text-zinc-500 dark:text-zinc-400">Доставка</span>
                        <span class="text-sm font-semibold text-emerald-600 dark:text-emerald-400">Бесплатно</span>
                    </div>
                    <div class="mt-2 flex items-baseline justify-between">
                        <span class="text-sm text-zinc-500 dark:text-zinc-400">НДС</span>
                        <span class="text-sm font-semibold text-zinc-900 dark:text-zinc-100">Включён</span>
                    </div>
                    <div class="mt-4 border-t border-zinc-200 pt-4 dark:border-zinc-800">
                        <div class="flex items-baseline justify-between">
                            <span class="text-base font-bold text-zinc-950 dark:text-white">К оплате:</span>
                            <span class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                                {{ formatPrice(total) }} ₽
                            </span>
                        </div>
                    </div>

                    <div class="mt-6 flex flex-col gap-3">
                        <a
                            :href="route('store.checkout.create')"
                            class="flex h-12 items-center justify-center rounded-full bg-orange-500 px-6 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/25 transition hover:bg-orange-400"
                        >
                            Оформить заказ
                        </a>
                        <a
                            :href="route('store.catalog.index')"
                            class="flex h-12 items-center justify-center rounded-full border border-zinc-200 bg-white px-6 text-sm font-semibold text-zinc-700 transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
                        >
                            <PhCaretLeft :size="16" class="mr-2" />
                            Продолжить покупки
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Empty cart -->
        <div v-else class="rounded-3xl border border-dashed border-zinc-300 bg-white p-16 text-center dark:border-zinc-700 dark:bg-zinc-900">
            <div class="mx-auto mb-4 flex size-16 items-center justify-center rounded-2xl bg-zinc-100 text-zinc-400 dark:bg-zinc-800">
                <PhShoppingCart :size="32" weight="light" />
            </div>
            <h3 class="text-xl font-extrabold text-zinc-900 dark:text-zinc-100">Корзина пуста</h3>
            <p class="mt-2 text-sm text-zinc-500 dark:text-zinc-400">Добавьте товары из каталога</p>
            <a
                :href="route('store.catalog.index')"
                class="mt-6 inline-flex h-12 items-center rounded-full bg-orange-500 px-8 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/25 transition hover:bg-orange-400"
            >
                Перейти в каталог
            </a>
        </div>
    </div>
</template>
