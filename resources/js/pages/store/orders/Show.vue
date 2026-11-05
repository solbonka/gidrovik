<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    PhCalendar,
    PhCaretLeft,
    PhChatText,
    PhEnvelope,
    PhMapPin,
    PhPhone,
    PhBuildings,
    PhTruck,
} from '@phosphor-icons/vue'

defineProps<{
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
        status_history?: Array<{
            id: number
            from_status: string | null
            to_status: string
            note: string | null
            changed_by: string | null
            created_at: string
        }>
    }
}>()

const cardClass = 'rounded-3xl border border-zinc-200 bg-white shadow-sm dark:border-zinc-800 dark:bg-zinc-900'
const metaChipClass = 'rounded-lg bg-zinc-100 px-2 py-0.5 text-[11px] font-medium text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400'
const sectionLabelClass = 'flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-zinc-500 before:h-3 before:w-0.5 before:rounded-full before:bg-orange-500 dark:text-zinc-400'
const iconBubbleClass = 'flex size-8 shrink-0 items-center justify-center rounded-full bg-orange-500/10 text-orange-500'

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}

function statusClass(status: string): string {
    const map: Record<string, string> = {
        pending: 'bg-amber-500/10 text-amber-700 ring-amber-500/20 dark:text-amber-400',
        processing: 'bg-blue-500/10 text-blue-700 ring-blue-500/20 dark:text-blue-400',
        completed: 'bg-emerald-500/10 text-emerald-700 ring-emerald-500/20 dark:text-emerald-400',
        cancelled: 'bg-rose-500/10 text-rose-700 ring-rose-500/20 dark:text-rose-400',
    }

    return map[status] || 'bg-zinc-500/10 text-zinc-600 ring-zinc-500/20 dark:text-zinc-300'
}
</script>

