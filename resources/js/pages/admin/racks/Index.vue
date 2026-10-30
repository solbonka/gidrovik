<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, ref, watch } from 'vue';
import type { Component } from 'vue';
import { toast } from 'vue-sonner';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { create, destroy, edit, index } from '@/routes/admin/racks';
import {
    destroy as destroyLocation,
    store as storeLocation,
} from '@/routes/admin/racks/locations';
import { Button } from '@/components/ui/button';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import ProductSelect from '@/components/admin/ProductSelect.vue';
import {
    ArrowLeft,
    ChevronRight,
    ClipboardCheck,
    Grid2X2,
    Loader2,
    PackageCheck,
    PackageMinus,
    PackagePlus,
    Pencil,
    Plus,
    RotateCcw,
    ArrowLeftRight,
    Trash2,
    Boxes,
    Package,
    X,
    Building2,
} from '@lucide/vue';

defineOptions({
    layout: AdminLayout,
});

interface LocationProduct {
    id: number;
    name: string;
    code: string | null;
    article: string | null;
    quantity: number;
}

interface Location {
    id: number;
    rack_id: number;
    number: number;
    code: string;
    stock_quantity: number | string | null;
    incoming_movements_count: number;
    outgoing_movements_count: number;
}

interface Rack {
    id: number;
    code: string;
    name: string | null;
    locations_count: number;
    locations: Location[];
}

interface Product {
    id: number;
    name: string;
    code: string | null;
    article: string | null;
    unit: string;
    characteristics?: string;
    category_id?: number | string | null;
    category?: {
        id: number | string;
        name?: string;
    } | null;
}

interface ProductStockLocation {
    id: number;
    number: number;
    code: string | null;
    quantity: string | number;
}

interface ProductDetails {
    id: number;
    name: string;
    code: string | null;
    article: string | null;
    quantity: string | number;
}

interface Props {
    racks: Rack[];
    allProducts: Product[];
    allLocations: {
        id: number;
        code: string;
        rack_name: string | null;
    }[];
    categories?: {
        id: number;
        name: string;
    }[];
    warehouses: {
        id: number;
        name: string;
    }[];
    selectedWarehouse: {
        id: number;
        name: string;
    } | null;
}

type Operation = 'receipt' | 'write_off' | 'transfer' | 'return' | 'inventory';

interface OperationButton {
    value: Operation;
    label: string;
    description: string;
    icon: Component;
    tone: string;
}

const props = defineProps<Props>();

const operationButtons: OperationButton[] = [
    {
        value: 'receipt',
        label: 'Пополнение',
        description: 'Приход товара',
        icon: PackagePlus,
        tone: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400',
    },
    {
        value: 'write_off',
        label: 'Списание',
        description: 'Расход товара',
        icon: PackageMinus,
        tone: 'bg-rose-500/10 text-rose-600 dark:text-rose-400',
    },
    {
        value: 'transfer',
        label: 'Перемещение',
        description: 'Между ячейками',
        icon: ArrowLeftRight,
        tone: 'bg-sky-500/10 text-sky-600 dark:text-sky-400',
    },
    {
        value: 'return',
        label: 'Возврат',
        description: 'Возврат товара',
        icon: RotateCcw,
        tone: 'bg-violet-500/10 text-violet-600 dark:text-violet-400',
    },
    {
        value: 'inventory',
        label: 'Инвентаризация',
        description: 'Проверка остатка',
        icon: ClipboardCheck,
        tone: 'bg-amber-500/10 text-amber-600 dark:text-amber-400',
    },
];

// Общий стиль для нативных полей формы
const fieldClass =
    'w-full rounded-xl border border-input bg-background px-3 py-2.5 text-sm shadow-xs outline-none transition focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30';

const emptyOperationForm = () => ({
    product_id: '',
    quantity: '1',
    comment: '',
    to_location_id: '',
    current_quantity: null as number | null,
});

const locationModal = ref({
    open: false,
    locationCode: '',
    locationId: null as number | null,
    products: [] as LocationProduct[],
    loading: false,
    error: '',
    operation: null as Operation | null,
    operationLoading: false,
});

const operationForm = ref(emptyOperationForm());

const productDetailsModal = ref({
    open: false,
    loading: false,
    error: '',
    product: null as ProductDetails | null,
    locations: [] as ProductStockLocation[],
    totalQuantity: 0,
});

const deleteConfirmation = ref({
    open: false,
    type: null as 'rack' | 'location' | null,
    rack: null as Rack | null,
    location: null as Location | null,
    loading: false,
});

/* ---------- Фильтр по складу ---------- */

