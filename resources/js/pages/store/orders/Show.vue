<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    PhCaretLeft,
    PhCalendar,
    PhMapPin,
    PhPhone,
    PhEnvelope,
    PhPackage,
} from '@phosphor-icons/vue'

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
            code: string | null
            article: string | null
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

function statusClass(status: string): string {
    const map: Record<string, string> = {
        pending: 'bg-amber-500/10 text-amber-700 dark:text-amber-400',
        processing: 'bg-blue-500/10 text-blue-700 dark:text-blue-400',
        completed: 'bg-emerald-500/10 text-emerald-700 dark:text-emerald-400',
        cancelled: 'bg-rose-500/10 text-rose-700 dark:text-rose-400',
    }
    return map[status] || 'bg-zinc-500/10 text-zinc-600 dark:text-zinc-300'
}
</script>

<template>
    <Head title="Заказ" />

    <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-10 lg:py-12">
        <!-- Header -->
        <div class="mb-8 flex items-center gap-4">
            <a
                :href="route('store.orders.index')"
                class="flex size-10 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-600 transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
            >
                <PhCaretLeft :size="20" weight="bold" />
            </a>
            <div>
                <p class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400">Личный кабинет</p>
                <h1 class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-3xl">
                    Заказ {{ order.order_number }}
                </h1>
            </div>
        </div>

        <!-- Status -->
        <div class="mb-8">
            <span
                class="inline-flex rounded-full px-4 py-1.5 text-sm font-bold"
                :class="statusClass(order.status)"
            >
                {{ order.status_label }}
            </span>
        </div>

        <div class="grid gap-8 lg:grid-cols-5">
            <!-- Order items -->
            <div class="lg:col-span-3">
                <div class="rounded-2xl border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900">
                    <div class="border-b border-zinc-200 px-6 py-4 dark:border-zinc-800">
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Товары</h2>
                    </div>

                    <div class="divide-y divide-zinc-100 dark:divide-zinc-800">
                        <div
                            v-for="item in order.items"
                            :key="item.id"
                            class="flex justify-between px-6 py-4"
                        >
                            <div class="min-w-0 flex-1">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ item.name }}</div>
                                <div class="mt-1 flex flex-wrap gap-1.5">
                                    <span v-if="item.code" class="rounded-md bg-zinc-100 px-2 py-0.5 text-[11px] font-medium text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400">
                                        Код: {{ item.code }}
                                    </span>
                                    <span v-if="item.article" class="rounded-md bg-zinc-100 px-2 py-0.5 text-[11px] font-medium text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400">
                                        Артикул: {{ item.article }}
                                    </span>
                                </div>
                                <div class="mt-1 text-xs text-zinc-500 dark:text-zinc-400">
                                    {{ formatPrice(item.price) }} ₽ × {{ item.quantity }}
                                </div>
                            </div>
                            <div class="shrink-0 text-right font-bold text-zinc-900 dark:text-zinc-100">
                                {{ formatPrice(item.subtotal) }} ₽
                            </div>
                        </div>
                    </div>

                    <div class="border-t border-zinc-200 px-6 py-4 dark:border-zinc-800">
                        <div class="flex items-baseline justify-between">
                            <span class="text-base font-bold text-zinc-950 dark:text-white">Итого:</span>
                            <span class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                                {{ formatPrice(order.total_amount) }} ₽
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Order details -->
            <div class="space-y-6 lg:col-span-2">
                <!-- Info card -->
                <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                    <h3 class="text-sm font-bold text-zinc-950 dark:text-white">Детали заказа</h3>
                    <div class="mt-4 space-y-3 text-sm">
                        <div class="flex justify-between">
                            <span class="text-zinc-500 dark:text-zinc-400">Дата оформления</span>
                            <span class="flex items-center gap-1.5 font-medium text-zinc-900 dark:text-zinc-100">
                                <PhCalendar :size="14" />
                                {{ order.created_at }}
                            </span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-zinc-500 dark:text-zinc-400">Способ получения</span>
                            <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ order.delivery_method_label }}</span>
                        </div>
                        <div v-if="order.delivery_address" class="flex flex-col gap-1">
                            <span class="text-zinc-500 dark:text-zinc-400">Адрес доставки</span>
                            <span class="flex items-center gap-1.5 font-medium text-zinc-900 dark:text-zinc-100">
                                <PhMapPin :size="14" />
                                {{ order.delivery_address }}
                            </span>
                        </div>
                        <div v-if="order.comment" class="flex flex-col gap-1">
                            <span class="text-zinc-500 dark:text-zinc-400">Комментарий</span>
                            <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ order.comment }}</span>
                        </div>
                    </div>
                </div>

                <!-- Contact info -->
                <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                    <h3 class="text-sm font-bold text-zinc-950 dark:text-white">Контактные данные</h3>
                    <div class="mt-4 space-y-3 text-sm">
                        <div class="flex items-center gap-2">
                            <PhPhone :size="16" weight="bold" class="text-zinc-400" />
                            <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ order.customer_phone }}</span>
                        </div>
                        <div class="flex items-center gap-2">
                            <PhEnvelope :size="16" weight="bold" class="text-zinc-400" />
                            <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ order.customer_email }}</span>
                        </div>
                        <div v-if="order.customer_organization" class="flex flex-col gap-1">
                            <span class="text-zinc-500 dark:text-zinc-400">Организация:</span>
                            <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ order.customer_organization }}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Status history -->
        <div class="mt-8">
            <h2 class="text-lg font-bold text-zinc-950 dark:text-white">История статусов</h2>
            <div class="mt-4 space-y-4">
                <div
                    v-for="(history, i) in order.status_history"
                    :key="history.id"
                    class="flex gap-4"
                >
                    <div class="flex flex-col items-center">
                        <div class="flex size-8 items-center justify-center rounded-full bg-orange-500/10 text-sm font-bold text-orange-600 dark:text-orange-400">
                            {{ i + 1 }}
                        </div>
                        <div v-if="i < order.status_history.length - 1" class="mt-1 h-8 w-px bg-zinc-200 dark:bg-zinc-800" />
                    </div>
                    <div class="pb-6">
                        <div class="text-sm font-medium text-zinc-900 dark:text-zinc-100">
                            {{ history.to_status }}
                            <span v-if="history.from_status" class="text-zinc-400">
                                (было: {{ history.from_status }})
                            </span>
                        </div>
                        <p v-if="history.note" class="mt-0.5 text-xs text-zinc-500 dark:text-zinc-400">{{ history.note }}</p>
                        <p class="mt-1 text-xs text-zinc-400">
                            {{ history.created_at }}
                            <span v-if="history.changed_by">· {{ history.changed_by }}</span>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
