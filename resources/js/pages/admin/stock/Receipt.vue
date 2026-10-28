<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { computed, ref } from 'vue';
import { toast } from 'vue-sonner';
import {
    Check,
    LoaderCircle,
    Package,
    PackagePlus,
    Plus,
    Trash2,
} from '@lucide/vue';
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

interface ReceiptItem {
    uid: number;
    product_id: string;
    location_id: string;
    quantity: string;
    comment: string;
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

// Уникальный ключ позиции: при удалении из середины состояние селектов не съезжает
let uidCounter = 0;

const newItem = (locationId = ''): ReceiptItem => ({
    uid: ++uidCounter,
    product_id: '',
    location_id: locationId,
    quantity: '1',
    comment: '',
});

const items = ref<ReceiptItem[]>([newItem()]);

const unitFor = (productId: string): string | null =>
    props.products.find((product) => String(product.id) === productId)?.unit ??
    null;

// Новая позиция по умолчанию берёт ячейку предыдущей
const addItem = (): void => {
    const last = items.value[items.value.length - 1];

    items.value.push(newItem(last?.location_id ?? ''));
};

const removeItem = (index: number): void => {
    items.value.splice(index, 1);
};

const completeCount = computed(
    () =>
        items.value.filter(
            (item) =>
                item.product_id &&
                item.location_id &&
                Number(item.quantity) > 0,
        ).length,
);

const form = useForm<{ items: Omit<ReceiptItem, 'uid'>[] }>({
    items: [],
});

const errorFor = (index: number, field: string): string | undefined =>
    (form.errors as Record<string, string | undefined>)[
        `items.${index}.${field}`
        ];

const submit = (): void => {
    if (items.value.length === 0) {
        toast.error('Добавьте хотя бы один товар.');
        return;
    }

    form.transform(() => ({
        items: items.value.map(({ uid: _uid, ...rest }) => rest),
    })).post('/admin/stock/receipt/batch', {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Поступление товара успешно оформлено.');
            items.value = [newItem()];
        },
        onError: () => {
            toast.error('Не удалось оформить поступление. Проверьте поля формы.');
        },
    });
};
</script>

<template>
    <Head title="Приёмка товара" />

    <div class="mx-auto max-w-6xl space-y-6">
        <StockPageHeader
            title="Приёмка товара"
            description="Приёмка нескольких товаров на склад в одном документе"
            back-href="/admin/stock"
            back-label="К остаткам"
            :icon="PackagePlus"
        />

        <form
            class="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_300px]"
            novalidate
            @submit.prevent="submit"
        >
            <div class="overflow-hidden rounded-2xl border bg-card shadow-sm">
                <div
                    class="flex items-center justify-between gap-3 border-b px-5 py-4 sm:px-6"
                >
                    <div>
                        <h2 class="font-semibold">
                            Позиции ({{ items.length }})
                        </h2>
                        <p class="mt-0.5 text-sm text-muted-foreground">
                            Добавьте товары для поступления
                        </p>
                    </div>

                    <Button type="button" variant="outline" @click="addItem">
                        <Plus :size="16" class="mr-2" />
                        Добавить товар
                    </Button>
                </div>

                <div class="space-y-4 p-5 sm:p-6">
                    <div
                        v-if="items.length === 0"
                        class="flex flex-col items-center rounded-2xl border border-dashed px-6 py-12 text-center"
                    >
                        <Package :size="36" class="mb-3 text-muted-foreground" />
                        <p class="text-sm text-muted-foreground">
                            Список товаров пуст. Добавьте первую позицию.
                        </p>
                        <Button
                            type="button"
                            class="mt-4"
                            @click="addItem"
                        >
                            <Plus :size="16" class="mr-2" />
                            Добавить товар
                        </Button>
                    </div>

                    <div
                        v-for="(item, index) in items"
                        :key="item.uid"
                        class="rounded-2xl border bg-muted/30 p-4 sm:p-5"
                    >
                        <div class="mb-4 flex items-center justify-between">
                            <span class="text-sm font-semibold">
                                Позиция {{ index + 1 }}
                            </span>

                            <Button
                                type="button"
                                variant="ghost"
                                size="icon"
                                class="size-8 text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
                                title="Удалить позицию"
                                @click="removeItem(index)"
                            >
                                <Trash2 :size="16" />
                                <span class="sr-only">Удалить позицию</span>
                            </Button>
                        </div>

                        <div class="grid gap-4 sm:grid-cols-2 sm:gap-5">
                            <div class="sm:col-span-2">
                                <StockField
                                    label="Товар"
                                    required
                                    :error="errorFor(index, 'product_id')"
                                >
                                    <ProductSelect
                                        :products="products"
                                        :categories="categories"
                                        :model-value="item.product_id"
                                        :show-stock-quantity="true"
                                        @update:model-value="
                                            item.product_id =
                                                $event !== null
                                                    ? String($event)
                                                    : ''
                                        "
                                    />
                                </StockField>
                            </div>

                            <div class="sm:col-span-2">
                                <StockField
                                    label="Ячейка назначения"
                                    required
                                    :error="errorFor(index, 'location_id')"
                                    :warning="
                                        locations.length === 0
                                            ? 'Нет доступных ячеек. Сначала создайте стеллаж и ячейки хранения.'
                                            : undefined
                                    "
                                >
                                    <LocationSelect
                                        :locations="locations"
                                        :model-value="item.location_id"
                                        @update:model-value="
                                            item.location_id = $event
                                        "
                                    />
                                </StockField>
                            </div>

                            <QuantityField
                                :id="`quantity_${item.uid}`"
                                v-model="item.quantity"
                                :unit="unitFor(item.product_id)"
                                :error="errorFor(index, 'quantity')"
                            />

                            <CommentField
                                :id="`comment_${item.uid}`"
                                v-model="item.comment"
                                :rows="2"
                                placeholder="Например, поступление от поставщика"
                                :error="errorFor(index, 'comment')"
                            />
                        </div>
                    </div>
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
                            items.length === 0 ||
                            locations.length === 0
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
                                : 'Оформить поступление'
                        }}
                    </Button>
                </div>
            </div>

            <aside class="lg:sticky lg:top-6">
                <OperationSummary
                    :rows="[
                        { label: 'Позиций', value: String(items.length) },
                        {
                            label: 'Заполнено',
                            value: `${completeCount} из ${items.length}`,
                            tone:
                                items.length > 0 && completeCount === items.length
                                    ? 'positive'
                                    : 'default',
                        },
                    ]"
                    :tips="[
                        'Для каждой позиции укажите товар, ячейку и количество.',
                        'Новая позиция по умолчанию берёт ячейку предыдущей.',
                        'Все позиции сохраняются одним документом.',
                    ]"
                />
            </aside>
        </form>
    </div>
</template>
