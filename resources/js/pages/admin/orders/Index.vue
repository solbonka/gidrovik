<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import {
    ChevronRight,
    FileText,
    Mail,
    Package,
    Phone,
    Search,
    Sparkles,
    Store,
    Truck,
    X,
} from '@lucide/vue'

import AdminLayout from '@/layouts/AdminLayout.vue'
import Pagination from '@/components/admin/Pagination.vue'
import { Button } from '@/components/ui/button'
import { statusStyle } from '@/lib/orderStatusStyles'
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
    status_counts: Record<string, number>
}>()

function countOf(status: string): number {
    return props.status_counts?.[status] ?? 0
}

const countAll = computed(() =>
    Object.values(props.status_counts ?? {}).reduce((sum, n) => sum + n, 0),
)

const search = ref(props.filters.search || '')
const statusFilter = ref(props.filters.status || '')
const dateFrom = ref(props.filters.date_from || '')
const dateTo = ref(props.filters.date_to || '')

const hasFilters = computed(
    () => !!(search.value.trim() || statusFilter.value || dateFrom.value || dateTo.value),
)

// Все фильтры работают на сервере — иначе поиск видит только текущую страницу
function applyFilters() {
    router.get(
        route('admin.orders.index'),
        {
            search: search.value.trim() || undefined,
            status: statusFilter.value || undefined,
            date_from: dateFrom.value || undefined,
            date_to: dateTo.value || undefined,
        },
        { preserveState: true, preserveScroll: true, replace: true },
    )
}

let searchTimer: ReturnType<typeof setTimeout> | undefined
watch(search, () => {
    clearTimeout(searchTimer)
    searchTimer = setTimeout(applyFilters, 400)
})
onBeforeUnmount(() => clearTimeout(searchTimer))

function setStatus(value: string) {
    statusFilter.value = value
    applyFilters()
}

function clearFilters() {
    clearTimeout(searchTimer)
    search.value = ''
    statusFilter.value = ''
    dateFrom.value = ''
    dateTo.value = ''
    router.get(route('admin.orders.index'), {}, {
        preserveState: true,
        preserveScroll: true,
        replace: true,
    })
}

function openOrder(order: Order) {
    router.visit(route('admin.orders.show', { order: order.order_number }))
}

function itemsLabel(count: number): string {
    const mod10 = count % 10
    const mod100 = count % 100
    if (mod10 === 1 && mod100 !== 11) return `${count} товар`
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) return `${count} товара`
    return `${count} товаров`
}

const rows = computed(() => props.orders.data)

const stats = computed(() => [
    {
        title: 'Всего заказов',
        value: props.orders.total,
        icon: FileText,
        tone: 'bg-primary/10 text-primary',
    },
    {
        title: 'Новых заказов',
        value: countOf('new'),
        icon: Sparkles,
        tone: 'bg-amber-500/10 text-amber-600 dark:text-amber-400',
    },
    {
        title: 'Товаров на странице',
        value: rows.value.reduce((sum, o) => sum + (o.items_count || 0), 0),
        icon: Package,
        tone: 'bg-sky-500/10 text-sky-600 dark:text-sky-400',
    },
])

const inputClass =
    'rounded-xl border border-input bg-background px-3 py-2.5 text-sm shadow-xs outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30'
</script>