const selectedWarehouseId = ref<string | null>(
    props.selectedWarehouse?.id.toString() ?? null,
);

const onWarehouseChange = (value: unknown): void => {
    selectedWarehouseId.value = value === 'all' ? null : String(value);

    router.get(
        index().url,
        {
            warehouse_id: selectedWarehouseId.value,
        },
        {
            preserveState: true,
            replace: true,
        },
    );
};

const currentOperation = computed(
    () =>
        operationButtons.find(
            (item) => item.value === locationModal.value.operation,
        ) ?? null,
);

const productsForSelect = computed(() =>
    props.allProducts.map((product) => ({
        id: product.id,
        name: product.name,
        code: product.code,
        article: product.article,
        unit: product.unit,
        characteristics: product.characteristics,
        category_id: product.category_id ?? product.category?.id ?? null,
        category: product.category ?? null,
    })),
);

const locationProductsForSelect = computed(() =>
    locationModal.value.products.map((product) => ({
        id: product.id,
        name: product.name,
        code: product.code,
        article: product.article,
        unit: 'шт.',
    })),
);

const operationProducts = computed(() => {
    const operation = locationModal.value.operation;

    if (operation === 'receipt' || operation === 'return') {
        return productsForSelect.value;
    }

    return locationProductsForSelect.value;
});

const locationQuantity = (location: Location): number => {
    const quantity = Number(location.stock_quantity ?? 0);
    return Number.isFinite(quantity) ? quantity : 0;
};

const formatQuantity = (value: string | number | null | undefined): string => {
    const quantity = Number(value ?? 0);

    return Number.isFinite(quantity)
        ? quantity.toLocaleString('ru-RU', { maximumFractionDigits: 3 })
        : '0';
};

const occupiedInRack = (rack: Rack): number =>
    (rack.locations ?? []).filter((location) => locationQuantity(location) > 0)
        .length;

const totalLocationsCount = computed(() =>
    props.racks.reduce(
        (sum, rack) => sum + (rack.locations_count || rack.locations?.length || 0),
        0,
    ),
);

const occupiedLocationsCount = computed(() =>
    props.racks.reduce((sum, rack) => sum + occupiedInRack(rack), 0),
);

const occupancyPercent = computed(() =>
    totalLocationsCount.value
        ? Math.round(
            (occupiedLocationsCount.value / totalLocationsCount.value) * 100,
        )
        : 0,
);

const summaryCards = computed(() => [
    {
        title: 'Стеллажей',
        value: String(props.racks.length),
        icon: Grid2X2,
        tone: 'bg-sky-500/10 text-sky-600 dark:text-sky-400',
    },
    {
        title: 'Ячеек всего',
        value: String(totalLocationsCount.value),
        icon: Boxes,
        tone: 'bg-violet-500/10 text-violet-600 dark:text-violet-400',
    },
    {
        title: 'Занято ячеек',
        value: `${occupiedLocationsCount.value} · ${occupancyPercent.value}%`,
        icon: PackageCheck,
        tone: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400',
    },
]);

/* ---------- Ячейки ---------- */

const addingLocationRackId = ref<number | null>(null);
const newLocationNumber = ref<Record<number, string>>({});

const editRack = (rack: Rack): void => {
    router.visit(edit(rack.id).url);
};

const startAddLocation = (rackId: number): void => {
    const rack = props.racks.find((item) => item.id === rackId);

    if (!rack) return;

    const existingNumbers = rack.locations.map((location) => location.number);
    let nextNumber = 1;

    while (existingNumbers.includes(nextNumber)) {
        nextNumber++;
    }

    newLocationNumber.value[rackId] = String(nextNumber);
    addingLocationRackId.value = rackId;
};

const cancelAddLocation = (): void => {
    addingLocationRackId.value = null;
};

const addLocation = (rack: Rack): void => {
    const value = Number(newLocationNumber.value[rack.id]);

    if (!Number.isInteger(value) || value < 1) {
        toast.error('Укажите корректный номер ячейки.');
        return;
    }

    router.post(
        storeLocation(rack.id).url,
        { number: value },
        {
            preserveScroll: true,
            onSuccess: () => {
                addingLocationRackId.value = null;
                toast.success('Ячейка добавлена.');
            },
            onError: (errors) => {
                toast.error(
                    Object.values(errors).flat().join(', ') ||
                    'Не удалось добавить ячейку.',
                );
            },
        },
    );
};

/* ---------- Удаление ---------- */

const deleteRack = (rack: Rack): void => {
    deleteConfirmation.value = {
        open: true,
        type: 'rack',
        rack,
        location: null,
        loading: false,
    };
};

