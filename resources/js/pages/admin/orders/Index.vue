<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    Calendar,
    ChevronDown,
    ChevronLeft,
    ChevronRight,
    Filter,
    Mail,
    Phone,
    Search,
    Store,
    Truck,
} from '@lucide/vue'
import { ref } from 'vue'

import AdminLayout from '@/layouts/AdminLayout.vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import type { Order, OrderFilters, OrderStatus } from '@/types/order'

defineOptions({ layout: AdminLayout })

const props = defineProps<{
    orders: {
        data: Order[]
        current_page: number
        last_page: number
        per_page: number
        total: number
        links: Array<{ url: string | null, label: string, active: boolean }>
    }
    filters: OrderFilters
    statuses: OrderStatus[]
}>()

const showFilters = ref(false)
const localFilters = ref({ ...props.filters })

function applyFilters() {
    router.get(route('admin.orders.index'), localFilters.value, {
        preserveState: true,
        preserveScroll: true,
    })
}

function clearFilters() {
    localFilters.value = { search: '', status: '', date_from: '', date_to: '' }
    router.get(route('admin.orders.index'), {}, {
        preserveState: true,
        preserveScroll: true,
    })
}

function formatDate(dateStr: string): string {
    return dateStr
}
</script>

<template>
    <Head title="Заказы — Гидровик" />

    <div class="p-6 lg:p-8">
        <!-- Header -->
        <div class="mb-6 flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
            <div>
                <h1 class="text-2xl font-extrabold tracking-tight sm:text-3xl">Заказы</h1>
                <p class="mt-1 text-sm text-muted-foreground">
                    Всего заказов: {{ orders.total }}
                </p>
            </div>

            <Button
                variant="outline"
                @click="showFilters = !showFilters"
                class="sm:hidden"
            >
                <Filter :size="16" class="mr-2" />
                Фильтры
            </Button>
        </div>

        <!-- Filters -->
        <div
            class="mb-6 rounded-xl border bg-card p-4 shadow-sm"
            :class="showFilters ? 'block sm:hidden' : 'hidden sm:block'"
        >
            <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                <div>
                    <label class="mb-1 block text-xs font-medium text-muted-foreground">Поиск</label>
                    <Input
                        v-model="localFilters.search"
                        placeholder="Номер, имя, email, телефон"
                        @keyup.enter="applyFilters"
                    />
                </div>

                <div>
                    <label class="mb-1 block text-xs font-medium text-muted-foreground">Статус</label>
                    <select
                        v-model="localFilters.status"
                        @change="applyFilters"
                        class="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm focus:border-ring focus:ring-ring/30"
                    >
                        <option value="">Все статусы</option>
                        <option
                            v-for="status in statuses"
                            :key="status.value"
                            :value="status.value"
                        >
                            {{ status.label }}
                        </option>
                    </select>
                </div>

                <div>
                    <label class="mb-1 block text-xs font-medium text-muted-foreground">С даты</label>
                    <Input
                        v-model="localFilters.date_from"
                        type="date"
                        @change="applyFilters"
                    />
                </div>

                <div>
                    <label class="mb-1 block text-xs font-medium text-muted-foreground">По дату</label>
                    <Input
                        v-model="localFilters.date_to"
                        type="date"
                        @change="applyFilters"
                    />
                </div>
            </div>

            <div class="mt-3 flex justify-end">
                <Button variant="ghost" size="sm" @click="clearFilters">
                    Сбросить
                </Button>
            </div>
        </div>

        <!-- Table -->
        <div class="overflow-hidden rounded-xl border bg-card shadow-sm">
            <!-- Desktop table -->
            <div class="hidden overflow-x-auto md:block">
                <table class="w-full text-sm">
                    <thead class="bg-muted/40">
                        <tr class="border-b border-border">
                            <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                                № заказа
                            </th>
                            <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                                Покупатель
                            </th>
                            <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                                Способ
                            </th>
                            <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                                Сумма
                            </th>
                            <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                                Статус
                            </th>
                            <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                                Дата
                            </th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-border">
                        <tr
                            v-for="order in orders.data"
                            :key="order.id"
                            class="hover:bg-muted/40"
                        >
                            <td class="px-4 py-3">
                                <a
                                    :href="route('admin.orders.show', { order: order.order_number })"
                                    class="font-semibold text-primary hover:text-primary/80"
                                >
                                    {{ order.order_number }}
                                </a>
                                <div class="mt-0.5 text-xs text-muted-foreground">
                                    {{ order.items_count }} {{ order.items_count === 1 ? 'товар' : order.items_count < 5 ? 'товара' : 'товаров' }}
                                </div>
                            </td>

                            <td class="px-4 py-3">
                                <div class="font-medium">{{ order.customer_name }}</div>
                                <div class="mt-0.5 text-xs text-muted-foreground">
                                    <Phone :size="10" class="inline mr-0.5" />
                                    {{ order.customer_phone }}
                                </div>
                                <div class="text-xs text-muted-foreground">
                                    <Mail :size="10" class="inline mr-0.5" />
                                    {{ order.customer_email }}
                                </div>
                            </td>

                            <td class="px-4 py-3">
                                <div class="flex items-center gap-1.5 text-muted-foreground">
                                    <Truck v-if="order.delivery_method === 'Доставка'" :size="14" />
                                    <Store v-else :size="14" />
                                    {{ order.delivery_method }}
                                </div>
                            </td>

                            <td class="px-4 py-3">
                                <span class="font-bold tabular-nums">{{ order.total_amount }} ₽</span>
                            </td>

                            <td class="px-4 py-3">
                                <span
                                    class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-bold"
                                    :class="order.status_color"
                                >
                                    {{ order.status_label }}
                                </span>
                            </td>

                            <td class="px-4 py-3 text-muted-foreground">
                                {{ formatDate(order.created_at) }}
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Mobile cards -->
            <div class="md:hidden">
                <div
                    v-for="order in orders.data"
                    :key="order.id"
                    class="border-b border-border p-4"
                >
                    <div class="flex items-start justify-between">
                        <a
                            :href="route('admin.orders.show', { order: order.order_number })"
                            class="font-bold text-primary hover:text-primary/80"
                        >
                            {{ order.order_number }}
                        </a>
                        <span
                            class="rounded-full px-2 py-0.5 text-[10px] font-bold"
                            :class="order.status_color"
                        >
                            {{ order.status_label }}
                        </span>
                    </div>

                    <p class="mt-1 text-sm font-medium">{{ order.customer_name }}</p>
                    <p class="mt-0.5 text-xs text-muted-foreground">{{ order.customer_phone }}</p>

                    <div class="mt-3 flex items-center justify-between">
                        <div class="flex items-center gap-2 text-xs text-muted-foreground">
                            <Calendar :size="12" />
                            {{ formatDate(order.created_at) }}
                        </div>
                        <div class="text-sm font-bold tabular-nums">
                            {{ order.total_amount }} ₽
                        </div>
                    </div>
                </div>
            </div>

            <!-- Empty state -->
            <div v-if="orders.data.length === 0" class="p-16 text-center">
                <div class="mx-auto flex size-14 items-center justify-center rounded-2xl bg-muted text-muted-foreground">
                    <Store :size="28" />
                </div>
                <h3 class="mt-4 text-lg font-bold">Заказов пока нет</h3>
                <p class="mt-1 text-sm text-muted-foreground">Новые заказы появятся здесь</p>
            </div>

            <!-- Pagination -->
            <div v-if="orders.data.length > 0" class="border-t border-border px-4 py-3">
                <div class="flex items-center justify-between">
                    <p class="text-xs text-muted-foreground">
                        Показано {{ orders.data.length }} из {{ orders.total }}
                    </p>
                    <nav class="flex items-center gap-1">
                        <template v-for="(link, i) in orders.links" :key="i">
                            <button
                                v-if="link.url"
                                :disabled="!link.url"
                                :class="[
                                    'rounded px-2 py-1 text-xs font-medium transition',
                                    link.active
                                        ? 'bg-primary text-primary-foreground'
                                        : 'text-muted-foreground hover:bg-muted'
                                ]"
                                v-html="link.label"
                            />
                            <span v-else class="px-1 text-muted-foreground">…</span>
                        </template>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</template>
