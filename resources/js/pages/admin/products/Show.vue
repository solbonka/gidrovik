<script setup lang="ts">
import { Head, Link, useForm, usePage } from '@inertiajs/vue3';
import { computed, ref } from 'vue';
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
    Plus,
    Ruler,
    Scissors,
    Trash2,
    Warehouse,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
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

interface SegmentRack {
    id: number;
    code: string;
    name: string | null;
}

interface SegmentLocation {
    id: number;
    number: number;
    rack: SegmentRack | null;
}

interface ProductSegment {
    id: number;
    length_mm: string;
    status: string;
    status_label: string;
    parent_segment_id: number | null;
    created_at: string | null;
    location: SegmentLocation | null;
}

interface StockLocation {
    id: number;
    number: number;
    code: string | null;
    rack: SegmentRack | null;
}

interface SegmentStats {
    total_mm: string;
    max_mm: string;
    count: number;
}

interface Product {
    id: number;
    name: string;
    code: string;
    article: string | null;
    angle: number | null;
    description: string | null;
    is_active: boolean;
    unit: string;
    stock_mode?: string;
    allow_cutting?: boolean;
    retail_price?: number | string | null;
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
    segments?: ProductSegment[];
    allLocations?: StockLocation[];
    segmentStats?: SegmentStats;
}>();

const isLengthMode = computed(() => props.product.stock_mode === 'length');

const page = usePage();
const canOperateStock = computed(() =>
    ((page.props.permissions as string[] | undefined) ?? []).includes(
        'stock.operate',
    ),
);

const numberFormat = new Intl.NumberFormat('ru-RU', {
    maximumFractionDigits: 3,
});

const formatNumber = (value: number | string | null | undefined): string =>
    value === null || value === undefined
        ? '—'
        : numberFormat.format(Number(value));

const priceFormat = new Intl.NumberFormat('ru-RU', {
    maximumFractionDigits: 2,
});

const formatPrice = (value: number | string | null | undefined): string => {
    const price = Number(value ?? 0);

    return price > 0 ? `${priceFormat.format(price)} ₽` : '—';
};

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

/* ---------- Отрезки ---------- */

const formatMm = (mm: string | number | null | undefined): string =>
    mm === null || mm === undefined ? '—' : numberFormat.format(Number(mm));

const formatMmAsUnit = (mm: string | number): string => {
    const value = Number(mm) / 1000;

    return `${numberFormat.format(value)} ${props.product.unit}`;
};

const locationLabel = (
    location:
        | { number: number; rack: SegmentRack | null }
        | null
        | undefined,
): string => {
    if (!location) return '—';

    const rack = location.rack?.code ? `${location.rack.code}-` : '';

    return `${rack}${location.number}`;
};

const segmentStatusClass = (status: string): string => {
    switch (status) {
        case 'available':
            return 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400';
        case 'reserved':
            return 'bg-blue-500/10 text-blue-700 ring-blue-600/20 dark:text-blue-400';
        case 'quarantined':
            return 'bg-amber-500/10 text-amber-700 ring-amber-600/20 dark:text-amber-400';
        default:
            return 'bg-muted text-muted-foreground ring-border';
    }
};

const availableSegments = computed(() =>
    (props.segments ?? []).filter((segment) => segment.status === 'available'),
);

const receiptForm = useForm({
    segments: [{ location_id: null as number | null, length_mm: '' }],
    comment: '',
});

const addSegmentRow = (): void => {
    receiptForm.segments.push({ location_id: null, length_mm: '' });
};

const removeSegmentRow = (index: number): void => {
    receiptForm.segments.splice(index, 1);
};

const submitSegments = (): void => {
    receiptForm.post(
        route('admin.products.segments.store', { product: props.product.id }),
        {
            preserveScroll: true,
            onSuccess: () => {
                receiptForm.reset();
                receiptForm.segments = [{ location_id: null, length_mm: '' }];
            },
        },
    );
};