const closeDeleteConfirmation = (): void => {
    if (deleteConfirmation.value.loading) return;

    deleteConfirmation.value.open = false;
    deleteConfirmation.value.type = null;
    deleteConfirmation.value.rack = null;
    deleteConfirmation.value.location = null;
};

const confirmDelete = (): void => {
    const confirmation = deleteConfirmation.value;

    if (confirmation.loading || !confirmation.type) return;

    const options = {
        preserveScroll: true,
        onSuccess: () => {
            toast.success(
                confirmation.type === 'rack'
                    ? 'Стеллаж успешно удалён.'
                    : 'Ячейка успешно удалена.',
            );

            deleteConfirmation.value.open = false;
        },
        onError: () => {
            toast.error(
                confirmation.type === 'rack'
                    ? 'Не удалось удалить стеллаж. Проверьте остатки и историю движений.'
                    : 'Не удалось удалить ячейку. Возможно, в ней есть остатки или история движений.',
            );
        },
        onFinish: () => {
            deleteConfirmation.value.loading = false;
        },
    };

    confirmation.loading = true;

    if (confirmation.type === 'rack' && confirmation.rack) {
        router.delete(destroy(confirmation.rack.id).url, options);
        return;
    }

    if (
        confirmation.type === 'location' &&
        confirmation.rack &&
        confirmation.location
    ) {
        router.delete(
            destroyLocation({
                rack: confirmation.rack.id,
                location: confirmation.location.id,
            }).url,
            options,
        );
        return;
    }

    confirmation.loading = false;
};

/* ---------- Товары в ячейке ---------- */

const viewLocationProducts = (
    location: Pick<Location, 'id' | 'code'>,
): void => {
    locationModal.value.open = true;
    locationModal.value.locationCode = location.code;
    locationModal.value.locationId = location.id;
    locationModal.value.loading = true;
    locationModal.value.error = '';
    locationModal.value.products = [];

    fetch(`/admin/locations/${location.id}/products`)
        .then(async (response) => {
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }
            return response.json();
        })
        .then((data) => {
            const products = data.products || [];
            locationModal.value.products = (products as LocationProduct[]).filter(
                (product) => Number(product.quantity) > 0,
            );
            locationModal.value.loading = false;
        })
        .catch((error) => {
            console.error(error);
            locationModal.value.error = `Не удалось загрузить товары: ${error.message}`;
            locationModal.value.loading = false;
        });
};

const closeLocationModal = (): void => {
    if (locationModal.value.operationLoading) return;

    locationModal.value.open = false;
    locationModal.value.products = [];
    locationModal.value.operation = null;
    locationModal.value.error = '';
};

const startOperation = (
    operation: Operation,
    product?: LocationProduct,
): void => {
    locationModal.value.operation = operation;

    operationForm.value = {
        ...emptyOperationForm(),
        product_id: product ? String(product.id) : '',
        quantity:
            operation === 'inventory' && product
                ? String(product.quantity)
                : '1',
        current_quantity: product ? Number(product.quantity) : null,
    };
};

// Возврат к списку операций, не закрывая окно ячейки
const closeOperation = (): void => {
    if (locationModal.value.operationLoading) return;

    locationModal.value.operation = null;
    operationForm.value = emptyOperationForm();
};

watch(
    () => operationForm.value.product_id,
    (productId) => {
        const product = locationModal.value.products.find(
            (item) => item.id === Number(productId),
        );

        operationForm.value.current_quantity = product
            ? Number(product.quantity)
            : null;

        if (locationModal.value.operation === 'inventory' && product) {
            operationForm.value.quantity = String(product.quantity);
        }
    },
);