<template>
    <Head title="Заказы" />

    <div class="space-y-6 pb-4">
        <!-- Заголовок -->
        <header class="flex items-center gap-4">
            <div
                class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
            >
                <FileText :size="24" />
            </div>
            <div>
                <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">Заказы</h1>
                <p class="mt-1 text-sm text-muted-foreground">
                    Управление заказами и их статусами
                </p>
            </div>
        </header>

        <!-- Статистика -->
        <section class="grid gap-4 sm:grid-cols-3" aria-label="Сводка">
            <div
                v-for="stat in stats"
                :key="stat.title"
                class="flex items-center gap-4 rounded-2xl border bg-card p-5 shadow-sm"
            >
                <div
                    class="flex size-11 shrink-0 items-center justify-center rounded-xl"
                    :class="stat.tone"
                >
                    <component :is="stat.icon" :size="22" />
                </div>
                <div class="min-w-0">
                    <p class="truncate text-sm text-muted-foreground">{{ stat.title }}</p>
                    <p class="mt-0.5 text-2xl font-bold tracking-tight tabular-nums">
                        {{ stat.value }}
                    </p>
                </div>
            </div>
        </section>

        <section
            class="overflow-hidden rounded-2xl border bg-card shadow-sm"
            aria-labelledby="orders-title"
        >
            <!-- Фильтры -->
            <div class="space-y-4 border-b px-5 py-4 sm:px-6">
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <h2 id="orders-title" class="font-semibold">Список заказов</h2>
                        <p class="mt-0.5 text-sm text-muted-foreground">
                            Найдено:
                            <span class="font-medium text-foreground tabular-nums">
                                {{ props.orders.total }}
                            </span>
                        </p>
                    </div>
                    <Button v-if="hasFilters" variant="ghost" size="sm" @click="clearFilters">
                        <X :size="14" class="mr-1.5" />
                        Сбросить
                    </Button>
                </div>

                <!-- Быстрые статусы -->
                <div class="-mx-1 flex gap-2 overflow-x-auto px-1 pb-1" role="tablist" aria-label="Статус">
                    <button
                        type="button"
                        role="tab"
                        :aria-selected="statusFilter === ''"
                        class="shrink-0 rounded-full border px-3.5 py-1.5 text-sm font-medium transition"
                        :class="statusFilter === ''
                            ? 'border-primary bg-primary text-primary-foreground'
                            : 'bg-background text-muted-foreground hover:bg-muted hover:text-foreground'"
                        @click="setStatus('')"
                    >
                        Все
                        <span class="ml-1 tabular-nums opacity-70">{{ countAll }}</span>
                    </button>
                    <button
                        v-for="status in statuses"
                        :key="status.value"
                        type="button"
                        role="tab"
                        :aria-selected="statusFilter === status.value"
                        class="inline-flex shrink-0 items-center gap-2 rounded-full border px-3.5 py-1.5 text-sm font-medium transition"
                        :class="statusFilter === status.value
                            ? statusStyle(status.value).chipActive
                            : 'bg-background text-muted-foreground hover:bg-muted hover:text-foreground'"
                        @click="setStatus(status.value)"
                    >
                        <span class="size-2 rounded-full" :class="statusStyle(status.value).dot" />
                        {{ status.label }}
                        <span class="ml-1 tabular-nums opacity-70">{{ countOf(status.value) }}</span>
                    </button>
                </div>

                <div class="flex flex-col gap-3 lg:flex-row lg:items-center">
                    <div class="relative w-full lg:max-w-sm">
                        <Search
                            :size="16"
                            class="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-muted-foreground"
                        />
                        <input
                            v-model="search"
                            type="search"
                            placeholder="Номер, имя, email, телефон"
                            aria-label="Поиск заказов"
                            class="w-full pr-9 pl-9"
                            :class="inputClass"
                        />
                        <button
                            v-if="search"
                            type="button"
                            aria-label="Очистить поиск"
                            class="absolute top-1/2 right-3 -translate-y-1/2 text-muted-foreground transition hover:text-foreground"
                            @click="search = ''"
                        >
                            <X :size="16" />
                        </button>
                    </div>

                    <div class="flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
                        <span>Дата:</span>
                        <input
                            v-model="dateFrom"
                            type="date"
                            aria-label="Дата от"
                            :class="inputClass"
                            @change="applyFilters"
                        />
                        <span>—</span>
                        <input
                            v-model="dateTo"
                            type="date"
                            aria-label="Дата до"
                            :class="inputClass"
                            @change="applyFilters"
                        />
                    </div>
                </div>
            </div>

            <!-- Пустое состояние -->
            <div
                v-if="rows.length === 0"
                class="flex flex-col items-center px-6 py-16 text-center"
            >
                <div class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted">
                    <Search v-if="hasFilters" :size="28" class="text-muted-foreground" />
                    <FileText v-else :size="28" class="text-muted-foreground" />
                </div>
                <p class="font-medium">
                    {{ hasFilters ? 'Ничего не найдено' : 'Заказов пока нет' }}
                </p>
                <p class="mt-1 max-w-sm text-sm text-muted-foreground">
                    {{
                        hasFilters
                            ? 'Попробуйте изменить или сбросить фильтры.'
                            : 'Новые заказы появятся здесь, когда покупатели оформят покупки.'
                    }}
                </p>
                <Button v-if="hasFilters" variant="outline" class="mt-5" @click="clearFilters">
                    <X :size="15" class="mr-1.5" />
                    Сбросить фильтры
                </Button>
            </div>

            <template v-else>
                <!-- Мобильные карточки: вся карточка кликабельна -->
                <ul class="divide-y md:hidden">
                    <li
                        v-for="order in rows"
                        :key="order.id"
                        class="cursor-pointer space-y-3 p-4 transition active:bg-muted/50"
                        @click="openOrder(order)"
                    >
                        <div class="flex items-start justify-between gap-3">
                            <div class="min-w-0">
                                <h3 class="text-sm font-semibold break-words">
                                    {{ order.order_number }}
                                </h3>
                                <p class="truncate text-sm">{{ order.customer_name }}</p>
                            </div>
                            <span
                                class="inline-flex shrink-0 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset"
                                :class="order.status_color"
                            >
                                {{ order.status_label }}
                            </span>
                        </div>

                        <div class="flex items-center justify-between gap-3">
                            <a
                                :href="`tel:${order.customer_phone}`"
                                class="flex items-center gap-1.5 text-xs text-muted-foreground"
                                @click.stop
                            >
                                <Phone :size="12" />
                                {{ order.customer_phone }}
                            </a>
                            <span class="text-base font-bold tabular-nums">
                                {{ order.total_amount }} ₽
                            </span>
                        </div>

                        <div class="flex items-center justify-between text-xs text-muted-foreground">
                            <span>{{ order.created_at }}</span>
                            <span class="flex items-center gap-1">
                                {{ itemsLabel(order.items_count ?? 0) }}
                                <ChevronRight :size="14" />
                            </span>
                        </div>
                    </li>
                </ul>

                <!-- Таблица: вся строка кликабельна -->
                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full min-w-[800px] text-left text-sm">
                        <thead>
                        <tr class="border-b bg-muted/40">
                            <th scope="col" class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Заказ</th>
                            <th scope="col" class="px-4 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Покупатель</th>
                            <th scope="col" class="px-4 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Получение</th>
                            <th scope="col" class="px-4 py-3.5 text-right text-xs font-semibold tracking-wider text-muted-foreground uppercase">Сумма</th>
                            <th scope="col" class="px-4 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Статус</th>
                            <th scope="col" class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Дата</th>
                            <th scope="col" class="w-10 py-3.5 pr-4"><span class="sr-only">Открыть</span></th>
                        </tr>
                        </thead>

                        <tbody class="divide-y">
                        <tr
                            v-for="order in rows"
                            :key="order.id"
                            class="group cursor-pointer transition-colors hover:bg-muted/40"
                            @click="openOrder(order)"
                        >
                            <td class="px-6 py-4">
                                <Link
                                    :href="route('admin.orders.show', { order: order.order_number })"
                                    class="font-semibold text-primary hover:text-primary/80"
                                    @click.stop
                                >
                                    {{ order.order_number }}
                                </Link>
                                <p class="mt-0.5 text-xs text-muted-foreground">
                                    {{ itemsLabel(order.items_count ?? 0) }}
                                </p>
                            </td>

                            <td class="px-4 py-4">
                                <p class="font-medium">{{ order.customer_name }}</p>
                                <a
                                    :href="`tel:${order.customer_phone}`"
                                    class="mt-0.5 flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground"
                                    @click.stop
                                >
                                    <Phone :size="11" />
                                    {{ order.customer_phone }}
                                </a>
                                <a
                                    :href="`mailto:${order.customer_email}`"
                                    class="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground"
                                    @click.stop
                                >
                                    <Mail :size="11" />
                                    {{ order.customer_email }}
                                </a>
                            </td>

                            <td class="px-4 py-4">
                                <div class="flex items-center gap-1.5 text-muted-foreground">
                                    <Truck v-if="order.delivery_method === 'Доставка'" :size="14" />
                                    <Store v-else :size="14" />
                                    {{ order.delivery_method }}
                                </div>
                            </td>

                            <td class="px-4 py-4 text-right">
                                    <span class="font-bold whitespace-nowrap tabular-nums">
                                        {{ order.total_amount }} ₽
                                    </span>
                            </td>

                            <td class="px-4 py-4">
                                    <span
                                        class="inline-flex rounded-full px-2.5 py-1 text-xs font-semibold whitespace-nowrap ring-1 ring-inset"
                                        :class="order.status_color"
                                    >
                                        {{ order.status_label }}
                                    </span>
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap text-muted-foreground">
                                {{ order.created_at }}
                            </td>

                            <td class="py-4 pr-4 text-muted-foreground">
                                <ChevronRight
                                    :size="16"
                                    class="transition group-hover:translate-x-0.5 group-hover:text-foreground"
                                />
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </template>

            <Pagination
                v-if="rows.length > 0"
                :links="props.orders.links"
                :current="props.orders.current_page"
                :last="props.orders.last_page"
                :total="props.orders.total"
                :per-page="props.orders.per_page"
            />
        </section>
    </div>
</template>