const transferForm = useForm({
    segment_ids: [] as number[],
    to_location_id: null as number | null,
    comment: '',
});

const toggleSegment = (segmentId: number, checked: boolean): void => {
    const ids = transferForm.segment_ids;

    if (checked) {
        if (!ids.includes(segmentId)) ids.push(segmentId);
    } else {
        transferForm.segment_ids = ids.filter((id) => id !== segmentId);
    }

    writeOffForm.segment_ids = [...transferForm.segment_ids];
};

const selectedSegmentsTotalMm = computed(() => {
    const ids = new Set(transferForm.segment_ids);

    return (props.segments ?? [])
        .filter((segment) => ids.has(segment.id))
        .reduce((sum, segment) => sum + Number(segment.length_mm), 0);
});

const writeOffForm = useForm({
    segment_ids: [] as number[],
    comment: '',
});

const editingSegmentId = ref<number | null>(null);
const editLengthMm = ref('');
const correctForm = useForm({
    length_mm: '',
    comment: '',
});

const startEditSegment = (segment: { id: number; length_mm: number | string }): void => {
    editingSegmentId.value = segment.id;
    editLengthMm.value = String(segment.length_mm);
    correctForm.comment = '';
};

const cancelEditSegment = (): void => {
    editingSegmentId.value = null;
};

const submitCorrectSegment = (segmentId: number): void => {
    correctForm.length_mm = editLengthMm.value;
    correctForm.patch(
        route('admin.products.segments.correct', {
            product: props.product.id,
            segment: segmentId,
        }),
        {
            preserveScroll: true,
            onSuccess: () => {
                editingSegmentId.value = null;
                correctForm.reset('comment');
            },
        },
    );
};

const submitWriteOff = (): void => {
    writeOffForm.post(
        route('admin.products.segments.write-off', {
            product: props.product.id,
        }),
        {
            preserveScroll: true,
            onSuccess: () => {
                writeOffForm.reset('comment');
            },
        },
    );
};

const submitTransfer = (): void => {
    transferForm.post(
        route('admin.products.segments.transfer', {
            product: props.product.id,
        }),
        {
            preserveScroll: true,
            onSuccess: () => {
                transferForm.reset('segment_ids', 'comment');
            },
        },
    );
};

