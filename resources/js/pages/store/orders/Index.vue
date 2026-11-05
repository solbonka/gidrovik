<script setup lang="ts">
import { Head, router } from '@inertiajs/vue3'
import { PhCaretRight, PhPackage, PhReceipt } from '@phosphor-icons/vue'

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

function formatPrice(price: string): string {
    const n = parseFloat(price)

    return Number.isNaN(n) ? price : new Intl.NumberFormat('ru-RU').format(n)
}

function pluralItems(n: number): string {
    const m10 = n % 10
    const m100 = n % 100

    if (m10 === 1 && m100 !== 11) return 'товар'
    if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return 'товара'

    return 'товаров'
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

function goTo(url: string | null) {
    if (!url) return

    router.get(url, {}, { preserveScroll: false })
}
</script>

<template>
    <Head title="Мои заказы" />

    <div class="mx-auto max-w-7xl px-3 py-5 sm:px-6 sm:py-8 lg:px-10 lg:py-10">
        <!-- Шапка -->
        <header class="relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-orange-50 via-white to-white p-5 dark:border-zinc-800 dark:from-orange-500/10 dark:via-zinc-900 dark:to-zinc-900 sm:p-8">
            <div class="pointer-events-none absolute -right-16 -top-16 size-64 rounded-full bg-orange-400/20 blur-3xl dark:bg-orange-500/15" />
            <div class="pointer-events-none absolute -bottom-24 right-1/3 size-56 rounded-full bg-amber-300/20 blur-3xl dark:bg-amber-500/10" />

            <div class="relative">
                <p class="inline-flex items-center gap-2 rounded-full bg-orange-500/10 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400 sm:text-xs">
                    <span class="size-1.5 rounded-full bg-orange-500" />
                    Личный кабинет
                </p>

                <h1 class="mt-2 text-3xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-4xl">
                    Мои заказы
                </h1>
            </div>
        </header>

        <!-- Список заказов -->
        <div v-if="orders.data.length > 0" class="mt-6 space-y-3 lg:mt-8">
            <a
                v-for="order in orders.data"
                :key="order.id"
                :href="route('store.orders.show', { order: order.order_number })"
                class="group flex flex-col justify-between gap-4 rounded-3xl border border-zinc-200 bg-white p-5 shadow-sm transition hover:-translate-y-0.5 hover:border-orange-200 hover:shadow-md focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/20 dark:border-zinc-800 dark:bg-zinc-900 dark:hover:border-orange-500/30 sm:flex-row sm:items-center sm:p-6"
            >
                <div class="flex min-w-0 items-center gap-4">
                    <span class="hidden size-12 shrink-0 items-center justify-center rounded-2xl bg-orange-500/10 text-orange-500 sm:flex">
                        <PhReceipt :size="24" weight="duotone" />
                    </span>

                    <div class="min-w-0">
                        <div class="inline-flex items-center gap-2 text-base font-extrabold text-zinc-950 transition group-hover:text-orange-600 dark:text-white dark:group-hover:text-orange-400">
                            Заказ {{ order.order_number }}
                            <PhCaretRight
                                :size="16"
                                weight="bold"
                                class="text-zinc-400 transition group-hover:translate-x-1 group-hover:text-orange-500"
                            />
                        </div>

                        <p class="mt-1 text-xs text-zinc-400">
                            {{ order.created_at }}
                        </p>

                        <p class="mt-0.5 text-xs text-zinc-500 dark:text-zinc-400">
                            {{ order.delivery_method }}
                        </p>
                    </div>
                </div>

                <div class="flex items-center justify-between gap-4 sm:justify-end">
                    <span
                        class="rounded-full px-3 py-1.5 text-xs font-bold ring-1 ring-inset"
                        :class="statusClass(order.status)"
                    >
                        {{ order.status_label }}
                    </span>

                    <div class="text-right">
                        <div class="text-xl font-black tracking-tight text-zinc-950 dark:text-white">
                            {{ formatPrice(order.total_amount) }} ₽
                        </div>

                        <div class="text-xs text-zinc-400">
                            {{ order.items_count }} {{ pluralItems(order.items_count) }}
                        </div>
                    </div>
                </div>
            </a>
        </div>

        <!-- Пусто -->
        <div
            v-else
            class="mt-6 rounded-3xl border border-dashed border-orange-300/70 bg-gradient-to-b from-orange-50/60 to-white p-8 text-center dark:border-orange-500/30 dark:from-orange-500/5 dark:to-zinc-900 sm:mt-8 sm:p-16"
        >
            <div class="mx-auto mb-5 flex size-20 items-center justify-center rounded-3xl bg-orange-100 text-orange-500 shadow-inner dark:bg-orange-500/15">
                <PhPackage :size="38" weight="duotone" />
            </div>

            <h3 class="text-xl font-extrabold text-zinc-900 dark:text-zinc-100">
                У вас пока нет заказов
            </h3>

            <p class="mx-auto mt-2 max-w-sm text-sm text-zinc-500 dark:text-zinc-400">
                Оформите первый заказ в каталоге
            </p>

            <a
                :href="route('store.catalog.index')"
                class="mt-6 inline-flex h-12 items-center rounded-full bg-orange-500 px-8 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/30 transition hover:-translate-y-0.5 hover:bg-orange-400"
            >
                Перейти в каталог
            </a>
        </div>

        <!-- Пагинация -->
        <div v-if="orders.data.length > 0 && orders.last_page > 1" class="mt-8 flex justify-center">
            <nav class="flex items-center gap-1.5" aria-label="Страницы">
                <template v-for="(link, i) in orders.links" :key="i">
                    <button
                        v-if="link.url"
                        type="button"
                        class="flex h-10 min-w-10 items-center justify-center rounded-full px-3 text-sm font-semibold transition focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/20"
                        :class="link.active
                            ? 'bg-orange-500 text-zinc-950 shadow-md shadow-orange-500/30'
                            : 'text-zinc-600 hover:bg-zinc-100 dark:text-zinc-300 dark:hover:bg-zinc-800'"
                        :aria-current="link.active ? 'page' : undefined"
                        @click="goTo(link.url)"
                        v-html="link.label"
                    />

                    <span v-else class="px-2 text-zinc-400" v-html="link.label" />
                </template>
            </nav>
        </div>
    </div>
</template>
