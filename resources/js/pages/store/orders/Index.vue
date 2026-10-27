<script setup lang="ts">
import { Package } from '@lucide/vue'

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
</script>

<template>
    <div class="mx-auto max-w-4xl px-5 py-8 lg:px-10">
            <h1 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">Мои заказы</h1>

            <div v-if="orders.data.length > 0" class="mt-8 space-y-4">
                <div
                    v-for="order in orders.data"
                    :key="order.id"
                    class="rounded-xl border border-slate-200 bg-white p-5 transition hover:border-emerald-200"
                >
                    <div class="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
                        <div>
                            <a
                                :href="route('store.orders.show', { order: order.order_number })"
                                class="text-sm font-bold text-emerald-700 hover:text-emerald-800"
                            >
                                {{ order.order_number }}
                            </a>
                            <p class="mt-1 text-xs text-slate-400">{{ formatDate(order.created_at) }}</p>
                            <p class="mt-1 text-xs text-slate-500">{{ order.delivery_method }}</p>
                        </div>

                        <div class="flex items-center gap-4">
                            <span
                                class="rounded-full px-3 py-1 text-xs font-bold"
                                :class="order.status_color"
                            >
                                {{ order.status_label }}
                            </span>
                            <div class="text-right">
                                <div class="text-lg font-extrabold text-slate-900">
                                    {{ order.total_amount }} ₽
                                </div>
                                <div class="text-xs text-slate-400">{{ order.items_count }} {{ order.items_count === 1 ? 'товар' : order.items_count < 5 ? 'товара' : 'товаров' }}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Empty state -->
            <div v-else class="mt-8 rounded-2xl border border-slate-200 bg-white p-16 text-center">
                <div class="mx-auto flex size-16 items-center justify-center rounded-2xl bg-slate-100 text-slate-400">
                    <Package :size="32" />
                </div>
                <h3 class="mt-4 text-lg font-bold text-slate-900">У вас пока нет заказов</h3>
                <p class="mt-2 text-sm text-slate-500">Оформите первый заказ в каталоге</p>
            </div>

            <!-- Pagination -->
            <div v-if="orders.data.length > 0" class="mt-8 flex justify-center">
                <nav class="flex items-center gap-1">
                    <template v-for="(link, i) in orders.links" :key="i">
                        <button
                            v-if="link.url"
                            :class="[
                                'rounded-lg px-3 py-2 text-sm font-medium transition',
                                link.active ? 'bg-emerald-600 text-white' : 'text-slate-600 hover:bg-slate-100'
                            ]"
                            v-html="link.label"
                        />
                        <span v-else class="px-2 text-slate-400">…</span>
                    </template>
                </nav>
            </div>
        </div>
</template>
