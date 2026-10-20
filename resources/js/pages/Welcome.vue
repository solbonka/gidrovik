<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3'
import {
    ArrowDownToLine,
    ArrowLeftRight,
    ArrowRight,
    ArrowUpFromLine,
    Bell,
    Boxes,
    Check,
    Clock3,
    History,
    MapPin,
    Package,
    ShieldCheck,
    TrendingDown,
    Undo2,
    Warehouse,
} from '@lucide/vue'
import type { Component } from 'vue'
import { computed } from 'vue'

import { login, register } from '@/routes'
import { Button } from '@/components/ui/button'

interface Statistic {
    products: number
    total_quantity: string
    low_stock: number
}

interface Movement {
    id: number
    product_name: string
    sku: string | null
    type: string
    type_label: string
    quantity: number | string
    from_location: string | null
    to_location: string | null
    created_at: string | null
}

interface LowStockProduct {
    id: number
    name: string
    sku: string | null
    unit: string
    quantity: string | number
    minimum_stock: number | string | null
    locations: Array<{
        code: string | null
        rack_code: string | null
    }>
}

const props = defineProps<{
    statistics: Statistic
    recent_movements: Movement[]
    low_stock_products: LowStockProduct[]
}>()

/* ---------- Движения ---------- */

type MovementKind = 'receipt' | 'transfer' | 'writeoff' | 'return' | 'other'

const movementStyles: Record<MovementKind, { tone: string; icon: Component }> = {
    receipt: { tone: 'bg-emerald-50 text-emerald-700 ring-emerald-600/15', icon: ArrowDownToLine },
    transfer: { tone: 'bg-sky-50 text-sky-700 ring-sky-600/15', icon: ArrowLeftRight },
    writeoff: { tone: 'bg-rose-50 text-rose-700 ring-rose-600/15', icon: ArrowUpFromLine },
    return: { tone: 'bg-violet-50 text-violet-700 ring-violet-600/15', icon: Undo2 },
    other: { tone: 'bg-slate-100 text-slate-700 ring-slate-500/15', icon: ArrowLeftRight },
}

function movementKind(movement: Movement): MovementKind {
    const text = `${movement.type} ${movement.type_label}`.toLowerCase()

    if (/receipt|income|приход|поступ/.test(text)) return 'receipt'
    if (/transfer|перемещ/.test(text)) return 'transfer'
    if (/write|issue|спис|расход|отгруз/.test(text)) return 'writeoff'
    if (/return|возврат/.test(text)) return 'return'

    return 'other'
}

const style = (movement: Movement) => movementStyles[movementKind(movement)]

function locationLabel(location: string | null) {
    return location?.trim() || '—'
}

const numberFormat = new Intl.NumberFormat('ru-RU', { maximumFractionDigits: 3 })

function formatNumber(value: number | string | null | undefined) {
    if (value === null || value === undefined || value === '') return '—'

    const number = Number(value)

    return Number.isNaN(number) ? String(value) : numberFormat.format(number)
}

/* ---------- Остатки ---------- */

function stockPercent(product: LowStockProduct) {
    const quantity = Number(product.quantity)
    const minimum = Number(product.minimum_stock)

    if (!Number.isFinite(quantity) || !Number.isFinite(minimum) || minimum <= 0) return 0

    return Math.max(0, Math.min(100, (quantity / minimum) * 100))
}

function stockState(product: LowStockProduct) {
    const quantity = Number(product.quantity)
    const percent = stockPercent(product)
    if (quantity <= 0) {
        return { label: 'Нет в наличии', badge: 'bg-rose-100 text-rose-800', bar: 'bg-rose-500', value: 'text-rose-700' }
    }
    if (percent < 50) {
        return { label: 'Критично', badge: 'bg-orange-100 text-orange-800', bar: 'bg-orange-500', value: 'text-orange-700' }
    }
    return { label: 'Мало', badge: 'bg-amber-100 text-amber-800', bar: 'bg-amber-500', value: 'text-amber-700' }
}

function locationText(product: LowStockProduct) {
    return (
        product.locations
            .map((location) => [location.rack_code, location.code].filter(Boolean).join(' · '))
            .filter(Boolean)
            .join(', ') || 'Не указано'
    )
}