const submitOperation = (): void => {
    const locationId = locationModal.value.locationId;
    const operation = locationModal.value.operation;

    if (!locationId || !operation) return;

    const quantity = Number(operationForm.value.quantity);

    if (!operationForm.value.product_id) {
        toast.error('Выберите товар.');
        return;
    }

    if (!Number.isFinite(quantity) || quantity < 0) {
        toast.error('Укажите корректное количество.');
        return;
    }

    if (operation !== 'inventory' && quantity <= 0) {
        toast.error('Количество должно быть больше нуля.');
        return;
    }

    if (
        operation === 'transfer' &&
        (!operationForm.value.to_location_id ||
            Number(operationForm.value.to_location_id) === locationId)
    ) {
        toast.error('Выберите другую ячейку назначения.');
        return;
    }

    locationModal.value.operationLoading = true;

    const data: Record<string, string | number> = {
        product_id: Number(operationForm.value.product_id),
        comment: operationForm.value.comment,
        operation: operation,
    };

    switch (operation) {
        case 'receipt':
        case 'write_off':
        case 'return':
            data.location_id = Number(locationId);
            data.quantity = quantity;
            break;

        case 'transfer':
            data.from_location_id = Number(locationId);
            data.to_location_id = Number(operationForm.value.to_location_id);
            data.quantity = quantity;
            break;

        case 'inventory':
            data.location_id = Number(locationId);
            data.actual_quantity = quantity;
            break;
    }

    router.post(
        route('stock.operation.execute'),
        data,
        {
            preserveScroll: true,
            onSuccess: () => {
                locationModal.value.operation = null;
                operationForm.value = emptyOperationForm();
                toast.success('Операция успешно выполнена.');
            },
            onError: (errors) => {
                const message = Object.values(errors).flat().join(', ') || 'Ошибка при выполнении операции.';
                toast.error(message);
            },
            onFinish: () => {
                locationModal.value.operationLoading = false;
            },
        },
    );
};

/* ---------- Расположение товара ---------- */

const showProductDetails = (product: LocationProduct): void => {
    productDetailsModal.value = {
        open: true,
        loading: true,
        error: '',
        product: {
            id: product.id,
            name: product.name,
            code: product.code,
            article: product.article,
            quantity: product.quantity,
        },
        locations: [],
        totalQuantity: 0,
    };

    fetch(`/admin/products/${product.id}/locations`)
        .then(async (response) => {
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            return response.json();
        })
        .then((data) => {
            const locations = data.locations || [];
            const filteredLocations = (locations as ProductStockLocation[]).filter(
                (location) => Number(location.quantity) > 0,
            );

            productDetailsModal.value.locations = filteredLocations;
            productDetailsModal.value.totalQuantity = filteredLocations.reduce(
                (sum, location) => sum + Number(location.quantity || 0),
                0,
            );
            productDetailsModal.value.loading = false;
        })
        .catch((error) => {
            productDetailsModal.value.error = `Не удалось загрузить данные товара: ${error.message}`;
            productDetailsModal.value.loading = false;
        });

};

const closeProductDetails = (): void => {
    productDetailsModal.value.open = false;
};
</script>

