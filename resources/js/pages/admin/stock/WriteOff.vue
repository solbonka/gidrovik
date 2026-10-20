<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { computed, watch } from 'vue';
import { toast } from 'vue-sonner';
import { LoaderCircle, PackageMinus } from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ProductSelect from '@/components/admin/ProductSelect.vue';
import LocationSelect from '@/components/admin/LocationSelect.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import StockField from '@/components/admin/stock/StockField.vue';
import QuantityField from '@/components/admin/stock/QuantityField.vue';
import CommentField from '@/components/admin/stock/CommentField.vue';
import OperationSummary from '@/components/admin/stock/OperationSummary.vue';
import { Button } from '@/components/ui/button';

defineOptions({ layout: AdminLayout });

interface ProductOption {
    id: number;
    name: string;
    sku: string;
    unit: string;
    stock_quantity?: number;
    minimum_stock?: number | null;
    characteristics?: string;
    category_id?: number | string | null;
}

interface LocationOption {
    id: number;
    code: string;
    rack_name: string | null;
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

const numberFormat = new Intl.NumberFormat('ru-RU', {
    maximumFractionDigits: 3,
});

const selectedProduct = computed(() =>
    props.products.find((product) => String(product.id) === form.product_id),
);

const locationText = computed(() => {
    const location = props.locations.find(
        (item) => String(item.id) === String(form.location_id),
    );

    if (!location) return null;

    return [location.rack_name, location.code].filter(Boolean).join(' · ');
});

const quantityText = computed(() => {
    if (!form.quantity) return null;

    return `−${form.quantity} ${selectedProduct.value?.unit ?? ''}`.trim();
});

const totalStockText = computed(() => {
    const product = selectedProduct.value;

    if (!product || product.stock_quantity === undefined) return null;

    return `${numberFormat.format(Number(product.stock_quantity))} ${product.unit}`;
});

// Предупреждаем, если списываем больше общего остатка товара
const overStockWarning = computed(() => {
    const product = selectedProduct.value;

    if (!product || product.stock_quantity === undefined) return undefined;

    return Number(form.quantity) > Number(product.stock_quantity)
        ? `Количество больше общего остатка товара (${totalStockText.value}).`
        : undefined;
});

watch(
    () => form.product_id,
    () => {
        form.clearErrors('quantity');
    },
);

const submit = (): void => {
    form.post('/admin/stock/write-off', {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Списание товара успешно оформлено.');
            form.reset();
        },
        onError: () => {
            toast.error('Не удалось оформить списание. Проверьте поля формы.');
        },
    });
};
</script>

<template>
    <Head title="Списание товара" />

    <div class="mx-auto max-w-5xl space-y-6">
        <StockPageHeader
            title="Списание товара"
            description="Списываемое количество будет вычтено из остатка выбранной ячейки"
            back-href="/admin/stock"
            back-label="К остаткам"
            :icon="PackageMinus"
            tone="danger"
        />

        <div class="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_300px]">
            <form
                class="overflow-hidden rounded-2xl border bg-card shadow-sm"
                novalidate
                @submit.prevent="submit"
            >
                <div class="border-b px-5 py-4 sm:px-6">
                    <h2 class="font-semibold">Данные списания</h2>
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
                        label="Ячейка"
                        required
                        :error="form.errors.location_id"
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
                        :warning="overStockWarning"
                    />

                    <CommentField
                        id="comment"
                        v-model="form.comment"
                        label="Причина списания"
                        required
                        placeholder="Например, брак или повреждение"
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
                        variant="destructive"
                        :disabled="
                            form.processing ||
                            !products.length ||
                            !locations.length
                        "
                    >
                        <LoaderCircle
                            v-if="form.processing"
                            :size="17"
                            class="mr-2 animate-spin"
                        />
                        <PackageMinus v-else :size="17" class="mr-2" />
                        {{
                            form.processing
                                ? 'Сохранение...'
                                : 'Оформить списание'
                        }}
                    </Button>
                </div>
            </form>

            <aside class="lg:sticky lg:top-6">
                <OperationSummary
                    :rows="[
                        { label: 'Товар', value: selectedProduct?.name },
                        { label: 'Ячейка', value: locationText },
                        { label: 'Общий остаток', value: totalStockText },
                        { label: 'Списывается', value: quantityText, tone: 'negative' },
                    ]"
                    :tips="[
                        'Нельзя списать больше, чем лежит в выбранной ячейке.',
                        'Причина списания сохранится в журнале движений.',
                    ]"
                />
            </aside>
        </div>
    </div>
</template>
