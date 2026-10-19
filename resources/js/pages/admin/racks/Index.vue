<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, ref, watch } from 'vue';
import type { Component } from 'vue';
import { toast } from 'vue-sonner';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { create, destroy, edit } from '@/routes/admin/racks';
import {
    destroy as destroyLocation,
    store as storeLocation,
} from '@/routes/admin/racks/locations';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import ProductSelect from '@/components/admin/ProductSelect.vue';
import {
    PackagePlus,
    ArrowDownToLine,
    ArrowLeftRight,
    RotateCcw,
    ClipboardCheck,
    X,
} from '@lucide/vue';

defineOptions({
    layout: AdminLayout,
});

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
    sku: string | null;
    unit: string;
    characteristics?: string;
    category_id?: number | null;
}

interface LocationProduct {
    id: number;
    name: string;
    sku: string | null;
    quantity: string | number;
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
    sku: string | null;
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
}

type Operation = 'receipt' | 'write_off' | 'transfer' | 'return' | 'inventory';

interface OperationButton {
    value: Operation;
    label: string;
    description: string;
    icon: Component;
    active: string;
    iconClass: string;
}

const props = defineProps<Props>();

const operationButtons: OperationButton[] = [
    {
        value: 'receipt',
        label: 'Пополнение',
        description: 'Приход товара',
        icon: PackagePlus,
        active: 'border-emerald-300 bg-emerald-50 text-emerald-800 hover:border-emerald-400 dark:border-emerald-700 dark:bg-emerald-950 dark:text-emerald-300',
        iconClass:
            'bg-emerald-100 text-emerald-600 dark:bg-emerald-500/20 dark:text-emerald-300',
    },
    {
        value: 'write_off',
        label: 'Списание',
        description: 'Расход товара',
        icon: ArrowDownToLine,
        active: 'border-rose-300 bg-rose-50 text-rose-800 hover:border-rose-400 dark:border-rose-700 dark:bg-rose-950 dark:text-rose-300',
        iconClass:
            'bg-rose-100 text-rose-600 dark:bg-rose-500/20 dark:text-rose-300',
    },
    {
        value: 'transfer',
        label: 'Перемещение',
        description: 'Между ячейками',
        icon: ArrowLeftRight,
        active: 'border-blue-300 bg-blue-50 text-blue-800 hover:border-blue-400 dark:border-blue-700 dark:bg-blue-950 dark:text-blue-300',
        iconClass:
            'bg-blue-100 text-blue-600 dark:bg-blue-500/20 dark:text-blue-300',
    },
    {
        value: 'return',
        label: 'Возврат',
        description: 'Возврат товара',
        icon: RotateCcw,
        active: 'border-violet-300 bg-violet-50 text-violet-800 hover:border-violet-400 dark:border-violet-700 dark:bg-violet-950 dark:text-violet-300',
        iconClass:
            'bg-violet-100 text-violet-600 dark:bg-violet-500/20 dark:text-violet-300',
    },
    {
        value: 'inventory',
        label: 'Инвентаризация',
        description: 'Проверка остатка',
        icon: ClipboardCheck,
        active: 'border-amber-300 bg-amber-50 text-amber-800 hover:border-amber-400 dark:border-amber-700 dark:bg-amber-950 dark:text-amber-300',
        iconClass:
            'bg-amber-100 text-amber-600 dark:bg-amber-500/20 dark:text-amber-300',
    },
];

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

const operationForm = ref({
    product_id: '',
    quantity: '1',
    comment: '',
    to_location_id: '',
    current_quantity: null as number | null,
});

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

const productsForSelect = computed(() =>
    props.allProducts.map((product) => ({
        id: product.id,
        name: product.name,
        sku: product.sku,
        unit: product.unit,
        characteristics: product.characteristics,
    })),
);

