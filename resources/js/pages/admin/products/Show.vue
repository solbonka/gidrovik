
<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3'
import {
    ArrowLeft,
    ArrowRight,
    Ruler,
    Check,
    ChevronRight,
    ClipboardList,
    FileText,
    Layers3,
    MapPin,
    Package,
    Pencil,
    Plug,
    Warehouse,
    Factory,
    Globe,
    Boxes,
    Hash,
} from '@lucide/vue'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { create, index, edit } from '@/routes/admin/products'

defineOptions({
    layout: AdminLayout,
})

interface Category {
    id: number
    name: string
    slug: string
}

interface ProductType {
    id: number
    name: string
    slug: string
}

interface Characteristic {
    id: number
    characteristic_id: number
    name: string
    slug: string
    type: string
    unit: string | null
    value: string | null
}

interface Standard {
    id: number
    code: string
    name: string
}

interface Diameter {
    id: number
    value: number
    unit: string
}

interface Thread {
    id: number
    system: string
    designation: string
    name: string
}

interface Connection {
    id: number
    position: number
    standard: Standard | null
    diameter: Diameter | null
    thread: Thread | null
}

interface Rack {
    id: number
    code: string
    name: string | null
}

interface Location {
    id: number
    code: string
    rack: Rack
    number: number
    quantity: number
}

interface Product {
    id: number
    name: string
    sku: string
    angle: number | null
    description: string | null
    is_active: boolean
    unit: string
    manufacturer: { id: number; name: string } | null
    country: { id: number; name: string } | null
    category: Category | null
    product_type: ProductType | null
    stock_quantity: number
    characteristics: Characteristic[]
    connections: Connection[]
    locations: Location[]
}

interface Props {
    product: Product
}

const props = defineProps<Props>()

const formatCharacteristicValue = (
    characteristic: Characteristic,
): string => {
    if (characteristic.value === null || characteristic.value === '') {
        return '—'
    }

    if (characteristic.unit) {
        return `${characteristic.value} ${characteristic.unit}`
    }

    return characteristic.value
}

const connectionTitle = (connection: Connection): string => {
    const parts: string[] = []

    if (connection.standard) {
        parts.push(connection.standard.code)
    }

    if (connection.diameter) {
        parts.push(
            `${connection.diameter.value} ${connection.diameter.unit}`,
        )
    }

    if (connection.thread) {
        parts.push(connection.thread.designation)
    }

    return parts.length > 0 ? parts.join(' / ') : 'Параметры не указаны'
}
</script>

