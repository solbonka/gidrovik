<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import { Check, ClipboardCheck, Info, LoaderCircle } from '@lucide/vue';
import { toast } from 'vue-sonner';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ProductSelect from '@/components/admin/ProductSelect.vue';
import LocationSelect from '@/components/admin/LocationSelect.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import StockField from '@/components/admin/stock/StockField.vue';
import CommentField from '@/components/admin/stock/CommentField.vue';
import OperationSummary from '@/components/admin/stock/OperationSummary.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

defineOptions({
    layout: AdminLayout,
});

interface ProductOption {
    id: number;
    name: string;
    sku: string | null;
    characteristics?: string;
    category_id?: number | string | null;
}

interface RackOption {
    id: number;
    code: string;
    name: string | null;
}

interface LocationOption {
    id: number;
    number: number;
    code: string;
    rack: RackOption | null;
}

interface Props {
    products: ProductOption[];
    locations: LocationOption[];
    categories?: {
        id: number;
        name: string;
    }[];
}

interface CurrentStockResponse {
    quantity: number;
}

const props = defineProps<Props>();

const numberFormat = new Intl.NumberFormat('ru-RU', {
    maximumFractionDigits: 3,
});

const form = useForm({
    product_id: '',
    location_id: '',
    // Строка, чтобы не зависеть от модификаторов v-model на компоненте Input
    actual_quantity: '0',
    comment: '',
});

const currentQuantity = ref<number | null>(null);
const loadingQuantity = ref(false);
const quantityError = ref('');

const selectedProduct = computed(() =>
    props.products.find((product) => String(product.id) === form.product_id),
);

const locationText = computed(() => {
    const location = props.locations.find(
        (item) => String(item.id) === String(form.location_id),
    );

    if (!location) return null;

    return [location.rack?.code, location.code].filter(Boolean).join(' · ');
});

const difference = computed<number | null>(() => {
    if (currentQuantity.value === null) {
        return null;
    }

    const value = Number(form.actual_quantity) - currentQuantity.value;

    return Math.round(value * 1000) / 1000;
});

const differenceLabel = computed<string | null>(() => {
    if (difference.value === null) {
        return null;
    }

    const sign = difference.value > 0 ? '+' : '';

    return `${sign}${numberFormat.format(difference.value)} шт.`;
});

const differenceTone = computed<'default' | 'positive' | 'negative'>(() => {
    if (difference.value === null || difference.value === 0) {
        return 'default';
    }

    return difference.value > 0 ? 'positive' : 'negative';
});

// Защита от случайного обнуления остатка
const zeroWarning = computed(() =>
    currentQuantity.value !== null &&
    currentQuantity.value > 0 &&
    Number(form.actual_quantity) === 0
        ? 'Фактическое количество — 0: остаток ячейки будет обнулён.'
        : undefined,
);

let requestController: AbortController | null = null;

watch(
    [() => form.product_id, () => form.location_id],
    async ([productId, locationId]) => {
        requestController?.abort();
        currentQuantity.value = null;
        quantityError.value = '';

        if (!productId || !locationId) {
            loadingQuantity.value = false;
            return;
        }

        const controller = new AbortController();
        requestController = controller;
        loadingQuantity.value = true;

        try {
            const params = new URLSearchParams({
                product_id: productId,
                location_id: String(locationId),
            });

            const response = await fetch(
                `/admin/stock/inventory/current?${params.toString()}`,
                {
                    headers: {
                        Accept: 'application/json',
                    },
                    credentials: 'same-origin',
                    signal: controller.signal,
                },
            );

            if (!response.ok) {
                throw new Error('Не удалось загрузить текущий остаток.');
            }

            const data = (await response.json()) as CurrentStockResponse;

            if (!controller.signal.aborted) {
                currentQuantity.value = data.quantity;
            }
        } catch (error: unknown) {
            if (error instanceof DOMException && error.name === 'AbortError') {
                return;
            }

            quantityError.value =
                error instanceof Error
                    ? error.message
                    : 'Не удалось загрузить текущий остаток.';
        } finally {
            if (!controller.signal.aborted) {
                loadingQuantity.value = false;
            }
        }
    },
);

const submit = (): void => {
    if (currentQuantity.value === null || loadingQuantity.value) {
        return;
    }

    form.transform((data) => ({
        ...data,
        actual_quantity: Number(data.actual_quantity),
    })).post('/admin/stock/inventory', {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Инвентаризация успешно завершена.');
            form.reset();
            currentQuantity.value = null;
        },
        onError: () => {
            toast.error('Не удалось завершить инвентаризацию. Проверьте поля формы.');
        },
    });
};
</script>

