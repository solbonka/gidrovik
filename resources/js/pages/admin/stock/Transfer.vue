<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { computed, watch } from 'vue';
import { toast } from 'vue-sonner';
import { ArrowLeftRight, ArrowRight, Info, LoaderCircle } from '@lucide/vue';
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
    code: string;
    name: string | null;
}

interface LocationOption {
    id: number;
    code: string;
    rack: RackOption;
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
    from_location_id: '',
    to_location_id: '',
    quantity: '1',
    comment: '',
});

const selectedProduct = computed(() =>
    props.products.find((product) => String(product.id) === form.product_id),
);

const locationText = (id: string): string | null => {
    const location = props.locations.find(
        (item) => String(item.id) === String(id),
    );

    if (!location) return null;

    return [location.rack?.code, location.code].filter(Boolean).join(' · ');
};

const sameLocation = computed(
    () =>
        !!form.from_location_id &&
        String(form.from_location_id) === String(form.to_location_id),
);

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
    if (sameLocation.value) return;

    form.post('/admin/stock/transfer', {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Товар успешно перемещён.');
            form.reset();
        },
        onError: () => {
            toast.error('Не удалось переместить товар. Проверьте поля формы.');
        },
    });
};
</script>

<template>
    <Head title="Перемещение товара" />

    <div class="mx-auto max-w-5xl space-y-6">
        <StockPageHeader
            title="Перемещение товара"
            description="Перенос товара из одной ячейки хранения в другую"
            back-href="/admin/stock"
            back-label="К остаткам"
            :icon="ArrowLeftRight"
        />

        <div
            v-if="locations.length < 2"
            class="flex items-start gap-3 rounded-2xl border border-amber-500/30 bg-amber-500/10 p-4 text-sm text-amber-900 dark:text-amber-200"
        >
            <Info :size="18" class="mt-0.5 shrink-0" />
            Для перемещения нужно как минимум две ячейки хранения. Сначала
            создайте недостающие ячейки.
        </div>

        <div class="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_300px]">
            <form
                class="overflow-hidden rounded-2xl border bg-card shadow-sm"
                novalidate
                @submit.prevent="submit"
            >
                <div class="border-b px-5 py-4 sm:px-6">
                    <h2 class="font-semibold">Данные перемещения</h2>
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

                    <div class="grid gap-6 md:grid-cols-2">
                        <StockField
                            label="Откуда переместить"
                            required
                            :error="form.errors.from_location_id"
                        >
                            <LocationSelect
                                :locations="locations"
                                :model-value="form.from_location_id"
                                @update:model-value="
                                    form.from_location_id = $event
                                "
                            />
                        </StockField>

                        <StockField
                            label="Куда переместить"
                            required
                            :error="
                                form.errors.to_location_id ||
                                (sameLocation
                                    ? 'Ячейки отправления и назначения совпадают.'
                                    : undefined)
                            "
                        >
                            <LocationSelect
                                :locations="locations"
                                :model-value="form.to_location_id"
                                @update:model-value="
                                    form.to_location_id = $event
                                "
                            />
                        </StockField>
                    </div>

                    <QuantityField
                        id="quantity"
                        v-model="form.quantity"
                        :unit="selectedProduct?.unit"
                        :error="form.errors.quantity"
                    />

                    <CommentField
                        id="comment"
                        v-model="form.comment"
                        placeholder="Причина перемещения"
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
                            locations.length < 2 ||
                            sameLocation
                        "
                    >
                        <LoaderCircle
                            v-if="form.processing"
                            :size="17"
                            class="mr-2 animate-spin"
                        />
                        <ArrowRight v-else :size="17" class="mr-2" />
                        {{
                            form.processing
                                ? 'Сохранение...'
                                : 'Переместить товар'
                        }}
                    </Button>
                </div>
            </form>

            <aside class="lg:sticky lg:top-6">
                <OperationSummary
                    :rows="[
                        { label: 'Товар', value: selectedProduct?.name },
                        { label: 'Откуда', value: locationText(form.from_location_id) },
                        { label: 'Куда', value: locationText(form.to_location_id) },
                        { label: 'Количество', value: quantityText },
                    ]"
                    :tips="[
                        'Общий остаток товара не изменится — он перейдёт из одной ячейки в другую.',
                        'Нельзя переместить больше, чем лежит в ячейке-источнике.',
                    ]"
                />
            </aside>
        </div>
    </div>
</template>
