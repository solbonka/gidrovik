<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { computed, watch } from 'vue';
import { toast } from 'vue-sonner';
import { Check, LoaderCircle, RotateCcw } from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ProductSelect from '@/components/admin/ProductSelect.vue';
import LocationSelect from '@/components/admin/LocationSelect.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import StockField from '@/components/admin/stock/StockField.vue';
import QuantityField from '@/components/admin/stock/QuantityField.vue';
import CommentField from '@/components/admin/stock/CommentField.vue';
import OperationSummary from '@/components/admin/stock/OperationSummary.vue';
import { Button } from '@/components/ui/button';

defineOptions({
    layout: AdminLayout,
});

interface ProductOption {
    id: number;
    name: string;
    code: string | null;
    article: string | null;
    unit: string;
    stock_quantity?: number;
    minimum_stock?: number | null;
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

const props = defineProps<Props>();

const form = useForm({
    product_id: '',
    location_id: '',
    quantity: '1',
    comment: '',
});

const selectedProduct = computed(() =>
    props.products.find((product) => String(product.id) === form.product_id),
);

const selectedLocation = computed(() =>
    props.locations.find(
        (location) => String(location.id) === String(form.location_id),
    ),
);

const locationText = computed(() => {
    const location = selectedLocation.value;

    if (!location) return null;

    return [location.rack?.code, location.code].filter(Boolean).join(' · ');
});

const quantityText = computed(() => {
    if (!form.quantity) return null;

    return `${form.quantity} ${selectedProduct.value?.unit ?? ''}`.trim();
});

watch(
    () => form.product_id,
    () => {
        form.clearErrors('quantity');
    },
);

const submit = (): void => {
    form.post('/admin/stock/return', {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Возврат товара успешно оформлен.');
            form.reset();
        },
        onError: () => {
            toast.error('Не удалось оформить возврат. Проверьте поля формы.');
        },
    });
};
</script>

<template>
    <Head title="Возврат товара" />

    <div class="mx-auto max-w-5xl space-y-6">
        <StockPageHeader
            title="Возврат товара"
            description="Возврат товара на склад с записью в историю движений"
            back-href="/admin/stock"
            back-label="К остаткам"
            :icon="RotateCcw"
        />

        <div class="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_300px]">
            <form
                class="overflow-hidden rounded-2xl border bg-card shadow-sm"
                novalidate
                @submit.prevent="submit"
            >
                <div class="border-b px-5 py-4 sm:px-6">
                    <h2 class="font-semibold">Данные возврата</h2>
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
                            :products="products"
                            :categories="categories"
                            :model-value="form.product_id"
                            :show-stock-quantity="true"
                            @update:model-value="
                                form.product_id =
                                    $event !== null ? String($event) : ''
                            "
                        />
                    </StockField>

                    <StockField
                        label="Ячейка назначения"
                        required
                        :error="form.errors.location_id"
                        :warning="
                            locations.length === 0
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

                    <QuantityField
                        id="quantity"
                        v-model="form.quantity"
                        :unit="selectedProduct?.unit"
                        :error="form.errors.quantity"
                    />

                    <CommentField
                        id="comment"
                        v-model="form.comment"
                        label="Причина возврата"
                        required
                        :rows="4"
                        placeholder="Например, возврат от покупателя или результат проверки качества"
                        hint="Причина сохранится в журнале складских операций."
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
                            products.length === 0 ||
                            locations.length === 0
                        "
                    >
                        <LoaderCircle
                            v-if="form.processing"
                            :size="17"
                            class="mr-2 animate-spin"
                        />
                        <Check v-else :size="17" class="mr-2" />
                        {{ form.processing ? 'Сохранение...' : 'Оформить возврат' }}
                    </Button>
                </div>
            </form>

            <aside class="lg:sticky lg:top-6">
                <OperationSummary
                    :rows="[
                        { label: 'Товар', value: selectedProduct?.name },
                        { label: 'Ячейка', value: locationText },
                        { label: 'Количество', value: quantityText, tone: 'positive' },
                    ]"
                    :tips="[
                        'Возвращённое количество добавится к остатку выбранной ячейки.',
                        'Укажите причину — она попадёт в журнал движений.',
                    ]"
                />
            </aside>
        </div>
    </div>
</template>