const infoItems = computed(() => [
    { label: 'Категория', value: props.product.category?.name ?? '—' },
    { label: 'Тип товара', value: props.product.product_type?.name ?? '—' },
    ...(props.product.angle !== null
        ? [{ label: 'Угол', value: `${props.product.angle}°` }]
        : []),
    { label: 'Единица измерения', value: props.product.unit },
    {
        label: 'Режим учёта',
        value: isLengthMode.value ? 'По отрезкам (мерный)' : 'По количеству',
    },
    {
        label: 'Розничная цена',
        value: formatPrice(props.product.retail_price),
    },
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
                            <div class="space-y-1">
                                <p v-if="product.code" class="text-xs font-medium tracking-wider text-muted-foreground uppercase">
                                    Код товара
                                </p>
                                <p v-if="product.article" class="text-xs font-medium tracking-wider text-muted-foreground uppercase">
                                    Артикул
                                </p>
                                <p v-if="product.code" class="font-mono text-sm">
                                    {{ product.code }}
                                </p>
                                <p v-if="product.article" class="font-mono text-sm text-muted-foreground">
                                    {{ product.article }}
                                </p>
                            </div>
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

        <!-- Складские отрезки -->
        <section
            v-if="isLengthMode"
            class="overflow-hidden rounded-2xl border bg-card shadow-sm"
        >
            <div class="flex items-center gap-3 border-b px-5 py-4 sm:px-6">
                <div
                    class="flex size-10 items-center justify-center rounded-xl bg-cyan-500/10 text-cyan-600 dark:text-cyan-400"
                >
                    <Scissors :size="20" />
                </div>
                <div>
                    <h2 class="font-semibold">Складские отрезки</h2>
                    <p class="mt-0.5 text-xs text-muted-foreground">
                        Физические куски товара с учётом длины
                    </p>
                </div>
                <span
                    class="ml-auto rounded-lg bg-muted px-2.5 py-1 text-xs font-semibold tabular-nums"
                >
                    {{ segmentStats?.count ?? 0 }} шт.
                </span>
            </div>

            <div class="grid gap-px bg-border sm:grid-cols-3">
                <div class="bg-card px-5 py-4 sm:px-6">
                    <p class="text-xs text-muted-foreground">Общая длина</p>
                    <p class="mt-1 text-lg font-bold tabular-nums">
                        {{ formatMmAsUnit(segmentStats?.total_mm ?? '0') }}
                    </p>
                </div>
                <div class="bg-card px-5 py-4 sm:px-6">
                    <p class="text-xs text-muted-foreground">
                        Самый длинный отрезок
                    </p>
                    <p class="mt-1 text-lg font-bold tabular-nums">
                        {{ formatMmAsUnit(segmentStats?.max_mm ?? '0') }}
                    </p>
                </div>
                <div class="bg-card px-5 py-4 sm:px-6">
                    <p class="text-xs text-muted-foreground">
                        Отрезков в наличии
                    </p>
                    <p class="mt-1 text-lg font-bold tabular-nums">
                        {{ segmentStats?.count ?? 0 }}
                    </p>
                </div>
            </div>

            <div class="border-t">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="border-b text-left text-xs text-muted-foreground">
                            <th class="px-5 py-3 font-medium sm:px-6">
                                Отрезок
                            </th>
                            <th class="px-3 py-3 font-medium">Длина</th>
                            <th class="px-3 py-3 font-medium">Ячейка</th>
                            <th class="px-3 py-3 font-medium">Статус</th>
                            <th class="px-5 py-3 font-medium sm:px-6">
                                Дата
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr
                            v-for="segment in segments ?? []"
                            :key="segment.id"
                            class="border-b last:border-0"
                        >
                            <td class="px-5 py-3 font-mono text-xs sm:px-6">
                                #{{ segment.id }}
                                <span
                                    v-if="segment.parent_segment_id"
                                    class="ml-1 text-muted-foreground"
                                >
                                    от #{{ segment.parent_segment_id }}
                                </span>
                            </td>
                            <td class="px-3 py-3 font-semibold tabular-nums">
                                <div
                                    v-if="editingSegmentId === segment.id && hasStockOperate"
                                    class="flex items-center gap-1.5"
                                >
                                    <Input
                                        v-model="editLengthMm"
                                        type="number"
                                        step="0.001"
                                        min="0.001"
                                        class="h-8 w-24"
                                    />
                                    <Button
                                        type="button"
                                        size="sm"
                                        :disabled="correctForm.processing"
                                        @click="submitCorrectSegment(segment.id)"
                                    >
                                        OK
                                    </Button>
                                    <Button
                                        type="button"
                                        size="sm"
                                        variant="ghost"
                                        @click="cancelEditSegment"
                                    >
                                        ✕
                                    </Button>
                                </div>
                                <template v-else>
                                    {{ formatMm(segment.length_mm) }} мм
                                    <span class="ml-1 text-xs font-normal text-muted-foreground">
                                        ({{ formatMmAsUnit(segment.length_mm) }})
                                    </span>
                                    <button
                                        v-if="hasStockOperate && segment.status !== 'consumed' && segment.status !== 'scrapped'"
                                        type="button"
                                        class="ml-2 text-muted-foreground hover:text-foreground"
                                        title="Скорректировать длину (инвентаризация)"
                                        @click="startEditSegment(segment)"
                                    >
                                        <Pencil :size="12" />
                                    </button>
                                </template>
                            </td>
                            <td class="px-3 py-3">
                                {{ locationLabel(segment.location) }}
                            </td>
                            <td class="px-3 py-3">
                                <span
                                    class="inline-flex rounded-full px-2 py-0.5 text-[11px] font-semibold ring-1 ring-inset"
                                    :class="segmentStatusClass(segment.status)"
                                >
                                    {{ segment.status_label }}
                                </span>
                            </td>
                            <td class="px-5 py-3 text-xs text-muted-foreground sm:px-6">
                                {{ segment.created_at?.slice(0, 10) ?? '—' }}
                            </td>
                        </tr>
                        <tr v-if="!(segments ?? []).length">
                            <td
                                colspan="5"
                                class="px-6 py-8 text-center text-sm text-muted-foreground"
                            >
                                Отрезков пока нет. Оприходуйте первый отрезок
                                ниже.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div
                v-if="canOperateStock"
                class="grid gap-6 border-t p-5 sm:p-6 lg:grid-cols-2"
            >
                <!-- Поступление отрезков -->
                <div class="rounded-xl border p-4">
                    <h3 class="text-sm font-semibold">Оприходовать отрезки</h3>
                    <p class="mt-1 text-xs text-muted-foreground">
                        Укажите длину каждого физического куска в мм.
                    </p>

                    <div class="mt-4 space-y-3">
                        <div
                            v-for="(row, index) in receiptForm.segments"
                            :key="index"
                            class="flex items-start gap-2"
                        >
                            <select
                                v-model="row.location_id"
                                class="h-10 flex-1 rounded-lg border border-input bg-background px-2 text-sm"
                            >
                                <option :value="null">
                                    Ячейка…
                                </option>
                                <option
                                    v-for="location in allLocations ?? []"
                                    :key="location.id"
                                    :value="location.id"
                                >
                                    {{ locationLabel(location) }}
                                </option>
                            </select>
                            <input
                                v-model="row.length_mm"
                                type="number"
                                inputmode="decimal"
                                min="0"
                                step="0.001"
                                placeholder="Длина, мм"
                                class="h-10 w-32 rounded-lg border border-input bg-background px-2 text-sm"
                            />
                            <Button
                                type="button"
                                variant="ghost"
                                size="sm"
                                class="text-muted-foreground hover:text-destructive"
                                :disabled="receiptForm.segments.length === 1"
                                @click="removeSegmentRow(index)"
                            >
                                <Trash2 :size="15" />
                            </Button>
                        </div>

                        <Button
                            type="button"
                            variant="outline"
                            size="sm"
                            @click="addSegmentRow"
                        >
                            <Plus :size="15" class="mr-1.5" />
                            Добавить отрезок
                        </Button>
                    </div>

                    <input
                        v-model="receiptForm.comment"
                        type="text"
                        placeholder="Комментарий (необязательно)"
                        class="mt-3 h-10 w-full rounded-lg border border-input bg-background px-3 text-sm"
                    />

                    <p
                        v-if="receiptForm.errors.segments"
                        class="mt-2 text-sm text-destructive"
                    >
                        {{ receiptForm.errors.segments }}
                    </p>
                    <p
                        v-for="(error, key) in receiptForm.errors"
                        :key="key"
                        v-show="String(key).startsWith('segments.')"
                        class="mt-1 text-xs text-destructive"
                    >
                        {{ error }}
                    </p>

                    <Button
                        type="button"
                        class="mt-4 w-full"
                        :disabled="receiptForm.processing"
                        @click="submitSegments"
                    >
                        Оприходовать
                    </Button>
                </div>

                <!-- Перемещение отрезков -->
                <div class="rounded-xl border p-4">
                    <h3 class="text-sm font-semibold">
                        Переместить отрезки
                    </h3>
                    <p class="mt-1 text-xs text-muted-foreground">
                        Выберите отрезки и целевую ячейку. Отрезки перемещаются
                        целиком.
                    </p>

                    <div
                        class="mt-4 max-h-56 space-y-1 overflow-y-auto rounded-lg border p-2"
                    >
                        <label
                            v-for="segment in availableSegments"
                            :key="segment.id"
                            class="flex cursor-pointer items-center gap-2 rounded-md px-2 py-1.5 text-sm hover:bg-muted/60"
                        >
                            <input
                                type="checkbox"
                                class="size-4 rounded border-input accent-primary"
                                :checked="transferForm.segment_ids.includes(segment.id)"
                                @change="
                                    toggleSegment(
                                        segment.id,
                                        ($event.target as HTMLInputElement).checked,
                                    )
                                "
                            />
                            <span class="font-mono text-xs">#{{ segment.id }}</span>
                            <span class="tabular-nums">
                                {{ formatMm(segment.length_mm) }} мм
                            </span>
                            <span class="ml-auto text-xs text-muted-foreground">
                                {{ locationLabel(segment.location) }}
                            </span>
                        </label>
                        <p
                            v-if="!availableSegments.length"
                            class="px-2 py-4 text-center text-xs text-muted-foreground"
                        >
                            Нет доступных отрезков для перемещения
                        </p>
                    </div>

                    <p class="mt-2 text-xs text-muted-foreground">
                        Выбрано: {{ transferForm.segment_ids.length }} шт.,
                        {{ formatMm(selectedSegmentsTotalMm) }} мм
                    </p>

                    <div class="mt-3 flex gap-2">
                        <select
                            v-model="transferForm.to_location_id"
                            class="h-10 flex-1 rounded-lg border border-input bg-background px-2 text-sm"
                        >
                            <option :value="null">Целевая ячейка…</option>
                            <option
                                v-for="location in allLocations ?? []"
                                :key="location.id"
                                :value="location.id"
                            >
                                {{ locationLabel(location) }}
                            </option>
                        </select>
                    </div>

                    <input
                        v-model="transferForm.comment"
                        type="text"
                        placeholder="Комментарий (необязательно)"
                        class="mt-3 h-10 w-full rounded-lg border border-input bg-background px-3 text-sm"
                    />

                    <p
                        v-if="transferForm.errors.segment_ids"
                        class="mt-2 text-sm text-destructive"
                    >
                        {{ transferForm.errors.segment_ids }}
                    </p>
                    <p
                        v-if="transferForm.errors.to_location_id"
                        class="mt-1 text-xs text-destructive"
                    >
                        {{ transferForm.errors.to_location_id }}
                    </p>

                    <Button
                        type="button"
                        class="mt-4 w-full"
                        :disabled="
                            transferForm.processing ||
                            !transferForm.segment_ids.length ||
                            !transferForm.to_location_id
                        "
                        @click="submitTransfer"
                    >
                        Переместить
                    </Button>
                </div>

                <div
                    v-if="hasStockOperate"
                    class="rounded-xl border border-destructive/30 bg-destructive/5 p-4"
                >
                    <p class="text-sm font-semibold">Списание отрезков</p>
                    <p class="mt-1 text-xs text-muted-foreground">
                        Выбранные отрезки получат статус «Списан» и выбывают из запаса.
                    </p>
                    <div class="mt-3">
                        <Label for="segment-writeoff-comment">Комментарий</Label>
                        <Textarea
                            id="segment-writeoff-comment"
                            v-model="writeOffForm.comment"
                            rows="2"
                        />
                    </div>
                    <p
                        v-if="writeOffForm.errors.segment_ids"
                        class="mt-1 text-xs text-destructive"
                    >
                        {{ writeOffForm.errors.segment_ids }}
                    </p>
                    <Button
                        type="button"
                        variant="destructive"
                        class="mt-3 w-full"
                        :disabled="
                            writeOffForm.processing ||
                            !writeOffForm.segment_ids.length
                        "
                        @click="submitWriteOff"
                    >
                        Списать выбранные ({{ writeOffForm.segment_ids.length }})
                    </Button>
                </div>
            </div>
        </section>

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
