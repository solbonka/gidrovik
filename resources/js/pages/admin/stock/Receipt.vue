<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { computed, ref } from 'vue';
import {
    ArrowLeft,
    Check,
    CirclePlus,
    FileText,
    Info,
    LoaderCircle,
    Package,
    Plus,
    Trash2,
} from '@lucide/vue';
import { toast } from 'vue-sonner';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ProductSelect from '@/components/admin/ProductSelect.vue';
import LocationSelect from '@/components/admin/LocationSelect.vue';

defineOptions({
    layout: AdminLayout,
});

interface ProductOption {
    id: number;
    name: string;
    sku: string | null;
    unit: string;
    stock_quantity?: number;
    minimum_stock?: number | null;
    characteristics?: string;
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

const items = ref<ReceiptItem[]>([]);

const selectedProduct = (productId: string) =>
    props.products.find((product) => String(product.id) === productId);

const isIntegerUnit = (productId: string) =>
    ['шт.', 'упаковка', 'комплект'].includes(
        selectedProduct(productId)?.unit ?? '',
    );

const quantityStep = (productId: string) =>
    isIntegerUnit(productId) ? '1' : '0.001';

const quantityMin = (productId: string) =>
    isIntegerUnit(productId) ? '1' : '0.001';

const addItem = (): void => {
    items.value.push({
        product_id: '',
        location_id: '',
        quantity: '1',
        comment: '',
    });
};

const removeItem = (index: number): void => {
    items.value.splice(index, 1);
};

const form = useForm({
    items: [] as ReceiptItem[],
});

const submit = (): void => {
    if (items.value.length === 0) {
        toast.error('Добавьте хотя бы один товар');
        return;
    }

    form.items = items.value;
    form.post('/admin/stock/receipt/batch', {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Поступление товара успешно оформлено.');
            items.value = [];
            addItem();
        },
    });
};

addItem();
</script>