<template>
    <Head title="Заказ" />

    <div class="mx-auto max-w-7xl px-3 py-5 sm:px-6 sm:py-8 lg:px-10 lg:py-10">
        <!-- Шапка -->
        <header class="relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-orange-50 via-white to-white p-5 dark:border-zinc-800 dark:from-orange-500/10 dark:via-zinc-900 dark:to-zinc-900 sm:p-8">
            <div class="pointer-events-none absolute -right-16 -top-16 size-64 rounded-full bg-orange-400/20 blur-3xl dark:bg-orange-500/15" />
            <div class="pointer-events-none absolute -bottom-24 right-1/3 size-56 rounded-full bg-amber-300/20 blur-3xl dark:bg-amber-500/10" />

            <div class="relative flex flex-wrap items-center justify-between gap-x-6 gap-y-4">
                <div class="flex items-center gap-4">
                    <a
                        :href="route('store.orders.index')"
                        class="flex size-11 shrink-0 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-600 shadow-sm transition hover:border-orange-400 hover:text-orange-600 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/20 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
                        aria-label="К списку заказов"
                    >
                        <PhCaretLeft :size="20" weight="bold" />
                    </a>

                    <div>
                        <p class="inline-flex items-center gap-2 rounded-full bg-orange-500/10 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400 sm:text-xs">
                            <span class="size-1.5 rounded-full bg-orange-500" />
                            Личный кабинет
                        </p>

                        <h1 class="mt-2 text-3xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-4xl">
                            Заказ {{ order.order_number }}
                        </h1>
                    </div>
                </div>

                <span
                    class="inline-flex rounded-full px-4 py-2 text-sm font-bold ring-1 ring-inset"
                    :class="statusClass(order.status)"
                >
                    {{ order.status_label }}
                </span>
            </div>
        </header>

        <div class="mt-6 grid gap-6 lg:mt-8 lg:grid-cols-5 lg:items-start lg:gap-8">
            <!-- Товары -->
            <section :class="cardClass" class="overflow-hidden lg:col-span-3">
                <div class="border-b border-zinc-100 bg-gradient-to-br from-orange-50/70 to-white px-6 py-4 dark:border-zinc-800 dark:from-orange-500/10 dark:to-zinc-900">
                    <h2 class="text-lg font-extrabold text-zinc-950 dark:text-white">
                        Товары
                    </h2>
                </div>

                <ul class="divide-y divide-zinc-100 dark:divide-zinc-800">
                    <li
                        v-for="item in order.items"
                        :key="item.id"
                        class="flex justify-between gap-4 px-6 py-4"
                    >
                        <div class="min-w-0 flex-1">
                            <div class="font-semibold text-zinc-900 dark:text-zinc-100">
                                {{ item.name }}
                            </div>

                            <div class="mt-1.5 flex flex-wrap gap-1.5">
                                <span v-if="item.code" :class="metaChipClass">Код: {{ item.code }}</span>
                                <span v-if="item.article" :class="metaChipClass">Артикул: {{ item.article }}</span>
                            </div>

                            <div class="mt-1.5 text-xs text-zinc-500 dark:text-zinc-400">
                                {{ formatPrice(item.price) }} ₽ × {{ item.quantity }}
                            </div>
                        </div>

                        <div class="shrink-0 text-right text-base font-black tracking-tight text-zinc-900 dark:text-zinc-100">
                            {{ formatPrice(item.subtotal) }} ₽
                        </div>
                    </li>
                </ul>

                <div class="border-t border-dashed border-zinc-200 px-6 py-5 dark:border-zinc-700">
                    <div class="flex items-baseline justify-between gap-3">
                        <span class="text-base font-bold text-zinc-950 dark:text-white">Итого</span>
                        <span class="text-3xl font-black tracking-tight text-zinc-950 dark:text-white">
                            {{ formatPrice(order.total_amount) }} ₽
                        </span>
                    </div>
                </div>
            </section>

            <!-- Детали -->
            <div class="space-y-5 lg:col-span-2">
                <section :class="cardClass" class="p-6">
                    <h3 :class="sectionLabelClass">
                        Детали заказа
                    </h3>

                    <ul class="mt-5 space-y-4 text-sm">
                        <li class="flex items-center gap-3">
                            <span :class="iconBubbleClass"><PhCalendar :size="16" weight="duotone" /></span>
                            <div>
                                <div class="text-xs text-zinc-400">Дата оформления</div>
                                <div class="font-semibold text-zinc-900 dark:text-zinc-100">{{ order.created_at }}</div>
                            </div>
                        </li>

                        <li class="flex items-center gap-3">
                            <span :class="iconBubbleClass"><PhTruck :size="16" weight="duotone" /></span>
                            <div>
                                <div class="text-xs text-zinc-400">Способ получения</div>
                                <div class="font-semibold text-zinc-900 dark:text-zinc-100">{{ order.delivery_method_label }}</div>
                            </div>
                        </li>

                        <li v-if="order.delivery_address" class="flex items-center gap-3">
                            <span :class="iconBubbleClass"><PhMapPin :size="16" weight="duotone" /></span>
                            <div>
                                <div class="text-xs text-zinc-400">Адрес доставки</div>
                                <div class="font-semibold text-zinc-900 dark:text-zinc-100">{{ order.delivery_address }}</div>
                            </div>
                        </li>

                        <li v-if="order.comment" class="flex items-center gap-3">
                            <span :class="iconBubbleClass"><PhChatText :size="16" weight="duotone" /></span>
                            <div>
                                <div class="text-xs text-zinc-400">Комментарий</div>
                                <div class="font-semibold text-zinc-900 dark:text-zinc-100">{{ order.comment }}</div>
                            </div>
                        </li>
                    </ul>
                </section>

                <section :class="cardClass" class="p-6">
                    <h3 :class="sectionLabelClass">
                        Контактные данные
                    </h3>

                    <ul class="mt-5 space-y-4 text-sm">
                        <li class="flex items-center gap-3">
                            <span :class="iconBubbleClass"><PhPhone :size="16" weight="duotone" /></span>
                            <span class="font-semibold text-zinc-900 dark:text-zinc-100">{{ order.customer_phone }}</span>
                        </li>

                        <li class="flex items-center gap-3">
                            <span :class="iconBubbleClass"><PhEnvelope :size="16" weight="duotone" /></span>
                            <span class="break-all font-semibold text-zinc-900 dark:text-zinc-100">{{ order.customer_email }}</span>
                        </li>

                        <li v-if="order.customer_organization" class="flex items-center gap-3">
                            <span :class="iconBubbleClass"><PhBuildings :size="16" weight="duotone" /></span>
                            <div>
                                <div class="text-xs text-zinc-400">Организация</div>
                                <div class="font-semibold text-zinc-900 dark:text-zinc-100">{{ order.customer_organization }}</div>
                            </div>
                        </li>
                    </ul>
                </section>
            </div>
        </div>

        <!-- История статусов -->
        <section v-if="(order.status_history ?? []).length > 0" :class="cardClass" class="mt-6 p-6 lg:mt-8">
            <h2 class="text-lg font-extrabold text-zinc-950 dark:text-white">
                История статусов
            </h2>

            <ol class="mt-6">
                <li
                    v-for="(history, i) in (order.status_history ?? [])"
                    :key="history.id"
                    class="flex gap-4"
                >
                    <div class="flex flex-col items-center">
                        <div class="flex size-9 items-center justify-center rounded-full bg-orange-500 text-sm font-black text-zinc-950 shadow-md shadow-orange-500/30">
                            {{ i + 1 }}
                        </div>

                        <div
                            v-if="i < (order.status_history ?? []).length - 1"
                            class="my-1 w-px flex-1 bg-gradient-to-b from-orange-300 to-zinc-200 dark:from-orange-500/50 dark:to-zinc-800"
                        />
                    </div>

                    <div class="pb-7">
                        <div class="text-sm font-bold text-zinc-900 dark:text-zinc-100">
                            {{ history.to_status }}
                            <span v-if="history.from_status" class="font-medium text-zinc-400">
                                (было: {{ history.from_status }})
                            </span>
                        </div>

                        <p v-if="history.note" class="mt-1 text-xs text-zinc-500 dark:text-zinc-400">
                            {{ history.note }}
                        </p>

                        <p class="mt-1 text-xs text-zinc-400">
                            {{ history.created_at }}
                            <span v-if="history.changed_by">· {{ history.changed_by }}</span>
                        </p>
                    </div>
                </li>
            </ol>
        </section>
    </div>
</template>