const hasLowStock = computed(() => props.statistics.low_stock > 0)
const previewMovements = computed(() => props.recent_movements.slice(0, 3))

/* ---------- Статичный контент ---------- */

const navItems = [
    { href: '#features', label: 'Возможности' },
    { href: '#movements', label: 'Движения' },
    { href: '#low-stock', label: 'Остатки' },
]

const features = [
    {
        icon: Boxes,
        title: 'Каталог товаров',
        text: 'Артикулы, единицы измерения и минимальные остатки — всё в одной карточке.',
    },
    {
        icon: MapPin,
        title: 'Адресное хранение',
        text: 'Стеллажи и ячейки: всегда понятно, где лежит товар и сколько его в каждой ячейке.',
    },
    {
        icon: History,
        title: 'История операций',
        text: 'Поступления, перемещения, списания и возвраты фиксируются и не теряются.',
    },
    {
        icon: Bell,
        title: 'Контроль минимума',
        text: 'Система сама показывает позиции, которые пора пополнить, до того как они закончатся.',
    },
]

const year = new Date().getFullYear()
</script>

<template>
    <Head title="Гидровик — управление складом" />

    <div class="min-h-screen overflow-x-hidden bg-white text-slate-900 antialiased">
        <a
            href="#main"
            class="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-50 focus:rounded-lg focus:bg-emerald-600 focus:px-4 focus:py-2 focus:text-sm focus:font-semibold focus:text-white"
        >
            Перейти к содержимому
        </a>

        <!-- Header -->
        <header class="sticky top-0 z-30 border-b border-slate-200/80 bg-white/90 backdrop-blur-xl">
            <div class="mx-auto flex h-[68px] max-w-7xl items-center justify-between gap-4 px-5 sm:px-8 lg:px-10">
                <Link href="/" class="flex shrink-0 items-center gap-3" aria-label="Гидровик — на главную">
                    <div class="flex size-10 items-center justify-center rounded-[14px] bg-emerald-600 text-white shadow-lg shadow-emerald-600/20">
                        <Warehouse :size="22" :stroke-width="1.8" />
                    </div>
                    <div>
                        <div class="text-[19px] font-extrabold leading-tight tracking-tight">Гидровик</div>
                        <div class="mt-0.5 text-[9px] font-bold uppercase tracking-[0.2em] text-slate-500">
                            Система складского учёта
                        </div>
                    </div>
                </Link>

                <nav class="hidden items-center gap-8 md:flex" aria-label="Разделы страницы">
                    <a
                        v-for="item in navItems"
                        :key="item.href"
                        :href="item.href"
                        class="text-sm font-medium text-slate-600 transition hover:text-emerald-700"
                    >
                        {{ item.label }}
                    </a>
                </nav>

                <div class="flex shrink-0 items-center gap-2">
                    <Button variant="ghost" as-child class="text-slate-600 hover:text-emerald-700">
                        <Link :href="login().url">Войти</Link>
                    </Button>

                    <Button
                        as-child
                        class="hidden h-10 rounded-xl bg-emerald-600 px-4 font-semibold text-white shadow-sm transition hover:bg-emerald-700 sm:inline-flex"
                    >
                        <Link :href="register().url">
                            Начать работу
                            <ArrowRight :size="16" class="ml-2" />
                        </Link>
                    </Button>
                </div>
            </div>

            <!-- Мобильная навигация -->
            <nav class="flex gap-5 overflow-x-auto border-t border-slate-100 px-5 py-2.5 md:hidden" aria-label="Разделы страницы">
                <a
                    v-for="item in navItems"
                    :key="item.href"
                    :href="item.href"
                    class="shrink-0 text-xs font-semibold text-slate-600 hover:text-emerald-700"
                >
                    {{ item.label }}
                </a>
            </nav>
        </header>

        <main id="main">
            <!-- Hero -->
            <section class="relative isolate overflow-hidden">
                <div class="pointer-events-none absolute inset-0 -z-10" aria-hidden="true">
                    <div class="absolute -right-48 -top-40 size-[620px] rounded-full bg-emerald-100/60 blur-3xl" />
                    <div class="absolute -left-40 top-64 size-[420px] rounded-full bg-slate-100/80 blur-3xl" />
                    <div class="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-emerald-200 to-transparent" />
                </div>

                <div class="mx-auto grid max-w-7xl items-center gap-12 px-5 pb-16 pt-12 sm:px-8 sm:pb-20 sm:pt-16 lg:grid-cols-[0.9fr_1.1fr] lg:gap-14 lg:px-10 lg:pb-24 lg:pt-24">
                    <div class="max-w-2xl">
                        <div class="inline-flex items-center gap-2.5 rounded-full border border-emerald-200 bg-white/80 px-3.5 py-2 text-xs font-semibold text-emerald-800 shadow-sm">
                            <span class="relative flex size-2" aria-hidden="true">
                                <span class="absolute inline-flex size-full rounded-full bg-emerald-500 opacity-30 motion-safe:animate-ping" />
                                <span class="relative inline-flex size-2 rounded-full bg-emerald-600" />
                            </span>
                            Единое пространство для вашего склада
                        </div>

                        <h1 class="mt-7 text-[40px] font-extrabold leading-[1.08] tracking-[-0.045em] text-slate-950 sm:text-5xl lg:text-[60px]">
                            Весь склад
                            <br class="hidden sm:block" />
                            <span class="bg-gradient-to-r from-emerald-600 to-teal-500 bg-clip-text text-transparent">под контролем.</span>
                        </h1>

                        <p class="mt-6 max-w-xl text-base leading-7 text-slate-600 sm:text-lg sm:leading-8">
                            Товары, остатки, ячейки и движения — в одной системе.
                            Принимайте решения на основе актуальных данных, а не догадок.
                        </p>

                        <div class="mt-8 flex flex-col gap-3 sm:flex-row">
                            <Button
                                as-child
                                size="lg"
                                class="h-12 rounded-xl bg-emerald-600 px-6 text-base font-semibold text-white shadow-lg shadow-emerald-600/20 transition hover:-translate-y-0.5 hover:bg-emerald-700"
                            >
                                <Link :href="register().url">
                                    Начать работу
                                    <ArrowRight :size="18" class="ml-2" />
                                </Link>
                            </Button>

                            <Button
                                as-child
                                variant="outline"
                                size="lg"
                                class="h-12 rounded-xl border-slate-300 bg-white/80 px-6 text-base font-semibold text-slate-700 hover:border-emerald-300 hover:bg-emerald-50 hover:text-emerald-800"
                            >
                                <a href="#features">Узнать больше</a>
                            </Button>
                        </div>

                        <ul class="mt-8 flex flex-wrap gap-x-5 gap-y-3 text-sm text-slate-600">
                            <li v-for="item in ['Контроль остатков', 'История операций', 'Адресное хранение']" :key="item" class="flex items-center gap-2">
                                <span class="flex size-5 items-center justify-center rounded-full bg-emerald-100 text-emerald-700">
                                    <Check :size="12" :stroke-width="3" />
                                </span>
                                {{ item }}
                            </li>
                        </ul>
                    </div>

                    <!-- Живой предпросмотр -->
                    <div class="relative mx-auto w-full max-w-[620px] lg:ml-auto">
                        <div class="absolute -inset-5 -z-10 rounded-[32px] bg-emerald-100/70 blur-2xl" aria-hidden="true" />

                        <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-2xl shadow-slate-900/[0.08]">
                            <div class="flex items-center justify-between gap-3 border-b border-slate-100 px-5 py-4 sm:px-6">
                                <div class="flex items-center gap-3">
                                    <div class="flex size-10 items-center justify-center rounded-xl bg-emerald-50 text-emerald-700">
                                        <Warehouse :size="21" />
                                    </div>
                                    <div>
                                        <h2 class="text-sm font-bold text-slate-900">Состояние склада</h2>
                                        <p class="mt-0.5 text-xs text-slate-500">Актуальные показатели системы</p>
                                    </div>
                                </div>

                                <span class="inline-flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50 px-2.5 py-1.5 text-[11px] font-semibold text-emerald-700">
                                    <span class="size-1.5 rounded-full bg-emerald-500" />
                                    Онлайн
                                </span>
                            </div>

                            <div class="space-y-4 bg-slate-50/70 p-4 sm:p-5">
                                <div class="grid grid-cols-3 gap-2.5 sm:gap-3">
                                    <div class="rounded-xl border border-slate-200/80 bg-white p-3.5 sm:p-4">
                                        <div class="flex size-9 items-center justify-center rounded-xl bg-emerald-50 text-emerald-700">
                                            <Boxes :size="19" />
                                        </div>
                                        <div class="mt-4 text-2xl font-extrabold tabular-nums tracking-tight text-slate-950 sm:text-3xl">
                                            {{ formatNumber(statistics.products) }}
                                        </div>
                                        <div class="mt-1 text-[11px] leading-4 text-slate-500 sm:text-xs">Товаров</div>
                                    </div>

                                    <div class="rounded-xl border border-slate-200/80 bg-white p-3.5 sm:p-4">
                                        <div class="flex size-9 items-center justify-center rounded-xl bg-sky-50 text-sky-700">
                                            <Package :size="19" />
                                        </div>
                                        <div class="mt-4 break-words text-xl font-extrabold tabular-nums tracking-tight text-slate-950 sm:text-3xl">
                                            {{ formatNumber(statistics.total_quantity) }}
                                        </div>
                                        <div class="mt-1 text-[11px] leading-4 text-slate-500 sm:text-xs">Единиц на складе</div>
                                    </div>

                                    <div
                                        class="rounded-xl border p-3.5 sm:p-4"
                                        :class="hasLowStock ? 'border-amber-200 bg-amber-50/70' : 'border-slate-200/80 bg-white'"
                                    >
                                        <div
                                            class="flex size-9 items-center justify-center rounded-xl"
                                            :class="hasLowStock ? 'bg-amber-100 text-amber-700' : 'bg-emerald-50 text-emerald-700'"
                                        >
                                            <TrendingDown :size="19" />
                                        </div>
                                        <div class="mt-4 text-2xl font-extrabold tabular-nums tracking-tight text-slate-950 sm:text-3xl">
                                            {{ formatNumber(statistics.low_stock) }}
                                        </div>
                                        <div class="mt-1 text-[11px] leading-4 text-slate-500 sm:text-xs">Требуют внимания</div>
                                    </div>
                                </div>

                                <div class="overflow-hidden rounded-xl border border-slate-200 bg-white">
                                    <div class="flex items-center justify-between border-b border-slate-100 px-4 py-3.5">
                                        <div>
                                            <h3 class="text-sm font-bold text-slate-900">Последние операции</h3>
                                            <p class="mt-0.5 text-xs text-slate-500">История движений</p>
                                        </div>
                                        <Clock3 :size="17" class="text-slate-400" />
                                    </div>

                                    <ul v-if="previewMovements.length">
                                        <li
                                            v-for="movement in previewMovements"
                                            :key="movement.id"
                                            class="flex items-center gap-3 border-b border-slate-100 px-4 py-3 last:border-b-0"
                                        >
                                            <div class="flex size-9 shrink-0 items-center justify-center rounded-xl" :class="style(movement).tone">
                                                <component :is="style(movement).icon" :size="17" />
                                            </div>

                                            <div class="min-w-0 flex-1">
                                                <div class="truncate text-xs font-semibold text-slate-800 sm:text-sm">
                                                    {{ movement.product_name }}
                                                </div>
                                                <div class="mt-0.5 truncate text-[11px] text-slate-500">
                                                    {{ movement.type_label }}<span v-if="movement.sku"> · {{ movement.sku }}</span>
                                                </div>
                                            </div>

                                            <div class="shrink-0 text-right">
                                                <div class="text-sm font-bold tabular-nums text-slate-900">
                                                    {{ formatNumber(movement.quantity) }}
                                                </div>
                                                <div class="mt-0.5 text-[10px] text-slate-400">
                                                    {{ movement.created_at || '—' }}
                                                </div>
                                            </div>
                                        </li>
                                    </ul>

                                    <div v-else class="px-4 py-8 text-center">
                                        <div class="mx-auto flex size-10 items-center justify-center rounded-xl bg-slate-50 text-slate-400">
                                            <Package :size="20" />
                                        </div>
                                        <p class="mt-3 text-sm font-medium text-slate-700">Пока нет движений</p>
                                        <p class="mt-1 text-xs text-slate-500">Новые операции появятся здесь</p>
                                    </div>
                                </div>

                                <a
                                    href="#low-stock"
                                    class="flex items-center gap-3 rounded-xl border px-4 py-3.5 transition hover:shadow-sm"
                                    :class="hasLowStock ? 'border-amber-200 bg-amber-50/70' : 'border-emerald-100 bg-emerald-50/70'"
                                >
                                    <div
                                        class="flex size-9 shrink-0 items-center justify-center rounded-xl bg-white"
                                        :class="hasLowStock ? 'text-amber-700' : 'text-emerald-700'"
                                    >
                                        <TrendingDown v-if="hasLowStock" :size="18" />
                                        <Check v-else :size="18" />
                                    </div>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-xs font-bold text-slate-900">
                                            {{ hasLowStock ? 'Есть товары для пополнения' : 'Критических остатков нет' }}
                                        </p>
                                        <p class="mt-1 text-[11px] leading-4 text-slate-600">
                                            {{
                                                hasLowStock
                                                    ? `Товаров ниже минимального остатка: ${statistics.low_stock}`
                                                    : 'Товары с настроенным минимумом в норме'
                                            }}
                                        </p>
                                    </div>
                                    <ArrowRight :size="16" class="shrink-0 text-slate-400" />
                                </a>
                            </div>

                            <div class="flex items-center justify-between border-t border-slate-100 bg-white px-5 py-3.5 sm:px-6">
                                <div class="flex items-center gap-2 text-xs text-slate-500">
                                    <ShieldCheck :size="15" class="text-emerald-600" />
                                    Складской учёт в одном месте
                                </div>
                                <span class="text-[10px] font-semibold uppercase tracking-wider text-slate-400">Гидровик</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Возможности -->
            <section id="features" class="scroll-mt-28 border-y border-slate-200 bg-slate-50/70 px-5 py-16 sm:px-8 sm:py-20 lg:px-10">
                <div class="mx-auto max-w-7xl">
                    <div class="max-w-2xl">
                        <p class="text-xs font-bold uppercase tracking-[0.16em] text-emerald-700">Возможности</p>
                        <h2 class="mt-2 text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">
                            Всё, что нужно для порядка на складе
                        </h2>
                        <p class="mt-3 text-sm leading-6 text-slate-500 sm:text-base">
                            Без лишних таблиц и ручных пересчётов: система хранит актуальное состояние и историю каждой операции.
                        </p>
                    </div>

                    <div class="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                        <article
                            v-for="feature in features"
                            :key="feature.title"
                            class="rounded-2xl border border-slate-200 bg-white p-6 transition duration-200 hover:-translate-y-0.5 hover:border-emerald-200 hover:shadow-lg hover:shadow-slate-900/[0.04]"
                        >
                            <div class="flex size-11 items-center justify-center rounded-xl bg-emerald-50 text-emerald-700">
                                <component :is="feature.icon" :size="22" />
                            </div>
                            <h3 class="mt-5 font-bold text-slate-900">{{ feature.title }}</h3>
                            <p class="mt-2 text-sm leading-6 text-slate-500">{{ feature.text }}</p>
                        </article>
                    </div>
                </div>
            </section>

            <!-- Движения -->
            <section id="movements" class="scroll-mt-28 px-5 py-16 sm:px-8 sm:py-20 lg:px-10">
                <div class="mx-auto max-w-7xl">
                    <div class="mb-8 flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
                        <div>
                            <p class="text-xs font-bold uppercase tracking-[0.16em] text-emerald-700">Прозрачность операций</p>
                            <h2 class="mt-2 text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">Последние движения</h2>
                            <p class="mt-2 text-sm leading-6 text-slate-500">История складских операций из вашей системы.</p>
                        </div>

                        <Button
                            as-child
                            variant="outline"
                            class="h-10 w-fit rounded-xl border-slate-300 bg-white font-semibold text-slate-700 hover:border-emerald-300 hover:bg-emerald-50 hover:text-emerald-800"
                        >
                            <Link href="/admin/stock/movements">
                                Все движения
                                <ArrowRight :size="16" class="ml-2" />
                            </Link>
                        </Button>
                    </div>

                    <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm shadow-slate-900/[0.02]">
                        <template v-if="recent_movements.length">
                            <!-- Мобильные карточки -->
                            <ul class="divide-y divide-slate-100 md:hidden">
                                <li v-for="movement in recent_movements" :key="movement.id" class="p-4">
                                    <div class="flex items-start justify-between gap-3">
                                        <div class="min-w-0">
                                            <p class="break-words text-sm font-semibold text-slate-900">{{ movement.product_name }}</p>
                                            <p class="mt-0.5 text-xs text-slate-500">{{ movement.sku || 'Без артикула' }}</p>
                                        </div>
                                        <p class="shrink-0 text-base font-bold tabular-nums text-slate-900">
                                            {{ formatNumber(movement.quantity) }}
                                        </p>
                                    </div>

                                    <div class="mt-3 flex flex-wrap items-center gap-2">
                                        <span
                                            class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset"
                                            :class="style(movement).tone"
                                        >
                                            <component :is="style(movement).icon" :size="13" />
                                            {{ movement.type_label }}
                                        </span>
                                        <span class="text-xs text-slate-400">{{ movement.created_at || '—' }}</span>
                                    </div>

                                    <div class="mt-3 flex items-center gap-2 text-xs text-slate-600">
                                        <span class="max-w-[42%] truncate rounded-md bg-slate-100 px-2 py-1">{{ locationLabel(movement.from_location) }}</span>
                                        <ArrowRight :size="13" class="shrink-0 text-slate-400" />
                                        <span class="max-w-[42%] truncate rounded-md bg-emerald-50 px-2 py-1 text-emerald-800">{{ locationLabel(movement.to_location) }}</span>
                                    </div>
                                </li>
                            </ul>

                            <!-- Таблица -->
                            <div class="hidden overflow-x-auto md:block">
                                <table class="w-full text-left text-sm">
                                    <thead>
                                        <tr class="border-b border-slate-200 bg-slate-50/80">
                                            <th scope="col" class="px-5 py-4 text-xs font-semibold uppercase tracking-wider text-slate-500">Дата</th>
                                            <th scope="col" class="px-5 py-4 text-xs font-semibold uppercase tracking-wider text-slate-500">Товар</th>
                                            <th scope="col" class="px-5 py-4 text-xs font-semibold uppercase tracking-wider text-slate-500">Операция</th>
                                            <th scope="col" class="px-5 py-4 text-right text-xs font-semibold uppercase tracking-wider text-slate-500">Количество</th>
                                            <th scope="col" class="px-5 py-4 text-xs font-semibold uppercase tracking-wider text-slate-500">Перемещение</th>
                                        </tr>
                                    </thead>

                                    <tbody class="divide-y divide-slate-100">
                                        <tr v-for="movement in recent_movements" :key="movement.id" class="transition hover:bg-slate-50/80">
                                            <td class="whitespace-nowrap px-5 py-4 text-xs text-slate-500">
                                                {{ movement.created_at || '—' }}
                                            </td>

                                            <td class="px-5 py-4">
                                                <div class="font-semibold text-slate-900">{{ movement.product_name }}</div>
                                                <div class="mt-1 text-xs text-slate-500">{{ movement.sku || 'Без артикула' }}</div>
                                            </td>

                                            <td class="px-5 py-4">
                                                <span
                                                    class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset"
                                                    :class="style(movement).tone"
                                                >
                                                    <component :is="style(movement).icon" :size="13" />
                                                    {{ movement.type_label }}
                                                </span>
                                            </td>

                                            <td class="whitespace-nowrap px-5 py-4 text-right font-bold tabular-nums text-slate-900">
                                                {{ formatNumber(movement.quantity) }}
                                            </td>

                                            <td class="px-5 py-4">
                                                <div class="flex items-center gap-2 text-xs text-slate-600">
                                                    <span class="max-w-28 truncate rounded-md bg-slate-100 px-2 py-1">{{ locationLabel(movement.from_location) }}</span>
                                                    <ArrowRight :size="13" class="shrink-0 text-slate-400" />
                                                    <span class="max-w-28 truncate rounded-md bg-emerald-50 px-2 py-1 text-emerald-800">{{ locationLabel(movement.to_location) }}</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>

                            <div class="border-t border-slate-100 bg-slate-50/60 px-5 py-3">
                                <p class="text-xs text-slate-500">Показаны последние операции: {{ recent_movements.length }}</p>
                            </div>
                        </template>

                        <div v-else class="px-6 py-14 text-center">
                            <div class="mx-auto flex size-14 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
                                <ArrowLeftRight :size="25" />
                            </div>
                            <h3 class="mt-4 text-base font-bold text-slate-900">Пока нет движений</h3>
                            <p class="mx-auto mt-2 max-w-sm text-sm leading-6 text-slate-500">
                                Когда в системе появятся поступления, перемещения или списания, они отобразятся здесь.
                            </p>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Низкие остатки -->
            <section id="low-stock" class="scroll-mt-28 border-y border-slate-200 bg-slate-50/70 px-5 py-16 sm:px-8 sm:py-20 lg:px-10">
                <div class="mx-auto max-w-7xl">
                    <div class="mb-8 flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
                        <div>
                            <p class="text-xs font-bold uppercase tracking-[0.16em] text-amber-700">Контроль запасов</p>
                            <h2 class="mt-2 text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">Требуют пополнения</h2>
                            <p class="mt-2 text-sm leading-6 text-slate-500">Товары, остаток которых ниже установленного минимума.</p>
                        </div>

                        <div
                            class="inline-flex w-fit items-center gap-2 rounded-xl border px-3.5 py-2 text-sm font-semibold"
                            :class="low_stock_products.length
                                ? 'border-amber-200 bg-amber-50 text-amber-800'
                                : 'border-emerald-200 bg-emerald-50 text-emerald-800'"
                        >
                            <TrendingDown v-if="low_stock_products.length" :size="17" />
                            <Check v-else :size="17" />
                            {{ low_stock_products.length ? `Позиций: ${low_stock_products.length}` : 'Всё в норме' }}
                        </div>
                    </div>

                    <div v-if="low_stock_products.length" class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                        <article
                            v-for="product in low_stock_products"
                            :key="product.id"
                            class="rounded-2xl border border-slate-200 bg-white p-5 transition duration-200 hover:-translate-y-0.5 hover:border-amber-200 hover:shadow-lg hover:shadow-slate-900/[0.04] sm:p-6"
                        >
                            <div class="flex items-start gap-3">
                                <div class="flex size-11 shrink-0 items-center justify-center rounded-xl bg-amber-50 text-amber-700">
                                    <Package :size="21" />
                                </div>

                                <div class="min-w-0 flex-1">
                                    <h3 class="break-words font-bold leading-5 text-slate-900">{{ product.name }}</h3>
                                    <p class="mt-1.5 text-xs text-slate-500">Артикул: {{ product.sku || 'Не указан' }}</p>
                                </div>

                                <span class="shrink-0 rounded-full px-2 py-1 text-[10px] font-bold" :class="stockState(product).badge">
                                    {{ stockState(product).label }}
                                </span>
                            </div>

                            <div class="mt-6 rounded-xl bg-slate-50 p-4">
                                <div class="flex items-end justify-between gap-3">
                                    <div>
                                        <p class="text-xs text-slate-500">Текущий остаток</p>
                                        <p class="mt-1.5 text-2xl font-extrabold tabular-nums tracking-tight" :class="stockState(product).value">
                                            {{ formatNumber(product.quantity) }}
                                            <span class="text-xs font-semibold text-slate-500">{{ product.unit }}</span>
                                        </p>
                                    </div>

                                    <div class="text-right">
                                        <p class="text-xs text-slate-500">Минимум</p>
                                        <p class="mt-2 text-sm font-bold tabular-nums text-slate-900">
                                            {{ formatNumber(product.minimum_stock) }}
                                            <span v-if="product.minimum_stock !== null" class="text-xs font-medium text-slate-500">
                                                {{ product.unit }}
                                            </span>
                                        </p>
                                    </div>
                                </div>

                                <div
                                    class="mt-4 h-1.5 overflow-hidden rounded-full bg-slate-200"
                                    role="progressbar"
                                    aria-label="Остаток относительно минимума"
                                    aria-valuemin="0"
                                    aria-valuemax="100"
                                    :aria-valuenow="Math.round(stockPercent(product))"
                                >
                                    <div
                                        class="h-full rounded-full transition-[width] duration-500"
                                        :class="stockState(product).bar"
                                        :style="{ width: `${stockPercent(product)}%` }"
                                    />
                                </div>
                                <p class="mt-2 text-[11px] text-slate-500">
                                    {{ Math.round(stockPercent(product)) }}% от минимального остатка
                                </p>
                            </div>

                            <div v-if="product.locations.length" class="mt-4 flex items-start gap-2.5">
                                <MapPin :size="16" class="mt-0.5 shrink-0 text-slate-400" />
                                <div class="min-w-0">
                                    <p class="text-[11px] font-semibold uppercase tracking-wider text-slate-400">Расположение</p>
                                    <p class="mt-1 break-words text-xs leading-5 text-slate-700">{{ locationText(product) }}</p>
                                </div>
                            </div>
                        </article>
                    </div>

                    <div v-else class="rounded-2xl border border-emerald-200 bg-white px-6 py-12 text-center shadow-sm">
                        <div class="mx-auto flex size-14 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-700">
                            <ShieldCheck :size="27" />
                        </div>
                        <h3 class="mt-4 text-lg font-bold text-slate-900">Все товары в норме</h3>
                        <p class="mx-auto mt-2 max-w-md text-sm leading-6 text-slate-500">
                            Сейчас нет товаров, требующих пополнения по настроенным минимальным остаткам.
                        </p>
                    </div>
                </div>
            </section>

            <!-- CTA -->
            <section class="px-5 py-16 sm:px-8 sm:py-20 lg:px-10">
                <div class="relative mx-auto max-w-7xl overflow-hidden rounded-3xl bg-slate-950 px-6 py-12 sm:px-10 sm:py-14 lg:px-14">
                    <div class="pointer-events-none absolute -right-20 -top-40 size-96 rounded-full bg-emerald-500/20 blur-3xl" aria-hidden="true" />
                    <div class="pointer-events-none absolute -bottom-48 left-1/3 size-96 rounded-full bg-emerald-700/20 blur-3xl" aria-hidden="true" />

                    <div class="relative flex flex-col items-start justify-between gap-8 md:flex-row md:items-center">
                        <div class="max-w-2xl">
                            <div class="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-3 py-1.5 text-xs font-semibold text-emerald-300">
                                <ShieldCheck :size="15" />
                                Порядок в каждой операции
                            </div>

                            <h2 class="mt-5 text-3xl font-extrabold tracking-tight text-white sm:text-4xl">
                                Склад под контролем.
                                <span class="text-emerald-400">Работа — по плану.</span>
                            </h2>

                            <p class="mt-4 max-w-xl text-sm leading-7 text-slate-300 sm:text-base">
                                Управляйте запасами, находите товары по ячейкам и контролируйте складские операции в одном месте.
                            </p>
                        </div>

                        <div class="flex shrink-0 flex-col gap-3 sm:flex-row">
                            <Button
                                as-child
                                size="lg"
                                class="h-12 rounded-xl bg-emerald-500 px-6 font-bold text-white shadow-lg shadow-emerald-950/30 hover:bg-emerald-400"
                            >
                                <Link :href="register().url">
                                    Создать аккаунт
                                    <ArrowRight :size="18" class="ml-2" />
                                </Link>
                            </Button>

                            <Button
                                as-child
                                variant="ghost"
                                size="lg"
                                class="h-12 rounded-xl px-6 font-semibold text-slate-200 hover:bg-white/10 hover:text-white"
                            >
                                <Link :href="login().url">Уже есть аккаунт</Link>
                            </Button>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <footer class="border-t border-slate-200 bg-white">
            <div class="mx-auto flex max-w-7xl flex-col items-center justify-between gap-4 px-5 py-7 sm:flex-row sm:px-8 lg:px-10">
                <Link href="/" class="flex items-center gap-2.5">
                    <div class="flex size-8 items-center justify-center rounded-lg bg-emerald-600 text-white">
                        <Warehouse :size="17" />
                    </div>
                    <span class="text-sm font-extrabold text-slate-900">Гидровик</span>
                </Link>

                <p class="text-center text-xs leading-5 text-slate-500">
                    © {{ year }} Гидровик · Система управления складскими запасами
                </p>

                <div class="flex items-center gap-2 text-xs font-medium text-slate-500">
                    <ShieldCheck :size="15" class="text-emerald-600" />
                    Учёт. Контроль. Порядок.
                </div>
            </div>
        </footer>
    </div>
</template>
