<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    PhPackage,
    PhCaretRight,
} from '@phosphor-icons/vue'

const props = defineProps<{
    orders: {
        data: Array<{
            id: number
            order_number: string
            total_amount: string
            status: string
            status_label: string
            status_color: string
            items_count: number
            created_at: string
            delivery_method: string
        }>
        current_page: number
        last_page: number
        links: Array<{ url: string | null, label: string, active: boolean }>
    }
}>()

function formatDate(dateStr: string): string {
    return dateStr
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
    <Head title="Мои заказы" />

    <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-10 lg:py-12">
        <!-- Header -->
        <div class="mb-8">
            <p class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400">Личный кабинет</p>
            <h1 class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-3xl">Мои заказы</h1>
        </div>

        <div v-if="orders.data.length > 0" class="space-y-3">
            <div
                v-for="order in orders.data"
                :key="order.id"
                class="group rounded-2xl border border-zinc-200 bg-white p-5 transition hover:shadow-lg dark:border-zinc-800 dark:bg-zinc-900"
            >
                <div class="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
                    <div>
                        <a
                            :href="route('store.orders.show', { order: order.order_number })"
                            class="inline-flex items-center gap-2 text-sm font-bold text-zinc-950 transition hover:text-orange-600 dark:text-white dark:hover:text-orange-400"
                        >
                            Заказ {{ order.order_number }}
                            <PhCaretRight :size="16" weight="bold" class="text-zinc-400 transition group-hover:translate-x-1 group-hover:text-orange-500" />
                        </a>
                        <p class="mt-1 text-xs text-zinc-400">{{ formatDate(order.created_at) }}</p>
                        <p class="mt-1 text-xs text-zinc-500 dark:text-zinc-400">{{ order.delivery_method }}</p>
                    </div>

                    <div class="flex items-center gap-4">
                        <span
                            class="rounded-full px-3 py-1 text-xs font-bold"
                            :class="statusClass(order.status)"
                        >
                            {{ order.status_label }}
                        </span>
                        <div class="text-right">
                            <div class="text-lg font-black tracking-tight text-zinc-950 dark:text-white">
                                {{ order.total_amount }} ₽
                            </div>
                            <div class="text-xs text-zinc-400">{{ order.items_count }} {{ order.items_count === 1 ? 'товар' : order.items_count < 5 ? 'товара' : 'товаров' }}</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Empty state -->
        <div v-else class="rounded-3xl border border-dashed border-zinc-300 bg-white p-16 text-center dark:border-zinc-700 dark:bg-zinc-900">
            <div class="mx-auto mb-4 flex size-16 items-center justify-center rounded-2xl bg-zinc-100 text-zinc-400 dark:bg-zinc-800">
                <PhPackage :size="32" weight="light" />
            </div>
            <h3 class="text-xl font-extrabold text-zinc-900 dark:text-zinc-100">У вас пока нет заказов</h3>
            <p class="mt-2 text-sm text-zinc-500 dark:text-zinc-400">Оформите первый заказ в каталоге</p>
        </div>

        <!-- Pagination -->
        <div v-if="orders.data.length > 0 && orders.last_page > 1" class="mt-8 flex justify-center">
            <nav class="flex items-center gap-1.5">
                <template v-for="(link, i) in orders.links" :key="i">
                    <button
                        v-if="link.url"
                        :class="[
                            'flex size-10 items-center justify-center rounded-full text-sm font-semibold transition',
                            link.active
                                ? 'bg-zinc-950 text-white dark:bg-white dark:text-zinc-950'
                                : 'text-zinc-600 hover:bg-zinc-100 dark:text-zinc-300 dark:hover:bg-zinc-800'
                        ]"
                        v-html="link.label"
                    />
                    <span v-else class="px-2 text-zinc-400">…</span>
                </template>
            </nav>
        </div>
    </div>
</template>