<template>
    <Head title="Инвентаризация" />

    <div class="mx-auto max-w-5xl space-y-6">
        <StockPageHeader
            title="Инвентаризация"
            description="Сверка фактического количества товара с учётным остатком"
            back-href="/admin/stock"
            back-label="К остаткам"
            :icon="ClipboardCheck"
        />

        <div class="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_300px]">
            <form
                class="overflow-hidden rounded-2xl border bg-card shadow-sm"
                novalidate
                @submit.prevent="submit"
            >
                <div class="border-b px-5 py-4 sm:px-6">
                    <h2 class="font-semibold">Данные инвентаризации</h2>
                    <p class="mt-0.5 text-sm text-muted-foreground">
                        Заполните обязательные поля формы
                    </p>
                </div>

                <div class="space-y-6 p-5 sm:p-6">
                    <StockField
                        label="Товар"
                        required
                        :error="form.errors.product_id"
                    >
                        <ProductSelect
                            :products="props.products"
                            :categories="categories"
                            :model-value="form.product_id"
                            @update:model-value="
                                form.product_id =
                                    $event !== null ? String($event) : ''
                            "
                        />
                    </StockField>

                    <StockField
                        label="Ячейка хранения"
                        required
                        :error="form.errors.location_id"
                        :warning="
                            props.locations.length === 0
                                ? 'Нет доступных ячеек. Сначала создайте стеллаж и ячейки хранения.'
                                : undefined
                        "
                    >
                        <LocationSelect
                            :locations="locations"
                            :model-value="form.location_id"
                            @update:model-value="form.location_id = $event"
                        />
                    </StockField>

                    <!-- Текущий остаток -->
                    <div class="rounded-xl border bg-muted/40 p-4">
                        <div class="flex items-center justify-between gap-4">
                            <span class="text-sm font-medium">
                                Текущий остаток
                            </span>

                            <span
                                class="flex items-center gap-2 text-lg font-bold tabular-nums"
                            >
                                <template v-if="loadingQuantity">
                                    <LoaderCircle
                                        :size="16"
                                        class="animate-spin text-muted-foreground"
                                    />
                                    <span class="text-sm font-medium text-muted-foreground">
                                        Загрузка…
                                    </span>
                                </template>
                                <template v-else-if="currentQuantity !== null">
                                    {{ numberFormat.format(currentQuantity) }} шт.
                                </template>
                                <template v-else>
                                    <span class="text-muted-foreground/60">—</span>
                                </template>
                            </span>
                        </div>

                        <p
                            v-if="quantityError"
                            role="alert"
                            class="mt-2 flex items-start gap-1.5 text-sm text-destructive"
                        >
                            <Info :size="15" class="mt-0.5 shrink-0" />
                            {{ quantityError }}
                        </p>
                    </div>

                    <StockField
                        label="Фактическое количество"
                        for-id="actual_quantity"
                        required
                        :error="form.errors.actual_quantity"
                        :warning="zeroWarning"
                        hint="Введите количество, которое фактически обнаружено в ячейке."
                    >
                        <Input
                            id="actual_quantity"
                            v-model="form.actual_quantity"
                            type="number"
                            inputmode="numeric"
                            min="0"
                            max="2147483647"
                            step="1"
                            required
                            class="h-11 rounded-xl"
                            :aria-invalid="!!form.errors.actual_quantity"
                            :aria-describedby="
                                form.errors.actual_quantity
                                    ? 'actual_quantity-error'
                                    : undefined
                            "
                        />
                    </StockField>

                    <!-- Расхождение -->
                    <div
                        class="flex items-center justify-between gap-4 rounded-xl border px-4 py-3"
                        :class="{
                            'border-emerald-500/30 bg-emerald-500/10':
                                differenceTone === 'positive',
                            'border-rose-500/30 bg-rose-500/10':
                                differenceTone === 'negative',
                            'bg-muted/40': differenceTone === 'default',
                        }"
                    >
                        <span class="text-sm font-medium">Расхождение</span>

                        <span
                            class="text-lg font-bold tabular-nums"
                            :class="{
                                'text-emerald-700 dark:text-emerald-400':
                                    differenceTone === 'positive',
                                'text-rose-700 dark:text-rose-400':
                                    differenceTone === 'negative',
                                'text-muted-foreground':
                                    differenceTone === 'default',
                            }"
                        >
                            {{
                                difference === 0
                                    ? 'Нет расхождений'
                                    : (differenceLabel ?? '—')
                            }}
                        </span>
                    </div>

                    <CommentField
                        id="comment"
                        v-model="form.comment"
                        required
                        placeholder="Например, плановая проверка остатков"
                        :error="form.errors.comment"
                    />
                </div>

                <div
                    class="flex flex-col-reverse gap-3 border-t bg-muted/30 px-5 py-4 sm:flex-row sm:justify-end sm:px-6"
                >
                    <Button
                        as-child
                        variant="outline"
                        :disabled="form.processing"
                    >
                        <Link href="/admin/stock">Отмена</Link>
                    </Button>

                    <Button
                        type="submit"
                        :disabled="
                            form.processing ||
                            loadingQuantity ||
                            currentQuantity === null ||
                            props.products.length === 0 ||
                            props.locations.length === 0
                        "
                    >
                        <LoaderCircle
                            v-if="form.processing"
                            :size="17"
                            class="mr-2 animate-spin"
                        />
                        <Check v-else :size="17" class="mr-2" />
                        {{
                            form.processing
                                ? 'Сохранение...'
                                : 'Завершить инвентаризацию'
                        }}
                    </Button>
                </div>
            </form>

            <aside class="lg:sticky lg:top-6">
                <OperationSummary
                    :rows="[
                        { label: 'Товар', value: selectedProduct?.name },
                        { label: 'Ячейка', value: locationText },
                        {
                            label: 'Учётный остаток',
                            value:
                                currentQuantity !== null
                                    ? `${numberFormat.format(currentQuantity)} шт.`
                                    : null,
                        },
                        {
                            label: 'Фактический',
                            value: `${numberFormat.format(Number(form.actual_quantity) || 0)} шт.`,
                        },
                        {
                            label: 'Расхождение',
                            value: differenceLabel,
                            tone: differenceTone,
                        },
                    ]"
                    :tips="[
                        'Выберите товар и ячейку — система покажет учётный остаток.',
                        'Расхождение будет скорректировано при сохранении.',
                        'Результат попадёт в журнал складских операций.',
                    ]"
                />
            </aside>
        </div>
    </div>
</template>
