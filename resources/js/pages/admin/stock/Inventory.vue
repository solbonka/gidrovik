<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import {
    ArrowLeft,
    Check,
    CirclePlus,
    FileText,
    Info,
    LoaderCircle,
    Package,
    Search,
    ShieldCheck,
    Save,
    ToggleRight,
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

const form = useForm({
    product_id: '',
    location_id: '',
    actual_quantity: 0,
    comment: '',
});

const currentQuantity = ref<number | null>(null);
const loadingQuantity = ref(false);
const quantityError = ref('');

const difference = computed<number | null>(() => {
    if (currentQuantity.value === null) {
        return null;
    }

    return form.actual_quantity - currentQuantity.value;
});

const differenceLabel = computed<string>(() => {
    if (difference.value === null) {
        return '—';
    }

    if (difference.value > 0) {
        return `+${difference.value} шт.`;
    }

    return `${difference.value} шт.`;
});

const differenceClass = computed<string>(() => {
    if (difference.value === null || difference.value === 0) {
        return 'text-slate-600 dark:text-slate-400';
    }

    return difference.value > 0
        ? 'text-emerald-600 dark:text-emerald-400'
        : 'text-rose-600 dark:text-rose-400';
});

let requestController: AbortController | null = null;

watch(
    [() => form.product_id, () => form.location_id],
    async ([productId, locationId]) => {
        requestController?.abort();
        currentQuantity.value = null;
        quantityError.value = '';

        if (!productId || !locationId) {
            return;
        }

        const controller = new AbortController();
        requestController = controller;
        loadingQuantity.value = true;

        try {
            const params = new URLSearchParams({
                product_id: productId,
                location_id: locationId,
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

    form.post('/admin/stock/inventory', {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Инвентаризация успешно завершена.');
            form.reset();
            currentQuantity.value = null;
        },
    });
};
</script>

<template>
    <Head title="Инвентаризация" />

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
                    href="/admin/stock/movements"
                    class="mb-5 inline-flex items-center gap-2 rounded-lg border border-white/20 bg-white/10 px-3 py-2 text-sm text-indigo-100 transition hover:bg-white/20 hover:text-white"
                >
                    <ArrowLeft class="h-4 w-4" />
                    К журналу складских операций
                </Link>

                <div class="flex items-center gap-4">
                    <div
                        class="hidden rounded-2xl border border-white/15 bg-white/10 p-3 sm:block"
                    >
                        <FileText class="h-8 w-8 text-indigo-200" />
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
                            Инвентаризация
                        </h1>

                        <p
                            class="mt-2 max-w-xl text-sm text-slate-300 sm:text-base"
                        >
                            Сверка фактического количества товара с учётным
                            остатком.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <div
            class="grid grid-cols-1 items-start gap-6 xl:grid-cols-[minmax(0,1fr)_300px]"
        >
            <!-- Форма -->
            <form
                class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900"
                @submit.prevent="submit"
            >
                <div
                    class="border-b border-slate-200 px-5 py-5 sm:px-7 dark:border-slate-800"
                >
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
                                Данные инвентаризации
                            </h2>
                            <p
                                class="mt-1 text-sm text-slate-500 dark:text-slate-400"
                            >
                                Заполните обязательные поля формы.
                            </p>
                        </div>
                    </div>
                </div>

                <div class="space-y-6 p-5 sm:p-7">
                    <div>
                        <label
                            for="product_id"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Товар
                            <span class="text-rose-500">*</span>
                        </label>

                        <ProductSelect
                            :products="props.products"
                            :categories="categories"
                            :model-value="form.product_id"
                            @update:model-value="
                                form.product_id =
                                    $event !== null ? String($event) : ''
                            "
                        />

                        <p
                            v-if="form.errors.product_id"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.product_id }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="location_id"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Ячейка хранения
                            <span class="text-rose-500">*</span>
                        </label>

                        <LocationSelect
                            :locations="locations"
                            :model-value="form.location_id"
                            @update:model-value="form.location_id = $event"
                        />

                        <p
                            v-if="form.errors.location_id"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.location_id }}
                        </p>

                        <p
                            v-if="props.locations.length === 0"
                            class="mt-2 flex items-center gap-1.5 text-sm text-amber-600 dark:text-amber-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            Нет доступных ячеек. Сначала создайте стеллаж и
                            ячейки хранения.
                        </p>
                    </div>

                    <div
                        class="rounded-xl border border-slate-200 bg-slate-50/70 p-4 dark:border-slate-700 dark:bg-slate-950/50"
                    >
                        <div class="flex items-center justify-between gap-4">
                            <span
                                class="text-sm font-semibold text-slate-700 dark:text-slate-200"
                            >
                                Текущий остаток
                            </span>

                            <span
                                class="text-base font-semibold text-slate-900 sm:text-lg dark:text-white"
                            >
                                <template v-if="loadingQuantity">
                                    Загрузка…
                                </template>
                                <template v-else-if="currentQuantity !== null">
                                    {{ currentQuantity }} шт.
                                </template>
                                <template v-else> — </template>
                            </span>
                        </div>

                        <p
                            v-if="quantityError"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ quantityError }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="actual_quantity"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Фактическое количество
                            <span class="text-rose-500">*</span>
                        </label>

                        <input
                            id="actual_quantity"
                            v-model.number="form.actual_quantity"
                            type="number"
                            min="0"
                            max="2147483647"
                            step="1"
                            required
                            class="w-full rounded-xl border bg-slate-50 px-4 py-3 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                            :class="{
                                'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500':
                                    form.errors.actual_quantity,
                                'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700':
                                    !form.errors.actual_quantity,
                            }"
                        />

                        <p
                            v-if="form.errors.actual_quantity"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.actual_quantity }}
                        </p>

                        <p
                            v-else
                            class="mt-2 text-xs text-slate-500 dark:text-slate-400"
                        >
                            Введите количество, которое фактически обнаружено в
                            ячейке.
                        </p>
                    </div>

                    <div
                        class="flex items-center justify-between gap-4 rounded-xl border border-slate-200 bg-slate-50/70 px-4 py-3 dark:border-slate-700 dark:bg-slate-950/50"
                    >
                        <span
                            class="text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Расхождение
                        </span>

                        <span
                            class="text-base font-semibold"
                            :class="differenceClass"
                        >
                            {{ differenceLabel }}
                        </span>
                    </div>

                    <div>
                        <label
                            for="comment"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Комментарий
                            <span class="text-rose-500">*</span>
                        </label>

                        <textarea
                            id="comment"
                            v-model="form.comment"
                            rows="3"
                            maxlength="5000"
                            required
                            placeholder="Например, плановая проверка остатков"
                            class="w-full resize-y rounded-xl border bg-slate-50 px-4 py-3 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                            :class="{
                                'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500':
                                    form.errors.comment,
                                'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700':
                                    !form.errors.comment,
                            }"
                        />

                        <p
                            v-if="form.errors.comment"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.comment }}
                        </p>
                    </div>
                </div>

                <div
                    class="flex flex-col-reverse gap-3 border-t border-slate-200 bg-slate-50/70 px-5 py-4 sm:flex-row sm:justify-end sm:px-7 dark:border-slate-800 dark:bg-slate-950/40"
                >
                    <Link
                        href="/admin/stock/movements"
                        class="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-5 py-2.5 text-sm font-semibold text-slate-700 transition hover:bg-slate-100 focus-visible:ring-2 focus-visible:ring-slate-400 focus-visible:outline-none dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                    >
                        <ArrowLeft class="h-4 w-4" />
                        Отмена
                    </Link>

                    <button
                        type="submit"
                        :disabled="
                            form.processing ||
                            loadingQuantity ||
                            currentQuantity === null ||
                            props.products.length === 0 ||
                            props.locations.length === 0
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
                                : 'Завершить инвентаризацию'
                        }}
                    </button>
                </div>
            </form>

            <aside class="space-y-4">
                <div
                    class="rounded-2xl border border-indigo-100 bg-indigo-50/70 p-5 dark:border-indigo-500/20 dark:bg-indigo-500/5"
                >
                    <div class="flex items-center gap-2">
                        <div
                            class="rounded-lg bg-indigo-100 p-2 dark:bg-indigo-500/15"
                        >
                            <Info
                                class="h-5 w-5 text-indigo-600 dark:text-indigo-400"
                            />
                        </div>

                        <h3
                            class="font-semibold text-slate-900 dark:text-white"
                        >
                            Полезно знать
                        </h3>
                    </div>

                    <ul
                        class="mt-4 space-y-4 text-sm text-slate-600 dark:text-slate-300"
                    >
                        <li class="flex items-start gap-2.5">
                            <Check
                                class="mt-0.5 h-4 w-4 shrink-0 text-indigo-600 dark:text-indigo-400"
                            />
                            <span>
                                Выберите товар и ячейку для проверки остатка.
                            </span>
                        </li>

                        <li class="flex items-start gap-2.5">
                            <Check
                                class="mt-0.5 h-4 w-4 shrink-0 text-indigo-600 dark:text-indigo-400"
                            />
                            <span>
                                Система автоматически покажет текущий учётный
                                остаток.
                            </span>
                        </li>

                        <li class="flex items-start gap-2.5">
                            <Check
                                class="mt-0.5 h-4 w-4 shrink-0 text-indigo-600 dark:text-indigo-400"
                            />
                            <span>
                                Расхождение будет скорректировано при
                                сохранении.
                            </span>
                        </li>
                    </ul>
                </div>
            </aside>
        </div>
    </div>
</template>
