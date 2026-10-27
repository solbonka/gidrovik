<script setup lang="ts">
import {
    Minus,
    Package,
    Plus,
    Trash2,
} from '@lucide/vue'
import { router } from '@inertiajs/vue3'
import { ref } from 'vue'

import { Button } from '@/components/ui/button'

const props = defineProps<{
    items: Array<{
        id: number
        product_id: number
        product_slug: string
        quantity: number
        name: string
        sku: string | null
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
            onFinish: () => { loadingItemId.value = null },
        }
    )
}
</script>

<template>
    <div class="mx-auto max-w-4xl px-5 py-8 lg:px-10">
            <h1 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">Корзина</h1>

            <div v-if="items.length > 0" class="mt-8">
                <!-- Items -->
                <div class="space-y-4">
                    <div
                        v-for="item in items"
                        :key="item.id"
                        class="flex gap-4 rounded-xl border border-slate-200 bg-white p-4"
                    >
                        <!-- Image -->
                        <div class="hidden size-20 shrink-0 items-center justify-center rounded-lg bg-slate-100 sm:flex">
                            <div v-if="item.image_path" class="h-full w-full overflow-hidden rounded-lg">
                                <img :src="item.image_path" :alt="item.name" class="h-full w-full object-cover" />
                            </div>
                            <div v-else class="text-slate-300">
                                <Package :size="24" />
                            </div>
                        </div>

                        <!-- Info -->
                        <div class="flex flex-1 flex-col justify-between">
                            <div>
                                <a
                                    :href="route('store.products.show', { product: item.product_slug })"
                                    class="text-sm font-semibold text-slate-900 hover:text-emerald-700"
                                >
                                    {{ item.name }}
                                </a>
                                <p v-if="item.sku" class="mt-0.5 text-xs text-slate-400">
                                    Арт: {{ item.sku }}
                                </p>
                            </div>

                            <div class="mt-3 flex items-end justify-between">
                                <!-- Quantity controls -->
                                <div class="flex items-center rounded-lg border border-slate-200">
                                    <button
                                        @click="updateQuantity(item.id, item.quantity - 1)"
                                        :disabled="loadingItemId === item.id"
                                        class="px-2.5 py-1.5 text-slate-500 hover:text-emerald-700 disabled:opacity-50"
                                    >
                                        <Minus :size="14" />
                                    </button>
                                    <input
                                        type="number"
                                        :value="item.quantity"
                                        min="0.001"
                                        step="0.1"
                                        @change="updateQuantity(item.id, parseFloat(($event.target as HTMLInputElement).value) || 1)"
                                        class="w-12 border-none text-center text-sm focus:ring-0"
                                    />
                                    <button
                                        @click="updateQuantity(item.id, item.quantity + 1)"
                                        :disabled="loadingItemId === item.id"
                                        class="px-2.5 py-1.5 text-slate-500 hover:text-emerald-700 disabled:opacity-50"
                                    >
                                        <Plus :size="14" />
                                    </button>
                                </div>

                                <!-- Price -->
                                <div class="text-right">
                                    <div class="text-lg font-extrabold text-slate-900">
                                        {{ formatPrice(item.subtotal) }} ₽
                                    </div>
                                    <div class="text-xs text-slate-400">
                                        {{ formatPrice(item.price) }} ₽ × {{ item.quantity }}
                                    </div>
                                </div>

                                <!-- Remove -->
                                <button
                                    @click="removeItem(item.id)"
                                    :disabled="loadingItemId === item.id"
                                    class="ml-3 text-slate-400 hover:text-rose-600 disabled:opacity-50"
                                >
                                    <Trash2 :size="18" />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Summary -->
                <div class="mt-8 rounded-xl border border-slate-200 bg-slate-50 p-6">
                    <div class="flex items-center justify-between">
                        <div class="text-lg font-bold text-slate-900">Итого:</div>
                        <div class="text-2xl font-extrabold text-slate-950">
                            {{ formatPrice(total) }} ₽
                        </div>
                    </div>

                    <div class="mt-6 flex flex-col gap-3 sm:flex-row">
                        <a
                            :href="route('store.catalog.index')"
                            class="flex-1 rounded-xl border border-slate-200 py-3 text-center text-sm font-semibold text-slate-700 hover:border-emerald-300 hover:bg-emerald-50 sm:flex-none"
                        >
                            Продолжить покупки
                        </a>
                        <a
                            :href="route('store.checkout.create')"
                            class="flex-1 rounded-xl bg-emerald-600 py-3 text-center text-sm font-semibold text-white shadow-lg shadow-emerald-600/20 hover:bg-emerald-700 sm:flex-none"
                        >
                            Оформить заказ
                        </a>
                    </div>
                </div>
            </div>

            <!-- Empty cart -->
            <div v-else class="rounded-2xl border border-slate-200 bg-white p-16 text-center">
                <div class="mx-auto flex size-16 items-center justify-center rounded-2xl bg-slate-100 text-slate-400">
                    <Package :size="32" />
                </div>
                <h3 class="mt-4 text-lg font-bold text-slate-900">Корзина пуста</h3>
                <p class="mt-2 text-sm text-slate-500">Добавьте товары из каталога</p>
                <a
                    :href="route('store.catalog.index')"
                    class="mt-6 inline-block rounded-xl bg-emerald-600 px-6 py-3 text-sm font-semibold text-white hover:bg-emerald-700"
                >
                    Перейти в каталог
                </a>
            </div>
        </div>
</template>