<template>
    <Head title="Склады и ячейки" />

    <div class="min-w-0 space-y-5 sm:space-y-8">
        <!-- Заголовок -->
        <header
            class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between"
        >
            <div class="flex min-w-0 items-center gap-3 sm:gap-4">
                <div
                    class="flex size-10 shrink-0 sm:size-12 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                >
                    <Grid2X2 :size="24" />
                </div>
                <div>
                    <h1 class="text-xl font-bold tracking-tight sm:text-2xl lg:text-3xl">
                        Склады и ячейки
                    </h1>
                    <p class="mt-1 text-sm leading-relaxed text-muted-foreground">
                        Управление стеллажами, ячейками и остатками товаров
                    </p>
                </div>
            </div>

            <div class="flex w-full min-w-0 flex-col gap-2 sm:w-auto sm:flex-row sm:items-center">
                <Select :model-value="selectedWarehouseId ?? 'all'" @update:model-value="onWarehouseChange">
                    <SelectTrigger class="w-full sm:w-[200px]">
                        <SelectValue placeholder="Все склады" />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="all">Все склады</SelectItem>
                        <SelectItem
                            v-for="warehouse in warehouses"
                            :key="warehouse.id"
                            :value="warehouse.id.toString()"
                        >
                            {{ warehouse.name }}
                        </SelectItem>
                    </SelectContent>
                </Select>

                <Button as-child class="w-full sm:w-auto">
                    <Link :href="create.url()">
                        <Plus :size="18" class="mr-2" />
                        Добавить стеллаж
                    </Link>
                </Button>
            </div>
        </header>

        <!-- Сводка -->
        <section class="grid gap-4 sm:grid-cols-3" aria-label="Сводка">
            <div
                v-for="card in summaryCards"
                :key="card.title"
                class="flex min-w-0 items-center gap-3 rounded-2xl border bg-card p-4 shadow-sm sm:gap-4 sm:p-5"
            >
                <div
                    class="flex size-11 shrink-0 items-center justify-center rounded-xl"
                    :class="card.tone"
                >
                    <component :is="card.icon" :size="22" />
                </div>
                <div>
                    <p class="text-sm text-muted-foreground">
                        {{ card.title }}
                    </p>
                    <p class="mt-0.5 text-2xl font-bold tracking-tight tabular-nums">
                        {{ card.value }}
                    </p>
                </div>
            </div>
        </section>

        <!-- Стеллажи -->
        <section
            v-if="racks.length"
            class="grid gap-4 md:grid-cols-2 xl:grid-cols-3"
            aria-label="Стеллажи"
        >
            <article
                v-for="rack in racks"
                :key="rack.id"
                class="flex min-w-0 flex-col rounded-2xl border bg-card p-3 shadow-sm transition hover:shadow-md sm:p-5"
            >
                <div class="flex items-start justify-between gap-3">
                    <div class="min-w-0">
                        <h2 class="truncate text-lg font-bold">
                            {{ rack.name || rack.code }}
                        </h2>
                        <p
                            class="mt-0.5 text-xs font-medium tracking-wider text-muted-foreground uppercase"
                        >
                            {{ rack.code }}
                        </p>
                    </div>

                    <div class="flex shrink-0 gap-1">
                        <Button
                            variant="ghost"
                            size="icon"
                            class="size-9 text-muted-foreground hover:text-foreground"
                            title="Редактировать"
                            aria-label="Редактировать стеллаж"
                            @click="editRack(rack)"
                        >
                            <Pencil :size="16" />
                        </Button>

                        <Button
                            variant="ghost"
                            size="icon"
                            class="size-9 text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
                            title="Удалить"
                            aria-label="Удалить стеллаж"
                            @click="deleteRack(rack)"
                        >
                            <Trash2 :size="16" />
                        </Button>
                    </div>
                </div>

                <!-- Заполненность -->
                <div class="mt-4">
                    <div
                        class="mb-1.5 flex items-center justify-between text-xs text-muted-foreground"
                    >
                        <span>Занято ячеек</span>
                        <span class="font-medium text-foreground tabular-nums">
                            {{ occupiedInRack(rack) }} из
                            {{ rack.locations_count || rack.locations?.length || 0 }}
                        </span>
                    </div>
                    <div class="h-1.5 overflow-hidden rounded-full bg-muted">
                        <div
                            class="h-full rounded-full bg-emerald-500 transition-[width] duration-500"
                            :style="{
                                width: `${
                                    (rack.locations_count || rack.locations?.length)
                                        ? (occupiedInRack(rack) /
                                              (rack.locations_count ||
                                                  rack.locations.length)) *
                                          100
                                        : 0
                                }%`,
                            }"
                        />
                    </div>
                </div>

                <!-- Ячейки -->
                <div class="mt-4 grid grid-cols-3 gap-1.5 min-[420px]:grid-cols-4 sm:mt-5 sm:gap-2">
                    <button
                        v-for="cell in rack.locations || []"
                        :key="cell.id"
                        type="button"
                        class="rounded-xl border px-2 py-2.5 text-center transition hover:-translate-y-0.5 focus-visible:ring-[3px] focus-visible:ring-ring/40 focus-visible:outline-none"
                        :class="
                            locationQuantity(cell) > 0
                                ? 'border-emerald-500/30 bg-emerald-500/10 text-emerald-800 hover:border-emerald-500/60 dark:text-emerald-300'
                                : 'border-border bg-muted/40 text-muted-foreground hover:border-primary/30'
                        "
                        :title="`Ячейка ${cell.code || cell.number}`"
                        @click="viewLocationProducts(cell)"
                    >
                        <span class="block truncate text-sm font-bold">
                            {{ cell.code || cell.number }}
                        </span>
                        <span class="mt-0.5 block text-[11px] tabular-nums">
                            {{ formatQuantity(cell.stock_quantity) }} шт.
                        </span>
                    </button>

                    <p
                        v-if="!rack.locations?.length"
                        class="col-span-full py-4 text-center text-sm text-muted-foreground"
                    >
                        Ячеек пока нет
                    </p>
                </div>

                <!-- Добавление ячейки -->
                <div class="mt-auto border-t pt-4">
                    <div class="mt-1">
                        <Button
                            v-if="addingLocationRackId !== rack.id"
                            variant="outline"
                            class="w-full border-dashed"
                            @click="startAddLocation(rack.id)"
                        >
                            <Plus :size="16" class="mr-2" />
                            Добавить ячейку
                        </Button>

                        <div v-else class="flex flex-col gap-2 min-[420px]:flex-row">
                            <input
                                v-model="newLocationNumber[rack.id]"
                                type="number"
                                min="1"
                                step="1"
                                placeholder="№ ячейки"
                                aria-label="Номер ячейки"
                                class="min-w-0 flex-1"
                                :class="fieldClass"
                                @keydown.enter="addLocation(rack)"
                                @keydown.esc="cancelAddLocation"
                            />

                            <Button class="w-full min-[420px]:w-auto" @click="addLocation(rack)">
                                Добавить
                            </Button>

                            <Button
                                variant="outline"
                                size="icon"
                                aria-label="Отмена"
                                @click="cancelAddLocation"
                            >
                                <X :size="16" />
                            </Button>
                        </div>
                    </div>
                </div>
            </article>
        </section>

        <section
            v-else
            class="rounded-2xl border border-dashed bg-card px-6 py-16 text-center"
        >
            <div
                class="mx-auto mb-4 flex size-16 items-center justify-center rounded-full bg-muted"
            >
                <Grid2X2 :size="30" class="text-muted-foreground" />
            </div>
            <h2 class="text-xl font-bold">Стеллажи не найдены</h2>
            <p class="mx-auto mt-2 max-w-sm text-sm text-muted-foreground">
                Создайте первый стеллаж, чтобы организовать хранение товаров.
            </p>
            <Button as-child class="mt-6">
                <Link :href="create().url">
                    <Plus :size="16" class="mr-2" />
                    Создать стеллаж
                </Link>
            </Button>
        </section>
    </div>

    <!-- Товары в ячейке -->
    <Dialog
        :open="locationModal.open"
        @update:open="
            (open) => {
                if (!open) closeLocationModal();
            }
        "
    >
        <DialogContent
            class="max-h-[90dvh] w-[calc(100vw-1rem)] max-w-2xl overflow-x-hidden overflow-y-auto p-4 sm:w-[95vw] sm:p-6 [&>*]:min-w-0"
        >
            <DialogHeader>
                <DialogTitle>
                    Ячейка {{ locationModal.locationCode }}
                </DialogTitle>
                <DialogDescription>
                    Остатки товаров и складские операции
                </DialogDescription>
            </DialogHeader>

            <div
                v-if="locationModal.loading"
                class="flex flex-col items-center gap-3 py-12"
            >
                <Loader2 :size="28" class="animate-spin text-primary" />
                <p class="text-sm text-muted-foreground">Загрузка товаров...</p>
            </div>

            <div v-else-if="locationModal.error" class="py-8 text-center">
                <p class="text-sm text-destructive">
                    {{ locationModal.error }}
                </p>
                <Button
                    v-if="locationModal.locationId"
                    variant="outline"
                    class="mt-4"
                    @click="
                        viewLocationProducts({
                            id: locationModal.locationId,
                            code: locationModal.locationCode,
                        })
                    "
                >
                    Повторить
                </Button>
            </div>

            <template v-else>
                <!-- Форма операции -->
                <div
                    v-if="currentOperation"
                    class="space-y-4 rounded-2xl border bg-muted/30 p-4 sm:p-5"
                >
                    <div class="flex items-center justify-between gap-3">
                        <div class="flex items-center gap-3">
                            <span
                                class="flex size-10 items-center justify-center rounded-xl"
                                :class="currentOperation.tone"
                            >
                                <component :is="currentOperation.icon" :size="20" />
                            </span>
                            <div>
                                <h3 class="font-semibold">
                                    {{ currentOperation.label }}
                                </h3>
                                <p class="text-xs text-muted-foreground">
                                    {{ currentOperation.description }}
                                </p>
                            </div>
                        </div>

                        <Button
                            variant="ghost"
                            size="sm"
                            :disabled="locationModal.operationLoading"
                            @click="closeOperation"
                        >
                            <ArrowLeft :size="16" class="mr-1.5" />
                            Назад
                        </Button>
                    </div>

                    <div class="space-y-1.5">
                        <label class="text-sm font-medium">Товар</label>

                        <ProductSelect
                            :key="locationModal.operation ?? undefined"
                            :products="operationProducts"
                            :categories="categories ?? []"
                            :model-value="operationForm.product_id"
                            @update:model-value="
                                operationForm.product_id =
                                    $event !== null ? String($event) : ''
                            "
                        />
                    </div>

                    <div class="space-y-1.5">
                        <label class="text-sm font-medium">
                            {{
                                locationModal.operation === 'inventory'
                                    ? 'Фактическое количество'
                                    : 'Количество'
                            }}
                        </label>

                        <input
                            v-model="operationForm.quantity"
                            type="number"
                            min="0"
                            step="0.001"
                            :class="fieldClass"
                        />

                        <p
                            v-if="
                                operationForm.current_quantity !== null &&
                                locationModal.operation !== 'receipt' &&
                                locationModal.operation !== 'return'
                            "
                            class="text-xs text-muted-foreground"
                        >
                            Текущий остаток:
                            <span class="font-medium text-foreground">
                                {{ formatQuantity(operationForm.current_quantity) }}
                            </span>
                        </p>
                    </div>

                    <div
                        v-if="locationModal.operation === 'transfer'"
                        class="space-y-1.5"
                    >
                        <label class="text-sm font-medium">
                            Ячейка назначения
                        </label>

                        <select
                            v-model="operationForm.to_location_id"
                            :class="fieldClass"
                        >
                            <option value="">Выберите ячейку</option>
                            <option
                                v-for="location in allLocations"
                                :key="location.id"
                                :value="String(location.id)"
                                :disabled="location.id === locationModal.locationId"
                            >
                                {{ location.code }}
                                ({{ location.rack_name || 'Без названия' }})
                            </option>
                        </select>
                    </div>

                    <div class="space-y-1.5">
                        <label class="text-sm font-medium">Комментарий</label>
                        <textarea
                            v-model="operationForm.comment"
                            rows="2"
                            :class="fieldClass"
                            placeholder="Необязательно"
                        />
                    </div>

                    <Button
                        class="w-full"
                        :disabled="
                            locationModal.operationLoading ||
                            !operationForm.product_id
                        "
                        @click="submitOperation"
                    >
                        <Loader2
                            v-if="locationModal.operationLoading"
                            :size="16"
                            class="mr-2 animate-spin"
                        />
                        {{
                            locationModal.operationLoading
                                ? 'Выполнение...'
                                : 'Выполнить операцию'
                        }}
                    </Button>
                </div>

                <template v-else>
                    <!-- Выбор операции -->
                    <div class="grid gap-2 sm:grid-cols-2">
                        <button
                            v-for="item in operationButtons"
                            :key="item.value"
                            type="button"
                            class="group flex items-center gap-3 rounded-xl border bg-card px-3.5 py-3 text-left transition hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-sm focus-visible:ring-[3px] focus-visible:ring-ring/40 focus-visible:outline-none"
                            @click="startOperation(item.value)"
                        >
                            <span
                                class="flex size-10 shrink-0 items-center justify-center rounded-xl transition group-hover:scale-105"
                                :class="item.tone"
                            >
                                <component :is="item.icon" :size="20" />
                            </span>
                            <span class="min-w-0 flex-1">
                                <span class="block text-sm font-semibold">
                                    {{ item.label }}
                                </span>
                                <span class="block text-xs text-muted-foreground">
                                    {{ item.description }}
                                </span>
                            </span>
                        </button>
                    </div>

                    <!-- Товары -->
                    <div>
                        <h3
                            class="mb-2 text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                        >
                            Товары в ячейке
                        </h3>

                        <div
                            v-if="!locationModal.products.length"
                            class="flex flex-col items-center gap-2 rounded-xl border border-dashed py-8 text-center"
                        >
                            <Package :size="24" class="text-muted-foreground" />
                            <p class="text-sm text-muted-foreground">
                                В ячейке пока нет товаров
                            </p>
                        </div>

                        <div v-else class="space-y-1.5">
                            <button
                                v-for="product in locationModal.products"
                                :key="product.id"
                                type="button"
                                :title="product.name"
                                class="group flex w-full min-w-0 items-center justify-between gap-3 rounded-lg border bg-card px-3 py-2.5 text-left transition hover:border-primary/30 hover:bg-muted/40"
                                @click="showProductDetails(product)"
                            >
                            <span class="min-w-0 flex-1">
                                <span
                                    class="line-clamp-2 block text-[13px] leading-snug font-medium break-words"
                                >
                                    {{ product.name }}
                                </span>
                                <span v-if="product.code" class="mt-0.5 block truncate text-[11px] text-muted-foreground">
                                    Код: {{ product.code }}
                                </span>
                                <span v-if="product.article" class="mt-0.5 block truncate text-[11px] text-muted-foreground">
                                    Артикул: {{ product.article }}
                                </span>
                                <span v-if="!product.code && !product.article" class="mt-0.5 block truncate text-[11px] text-muted-foreground">
                                    Без кода/артикула
                                </span>
                            </span>

                                <span class="flex shrink-0 items-center gap-2">
                                <span class="text-right">
                                    <span class="block text-sm font-bold tabular-nums">
                                        {{ formatQuantity(product.quantity) }}
                                    </span>
                                    <span class="text-[11px] text-muted-foreground">шт.</span>
                                </span>
                                <ChevronRight
                                    :size="16"
                                    class="text-muted-foreground transition group-hover:translate-x-0.5 group-hover:text-primary"
                                />
                            </span>
                            </button>
                        </div>
                    </div>
                </template>
            </template>

            <div class="flex justify-end border-t pt-4">
                <Button
                    variant="outline"
                    class="w-full sm:w-auto"
                    :disabled="locationModal.operationLoading"
                    @click="closeLocationModal"
                >
                    Закрыть
                </Button>
            </div>
        </DialogContent>
    </Dialog>

    <!-- Распределение товара по ячейкам -->
    <Dialog
        :open="productDetailsModal.open"
        @update:open="
            (open) => {
                if (!open) closeProductDetails();
            }
        "
    >
        <DialogContent
            class="max-h-[85dvh] w-[calc(100vw-1rem)] max-w-xl overflow-x-hidden overflow-y-auto p-4 sm:w-[95vw] sm:p-6 [&>*]:min-w-0"
        >
            <DialogHeader>
                <DialogTitle class="pr-6 text-base leading-snug break-words">
                    {{ productDetailsModal.product?.name || 'Расположение товара' }}
                </DialogTitle>
                <DialogDescription class="flex flex-col gap-0.5">
                    <template v-if="productDetailsModal.product?.code || productDetailsModal.product?.article">
                        <span v-if="productDetailsModal.product?.code">Код: {{ productDetailsModal.product.code }} · остатки по ячейкам</span>
                        <span v-if="productDetailsModal.product?.article">Артикул: {{ productDetailsModal.product.article }}</span>
                    </template>
                    <span v-else>Остатки товара по ячейкам</span>
                </DialogDescription>
            </DialogHeader>

            <div
                v-if="productDetailsModal.loading"
                class="flex flex-col items-center gap-3 py-10"
            >
                <Loader2 :size="26" class="animate-spin text-primary" />
                <p class="text-sm text-muted-foreground">Загрузка...</p>
            </div>

            <p
                v-else-if="productDetailsModal.error"
                class="py-6 text-center text-sm text-destructive"
            >
                {{ productDetailsModal.error }}
            </p>

            <template v-else>
                <div class="rounded-xl bg-emerald-500/10 p-4">
                    <p class="text-sm text-muted-foreground">Общий остаток</p>
                    <p
                        class="mt-1 text-3xl font-bold text-emerald-700 tabular-nums dark:text-emerald-300"
                    >
                        {{ formatQuantity(productDetailsModal.totalQuantity) }}
                    </p>
                </div>

                <div
                    v-if="productDetailsModal.locations.length"
                    class="space-y-2"
                >
                    <div
                        v-for="location in productDetailsModal.locations"
                        :key="location.id"
                        class="flex min-w-0 items-center justify-between gap-3 rounded-xl border bg-card p-3"
                    >
                        <p class="min-w-0 break-words font-medium">
                            {{ location.code || `Ячейка ${location.number}` }}
                        </p>
                        <p class="font-bold tabular-nums">
                            {{ formatQuantity(location.quantity) }}
                        </p>
                    </div>
                </div>

                <p v-else class="py-6 text-center text-sm text-muted-foreground">
                    Положительных остатков не найдено.
                </p>
            </template>
        </DialogContent>
    </Dialog>

    <!-- Подтверждение удаления -->
    <Dialog
        :open="deleteConfirmation.open"
        @update:open="
            (open) => {
                if (!open) closeDeleteConfirmation();
            }
        "
    >
        <DialogContent class="w-[calc(100vw-1rem)] max-w-md p-4 sm:w-[95vw] sm:p-6">
            <DialogHeader>
                <DialogTitle>Подтверждение удаления</DialogTitle>
                <DialogDescription>
                    {{
                        deleteConfirmation.type === 'rack'
                            ? `Удалить стеллаж «${deleteConfirmation.rack?.name || deleteConfirmation.rack?.code}»?`
                            : `Удалить ячейку «${deleteConfirmation.location?.code}»?`
                    }}
                </DialogDescription>
            </DialogHeader>

            <p class="text-sm text-muted-foreground">
                Удаление может быть запрещено, если существуют остатки или
                история складских движений.
            </p>

            <div class="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end sm:gap-3">
                <Button
                    variant="outline"
                    class="w-full sm:w-auto"
                    :disabled="deleteConfirmation.loading"
                    @click="closeDeleteConfirmation"
                >
                    Отмена
                </Button>

                <Button
                    variant="destructive"
                    class="w-full sm:w-auto"
                    :disabled="deleteConfirmation.loading"
                    @click="confirmDelete"
                >
                    <Loader2
                        v-if="deleteConfirmation.loading"
                        :size="16"
                        class="mr-2 animate-spin"
                    />
                    {{ deleteConfirmation.loading ? 'Удаление...' : 'Удалить' }}
                </Button>
            </div>
        </DialogContent>
    </Dialog>
</template>