<template>
    <Head :title="product.name" />

    <div class="space-y-6 pb-8">
        <!-- Заголовок -->
        <div
            class="relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm sm:p-7 dark:border-gray-800 dark:bg-gray-900"
        >
            <div
                class="pointer-events-none absolute -right-16 -top-20 h-56 w-56 rounded-full bg-primary/5 blur-3xl"
            />

            <div
                class="pointer-events-none absolute -bottom-24 right-1/4 h-40 w-40 rounded-full bg-indigo-500/5 blur-3xl"
            />

            <div class="relative">
                <div
                    class="mb-5 flex flex-wrap items-center gap-2 text-sm text-gray-500 dark:text-gray-400"
                >
                    <Link
                        :href="index().url"
                        class="transition hover:text-primary"
                    >
                        Товары
                    </Link>

                    <ChevronRight class="h-4 w-4" />

                    <span class="max-w-[240px] truncate font-medium text-gray-700 dark:text-gray-200">
                        {{ product.name }}
                    </span>
                </div>

                <div
                    class="flex flex-col gap-5 xl:flex-row xl:items-center xl:justify-between"
                >
                    <div class="flex min-w-0 items-start gap-4">
                        <div
                            class="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-primary to-indigo-600 text-white shadow-lg shadow-primary/20"
                        >
                            <Package class="h-7 w-7" />
                        </div>

                        <div class="min-w-0">
                            <h1
                                class="break-words text-2xl font-bold tracking-tight text-gray-900 sm:text-3xl dark:text-white"
                            >
                                {{ product.name }}
                            </h1>

                            <div class="mt-3 flex flex-wrap items-center gap-2">
                                <span
                                    class="inline-flex items-center gap-1.5 rounded-lg border border-gray-200 bg-gray-50 px-2.5 py-1.5 font-mono text-sm text-gray-700 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-200"
                                >
                                    <Hash class="h-3.5 w-3.5 text-gray-400" />
                                    {{ product.sku }}
                                </span>

                                <span
                                    class="inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-semibold"
                                    :class="
                                        product.is_active
                                            ? 'bg-emerald-50 text-emerald-700 ring-1 ring-inset ring-emerald-600/20 dark:bg-emerald-500/10 dark:text-emerald-400'
                                            : 'bg-gray-100 text-gray-600 ring-1 ring-inset ring-gray-500/20 dark:bg-gray-800 dark:text-gray-400'
                                    "
                                >
                                    <span
                                        class="h-1.5 w-1.5 rounded-full"
                                        :class="
                                            product.is_active
                                                ? 'bg-emerald-500'
                                                : 'bg-gray-400'
                                        "
                                    />
                                    {{ product.is_active ? 'Активен' : 'Неактивен' }}
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="flex flex-wrap items-center gap-2">
                        <Link
                            :href="index().url"
                            class="inline-flex h-10 items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white px-4 text-sm font-medium text-gray-700 transition hover:border-primary/30 hover:bg-primary/5 hover:text-primary dark:border-gray-700 dark:bg-gray-900 dark:text-gray-300"
                        >
                            <ArrowLeft class="h-4 w-4" />
                            <span>К товарам</span>
                        </Link>

                        <Link
                            :href="create().url"
                            class="inline-flex h-10 items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white px-4 text-sm font-medium text-gray-700 transition hover:border-primary/30 hover:bg-primary/5 hover:text-primary dark:border-gray-700 dark:bg-gray-900 dark:text-gray-300"
                        >
                            <Package class="h-4 w-4" />
                            <span>Создать товар</span>
                        </Link>

                        <Link
                            :href="edit(product.id).url"
                            class="inline-flex h-10 items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-primary to-indigo-600 px-4 text-sm font-semibold text-white shadow-md shadow-primary/20 transition hover:-translate-y-0.5 hover:shadow-lg"
                        >
                            <Pencil class="h-4 w-4" />
                            Редактировать
                        </Link>
                    </div>
                </div>
            </div>
        </div>

        <!-- Основная информация и остаток -->
        <div class="grid gap-6 lg:grid-cols-3">
            <!-- Основная информация -->
            <section
                class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm transition hover:shadow-md lg:col-span-2 dark:border-gray-800 dark:bg-gray-900"
            >
                <div
                    class="flex items-center gap-3 border-b border-gray-100 px-5 py-4 sm:px-6 dark:border-gray-800"
                >
                    <div
                        class="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/10 text-primary"
                    >
                        <ClipboardList class="h-5 w-5" />
                    </div>

                    <div>
                        <h2 class="font-semibold text-gray-900 dark:text-white">
                            Основная информация
                        </h2>
                        <p class="mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                            Общие сведения о товаре
                        </p>
                    </div>
                </div>

                <div class="grid gap-x-8 gap-y-6 p-5 sm:grid-cols-2 sm:p-6">
                    <div>
                        <div class="text-sm text-gray-500 dark:text-gray-400">
                            Название
                        </div>
                        <div class="mt-1.5 font-medium text-gray-900 dark:text-gray-100">
                            {{ product.name }}
                        </div>
                    </div>

                    <div>
                        <div class="text-sm text-gray-500 dark:text-gray-400">
                            Артикул
                        </div>
                        <div class="mt-1.5 font-mono font-medium text-gray-900 dark:text-gray-100">
                            {{ product.sku }}
                        </div>
                    </div>

                    <div>
                        <div class="text-sm text-gray-500 dark:text-gray-400">
                            Категория
                        </div>
                        <div class="mt-1.5 font-medium text-gray-900 dark:text-gray-100">
                            {{ product.category?.name ?? '—' }}
                        </div>
                    </div>

                    <div>
                        <div class="text-sm text-gray-500 dark:text-gray-400">
                            Тип товара
                        </div>
                        <div class="mt-1.5 font-medium text-gray-900 dark:text-gray-100">
                            {{ product.product_type?.name ?? '—' }}
                        </div>
                    </div>

                    <div v-if="product.angle !== null">
                        <div class="text-sm text-gray-500 dark:text-gray-400">
                            Угол
                        </div>
                        <div class="mt-1.5 font-medium text-gray-900 dark:text-gray-100">
                            {{ product.angle }}°
                        </div>
                    </div>

                    <div>
                        <div class="text-sm text-gray-500 dark:text-gray-400">
                            Единица измерения
                        </div>
                        <div class="mt-1.5 font-medium text-gray-900 dark:text-gray-100">
                            {{ product.unit }}
                        </div>
                    </div>

                    <div>
                        <div class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
                            <Factory class="h-4 w-4" />
                            Производитель
                        </div>
                        <div class="mt-1.5 font-medium text-gray-900 dark:text-gray-100">
                            {{ product.manufacturer?.name ?? '—' }}
                        </div>
                    </div>

                    <div>
                        <div class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
                            <Globe class="h-4 w-4" />
                            Страна
                        </div>
                        <div class="mt-1.5 font-medium text-gray-900 dark:text-gray-100">
                            {{ product.country?.name ?? '—' }}
                        </div>
                    </div>
                </div>

                <div
                    v-if="product.description"
                    class="border-t border-gray-100 px-5 py-5 sm:px-6 dark:border-gray-800"
                >
                    <div class="flex items-center gap-2 text-sm font-medium text-gray-500 dark:text-gray-400">
                        <FileText class="h-4 w-4" />
                        Описание
                    </div>

                    <p
                        class="mt-2 whitespace-pre-wrap text-sm leading-6 text-gray-700 dark:text-gray-300"
                    >
                        {{ product.description }}
                    </p>
                </div>
            </section>

            <!-- Остаток -->
            <section
                class="relative overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm transition hover:shadow-md dark:border-gray-800 dark:bg-gray-900"
            >
                <div
                    class="pointer-events-none absolute -right-10 -top-10 h-36 w-36 rounded-full bg-primary/10 blur-2xl"
                />

                <div class="relative p-5 sm:p-6">
                    <div class="flex items-center gap-3">
                        <div
                            class="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400"
                        >
                            <Boxes class="h-5 w-5" />
                        </div>

                        <div>
                            <h2 class="font-semibold text-gray-900 dark:text-white">
                                Остаток
                            </h2>
                            <p class="text-xs text-gray-500 dark:text-gray-400">
                                По всем ячейкам склада
                            </p>
                        </div>
                    </div>

                    <div class="mt-8">
                        <div class="break-words text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl dark:text-white">
                            {{ product.stock_quantity }}
                        </div>

                        <div class="mt-2 text-sm text-gray-500 dark:text-gray-400">
                            {{ product.unit }} на складе
                        </div>
                    </div>

                    <div class="mt-7 space-y-4 border-t border-gray-100 pt-5 dark:border-gray-800">
                        <div class="flex items-center justify-between gap-3">
                            <span class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
                                <MapPin class="h-4 w-4" />
                                Ячеек с товаром
                            </span>

                            <span
                                class="rounded-lg bg-gray-100 px-2.5 py-1 text-sm font-semibold text-gray-900 dark:bg-gray-800 dark:text-gray-100"
                            >
                                {{ product.locations.length }}
                            </span>
                        </div>

                        <div class="flex items-center justify-between gap-3">
                            <span class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
                                <Layers3 class="h-4 w-4" />
                                Подключений
                            </span>

                            <span
                                class="rounded-lg bg-gray-100 px-2.5 py-1 text-sm font-semibold text-gray-900 dark:bg-gray-800 dark:text-gray-100"
                            >
                                {{ product.connections.length }}
                            </span>
                        </div>
                    </div>

                    <Link
                        :href="`/admin/stock/movements?product_id=${product.id}`"
                        class="mt-6 inline-flex min-h-11 w-full items-center justify-center gap-2 rounded-xl border border-primary/20 bg-primary/5 px-4 py-3 text-sm font-semibold text-primary transition hover:bg-primary/10 dark:border-primary/30"
                    >
                        <ClipboardList class="h-4 w-4" />
                        Журнал движений
                        <ArrowRight class="ml-auto h-4 w-4" />
                    </Link>
                </div>
            </section>
        </div>

        <!-- Характеристики -->
        <section
            class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-800 dark:bg-gray-900"
        >
            <div
                class="flex items-center gap-3 border-b border-gray-100 px-5 py-4 sm:px-6 dark:border-gray-800"
            >
                <div
                    class="flex h-10 w-10 items-center justify-center rounded-xl bg-violet-50 text-violet-600 dark:bg-violet-500/10 dark:text-violet-400"
                >
                    <Ruler class="h-5 w-5" />
                </div>

                <div>
                    <h2 class="font-semibold text-gray-900 dark:text-white">
                        Характеристики
                    </h2>
                    <p class="mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                        Параметры и свойства товара
                    </p>
                </div>

                <span
                    class="ml-auto rounded-lg bg-gray-100 px-2.5 py-1 text-xs font-semibold text-gray-600 dark:bg-gray-800 dark:text-gray-300"
                >
                    {{ product.characteristics.length }}
                </span>
            </div>

            <div
                v-if="product.characteristics.length"
                class="grid gap-px bg-gray-100 sm:grid-cols-2 dark:bg-gray-800"
            >
                <div
                    v-for="characteristic in product.characteristics"
                    :key="characteristic.id"
                    class="flex items-start justify-between gap-4 bg-white px-5 py-4 sm:px-6 dark:bg-gray-900"
                >
                    <div class="min-w-0 text-sm text-gray-500 dark:text-gray-400">
                        {{ characteristic.name }}
                    </div>

                    <div class="shrink-0 text-right text-sm font-semibold text-gray-900 dark:text-gray-100">
                        {{ formatCharacteristicValue(characteristic) }}
                    </div>
                </div>
            </div>

            <div
                v-else
                class="flex flex-col items-center px-6 py-10 text-center"
            >
                <div
                    class="flex h-12 w-12 items-center justify-center rounded-2xl bg-gray-100 text-gray-400 dark:bg-gray-800"
                >
                    <Ruler class="h-6 w-6" />
                </div>

                <p class="mt-3 text-sm font-medium text-gray-700 dark:text-gray-300">
                    Характеристики не указаны
                </p>

                <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">
                    Для этого товара пока нет дополнительных параметров
                </p>
            </div>
        </section>

        <!-- Подключения -->
        <section
            class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-800 dark:bg-gray-900"
        >
            <div
                class="flex items-center gap-3 border-b border-gray-100 px-5 py-4 sm:px-6 dark:border-gray-800"
            >
                <div
                    class="flex h-10 w-10 items-center justify-center rounded-xl bg-amber-50 text-amber-600 dark:bg-amber-500/10 dark:text-amber-400"
                >
                    <Plug class="h-5 w-5" />
                </div>

                <div>
                    <h2 class="font-semibold text-gray-900 dark:text-white">
                        Подключения
                    </h2>
                    <p class="mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                        Стандарты, диаметры и резьбы
                    </p>
                </div>

                <span
                    class="ml-auto rounded-lg bg-gray-100 px-2.5 py-1 text-xs font-semibold text-gray-600 dark:bg-gray-800 dark:text-gray-300"
                >
                    {{ product.connections.length }}
                </span>
            </div>

            <div
                v-if="product.connections.length"
                class="grid gap-4 p-5 sm:p-6 xl:grid-cols-2"
            >
                <article
                    v-for="connection in product.connections"
                    :key="connection.id"
                    class="rounded-2xl border border-gray-200 p-4 transition hover:border-primary/30 hover:shadow-sm sm:p-5 dark:border-gray-800"
                >
                    <div class="flex items-start gap-3">
                        <div
                            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-indigo-600 text-sm font-bold text-white shadow-sm"
                        >
                            {{ connection.position }}
                        </div>

                        <div class="min-w-0 flex-1">
                            <div class="text-xs font-medium uppercase tracking-wide text-gray-500 dark:text-gray-400">
                                Подключение {{ connection.position }}
                            </div>

                            <div class="mt-1 break-words font-semibold text-gray-900 dark:text-white">
                                {{ connectionTitle(connection) }}
                            </div>
                        </div>
                    </div>

                    <div class="mt-5 grid gap-4 border-t border-gray-100 pt-4 sm:grid-cols-3 dark:border-gray-800">
                        <div>
                            <div class="text-xs text-gray-500 dark:text-gray-400">
                                Стандарт
                            </div>
                            <div class="mt-1 break-words text-sm font-medium text-gray-900 dark:text-gray-100">
                                {{
                                    connection.standard
                                        ? `${connection.standard.code} — ${connection.standard.name}`
                                        : '—'
                                }}
                            </div>
                        </div>

                        <div>
                            <div class="text-xs text-gray-500 dark:text-gray-400">
                                Диаметр
                            </div>
                            <div class="mt-1 text-sm font-medium text-gray-900 dark:text-gray-100">
                                {{
                                    connection.diameter
                                        ? `${connection.diameter.value} ${connection.diameter.unit}`
                                        : '—'
                                }}
                            </div>
                        </div>

                        <div>
                            <div class="text-xs text-gray-500 dark:text-gray-400">
                                Резьба
                            </div>
                            <div class="mt-1 break-words text-sm font-medium text-gray-900 dark:text-gray-100">
                                {{
                                    connection.thread
                                        ? `${connection.thread.name}`
                                        : '—'
                                }}
                            </div>
                        </div>
                    </div>
                </article>
            </div>

            <div
                v-else
                class="flex flex-col items-center px-6 py-10 text-center"
            >
                <div
                    class="flex h-12 w-12 items-center justify-center rounded-2xl bg-gray-100 text-gray-400 dark:bg-gray-800"
                >
                    <Plug class="h-6 w-6" />
                </div>

                <p class="mt-3 text-sm font-medium text-gray-700 dark:text-gray-300">
                    Подключения не указаны
                </p>

                <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">
                    Для товара не заданы параметры подключения
                </p>
            </div>
        </section>

        <!-- Расположение на складе -->
        <section
            class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-800 dark:bg-gray-900"
        >
            <div
                class="flex flex-col gap-3 border-b border-gray-100 px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6 dark:border-gray-800"
            >
                <div class="flex items-center gap-3">
                    <div
                        class="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-50 text-emerald-600 dark:bg-emerald-500/10 dark:text-emerald-400"
                    >
                        <Warehouse class="h-5 w-5" />
                    </div>

                    <div>
                        <h2 class="font-semibold text-gray-900 dark:text-white">
                            Расположение на складе
                        </h2>
                        <p class="mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                            Ячейки, стеллажи и количество товара
                        </p>
                    </div>
                </div>

                <span
                    class="inline-flex w-fit items-center gap-1.5 rounded-lg bg-emerald-50 px-3 py-1.5 text-xs font-semibold text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400"
                >
                    <MapPin class="h-3.5 w-3.5" />
                    {{ product.locations.length }} ячеек
                </span>
            </div>

            <div
                v-if="product.locations.length"
                class="overflow-x-auto"
            >
                <table class="w-full text-left text-sm">
                    <thead
                        class="border-b border-gray-100 bg-gray-50/80 dark:border-gray-800 dark:bg-gray-800/50"
                    >
                    <tr>
                        <th class="px-5 py-3.5 font-medium text-gray-500 sm:px-6 dark:text-gray-400">
                            Ячейка
                        </th>

                        <th class="px-5 py-3.5 font-medium text-gray-500 sm:px-6 dark:text-gray-400">
                            Стеллаж
                        </th>

                        <th class="px-5 py-3.5 text-right font-medium text-gray-500 sm:px-6 dark:text-gray-400">
                            Количество
                        </th>
                    </tr>
                    </thead>

                    <tbody class="divide-y divide-gray-100 dark:divide-gray-800">
                    <tr
                        v-for="location in product.locations"
                        :key="location.id"
                        class="transition hover:bg-gray-50/80 dark:hover:bg-gray-800/30"
                    >
                        <td class="px-5 py-4 sm:px-6">
                            <div class="flex items-center gap-3">
                                <div
                                    class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
                                >
                                    <MapPin class="h-4 w-4" />
                                </div>

                                <span class="font-mono font-semibold text-gray-900 dark:text-gray-100">
                                        {{ location.code }}
                                    </span>
                            </div>
                        </td>

                        <td class="px-5 py-4 sm:px-6">
                            <div class="font-medium text-gray-900 dark:text-gray-100">
                                {{ location.rack.code }}
                            </div>

                            <div
                                v-if="location.rack.name"
                                class="mt-0.5 text-xs text-gray-500 dark:text-gray-400"
                            >
                                {{ location.rack.name }}
                            </div>
                        </td>

                        <td class="px-5 py-4 text-right sm:px-6">
                                <span
                                    class="inline-flex items-center rounded-lg bg-emerald-50 px-3 py-1.5 font-semibold text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400"
                                >
                                    {{ location.quantity }} {{ product.unit }}
                                </span>
                        </td>
                    </tr>
                    </tbody>

                    <tfoot
                        class="border-t border-gray-200 bg-gray-50 dark:border-gray-800 dark:bg-gray-800/50"
                    >
                    <tr>
                        <td
                            colspan="2"
                            class="px-5 py-4 text-right font-semibold text-gray-700 sm:px-6 dark:text-gray-300"
                        >
                            Общий остаток
                        </td>

                        <td class="px-5 py-4 text-right sm:px-6">
                                <span class="text-base font-bold text-gray-900 dark:text-white">
                                    {{ product.stock_quantity }}
                                </span>

                            <span class="ml-1 text-xs text-gray-500 dark:text-gray-400">
                                    {{ product.unit }}
                                </span>
                        </td>
                    </tr>
                    </tfoot>
                </table>
            </div>

            <div
                v-else
                class="flex flex-col items-center px-6 py-12 text-center"
            >
                <div
                    class="flex h-14 w-14 items-center justify-center rounded-2xl bg-gray-100 text-gray-400 dark:bg-gray-800"
                >
                    <Warehouse class="h-7 w-7" />
                </div>

                <p class="mt-4 font-semibold text-gray-800 dark:text-gray-200">
                    Товар пока не размещён
                </p>

                <p class="mt-1 max-w-sm text-sm leading-6 text-gray-500 dark:text-gray-400">
                    У этого товара пока нет размещения в ячейках склада.
                </p>
            </div>
        </section>
    </div>
</template>