const locationProductsForSelect = computed(() =>
    locationModal.value.products.map((product) => ({
        id: product.id,
        name: product.name,
        sku: product.sku,
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

const occupiedLocationsCount = computed(() =>
    props.racks.reduce(
        (sum, rack) =>
            sum +
            (rack.locations ?? []).filter(
                (location) => locationQuantity(location) > 0,
            ).length,
        0,
    ),
);

const addingLocationRackId = ref<number | null>(null);
const newLocationNumber = ref<Record<number, string>>({});

const editRack = (rack: Rack): void => {
    router.visit(edit(rack.id).url);
};

const viewRackLocations = (rack: Rack): void => {
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

const deleteRack = (rack: Rack): void => {
    deleteConfirmation.value = {
        open: true,
        type: 'rack',
        rack,
        location: null,
        loading: false,
    };
};

const deleteLocation = (rack: Rack, location: Location): void => {
    deleteConfirmation.value = {
        open: true,
        type: 'location',
        rack,
        location,
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

const viewLocationProducts = async (location: Location): Promise<void> => {
    locationModal.value.open = true;
    locationModal.value.locationCode = location.code;
    locationModal.value.locationId = location.id;
    locationModal.value.loading = true;
    locationModal.value.error = '';
    locationModal.value.products = [];

    try {
        const response = await fetch(
            `/admin/locations/${location.id}/products`,
            {
                headers: {
                    Accept: 'application/json',
                    'X-Requested-With': 'XMLHttpRequest',
                },
            },
        );

        if (!response.ok) {
            throw new Error('Не удалось загрузить товары ячейки.');
        }

        const data: unknown = await response.json();

        if (!Array.isArray(data)) {
            throw new Error('Сервер вернул некорректный список товаров.');
        }

        // Не отображаем товары с нулевым остатком.
        locationModal.value.products = (data as LocationProduct[]).filter(
            (product) => Number(product.quantity) > 0,
        );
    } catch (error) {
        console.error('Failed to load location products:', error);
        locationModal.value.error =
            'Не удалось загрузить товары. Попробуйте ещё раз.';
    } finally {
        locationModal.value.loading = false;
    }
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
        product_id: product ? String(product.id) : '',
        quantity:
            operation === 'inventory' && product
                ? String(product.quantity)
                : '1',
        comment: '',
        to_location_id: '',
        current_quantity: product ? Number(product.quantity) : null,
    };
};

const closeOperation = (): void => {
    if (locationModal.value.operationLoading) return;

    locationModal.value.operation = null;
    operationForm.value = {
        product_id: '',
        quantity: '1',
        comment: '',
        to_location_id: '',
        current_quantity: null,
    };
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

const submitOperation = async (): Promise<void> => {
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

    try {
        const formData = new FormData();
        formData.append('product_id', operationForm.value.product_id);
        formData.append('comment', operationForm.value.comment);

        let url: string;

        switch (operation) {
            case 'receipt':
                url = '/admin/stock/receipt';
                formData.append('location_id', String(locationId));
                formData.append('quantity', String(quantity));
                break;

            case 'write_off':
                url = '/admin/stock/write-off';
                formData.append('location_id', String(locationId));
                formData.append('quantity', String(quantity));
                break;

            case 'transfer':
                url = '/admin/stock/transfer';
                formData.append('from_location_id', String(locationId));
                formData.append(
                    'to_location_id',
                    operationForm.value.to_location_id,
                );
                formData.append('quantity', String(quantity));
                break;

            case 'return':
                url = '/admin/stock/return';
                formData.append('location_id', String(locationId));
                formData.append('quantity', String(quantity));
                break;

            case 'inventory':
                url = '/admin/stock/inventory';
                formData.append('location_id', String(locationId));
                formData.append('actual_quantity', String(quantity));
                break;
        }

        const response = await fetch(url, {
            method: 'POST',
            headers: {
                Accept: 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'X-CSRF-TOKEN':
                    document.querySelector<HTMLMetaElement>(
                        'meta[name="csrf-token"]',
                    )?.content ?? '',
            },
            body: formData,
            credentials: 'same-origin',
        });

        const data = await response.json().catch(() => null);

        if (!response.ok) {
            let message = data?.message || 'Ошибка при выполнении операции.';

            if (data?.errors) {
                message =
                    Object.values(data.errors).flat().join(', ') || message;
            }

            toast.error(message);
            return;
        }

        toast.success('Операция успешно выполнена.');

        locationModal.value.operation = null;
        operationForm.value = {
            product_id: '',
            quantity: '1',
            comment: '',
            to_location_id: '',
            current_quantity: null,
        };

        const location = props.racks
            .flatMap((rack) => rack.locations ?? [])
            .find((item) => item.id === locationId);

        if (location) {
            await viewLocationProducts(location);
        }

        router.reload({ only: ['racks'] });
    } catch (error) {
        console.error('Operation error:', error);
        toast.error('Не удалось выполнить операцию.');
    } finally {
        locationModal.value.operationLoading = false;
    }
};

const showProductDetails = async (product: LocationProduct): Promise<void> => {
    productDetailsModal.value = {
        open: true,
        loading: true,
        error: '',
        product: {
            id: product.id,
            name: product.name,
            sku: product.sku,
            quantity: product.quantity,
        },
        locations: [],
        totalQuantity: 0,
    };

    try {
        const response = await fetch(
            `/admin/locations?product_id=${encodeURIComponent(String(product.id))}`,
            {
                headers: {
                    Accept: 'application/json',
                    'X-Requested-With': 'XMLHttpRequest',
                },
            },
        );

        if (!response.ok) {
            throw new Error('Не удалось загрузить расположение товара.');
        }

        const data = await response.json();

        const locations = (
            Array.isArray(data.locations)
                ? (data.locations as ProductStockLocation[])
                : []
        ).filter((location) => Number(location.quantity) > 0);

        productDetailsModal.value.locations = locations;
        productDetailsModal.value.totalQuantity = locations.reduce(
            (sum, location) => sum + Number(location.quantity || 0),
            0,
        );
    } catch (error) {
        console.error('Product details error:', error);
        productDetailsModal.value.error =
            'Не удалось загрузить расположение товара. Попробуйте ещё раз.';
    } finally {
        productDetailsModal.value.loading = false;
    }
};

const closeProductDetails = (): void => {
    productDetailsModal.value.open = false;
};
</script>

<template>
    <Head title="Склады и ячейки" />

    <div
        class="min-h-screen bg-gradient-to-br from-slate-50 via-slate-100 to-slate-200 px-4 py-6 sm:px-6 lg:px-8 dark:from-slate-950 dark:via-slate-900 dark:to-slate-800"
    >
        <div class="mx-auto max-w-7xl">
            <div
                class="mb-8 flex flex-col justify-between gap-6 md:flex-row md:items-center"
            >
                <div>
                    <h1
                        class="mb-1 text-3xl font-bold tracking-tight text-slate-900 dark:text-white"
                    >
                        Склады и ячейки
                    </h1>
                    <p class="text-sm text-slate-500 dark:text-slate-400">
                        Управление стеллажами, ячейками и остатками товаров
                    </p>
                </div>

                <Link
                    :href="create().url"
                    class="inline-flex items-center justify-center gap-2 rounded-xl bg-emerald-600 px-5 py-3 text-sm font-semibold text-white shadow-lg transition hover:bg-emerald-700"
                >
                    <span class="text-lg">+</span>
                    Добавить стеллаж
                </Link>
            </div>

            <div class="mb-8 grid gap-4 sm:grid-cols-3">
                <div
                    class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-white/10 dark:bg-slate-900"
                >
                    <p class="text-xs tracking-wider text-slate-500 uppercase">
                        Всего стеллажей
                    </p>
                    <p
                        class="mt-2 text-2xl font-bold text-slate-900 dark:text-white"
                    >
                        {{ racks.length }}
                    </p>
                </div>

                <div
                    class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-white/10 dark:bg-slate-900"
                >
                    <p class="text-xs tracking-wider text-slate-500 uppercase">
                        Всего ячеек
                    </p>
                    <p
                        class="mt-2 text-2xl font-bold text-slate-900 dark:text-white"
                    >
                        {{
                            racks.reduce(
                                (sum, rack) =>
                                    sum + (rack.locations_count || 0),
                                0,
                            )
                        }}
                    </p>
                </div>

                <div
                    class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-white/10 dark:bg-slate-900"
                >
                    <p class="text-xs tracking-wider text-slate-500 uppercase">
                        Занято ячеек
                    </p>
                    <p class="mt-2 text-2xl font-bold text-emerald-600">
                        {{ occupiedLocationsCount }}
                    </p>
                </div>
            </div>

            <div
                v-if="racks.length"
                class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4"
            >
                <article
                    v-for="rack in racks"
                    :key="rack.id"
                    class="rounded-3xl border border-slate-200 bg-white/90 p-5 shadow-sm transition hover:-translate-y-1 hover:shadow-lg dark:border-white/10 dark:bg-slate-900/90"
                >
                    <div class="mb-5 flex items-start justify-between gap-3">
                        <div>
                            <h2
                                class="text-lg font-bold text-slate-900 dark:text-white"
                            >
                                {{ rack.name || rack.code }}
                            </h2>
                            <p
                                class="text-xs tracking-wider text-slate-500 uppercase"
                            >
                                {{ rack.code }}
                            </p>
                        </div>

                        <div class="flex gap-1">
                            <button
                                type="button"
                                title="Просмотреть ячейки"
                                class="rounded-lg bg-slate-100 px-2.5 py-2 text-slate-600 hover:bg-emerald-100 dark:bg-slate-800 dark:text-slate-300"
                                @click="viewRackLocations(rack)"
                            >
                                <span aria-hidden="true">⌕</span>
                            </button>

                            <button
                                type="button"
                                title="Редактировать"
                                class="rounded-lg bg-slate-100 px-2.5 py-2 text-slate-600 hover:bg-blue-100 dark:bg-slate-800 dark:text-slate-300"
                                @click="editRack(rack)"
                            >
                                ✎
                            </button>

                            <button
                                type="button"
                                title="Удалить"
                                class="rounded-lg bg-slate-100 px-2.5 py-2 text-red-600 hover:bg-red-100 dark:bg-slate-800"
                                @click="deleteRack(rack)"
                            >
                                ×
                            </button>
                        </div>
                    </div>

                    <div class="flex flex-wrap gap-2">
                        <button
                            v-for="cell in rack.locations || []"
                            :key="cell.id"
                            type="button"
                            class="min-w-20 rounded-xl border p-3 text-center transition hover:-translate-y-0.5"
                            :class="
                                locationQuantity(cell) > 0
                                    ? 'border-emerald-300 bg-emerald-50 text-emerald-800 dark:border-emerald-700 dark:bg-emerald-950 dark:text-emerald-300'
                                    : 'border-slate-200 bg-slate-50 text-slate-600 dark:border-white/10 dark:bg-slate-800 dark:text-slate-300'
                            "
                            @click="viewLocationProducts(cell)"
                        >
                            <span class="block text-sm font-bold">
                                {{ cell.code || cell.number }}
                            </span>
                            <span class="mt-1 block text-xs">
                                {{ formatQuantity(cell.stock_quantity) }} шт.
                            </span>
                        </button>

                        <p
                            v-if="!rack.locations?.length"
                            class="w-full py-3 text-center text-sm text-slate-400"
                        >
                            Ячеек пока нет
                        </p>
                    </div>

                    <div
                        class="mt-5 border-t border-slate-200 pt-4 dark:border-white/10"
                    >
                        <button
                            v-if="addingLocationRackId !== rack.id"
                            type="button"
                            class="w-full rounded-xl border border-dashed border-slate-300 px-3 py-2.5 text-sm text-slate-600 hover:bg-slate-50 dark:border-white/20 dark:text-slate-300 dark:hover:bg-slate-800"
                            @click="startAddLocation(rack.id)"
                        >
                            + Добавить ячейку
                        </button>

                        <div v-else class="flex gap-2">
                            <input
                                v-model="newLocationNumber[rack.id]"
                                type="number"
                                min="1"
                                step="1"
                                placeholder="№ ячейки"
                                class="min-w-0 flex-1 rounded-xl border border-slate-300 bg-white px-3 py-2 text-sm dark:border-white/10 dark:bg-slate-800 dark:text-white"
                                @keydown.enter="addLocation(rack)"
                            />

                            <button
                                type="button"
                                class="rounded-xl bg-emerald-600 px-3 py-2 text-sm font-semibold text-white hover:bg-emerald-700"
                                @click="addLocation(rack)"
                            >
                                Добавить
                            </button>

                            <button
                                type="button"
                                class="rounded-xl bg-slate-100 px-3 py-2 dark:bg-slate-800 dark:text-white"
                                @click="cancelAddLocation"
                            >
                                ×
                            </button>
                        </div>
                    </div>
                </article>
            </div>

            <div
                v-else
                class="rounded-2xl border border-dashed border-slate-300 py-16 text-center dark:border-white/10"
            >
                <h2 class="text-xl font-bold text-slate-900 dark:text-white">
                    Стеллажи не найдены
                </h2>
                <p class="mt-2 text-sm text-slate-500">
                    Создайте первый стеллаж, чтобы организовать хранение
                    товаров.
                </p>
                <Link
                    :href="create().url"
                    class="mt-5 inline-flex rounded-xl bg-emerald-600 px-5 py-3 text-sm font-semibold text-white hover:bg-emerald-700"
                >
                    Создать стеллаж
                </Link>
            </div>
        </div>
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
        <DialogContent class="max-h-[90vh] w-[95vw] max-w-3xl overflow-y-auto">
            <DialogHeader>
                <DialogTitle>
                    Товары в ячейке {{ locationModal.locationCode }}
                </DialogTitle>
                <DialogDescription>
                    Остатки товаров и складские операции
                </DialogDescription>
            </DialogHeader>

            <div v-if="locationModal.loading" class="py-10 text-center">
                <div
                    class="mx-auto h-8 w-8 animate-spin rounded-full border-4 border-slate-200 border-t-emerald-500"
                ></div>
                <p class="mt-3 text-sm text-slate-500">Загрузка товаров...</p>
            </div>

            <div v-else-if="locationModal.error" class="py-8 text-center">
                <p class="text-sm text-red-600">
                    {{ locationModal.error }}
                </p>
                <button
                    v-if="locationModal.locationId"
                    type="button"
                    class="mt-3 rounded-lg bg-slate-100 px-4 py-2 text-sm dark:bg-slate-800 dark:text-white"
                    @click="
                        viewLocationProducts({
                            id: locationModal.locationId,
                            rack_id: 0,
                            number: 0,
                            code: locationModal.locationCode,
                            stock_quantity: 0,
                            incoming_movements_count: 0,
                            outgoing_movements_count: 0,
                        })
                    "
                >
                    Повторить
                </button>
            </div>

            <template v-else>
                <div
                    v-if="!locationModal.operation"
                    class="flex flex-col gap-2 border-b border-slate-200 pb-5 dark:border-white/10"
                >
                    <button
                        v-for="item in operationButtons"
                        :key="item.value"
                        type="button"
                        class="group flex w-full items-center gap-3 rounded-xl border border-primary/15 bg-gradient-to-r from-primary/5 to-indigo-500/5 px-4 py-3 text-left text-sm font-semibold text-foreground shadow-sm transition-all duration-200 hover:-translate-y-0.5 hover:border-primary/30 hover:from-primary/10 hover:to-indigo-500/10 hover:shadow-md focus-visible:ring-2 focus-visible:ring-primary/50 focus-visible:outline-none"
                        :class="item.active"
                        @click="startOperation(item.value)"
                    >
                        <span
                            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-primary/10 to-indigo-500/10 text-primary transition-colors group-hover:from-primary/20 group-hover:to-indigo-500/20"
                        >
                            <component
                                :is="item.icon"
                                :size="20"
                                :stroke-width="1.8"
                            />
                        </span>

                        <span>{{ item.label }}</span>
                    </button>
                </div>

                <div
                    v-if="locationModal.operation"
                    class="space-y-4 rounded-xl bg-slate-50 p-4 dark:bg-slate-900"
                >
                    <div class="flex items-center justify-between">
                        <h3
                            class="font-semibold text-slate-900 dark:text-white"
                        >
                            {{
                                {
                                    receipt: 'Пополнение',
                                    write_off: 'Списание',
                                    transfer: 'Перемещение',
                                    return: 'Возврат',
                                    inventory: 'Инвентаризация',
                                }[locationModal.operation]
                            }}
                        </h3>

                        <button
                            type="button"
                            class="inline-flex items-center justify-center gap-2 rounded-xl border border-primary/20 bg-gradient-to-r from-primary/5 to-indigo-500/5 px-5 py-2.5 text-sm font-semibold text-foreground shadow-sm transition-all hover:border-primary/40 hover:from-primary/10 hover:to-indigo-500/10 focus-visible:ring-2 focus-visible:ring-primary/50 focus-visible:outline-none"
                            @click="closeLocationModal"
                        >
                            <X :size="16" />
                            Отмена
                        </button>
                    </div>

                    <div>
                        <label
                            class="mb-1 block text-sm text-slate-600 dark:text-slate-300"
                        >
                            Товар
                        </label>

                        <ProductSelect
                            :key="locationModal.operation"
                            :products="operationProducts"
                            :categories="categories ?? []"
                            :model-value="operationForm.product_id"
                            @update:model-value="
                                operationForm.product_id =
                                    $event !== null ? String($event) : ''
                            "
                        />
                    </div>

                    <div>
                        <label
                            class="mb-1 block text-sm text-slate-600 dark:text-slate-300"
                        >
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
                            class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm dark:border-white/10 dark:bg-slate-800 dark:text-white"
                        />

                        <p
                            v-if="
                                operationForm.current_quantity !== null &&
                                locationModal.operation !== 'receipt' &&
                                locationModal.operation !== 'return'
                            "
                            class="mt-1 text-xs text-slate-500"
                        >
                            Текущий остаток:
                            {{ formatQuantity(operationForm.current_quantity) }}
                        </p>
                    </div>

                    <div v-if="locationModal.operation === 'transfer'">
                        <label
                            class="mb-1 block text-sm text-slate-600 dark:text-slate-300"
                        >
                            Ячейка назначения
                        </label>

                        <select
                            v-model="operationForm.to_location_id"
                            class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm dark:border-white/10 dark:bg-slate-800 dark:text-white"
                        >
                            <option value="">Выберите ячейку</option>
                            <option
                                v-for="location in allLocations"
                                :key="location.id"
                                :value="String(location.id)"
                                :disabled="
                                    location.id === locationModal.locationId
                                "
                            >
                                {{ location.code }}
                                ({{ location.rack_name || 'Без названия' }})
                            </option>
                        </select>
                    </div>

                    <div>
                        <label
                            class="mb-1 block text-sm text-slate-600 dark:text-slate-300"
                        >
                            Комментарий
                        </label>
                        <textarea
                            v-model="operationForm.comment"
                            rows="2"
                            class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm dark:border-white/10 dark:bg-slate-800 dark:text-white"
                            placeholder="Необязательно"
                        />
                    </div>

                    <button
                        type="button"
                        :disabled="
                            locationModal.operationLoading ||
                            !operationForm.product_id
                        "
                        class="w-full rounded-xl bg-emerald-600 px-4 py-3 text-sm font-semibold text-white transition hover:bg-emerald-700 disabled:cursor-not-allowed disabled:opacity-50"
                        @click="submitOperation"
                    >
                        {{
                            locationModal.operationLoading
                                ? 'Выполнение...'
                                : 'Выполнить операцию'
                        }}
                    </button>
                </div>

                <div
                    v-if="
                        !locationModal.operation &&
                        !locationModal.products.length
                    "
                    class="py-8 text-center"
                >
                    <p class="text-sm text-slate-500">
                        В ячейке пока нет товаров
                    </p>
                </div>

                <div v-else-if="!locationModal.operation" class="space-y-2">
                    <button
                        v-for="product in locationModal.products"
                        :key="product.id"
                        type="button"
                        class="flex w-full items-center justify-between gap-3 rounded-xl border border-slate-200 bg-white p-4 text-left transition hover:bg-slate-50 dark:border-white/10 dark:bg-slate-900 dark:hover:bg-slate-800"
                        @click="showProductDetails(product)"
                    >
                        <span class="min-w-0">
                            <span
                                class="block font-medium text-slate-900 dark:text-white"
                            >
                                {{ product.name }}
                            </span>
                            <span class="block text-xs text-slate-500">
                                {{ product.sku || 'Без артикула' }}
                            </span>
                        </span>

                        <span class="shrink-0 text-right">
                            <span
                                class="block font-bold text-slate-900 dark:text-white"
                            >
                                {{ formatQuantity(product.quantity) }}
                            </span>
                            <span class="text-xs text-emerald-600">
                                Подробнее →
                            </span>
                        </span>
                    </button>
                </div>
            </template>

            <div
                class="flex justify-end border-t border-slate-200 pt-4 dark:border-white/10"
            >
                <button
                    type="button"
                    class="rounded-xl bg-slate-100 px-5 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-200 dark:bg-slate-800 dark:text-white"
                    :disabled="locationModal.operationLoading"
                    @click="closeLocationModal"
                >
                    Закрыть
                </button>
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
        <DialogContent class="max-h-[85vh] w-[95vw] max-w-xl overflow-y-auto">
            <DialogHeader>
                <DialogTitle>
                    {{
                        productDetailsModal.product?.name ||
                        'Расположение товара'
                    }}
                </DialogTitle>
                <DialogDescription>
                    Остатки товара по ячейкам
                </DialogDescription>
            </DialogHeader>

            <div
                v-if="productDetailsModal.loading"
                class="py-8 text-center text-sm text-slate-500"
            >
                Загрузка...
            </div>

            <p
                v-else-if="productDetailsModal.error"
                class="py-6 text-sm text-red-600"
            >
                {{ productDetailsModal.error }}
            </p>

            <template v-else>
                <div class="rounded-xl bg-emerald-50 p-4 dark:bg-emerald-950">
                    <p class="text-sm text-slate-600 dark:text-slate-300">
                        Общий остаток
                    </p>
                    <p
                        class="mt-1 text-2xl font-bold text-emerald-700 dark:text-emerald-300"
                    >
                        {{ formatQuantity(productDetailsModal.totalQuantity) }}
                    </p>
                </div>

                <div
                    v-if="productDetailsModal.locations.length"
                    class="mt-4 space-y-2"
                >
                    <div
                        v-for="location in productDetailsModal.locations"
                        :key="location.id"
                        class="flex items-center justify-between rounded-xl border border-slate-200 p-3 dark:border-white/10"
                    >
                        <div>
                            <p
                                class="font-medium text-slate-900 dark:text-white"
                            >
                                {{
                                    location.code || `Ячейка ${location.number}`
                                }}
                            </p>
                        </div>
                        <p class="font-bold text-slate-900 dark:text-white">
                            {{ formatQuantity(location.quantity) }}
                        </p>
                    </div>
                </div>

                <p v-else class="py-6 text-center text-sm text-slate-500">
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
        <DialogContent class="w-[95vw] max-w-md">
            <DialogHeader>
                <DialogTitle> Подтверждение удаления </DialogTitle>
                <DialogDescription>
                    {{
                        deleteConfirmation.type === 'rack'
                            ? `Удалить стеллаж «${deleteConfirmation.rack?.name || deleteConfirmation.rack?.code}»?`
                            : `Удалить ячейку «${deleteConfirmation.location?.code}»?`
                    }}
                </DialogDescription>
            </DialogHeader>

            <p class="text-sm text-slate-500">
                Удаление может быть запрещено, если существуют остатки или
                история складских движений.
            </p>

            <div class="flex justify-end gap-3">
                <button
                    type="button"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 text-sm dark:bg-slate-800 dark:text-white"
                    :disabled="deleteConfirmation.loading"
                    @click="closeDeleteConfirmation"
                >
                    Отмена
                </button>

                <button
                    type="button"
                    class="rounded-xl bg-red-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-red-700 disabled:opacity-50"
                    :disabled="deleteConfirmation.loading"
                    @click="confirmDelete"
                >
                    {{ deleteConfirmation.loading ? 'Удаление...' : 'Удалить' }}
                </button>
            </div>
        </DialogContent>
    </Dialog>
</template>