<template>
    <Head title="Приёмка товара" />

    <div class="space-y-6 p-4 sm:p-6">
        <!-- Заголовок -->
        <div
            class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-indigo-950 to-violet-900 p-6 text-white shadow-lg sm:p-8"
        >
            <div
                class="pointer-events-none absolute -top-16 -right-10 h-52 w-52 rounded-full bg-violet-400/20 blur-3xl"
            />

            <div class="relative">
                <Link
                    href="/admin/stock"
                    class="mb-5 inline-flex items-center gap-2 rounded-lg border border-white/20 bg-white/10 px-3 py-2 text-sm text-indigo-100 transition hover:bg-white/20 hover:text-white"
                >
                    <ArrowLeft class="h-4 w-4" />
                    К складу
                </Link>

                <div class="flex items-center gap-4">
                    <div
                        class="hidden rounded-2xl border border-white/15 bg-white/10 p-3 sm:block"
                    >
                        <CirclePlus class="h-8 w-8 text-indigo-200" />
                    </div>

                    <div>
                        <div
                            class="mb-2 flex items-center gap-2 text-sm text-indigo-200"
                        >
                            <Package class="h-4 w-4" />
                            Склад
                        </div>

                        <h1
                            class="text-2xl font-bold tracking-tight sm:text-3xl"
                        >
                            Приёмка товара
                        </h1>

                        <p
                            class="mt-2 max-w-xl text-sm text-slate-300 sm:text-base"
                        >
                            Приёмка нескольких товаров на склад в одном
                            документе.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <form
            class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900"
            @submit.prevent="submit"
        >
            <div
                class="border-b border-slate-200 px-5 py-5 sm:px-7 dark:border-slate-800"
            >
                <div class="flex items-center justify-between gap-3">
                    <div class="flex items-center gap-3">
                        <div
                            class="rounded-xl bg-indigo-50 p-2.5 dark:bg-indigo-500/10"
                        >
                            <FileText
                                class="h-5 w-5 text-indigo-600 dark:text-indigo-400"
                            />
                        </div>

                        <div>
                            <h2
                                class="font-semibold text-slate-900 dark:text-white"
                            >
                                Товары ({{ items.length }})
                            </h2>
                            <p
                                class="mt-1 text-sm text-slate-500 dark:text-slate-400"
                            >
                                Добавьте товары для поступления
                            </p>
                        </div>
                    </div>

                    <button
                        type="button"
                        class="inline-flex items-center justify-center gap-2 rounded-xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 focus-visible:outline-none dark:focus-visible:ring-offset-slate-900"
                        @click="addItem"
                    >
                        <Plus class="h-4 w-4" />
                        Добавить товар
                    </button>
                </div>
            </div>

            <div class="space-y-4 p-5 sm:p-7">
                <div
                    v-if="items.length === 0"
                    class="rounded-2xl border border-dashed border-slate-300 p-8 text-center sm:p-12"
                >
                    <Package class="mx-auto mb-4 h-12 w-12 text-slate-300" />
                    <p class="text-sm text-slate-500">
                        Список товаров пуст. Добавьте первый товар.
                    </p>
                </div>

                <div
                    v-for="(item, index) in items"
                    :key="index"
                    class="rounded-2xl border border-slate-200 bg-slate-50/50 p-4 dark:border-slate-700 dark:bg-slate-900/50"
                >
                    <div class="mb-4 flex items-center justify-between">
                        <span
                            class="text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Товар #{{ index + 1 }}
                        </span>

                        <button
                            type="button"
                            class="inline-flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-500 transition hover:border-rose-200 hover:bg-rose-50 hover:text-rose-600 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-400"
                            @click="removeItem(index)"
                        >
                            <Trash2 class="h-4 w-4" />
                        </button>
                    </div>

                    <div class="grid gap-4 sm:grid-cols-2 sm:gap-6">
                        <div class="sm:col-span-2">
                            <label
                                :for="`product_${index}`"
                                class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                            >
                                Товар
                                <span class="text-rose-500">*</span>
                            </label>

                            <ProductSelect
                                :products="products"
                                :categories="categories"
                                :model-value="item.product_id"
                                :show-stock-quantity="true"
                                @update:model-value="
                                    item.product_id =
                                        $event !== null ? String($event) : ''
                                "
                            />

                            <p
                                v-if="form.errors[`items.${index}.product_id`]"
                                class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                            >
                                <Info class="h-4 w-4 shrink-0" />
                                {{ form.errors[`items.${index}.product_id`] }}
                            </p>
                        </div>

                        <div class="sm:col-span-2">
                            <label
                                :for="`location_${index}`"
                                class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                            >
                                Ячейка назначения
                                <span class="text-rose-500">*</span>
                            </label>

                            <LocationSelect
                                :locations="locations"
                                :model-value="item.location_id"
                                @update:model-value="item.location_id = $event"
                            />

                            <p
                                v-if="form.errors[`items.${index}.location_id`]"
                                class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                            >
                                <Info class="h-4 w-4 shrink-0" />
                                {{ form.errors[`items.${index}.location_id`] }}
                            </p>

                            <p
                                v-if="locations.length === 0"
                                class="mt-2 flex items-center gap-1.5 text-sm text-amber-600 dark:text-amber-400"
                            >
                                <Info class="h-4 w-4 shrink-0" />
                                Нет доступных ячеек. Сначала создайте стеллаж и
                                ячейки хранения.
                            </p>
                        </div>

                        <div>
                            <label
                                :for="`quantity_${index}`"
                                class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                            >
                                Количество
                                <template
                                    v-if="selectedProduct(item.product_id)"
                                >
                                    ({{
                                        selectedProduct(item.product_id).unit
                                    }})
                                </template>
                                <span class="text-rose-500">*</span>
                            </label>

                            <input
                                :id="`quantity_${index}`"
                                v-model="item.quantity"
                                type="number"
                                inputmode="decimal"
                                :min="quantityMin(item.product_id)"
                                max="999999999.999"
                                :step="quantityStep(item.product_id)"
                                required
                                class="w-full rounded-xl border bg-slate-50 px-4 py-3 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                                :class="{
                                    'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500':
                                        form.errors[`items.${index}.quantity`],
                                    'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700':
                                        !form.errors[`items.${index}.quantity`],
                                }"
                            />

                            <p
                                v-if="selectedProduct(item.product_id)"
                                class="mt-2 text-xs text-slate-500 dark:text-slate-400"
                            >
                                <template v-if="isIntegerUnit(item.product_id)">
                                    Для этой единицы измерения допускаются
                                    только целые количества.
                                </template>
                                <template v-else>
                                    Можно указать до трёх знаков после
                                    десятичного разделителя.
                                </template>
                            </p>

                            <p
                                v-if="form.errors[`items.${index}.quantity`]"
                                class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                            >
                                <Info class="h-4 w-4 shrink-0" />
                                {{ form.errors[`items.${index}.quantity`] }}
                            </p>
                        </div>

                        <div>
                            <label
                                :for="`comment_${index}`"
                                class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                            >
                                Комментарий
                            </label>

                            <textarea
                                :id="`comment_${index}`"
                                v-model="item.comment"
                                rows="2"
                                maxlength="5000"
                                placeholder="Например, поступление от поставщика"
                                class="w-full resize-y rounded-xl border bg-slate-50 px-4 py-3 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                                :class="{
                                    'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500':
                                        form.errors[`items.${index}.comment`],
                                    'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700':
                                        !form.errors[`items.${index}.comment`],
                                }"
                            />

                            <p
                                v-if="form.errors[`items.${index}.comment`]"
                                class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                            >
                                <Info class="h-4 w-4 shrink-0" />
                                {{ form.errors[`items.${index}.comment`] }}
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <div
                class="flex flex-col-reverse gap-3 border-t border-slate-200 bg-slate-50/70 px-5 py-4 sm:flex-row sm:justify-end sm:px-7 dark:border-slate-800 dark:bg-slate-950/40"
            >
                <Link
                    href="/admin/stock"
                    class="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-5 py-2.5 text-sm font-semibold text-slate-700 transition hover:bg-slate-100 focus-visible:ring-2 focus-visible:ring-slate-400 focus-visible:outline-none dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                >
                    <ArrowLeft class="h-4 w-4" />
                    Отмена
                </Link>

                <button
                    type="submit"
                    :disabled="
                        form.processing ||
                        items.length === 0 ||
                        locations.length === 0
                    "
                    class="inline-flex items-center justify-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-60 dark:focus-visible:ring-offset-slate-900"
                >
                    <LoaderCircle
                        v-if="form.processing"
                        class="h-4 w-4 animate-spin"
                    />
                    <Check v-else class="h-4 w-4" />

                    {{
                        form.processing
                            ? 'Сохранение...'
                            : 'Оформить поступление'
                    }}
                </button>
            </div>
        </form>
    </div>
</template>
