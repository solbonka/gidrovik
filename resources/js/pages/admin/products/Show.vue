<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import { computed } from 'vue';
import {
    ArrowLeft,
    ArrowRight,
    Boxes,
    ClipboardList,
    Factory,
    FileText,
    Globe,
    Hash,
    Layers3,
    MapPin,
    Package,
    Pencil,
    Plug,
    Ruler,
    Warehouse,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { Button } from '@/components/ui/button';
import { edit, index } from '@/routes/admin/products';

defineOptions({
    layout: AdminLayout,
});

interface Category {
    id: number;
    name: string;
    slug: string;
}

interface ProductType {
    id: number;
    name: string;
    slug: string;
}

interface Characteristic {
    id: number;
    characteristic_id: number;
    name: string;
    slug: string;
    type: string;
    unit: string | null;
    value: string | null;
}

interface Standard {
    id: number;
    code: string;
    name: string;
}

interface Diameter {
    id: number;
    value: number;
    unit: string;
}

interface Thread {
    id: number;
    system: string;
    designation: string;
    name: string;
}

interface Connection {
    id: number;
    position: number;
    standard: Standard | null;
    diameter: Diameter | null;
    thread: Thread | null;
}

interface Rack {
    id: number;
    code: string;
    name: string | null;
}

interface Location {
    id: number;
    code: string;
    rack: Rack;
    number: number;
    quantity: number;
}

interface Product {
    id: number;
    name: string;
    sku: string;
    angle: number | null;
    description: string | null;
    is_active: boolean;
    unit: string;
    // Необязательное поле: показываем, если бэкенд его передаёт
    minimum_stock?: number | null;
    manufacturer: { id: number; name: string } | null;
    country: { id: number; name: string } | null;
    category: Category | null;
    product_type: ProductType | null;
    stock_quantity: number;
    characteristics: Characteristic[];
    connections: Connection[];
    locations: Location[];
}

const props = defineProps<{
    product: Product;
}>();

const numberFormat = new Intl.NumberFormat('ru-RU', {
    maximumFractionDigits: 3,
});

const formatNumber = (value: number | string | null | undefined): string =>
    value === null || value === undefined
        ? '—'
        : numberFormat.format(Number(value));

const formatCharacteristicValue = (characteristic: Characteristic): string => {
    if (characteristic.value === null || characteristic.value === '') {
        return '—';
    }

    return characteristic.unit
        ? `${characteristic.value} ${characteristic.unit}`
        : characteristic.value;
};

const connectionTitle = (connection: Connection): string => {
    const parts: string[] = [];

    if (connection.standard) parts.push(connection.standard.code);

    if (connection.diameter) {
        parts.push(`${connection.diameter.value} ${connection.diameter.unit}`);
    }

    if (connection.thread) parts.push(connection.thread.designation);

    return parts.length > 0 ? parts.join(' / ') : 'Параметры не указаны';
};

const infoItems = computed(() => [
    { label: 'Категория', value: props.product.category?.name ?? '—' },
    { label: 'Тип товара', value: props.product.product_type?.name ?? '—' },
    ...(props.product.angle !== null
        ? [{ label: 'Угол', value: `${props.product.angle}°` }]
        : []),
    { label: 'Единица измерения', value: props.product.unit },
    {
        label: 'Производитель',
        value: props.product.manufacturer?.name ?? '—',
        icon: Factory,
    },
    {
        label: 'Страна',
        value: props.product.country?.name ?? '—',
        icon: Globe,
    },
]);

const stockState = computed(() => {
    const quantity = Number(props.product.stock_quantity);
    const minimum = props.product.minimum_stock;

    if (!(quantity > 0)) {
        return {
            label: 'Нет в наличии',
            badge: 'bg-rose-500/10 text-rose-700 ring-rose-600/20 dark:text-rose-400',
            bar: 'bg-rose-500',
        };
    }

    if (minimum !== null && minimum !== undefined && quantity < Number(minimum)) {
        return {
            label: 'Ниже минимума',
            badge: 'bg-amber-500/10 text-amber-700 ring-amber-600/20 dark:text-amber-400',
            bar: 'bg-amber-500',
        };
    }

    return {
        label: 'В наличии',
        badge: 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400',
        bar: 'bg-emerald-500',
    };
});

const stockPercent = computed<number | null>(() => {
    const minimum = Number(props.product.minimum_stock);

    if (!(minimum > 0)) return null;

    return Math.max(
        0,
        Math.min(100, (Number(props.product.stock_quantity) / minimum) * 100),
    );
});
</script>

<template>
    <Head :title="product.name" />

    <div class="space-y-6 pb-4">
        <!-- Заголовок -->
        <header>
            <Link
                :href="index().url"
                class="mb-4 inline-flex items-center gap-2 text-sm font-medium text-muted-foreground transition-colors hover:text-primary"
            >
                <ArrowLeft :size="16" />
                К товарам
            </Link>

            <div
                class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between"
            >
                <div class="flex min-w-0 items-start gap-4">
                    <div
                        class="flex size-14 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                    >
                        <Package :size="28" />
                    </div>

                    <div class="min-w-0">
                        <h1
                            class="text-2xl font-bold tracking-tight break-words sm:text-3xl"
                        >
                            {{ product.name }}
                        </h1>

                        <div class="mt-3 flex flex-wrap items-center gap-2">
                            <span
                                class="inline-flex items-center gap-1.5 rounded-lg border bg-muted/50 px-2.5 py-1.5 font-mono text-sm"
                            >
                                <Hash :size="14" class="text-muted-foreground" />
                                {{ product.sku }}
                            </span>

                            <span
                                class="inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-semibold ring-1 ring-inset"
                                :class="
                                    product.is_active
                                        ? 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400'
                                        : 'bg-muted text-muted-foreground ring-border'
                                "
                            >
                                <span
                                    class="size-1.5 rounded-full"
                                    :class="
                                        product.is_active
                                            ? 'bg-emerald-500'
                                            : 'bg-muted-foreground/50'
                                    "
                                />
                                {{ product.is_active ? 'Активен' : 'Неактивен' }}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="flex flex-col gap-3 sm:flex-row">
                    <Button as-child class="w-full sm:flex-1">
                        <Link :href="edit(product.id).url">
                            <Pencil :size="16" class="mr-2" />
                            Редактировать
                        </Link>
                    </Button>
                    <Button as-child variant="outline" class="w-full sm:flex-1">
                        <Link :href="route('admin.products.images', { product: product.id })">
                            <Package :size="16" class="mr-2" />
                            Изображения
                        </Link>
                    </Button>
                </div>
            </div>
        </header>

        <!-- Информация и остаток -->
        <div class="grid gap-6 lg:grid-cols-3">
            <section
                class="overflow-hidden rounded-2xl border bg-card shadow-sm lg:col-span-2"
            >
                <div class="flex items-center gap-3 border-b px-5 py-4 sm:px-6">
                    <div
                        class="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary"
                    >
                        <ClipboardList :size="20" />
                    </div>
                    <div>
                        <h2 class="font-semibold">Основная информация</h2>
                        <p class="mt-0.5 text-xs text-muted-foreground">
                            Общие сведения о товаре
                        </p>
                    </div>
                </div>

                <dl class="grid gap-x-8 gap-y-6 p-5 sm:grid-cols-2 sm:p-6">
                    <div v-for="item in infoItems" :key="item.label">
                        <dt
                            class="flex items-center gap-2 text-sm text-muted-foreground"
                        >
                            <component
                                :is="item.icon"
                                v-if="item.icon"
                                :size="15"
                            />
                            {{ item.label }}
                        </dt>
                        <dd class="mt-1.5 font-medium">{{ item.value }}</dd>
                    </div>
                </dl>

                <div v-if="product.description" class="border-t px-5 py-5 sm:px-6">
                    <div
                        class="flex items-center gap-2 text-sm font-medium text-muted-foreground"
                    >
                        <FileText :size="15" />
                        Описание
                    </div>
                    <p class="mt-2 text-sm leading-6 whitespace-pre-wrap">
                        {{ product.description }}
                    </p>
                </div>
            </section>

            <section class="rounded-2xl border bg-card p-5 shadow-sm sm:p-6">
                <div class="flex items-center justify-between gap-3">
                    <div class="flex items-center gap-3">
                        <div
                            class="flex size-10 items-center justify-center rounded-xl bg-sky-500/10 text-sky-600 dark:text-sky-400"
                        >
                            <Boxes :size="20" />
                        </div>
                        <div>
                            <h2 class="font-semibold">Остаток</h2>
                            <p class="text-xs text-muted-foreground">
                                По всем ячейкам склада
                            </p>
                        </div>
                    </div>

                    <span
                        class="shrink-0 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset"
                        :class="stockState.badge"
                    >
                        {{ stockState.label }}
                    </span>
                </div>

                <div class="mt-6">
                    <p
                        class="text-4xl font-bold tracking-tight break-words tabular-nums sm:text-5xl"
                    >
                        {{ formatNumber(product.stock_quantity) }}
                    </p>
                    <p class="mt-1.5 text-sm text-muted-foreground">
                        {{ product.unit }} на складе
                    </p>

                    <div
                        v-if="stockPercent !== null"
                        class="mt-4"
                    >
                        <div class="h-1.5 overflow-hidden rounded-full bg-muted">
                            <div
                                class="h-full rounded-full transition-[width] duration-500"
                                :class="stockState.bar"
                                :style="{ width: `${stockPercent}%` }"
                            />
                        </div>
                        <p class="mt-1.5 text-xs text-muted-foreground">
                            Минимум: {{ formatNumber(product.minimum_stock) }}
                            {{ product.unit }}
                        </p>
                    </div>
                </div>

                <dl class="mt-6 space-y-3 border-t pt-5 text-sm">
                    <div class="flex items-center justify-between gap-3">
                        <dt class="flex items-center gap-2 text-muted-foreground">
                            <MapPin :size="15" />
                            Ячеек с товаром
                        </dt>
                        <dd class="rounded-lg bg-muted px-2.5 py-1 font-semibold tabular-nums">
                            {{ product.locations.length }}
                        </dd>
                    </div>

                    <div class="flex items-center justify-between gap-3">
                        <dt class="flex items-center gap-2 text-muted-foreground">
                            <Layers3 :size="15" />
                            Подключений
                        </dt>
                        <dd class="rounded-lg bg-muted px-2.5 py-1 font-semibold tabular-nums">
                            {{ product.connections.length }}
                        </dd>
                    </div>
                </dl>

                <Button as-child variant="outline" class="mt-6 w-full justify-between">
                    <Link :href="`/admin/stock/movements?product_id=${product.id}`">
                        <span class="flex items-center gap-2">
                            <ClipboardList :size="16" />
                            Журнал движений
                        </span>
                        <ArrowRight :size="16" />
                    </Link>
                </Button>
            </section>
        </div>

        <!-- Характеристики -->
        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm">
            <div class="flex items-center gap-3 border-b px-5 py-4 sm:px-6">
                <div
                    class="flex size-10 items-center justify-center rounded-xl bg-violet-500/10 text-violet-600 dark:text-violet-400"
                >
                    <Ruler :size="20" />
                </div>
                <div>
                    <h2 class="font-semibold">Характеристики</h2>
                    <p class="mt-0.5 text-xs text-muted-foreground">
                        Параметры и свойства товара
                    </p>
                </div>
                <span
                    class="ml-auto rounded-lg bg-muted px-2.5 py-1 text-xs font-semibold tabular-nums"
                >
                    {{ product.characteristics.length }}
                </span>
            </div>

            <dl
                v-if="product.characteristics.length"
                class="grid gap-px bg-border sm:grid-cols-2"
            >
                <div
                    v-for="characteristic in product.characteristics"
                    :key="characteristic.id"
                    class="flex items-start justify-between gap-4 bg-card px-5 py-4 sm:px-6"
                >
                    <dt class="min-w-0 text-sm text-muted-foreground">
                        {{ characteristic.name }}
                    </dt>
                    <dd class="shrink-0 text-right text-sm font-semibold">
                        {{ formatCharacteristicValue(characteristic) }}
                    </dd>
                </div>
            </dl>

            <div v-else class="flex flex-col items-center px-6 py-10 text-center">
                <div
                    class="flex size-12 items-center justify-center rounded-2xl bg-muted text-muted-foreground"
                >
                    <Ruler :size="24" />
                </div>
                <p class="mt-3 text-sm font-medium">Характеристики не указаны</p>
                <p class="mt-1 text-xs text-muted-foreground">
                    Для этого товара пока нет дополнительных параметров
                </p>
            </div>
        </section>

        <!-- Подключения -->
        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm">
            <div class="flex items-center gap-3 border-b px-5 py-4 sm:px-6">
                <div
                    class="flex size-10 items-center justify-center rounded-xl bg-amber-500/10 text-amber-600 dark:text-amber-400"
                >
                    <Plug :size="20" />
                </div>
                <div>
                    <h2 class="font-semibold">Подключения</h2>
                    <p class="mt-0.5 text-xs text-muted-foreground">
                        Стандарты, диаметры и резьбы
                    </p>
                </div>
                <span
                    class="ml-auto rounded-lg bg-muted px-2.5 py-1 text-xs font-semibold tabular-nums"
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
                    class="rounded-2xl border p-4 transition hover:border-primary/30 hover:shadow-sm sm:p-5"
                >
                    <div class="flex items-start gap-3">
                        <div
                            class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary text-sm font-bold text-primary-foreground"
                        >
                            {{ connection.position }}
                        </div>

                        <div class="min-w-0 flex-1">
                            <p
                                class="text-xs font-medium tracking-wide text-muted-foreground uppercase"
                            >
                                Подключение {{ connection.position }}
                            </p>
                            <p class="mt-1 font-semibold break-words">
                                {{ connectionTitle(connection) }}
                            </p>
                        </div>
                    </div>

                    <dl class="mt-5 grid gap-4 border-t pt-4 sm:grid-cols-3">
                        <div>
                            <dt class="text-xs text-muted-foreground">Стандарт</dt>
                            <dd class="mt-1 text-sm font-medium break-words">
                                {{
                                    connection.standard
                                        ? `${connection.standard.code} — ${connection.standard.name}`
                                        : '—'
                                }}
                            </dd>
                        </div>

                        <div>
                            <dt class="text-xs text-muted-foreground">Диаметр</dt>
                            <dd class="mt-1 text-sm font-medium">
                                {{
                                    connection.diameter
                                        ? `${connection.diameter.value} ${connection.diameter.unit}`
                                        : '—'
                                }}
                            </dd>
                        </div>

                        <div>
                            <dt class="text-xs text-muted-foreground">Резьба</dt>
                            <dd class="mt-1 text-sm font-medium break-words">
                                {{ connection.thread?.name ?? '—' }}
                            </dd>
                        </div>
                    </dl>
                </article>
            </div>

            <div v-else class="flex flex-col items-center px-6 py-10 text-center">
                <div
                    class="flex size-12 items-center justify-center rounded-2xl bg-muted text-muted-foreground"
                >
                    <Plug :size="24" />
                </div>
                <p class="mt-3 text-sm font-medium">Подключения не указаны</p>
                <p class="mt-1 text-xs text-muted-foreground">
                    Для товара не заданы параметры подключения
                </p>
            </div>
        </section>

        <!-- Изображения -->
        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm">
            <div class="flex items-center justify-between border-b px-5 py-4 sm:px-6">
                <div class="flex items-center gap-3">
                    <div
                        class="flex size-10 items-center justify-center rounded-xl bg-blue-500/10 text-blue-600 dark:text-blue-400"
                    >
                        <Package :size="20" />
                    </div>
                    <div>
                        <h2 class="font-semibold">Изображения</h2>
                        <p class="mt-0.5 text-xs text-muted-foreground">
                            Фотографии товара
                        </p>
                    </div>
                </div>
                <Button as-child variant="outline" size="sm">
                    <Link :href="route('admin.products.images', { product: product.id })">
                        Управление
                        <ArrowRight :size="14" class="ml-1.5" />
                    </Link>
                </Button>
            </div>

            <div class="p-5 sm:p-6">
                <p class="text-sm text-muted-foreground">
                    Перейдите в раздел управления изображениями для загрузки и редактирования фотографий товара.
                </p>
            </div>
        </section>

        <!-- Расположение на складе -->
        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm">
            <div
                class="flex flex-col gap-3 border-b px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6"
            >
                <div class="flex items-center gap-3">
                    <div
                        class="flex size-10 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400"
                    >
                        <Warehouse :size="20" />
                    </div>
                    <div>
                        <h2 class="font-semibold">Расположение на складе</h2>
                        <p class="mt-0.5 text-xs text-muted-foreground">
                            Ячейки, стеллажи и количество товара
                        </p>
                    </div>
                </div>

                <span
                    class="inline-flex w-fit items-center gap-1.5 rounded-lg bg-emerald-500/10 px-3 py-1.5 text-xs font-semibold text-emerald-700 dark:text-emerald-400"
                >
                    <MapPin :size="14" />
                    Ячеек: {{ product.locations.length }}
                </span>
            </div>

            <template v-if="product.locations.length">
                <!-- Мобильные карточки -->
                <ul class="divide-y md:hidden">
                    <li
                        v-for="location in product.locations"
                        :key="location.id"
                        class="flex items-center justify-between gap-3 p-4"
                    >
                        <div class="flex min-w-0 items-center gap-3">
                            <div
                                class="flex size-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
                            >
                                <MapPin :size="16" />
                            </div>
                            <div class="min-w-0">
                                <p class="font-mono text-sm font-semibold">
                                    {{ location.code }}
                                </p>
                                <p class="truncate text-xs text-muted-foreground">
                                    {{ location.rack.code
                                    }}<template v-if="location.rack.name">
                                    · {{ location.rack.name }}
                                </template>
                                </p>
                            </div>
                        </div>

                        <span
                            class="shrink-0 rounded-lg bg-emerald-500/10 px-2.5 py-1 text-sm font-semibold text-emerald-700 tabular-nums dark:text-emerald-400"
                        >
                            {{ formatNumber(location.quantity) }}
                            {{ product.unit }}
                        </span>
                    </li>

                    <li class="flex items-center justify-between bg-muted/40 p-4">
                        <span class="text-sm font-semibold">Общий остаток</span>
                        <span class="font-bold tabular-nums">
                            {{ formatNumber(product.stock_quantity) }}
                            <span class="text-xs font-normal text-muted-foreground">
                                {{ product.unit }}
                            </span>
                        </span>
                    </li>
                </ul>

                <!-- Таблица -->
                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full text-left text-sm">
                        <thead>
                        <tr class="border-b bg-muted/40">
                            <th scope="col" class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Ячейка</th>
                            <th scope="col" class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Стеллаж</th>
                            <th scope="col" class="px-6 py-3.5 text-right text-xs font-semibold tracking-wider text-muted-foreground uppercase">Количество</th>
                        </tr>
                        </thead>

                        <tbody class="divide-y">
                        <tr
                            v-for="location in product.locations"
                            :key="location.id"
                            class="transition-colors hover:bg-muted/40"
                        >
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex size-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
                                    >
                                        <MapPin :size="16" />
                                    </div>
                                    <span class="font-mono font-semibold">
                                            {{ location.code }}
                                        </span>
                                </div>
                            </td>

                            <td class="px-6 py-4">
                                <div class="font-medium">
                                    {{ location.rack.code }}
                                </div>
                                <div
                                    v-if="location.rack.name"
                                    class="mt-0.5 text-xs text-muted-foreground"
                                >
                                    {{ location.rack.name }}
                                </div>
                            </td>

                            <td class="px-6 py-4 text-right">
                                    <span
                                        class="inline-flex rounded-lg bg-emerald-500/10 px-3 py-1.5 font-semibold text-emerald-700 tabular-nums dark:text-emerald-400"
                                    >
                                        {{ formatNumber(location.quantity) }}
                                        {{ product.unit }}
                                    </span>
                            </td>
                        </tr>
                        </tbody>

                        <tfoot>
                        <tr class="border-t bg-muted/40">
                            <td
                                colspan="2"
                                class="px-6 py-4 text-right font-semibold"
                            >
                                Общий остаток
                            </td>
                            <td class="px-6 py-4 text-right">
                                    <span class="text-base font-bold tabular-nums">
                                        {{ formatNumber(product.stock_quantity) }}
                                    </span>
                                <span class="ml-1 text-xs text-muted-foreground">
                                        {{ product.unit }}
                                    </span>
                            </td>
                        </tr>
                        </tfoot>
                    </table>
                </div>
            </template>

            <div v-else class="flex flex-col items-center px-6 py-12 text-center">
                <div
                    class="flex size-14 items-center justify-center rounded-2xl bg-muted text-muted-foreground"
                >
                    <Warehouse :size="28" />
                </div>
                <p class="mt-4 font-semibold">Товар пока не размещён</p>
                <p class="mt-1 max-w-sm text-sm leading-6 text-muted-foreground">
                    У этого товара пока нет размещения в ячейках склада.
                </p>
            </div>
        </section>
    </div>
</template>
