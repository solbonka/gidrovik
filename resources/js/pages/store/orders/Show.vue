<script setup lang="ts">
import { ArrowLeft, Calendar, MapPin, Phone, Package } from '@lucide/vue'

const props = defineProps<{
    order: {
        id: number
        order_number: string
        customer_name: string
        customer_email: string
        customer_phone: string
        customer_organization?: string | null
        delivery_method: string
        delivery_method_label: string
        delivery_address?: string | null
        comment?: string | null
        total_amount: string
        status: string
        status_label: string
        status_color: string
        created_at: string
        items: Array<{
            id: number
            name: string
            sku: string | null
            quantity: number
            price: string
            subtotal: string
        }>
        status_history: Array<{
            id: number
            from_status: string | null
            to_status: string
            note: string | null
            changed_by: string | null
            created_at: string
        }>
    }
}>()

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}
</script>

<template>
    <div class="mx-auto max-w-4xl px-5 py-8 lg:px-10">
            <a
                :href="route('store.orders.index')"
                class="mb-6 inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-emerald-700"
            >
                <ArrowLeft :size="14" />
                Вернуться к заказам
            </a>

            <h1 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">
                Заказ {{ order.order_number }}
            </h1>

            <!-- Status -->
            <div class="mt-4">
                <span
                    class="inline-flex rounded-full px-3 py-1.5 text-sm font-bold"
                    :class="order.status_color"
                >
                    {{ order.status_label }}
                </span>
            </div>

            <div class="mt-8 grid gap-8 lg:grid-cols-5">
                <!-- Order items -->
                <div class="lg:col-span-3">
                    <div class="rounded-xl border border-slate-200 bg-white">
                        <div class="border-b border-slate-200 px-6 py-4">
                            <h2 class="text-lg font-bold text-slate-900">Товары</h2>
                        </div>

                        <div class="divide-y divide-slate-100">
                            <div
                                v-for="item in order.items"
                                :key="item.id"
                                class="flex justify-between px-6 py-4"
                            >
                                <div class="min-w-0 flex-1">
                                    <div class="font-medium text-slate-900">{{ item.name }}</div>
                                    <p v-if="item.sku" class="mt-0.5 text-xs text-slate-400">Арт: {{ item.sku }}</p>
                                    <div class="mt-1 text-xs text-slate-500">
                                        {{ formatPrice(item.price) }} ₽ × {{ item.quantity }}
                                    </div>
                                </div>
                                <div class="shrink-0 text-right font-bold text-slate-900">
                                    {{ formatPrice(item.subtotal) }} ₽
                                </div>
                            </div>
                        </div>

                        <div class="border-t border-slate-200 px-6 py-4">
                            <div class="flex items-center justify-between">
                                <span class="text-base font-bold text-slate-900">Итого:</span>
                                <span class="text-2xl font-extrabold text-slate-950">
                                    {{ formatPrice(order.total_amount) }} ₽
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Order details -->
                <div class="lg:col-span-2 space-y-6">
                    <!-- Info card -->
                    <div class="rounded-xl border border-slate-200 bg-white p-6">
                        <h3 class="text-sm font-bold text-slate-900">Детали заказа</h3>
                        <div class="mt-4 space-y-3 text-sm">
                            <div class="flex justify-between">
                                <span class="text-slate-500">Дата оформления</span>
                                <span class="font-medium text-slate-900">{{ order.created_at }}</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-slate-500">Способ получения</span>
                                <span class="font-medium text-slate-900">{{ order.delivery_method_label }}</span>
                            </div>
                            <div v-if="order.delivery_address" class="flex flex-col gap-1">
                                <span class="text-slate-500">Адрес доставки</span>
                                <span class="font-medium text-slate-900">{{ order.delivery_address }}</span>
                            </div>
                            <div v-if="order.comment" class="flex flex-col gap-1">
                                <span class="text-slate-500">Комментарий</span>
                                <span class="font-medium text-slate-900">{{ order.comment }}</span>
                            </div>
                        </div>
                    </div>

                    <!-- Contact info -->
                    <div class="rounded-xl border border-slate-200 bg-white p-6">
                        <h3 class="text-sm font-bold text-slate-900">Контактные данные</h3>
                        <div class="mt-4 space-y-3 text-sm">
                            <div class="flex items-center gap-2">
                                <Phone :size="14" class="text-slate-400" />
                                <span class="font-medium text-slate-900">{{ order.customer_phone }}</span>
                            </div>
                            <div class="flex items-center gap-2">
                                <svg :size="14" class="text-slate-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/></svg>
                                <span class="font-medium text-slate-900">{{ order.customer_email }}</span>
                            </div>
                            <div v-if="order.customer_organization">
                                <span class="text-slate-500">Организация:</span>
                                <span class="ml-2 font-medium text-slate-900">{{ order.customer_organization }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Status history -->
            <div class="mt-8">
                <h2 class="text-lg font-bold text-slate-900">История статусов</h2>
                <div class="mt-4 space-y-4">
                    <div
                        v-for="(history, i) in order.status_history"
                        :key="history.id"
                        class="flex gap-4"
                    >
                        <div class="flex flex-col items-center">
                            <div class="flex size-8 items-center justify-center rounded-full bg-emerald-100 text-sm font-bold text-emerald-700">
                                {{ i + 1 }}
                            </div>
                            <div v-if="i < order.status_history.length - 1" class="mt-1 h-8 w-px bg-slate-200" />
                        </div>
                        <div class="pb-6">
                            <div class="text-sm font-medium text-slate-900">
                                {{ history.to_status }}
                                <span v-if="history.from_status" class="text-slate-400">
                                    (было: {{ history.from_status }})
                                </span>
                            </div>
                            <p v-if="history.note" class="mt-0.5 text-xs text-slate-500">{{ history.note }}</p>
                            <p class="mt-1 text-xs text-slate-400">
                                {{ history.created_at }}
                                <span v-if="history.changed_by">· {{ history.changed_by }}</span>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</template>
