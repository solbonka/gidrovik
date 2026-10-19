<script setup lang="ts">
import { computed, reactive, watch } from 'vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import {
    ArrowLeft,
    Check,
    ChevronRight,
    CircleAlert,
    FileText,
    Layers3,
    Package,
    Plug,
    Save,
    Settings2,
    Trash2,
    Warehouse,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { index, update } from '@/routes/admin/products';

defineOptions({
    layout: AdminLayout,
});

interface ProductType {
    id: number;
    category_id: number;
    name: string;
    slug: string;
    is_active: boolean;
}

interface Characteristic {
    id: number;
    name: string;
    slug: string;
    type: 'text' | 'number' | 'select' | 'boolean';
    unit: string | null;
    is_active: boolean;
    pivot?: {
        is_required: boolean;
        sort_order: number;
    };
}

interface Category {
    id: number;
    name: string;
    slug: string;
    is_active: boolean;
    product_types: ProductType[];
    characteristics: Characteristic[];
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

interface Manufacturer {
    id: number;
    name: string;
}

interface Country {
    id: number;
    name: string;
}

interface ProductConnection {
    position: number;
    standard_id: number | null;
    diameter_id: number | null;
    thread_id: number | null;
}

interface Product {
    id: number;
    category_id: number;
    product_type_id: number | null;
    name: string;
    sku: string;
    minimum_stock: number | null;
    angle: number | null;
    description: string | null;
    is_active: boolean;
    unit: string;
    manufacturer_id: number | null;
    country_id: number | null;
    characteristics: Record<string, string>;
    connections: ProductConnection[];
}

interface Props {
    product: Product;
    categories: Category[];
    standards: Standard[];
    diameters: Diameter[];
    threads: Thread[];
    manufacturers: Manufacturer[];
    countries: Country[];
}

interface ConnectionForm {
    position: number;
    standard_id: number | null;
    diameter_id: number | null;
    thread_id: number | null;
}

const props = defineProps<Props>();

const form = useForm({
    category_id: props.product.category_id,
    product_type_id: props.product.product_type_id,
    name: props.product.name,
    sku: props.product.sku,
    minimum_stock: props.product.minimum_stock,
    angle: props.product.angle,
    description: props.product.description ?? '',
    is_active: props.product.is_active,
    unit: props.product.unit ?? 'шт.',
    manufacturer_id: props.product.manufacturer_id,
    country_id: props.product.country_id,
    characteristics: {
        ...props.product.characteristics,
    } as Record<string, string>,
    connections: [
        {
            position: 1,
            standard_id: null,
            diameter_id: null,
            thread_id: null,
        },
        {
            position: 2,
            standard_id: null,
            diameter_id: null,
            thread_id: null,
        },
        {
            position: 3,
            standard_id: null,
            diameter_id: null,
            thread_id: null,
        },
    ] as ConnectionForm[],
});

const selectedCategory = computed<Category | undefined>(() =>
    props.categories.find((category) => category.id === form.category_id),
);

const characteristics = computed<Characteristic[]>(
    () => selectedCategory.value?.characteristics ?? [],
);

const productTypes = computed<ProductType[]>(
    () => selectedCategory.value?.product_types ?? [],
);

const isFitting = computed<boolean>(() => {
    if (!selectedCategory.value) return false;

    const slug = selectedCategory.value.slug.toLowerCase();
    const name = selectedCategory.value.name.toLowerCase();

    return (
        slug.includes('fitting') ||
        slug.includes('фитинг') ||
        slug.includes('фитин') ||
        name.includes('фитинг') ||
        name.includes('фитин')
    );
});

const isAdapter = computed<boolean>(() => {
    if (!selectedCategory.value) return false;

    const slug = selectedCategory.value.slug.toLowerCase();
    const name = selectedCategory.value.name.toLowerCase();

    return (
        slug.includes('adapter') ||
        slug.includes('адаптер') ||
        name.includes('адаптер')
    );
});

const isCoupling = computed<boolean>(() => {
    if (!selectedCategory.value) return false;

    const slug = selectedCategory.value.slug.toLowerCase();
    const name = selectedCategory.value.name.toLowerCase();

    return (
        slug.includes('hose') ||
        slug.includes('coupling') ||
        slug.includes('муфт') ||
        name.includes('муфт')
    );
});

const maxConnections = computed(() => {
    if (isFitting.value) return 1;
    if (isAdapter.value) return 3;
    if (isCoupling.value) return 1;

    return 0;
});

const visibleConnections = reactive<boolean[]>([false, false, false]);

for (const connection of props.product.connections) {
    const connectionIndex = connection.position - 1;

    if (connectionIndex >= 0 && connectionIndex < 3) {
        form.connections[connectionIndex] = {
            position: connection.position,
            standard_id: connection.standard_id,
            diameter_id: connection.diameter_id,
            thread_id: connection.thread_id,
        };

        visibleConnections[connectionIndex] = true;
    }
}

watch(
    () => form.category_id,
    (categoryId, oldCategoryId) => {
        if (categoryId === oldCategoryId || oldCategoryId === undefined) {
            return;
        }

        form.product_type_id = null;
        form.characteristics = {};
    },
);

const activeConnectionsCount = computed(
    () =>
        form.connections.filter(
            (connection) =>
                connection.standard_id ||
                connection.diameter_id ||
                connection.thread_id,
        ).length,
);

const showConnection = (connectionIndex: number): void => {
    if (activeConnectionsCount.value >= maxConnections.value) {
        return;
    }

    visibleConnections[connectionIndex] = true;
};

const hideConnection = (connectionIndex: number): void => {
    form.connections[connectionIndex] = {
        position: connectionIndex + 1,
        standard_id: null,
        diameter_id: null,
        thread_id: null,
    };

    visibleConnections[connectionIndex] = false;
};

const characteristicError = (id: number): string | undefined => {
    const key = `characteristics.${id}` as keyof typeof form.errors;

    return form.errors[key];
};

const submit = (): void => {
    form.put(update(props.product.id).url);
};
</script>

<template>
    <Head :title="`Редактирование: ${product.name}`" />

    <div class="mx-auto max-w-6xl space-y-6 pb-8">
        <!-- Шапка -->
        <header
            class="relative overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-700 dark:bg-gray-900"
        >
            <div
                class="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-indigo-500 via-violet-500 to-indigo-400"
            />

            <div class="p-5 sm:p-7">
                <div
                    class="mb-5 flex flex-wrap items-center gap-2 text-sm text-gray-500 dark:text-gray-400"
                >
                    <Link
                        :href="index().url"
                        class="transition hover:text-indigo-600 dark:hover:text-indigo-400"
                    >
                        Товары
                    </Link>

                    <ChevronRight class="h-4 w-4" />

                    <span class="text-gray-700 dark:text-gray-200">
                        Редактирование
                    </span>
                </div>

                <div
                    class="flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between"
                >
                    <div class="flex min-w-0 items-start gap-4">
                        <div
                            class="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400"
                        >
                            <Package class="h-6 w-6" />
                        </div>

                        <div class="min-w-0">
                            <h1
                                class="text-2xl font-bold tracking-tight text-gray-900 sm:text-3xl dark:text-white"
                            >
                                Редактирование товара
                            </h1>

                            <p
                                class="mt-1 text-sm break-words text-gray-500 dark:text-gray-400"
                            >
                                {{ product.name }}
                            </p>

                            <div class="mt-3 flex flex-wrap items-center gap-2">
                                <span
                                    class="inline-flex items-center gap-1.5 rounded-lg bg-gray-100 px-2.5 py-1 font-mono text-xs font-medium text-gray-600 dark:bg-gray-800 dark:text-gray-300"
                                >
                                    <Package class="h-3.5 w-3.5" />
                                    {{ product.sku }}
                                </span>

                                <span
                                    class="inline-flex items-center gap-1.5 rounded-lg px-2.5 py-1 text-xs font-medium"
                                    :class="
                                        form.is_active
                                            ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400'
                                            : 'bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400'
                                    "
                                >
                                    <span
                                        class="h-1.5 w-1.5 rounded-full"
                                        :class="
                                            form.is_active
                                                ? 'bg-emerald-500'
                                                : 'bg-gray-400'
                                        "
                                    />
                                    {{
                                        form.is_active ? 'Активен' : 'Неактивен'
                                    }}
                                </span>
                            </div>
                        </div>
                    </div>

                    <Link
                        :href="index().url"
                        class="inline-flex shrink-0 items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-gray-700 transition hover:border-gray-300 hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-200 dark:hover:bg-gray-700"
                    >
                        <ArrowLeft class="h-4 w-4" />
                        К списку
                    </Link>
                </div>
            </div>
        </header>

        <form class="space-y-6" @submit.prevent="submit">
            <!-- Основная информация -->
            <section
                class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-700 dark:bg-gray-900"
            >
                <div
                    class="flex items-center gap-3 border-b border-gray-100 px-5 py-4 sm:px-6 dark:border-gray-800"
                >
                    <div
                        class="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400"
                    >
                        <FileText class="h-5 w-5" />
                    </div>

                    <div>
                        <h2 class="font-semibold text-gray-900 dark:text-white">
                            Основная информация
                        </h2>

                        <p
                            class="mt-0.5 text-xs text-gray-500 dark:text-gray-400"
                        >
                            Название, категория и параметры учёта
                        </p>
                    </div>
                </div>

                <div class="grid gap-x-6 gap-y-5 p-5 sm:grid-cols-2 sm:p-6">
                    <div class="sm:col-span-2">
                        <label
                            for="name"
                            class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            Название товара
                            <span class="text-red-500">*</span>
                        </label>

                        <input
                            id="name"
                            v-model="form.name"
                            type="text"
                            autocomplete="off"
                            class="form-input"
                            :class="{ 'form-input-error': form.errors.name }"
                            placeholder="Введите название товара"
                        />

                        <p v-if="form.errors.name" class="field-error">
                            {{ form.errors.name }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="sku"
                            class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            Артикул
                            <span class="text-red-500">*</span>
                        </label>

                        <input
                            id="sku"
                            v-model="form.sku"
                            type="text"
                            autocomplete="off"
                            class="form-input font-mono"
                            :class="{ 'form-input-error': form.errors.sku }"
                            placeholder="Например: FIT-001"
                        />

                        <p v-if="form.errors.sku" class="field-error">
                            {{ form.errors.sku }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="minimum_stock"
                            class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            Минимальный остаток
                        </label>

                        <div class="relative">
                            <input
                                id="minimum_stock"
                                v-model.number="form.minimum_stock"
                                type="number"
                                min="0"
                                step="0.001"
                                class="form-input pr-16"
                                :class="{
                                    'form-input-error':
                                        form.errors.minimum_stock,
                                }"
                                placeholder="Не задан"
                            />

                            <span
                                class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-xs text-gray-400"
                            >
                                {{ form.unit || 'шт.' }}
                            </span>
                        </div>

                        <p
                            class="mt-1.5 text-xs leading-5 text-gray-500 dark:text-gray-400"
                        >
                            Если остаток на всех складах станет ниже указанного
                            значения, товар попадёт в список дефицита. Пустое
                            поле отключает контроль.
                        </p>

                        <p v-if="form.errors.minimum_stock" class="field-error">
                            {{ form.errors.minimum_stock }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="category"
                            class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            Категория
                            <span class="text-red-500">*</span>
                        </label>

                        <select
                            id="category"
                            v-model="form.category_id"
                            class="form-input"
                            :class="{
                                'form-input-error': form.errors.category_id,
                            }"
                        >
                            <option :value="0">Выберите категорию</option>

                            <option
                                v-for="category in categories"
                                :key="category.id"
                                :value="category.id"
                            >
                                {{ category.name }}
                            </option>
                        </select>

                        <p v-if="form.errors.category_id" class="field-error">
                            {{ form.errors.category_id }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="product_type"
                            class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            Тип товара
                        </label>

                        <select
                            id="product_type"
                            v-model="form.product_type_id"
                            class="form-input disabled:cursor-not-allowed disabled:opacity-60"
                            :class="{
                                'form-input-error': form.errors.product_type_id,
                            }"
                            :disabled="!form.category_id"
                        >
                            <option :value="null">Не указан</option>

                            <option
                                v-for="type in productTypes"
                                :key="type.id"
                                :value="type.id"
                            >
                                {{ type.name }}
                            </option>
                        </select>

                        <p
                            v-if="form.errors.product_type_id"
                            class="field-error"
                        >
                            {{ form.errors.product_type_id }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="angle"
                            class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            Угол
                        </label>

                        <select
                            id="angle"
                            v-model="form.angle"
                            class="form-input"
                            :class="{ 'form-input-error': form.errors.angle }"
                        >
                            <option :value="null">Не указан</option>
                            <option :value="45">45°</option>
                            <option :value="90">90°</option>
                        </select>

                        <p v-if="form.errors.angle" class="field-error">
                            {{ form.errors.angle }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="unit"
                            class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            Единица измерения
                        </label>

                        <select
                            id="unit"
                            v-model="form.unit"
                            class="form-input"
                            :class="{ 'form-input-error': form.errors.unit }"
                        >
                            <option value="шт.">шт.</option>
                            <option value="упаковка">упаковка</option>
                            <option value="комплект">комплект</option>
                            <option value="м">м</option>
                            <option value="л">л</option>
                        </select>

                        <p v-if="form.errors.unit" class="field-error">
                            {{ form.errors.unit }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="manufacturer"
                            class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            Производитель
                        </label>

                        <select
                            id="manufacturer"
                            v-model="form.manufacturer_id"
                            class="form-input"
                            :class="{
                                'form-input-error': form.errors.manufacturer_id,
                            }"
                        >
                            <option :value="null">Не выбран</option>

                            <option
                                v-for="manufacturer in manufacturers"
                                :key="manufacturer.id"
                                :value="manufacturer.id"
                            >
                                {{ manufacturer.name }}
                            </option>
                        </select>

                        <p
                            v-if="form.errors.manufacturer_id"
                            class="field-error"
                        >
                            {{ form.errors.manufacturer_id }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="country"
                            class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            Страна производства
                        </label>

                        <select
                            id="country"
                            v-model="form.country_id"
                            class="form-input"
                            :class="{
                                'form-input-error': form.errors.country_id,
                            }"
                        >
                            <option :value="null">Не выбрана</option>

                            <option
                                v-for="country in countries"
                                :key="country.id"
                                :value="country.id"
                            >
                                {{ country.name }}
                            </option>
                        </select>

                        <p v-if="form.errors.country_id" class="field-error">
                            {{ form.errors.country_id }}
                        </p>
                    </div>

                    <div class="sm:col-span-2">
                        <label
                            for="description"
                            class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            Описание
                        </label>

                        <textarea
                            id="description"
                            v-model="form.description"
                            rows="4"
                            class="form-input min-h-28 resize-y"
                            :class="{
                                'form-input-error': form.errors.description,
                            }"
                            placeholder="Дополнительная информация о товаре..."
                        />

                        <p v-if="form.errors.description" class="field-error">
                            {{ form.errors.description }}
                        </p>
                    </div>

                    <div
                        class="rounded-xl border border-gray-200 bg-gray-50/80 p-4 sm:col-span-2 dark:border-gray-700 dark:bg-gray-800/50"
                    >
                        <label class="flex cursor-pointer items-start gap-3">
                            <input
                                v-model="form.is_active"
                                type="checkbox"
                                class="mt-0.5 h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 dark:border-gray-600 dark:bg-gray-800"
                            />

                            <span class="min-w-0">
                                <span
                                    class="block text-sm font-semibold text-gray-800 dark:text-gray-200"
                                >
                                    Товар активен
                                </span>

                                <span
                                    class="mt-1 block text-xs leading-5 text-gray-500 dark:text-gray-400"
                                >
                                    Неактивный товар останется в системе, но не
                                    будет доступен для использования там, где
                                    предусмотрена фильтрация активных товаров.
                                </span>
                            </span>
                        </label>
                    </div>
                </div>
            </section>

            <!-- Характеристики -->
            <section
                class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-700 dark:bg-gray-900"
            >
                <div
                    class="flex items-center gap-3 border-b border-gray-100 px-5 py-4 sm:px-6 dark:border-gray-800"
                >
                    <div
                        class="flex h-10 w-10 items-center justify-center rounded-xl bg-violet-50 text-violet-600 dark:bg-violet-500/10 dark:text-violet-400"
                    >
                        <Settings2 class="h-5 w-5" />
                    </div>

                    <div>
                        <h2 class="font-semibold text-gray-900 dark:text-white">
                            Характеристики
                        </h2>

                        <p
                            class="mt-0.5 text-xs text-gray-500 dark:text-gray-400"
                        >
                            Параметры определяются выбранной категорией
                        </p>
                    </div>
                </div>

                <div
                    v-if="characteristics.length"
                    class="grid gap-x-6 gap-y-5 p-5 sm:grid-cols-2 sm:p-6"
                >
                    <div
                        v-for="characteristic in characteristics"
                        :key="characteristic.id"
                    >
                        <label
                            :for="`characteristic-${characteristic.id}`"
                            class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            {{ characteristic.name }}

                            <span
                                v-if="characteristic.pivot?.is_required"
                                class="text-red-500"
                            >
                                *
                            </span>
                        </label>

                        <template v-if="characteristic.type === 'boolean'">
                            <label
                                :for="`characteristic-${characteristic.id}`"
                                class="flex min-h-11 cursor-pointer items-center gap-3 rounded-xl border border-gray-200 bg-white px-3 dark:border-gray-700 dark:bg-gray-900"
                            >
                                <input
                                    :id="`characteristic-${characteristic.id}`"
                                    v-model="
                                        form.characteristics[characteristic.id]
                                    "
                                    type="checkbox"
                                    :true-value="'1'"
                                    :false-value="'0'"
                                    class="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 dark:border-gray-600 dark:bg-gray-800"
                                />

                                <span
                                    class="text-sm text-gray-700 dark:text-gray-300"
                                >
                                    Да
                                </span>
                            </label>
                        </template>

                        <template v-else-if="characteristic.type === 'number'">
                            <input
                                :id="`characteristic-${characteristic.id}`"
                                v-model="
                                    form.characteristics[characteristic.id]
                                "
                                type="number"
                                step="any"
                                class="form-input"
                                :class="{
                                    'form-input-error': characteristicError(
                                        characteristic.id,
                                    ),
                                }"
                            />
                        </template>

                        <template v-else>
                            <input
                                :id="`characteristic-${characteristic.id}`"
                                v-model="
                                    form.characteristics[characteristic.id]
                                "
                                type="text"
                                class="form-input"
                                :class="{
                                    'form-input-error': characteristicError(
                                        characteristic.id,
                                    ),
                                }"
                            />
                        </template>

                        <p
                            v-if="characteristic.unit"
                            class="mt-1.5 text-xs text-gray-500 dark:text-gray-400"
                        >
                            Единица измерения: {{ characteristic.unit }}
                        </p>

                        <p
                            v-if="characteristicError(characteristic.id)"
                            class="field-error"
                        >
                            {{ characteristicError(characteristic.id) }}
                        </p>
                    </div>
                </div>

                <div v-else class="p-5 sm:p-6">
                    <div
                        class="rounded-xl border border-dashed border-gray-300 px-4 py-8 text-center dark:border-gray-700"
                    >
                        <Layers3 class="mx-auto h-8 w-8 text-gray-400" />

                        <p
                            class="mt-3 text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            Характеристики не настроены
                        </p>

                        <p
                            class="mt-1 text-xs text-gray-500 dark:text-gray-400"
                        >
                            Для выбранной категории нет дополнительных
                            параметров.
                        </p>
                    </div>
                </div>
            </section>

            <!-- Подключения -->
            <section
                v-if="isFitting || isAdapter || isCoupling"
                class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-700 dark:bg-gray-900"
            >
                <div
                    class="flex items-center gap-3 border-b border-gray-100 px-5 py-4 sm:px-6 dark:border-gray-800"
                >
                    <div
                        class="flex h-10 w-10 items-center justify-center rounded-xl bg-amber-50 text-amber-600 dark:bg-amber-500/10 dark:text-amber-400"
                    >
                        <Plug class="h-5 w-5" />
                    </div>

                    <div>
                        <h2 class="font-semibold text-gray-900 dark:text-white">
                            Подключения
                        </h2>

                        <p
                            class="mt-0.5 text-xs text-gray-500 dark:text-gray-400"
                        >
                            {{
                                isFitting
                                    ? 'Одно подключение для фитинга'
                                    : isCoupling
                                      ? 'Укажите диаметр муфты'
                                      : `До ${maxConnections} подключений для адаптера`
                            }}
                        </p>
                    </div>
                </div>

                <div class="space-y-4 p-5 sm:p-6">
                    <div
                        v-for="(
                            connection, connectionIndex
                        ) in form.connections"
                        :key="connection.position"
                        class="overflow-hidden rounded-xl border border-gray-200 transition-colors dark:border-gray-700"
                        :class="
                            visibleConnections[connectionIndex]
                                ? 'bg-white dark:bg-gray-900'
                                : 'bg-gray-50/70 dark:bg-gray-800/40'
                        "
                    >
                        <div
                            class="flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between"
                        >
                            <div class="flex items-center gap-3">
                                <div
                                    class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl text-sm font-bold"
                                    :class="
                                        visibleConnections[connectionIndex]
                                            ? 'bg-indigo-100 text-indigo-700 dark:bg-indigo-500/20 dark:text-indigo-300'
                                            : 'bg-gray-200 text-gray-500 dark:bg-gray-700 dark:text-gray-400'
                                    "
                                >
                                    {{ connection.position }}
                                </div>

                                <div>
                                    <h3
                                        class="text-sm font-semibold text-gray-900 dark:text-white"
                                    >
                                        Подключение {{ connection.position }}
                                    </h3>

                                    <p
                                        class="mt-0.5 text-xs text-gray-500 dark:text-gray-400"
                                    >
                                        <template
                                            v-if="
                                                visibleConnections[
                                                    connectionIndex
                                                ]
                                            "
                                        >
                                            {{
                                                connection.standard_id ||
                                                connection.diameter_id ||
                                                connection.thread_id
                                                    ? 'Параметры заполнены'
                                                    : 'Заполните необходимые параметры'
                                            }}
                                        </template>

                                        <template v-else>
                                            Не добавлено
                                        </template>
                                    </p>
                                </div>
                            </div>

                            <button
                                v-if="!visibleConnections[connectionIndex]"
                                type="button"
                                :disabled="
                                    activeConnectionsCount >= maxConnections
                                "
                                class="inline-flex items-center justify-center gap-2 rounded-lg border border-indigo-200 bg-white px-3.5 py-2 text-sm font-semibold text-indigo-700 transition hover:bg-indigo-50 disabled:cursor-not-allowed disabled:opacity-40 dark:border-indigo-500/30 dark:bg-gray-900 dark:text-indigo-300 dark:hover:bg-indigo-500/10"
                                @click="showConnection(connectionIndex)"
                            >
                                <Plug class="h-4 w-4" />
                                Добавить
                            </button>

                            <button
                                v-else
                                type="button"
                                class="inline-flex items-center justify-center gap-2 rounded-lg px-3 py-2 text-sm font-medium text-red-600 transition hover:bg-red-50 dark:text-red-400 dark:hover:bg-red-500/10"
                                @click="hideConnection(connectionIndex)"
                            >
                                <Trash2 class="h-4 w-4" />
                                Удалить
                            </button>
                        </div>

                        <div
                            v-if="visibleConnections[connectionIndex]"
                            class="grid gap-4 border-t border-gray-100 p-4 dark:border-gray-800"
                            :class="
                                isCoupling
                                    ? 'sm:grid-cols-1'
                                    : 'sm:grid-cols-2 lg:grid-cols-3'
                            "
                        >
                            <div v-if="!isCoupling">
                                <label
                                    :for="`connection-standard-${connectionIndex}`"
                                    class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                                >
                                    Стандарт
                                </label>

                                <select
                                    :id="`connection-standard-${connectionIndex}`"
                                    v-model="connection.standard_id"
                                    class="form-input"
                                >
                                    <option :value="null">Не указан</option>

                                    <option
                                        v-for="standard in standards"
                                        :key="standard.id"
                                        :value="standard.id"
                                    >
                                        {{ standard.code }} —
                                        {{ standard.name }}
                                    </option>
                                </select>
                            </div>

                            <div>
                                <label
                                    :for="`connection-diameter-${connectionIndex}`"
                                    class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                                >
                                    Диаметр
                                </label>

                                <select
                                    :id="`connection-diameter-${connectionIndex}`"
                                    v-model="connection.diameter_id"
                                    class="form-input"
                                >
                                    <option :value="null">Не указан</option>

                                    <option
                                        v-for="diameter in diameters"
                                        :key="diameter.id"
                                        :value="diameter.id"
                                    >
                                        {{ diameter.value }} {{ diameter.unit }}
                                    </option>
                                </select>
                            </div>

                            <div v-if="!isCoupling">
                                <label
                                    :for="`connection-thread-${connectionIndex}`"
                                    class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300"
                                >
                                    Резьба
                                </label>

                                <select
                                    :id="`connection-thread-${connectionIndex}`"
                                    v-model="connection.thread_id"
                                    class="form-input"
                                >
                                    <option :value="null">Не указана</option>

                                    <option
                                        v-for="thread in threads"
                                        :key="thread.id"
                                        :value="thread.id"
                                    >
                                        {{ thread.designation }} —
                                        {{ thread.name }}
                                    </option>
                                </select>
                            </div>

                            <p
                                v-if="
                                    form.errors[
                                        `connections.${connectionIndex}.position`
                                    ]
                                "
                                class="field-error sm:col-span-2 lg:col-span-3"
                            >
                                {{
                                    form.errors[
                                        `connections.${connectionIndex}.position`
                                    ]
                                }}
                            </p>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Ошибки -->
            <div
                v-if="Object.keys(form.errors).length"
                class="flex items-start gap-3 rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-700 dark:border-red-500/30 dark:bg-red-500/10 dark:text-red-300"
            >
                <CircleAlert class="mt-0.5 h-5 w-5 shrink-0" />

                <div>
                    <p class="font-semibold">Не удалось сохранить изменения</p>

                    <p class="mt-1">
                        Проверьте поля с ошибками и повторите попытку.
                    </p>
                </div>
            </div>

            <!-- Кнопки -->
            <div
                class="flex flex-col-reverse gap-3 rounded-2xl border border-gray-200 bg-white p-4 shadow-sm sm:flex-row sm:items-center sm:justify-between sm:px-6 dark:border-gray-700 dark:bg-gray-900"
            >
                <p
                    class="hidden items-center gap-2 text-xs text-gray-500 md:flex dark:text-gray-400"
                >
                    <Warehouse class="h-4 w-4" />
                    Изменения применятся после сохранения формы
                </p>

                <div class="flex flex-col-reverse gap-3 sm:flex-row">
                    <Link
                        :href="index().url"
                        class="inline-flex items-center justify-center rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-semibold text-gray-700 transition hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-200 dark:hover:bg-gray-700"
                    >
                        Отмена
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing"
                        class="inline-flex items-center justify-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:outline-none disabled:cursor-not-allowed disabled:opacity-50 dark:focus:ring-offset-gray-900"
                    >
                        <span
                            v-if="form.processing"
                            class="h-4 w-4 animate-spin rounded-full border-2 border-white/30 border-t-white"
                        />

                        <Save v-else class="h-4 w-4" />

                        {{
                            form.processing
                                ? 'Сохранение...'
                                : 'Сохранить изменения'
                        }}
                    </button>
                </div>
            </div>
        </form>
    </div>
</template>

<style scoped>
.form-input {
    display: block;
    width: 100%;
    min-height: 2.75rem;
    border: 1px solid rgb(209 213 219);
    border-radius: 0.75rem;
    background-color: white;
    padding: 0.625rem 0.875rem;
    font-size: 0.875rem;
    line-height: 1.25rem;
    color: rgb(17 24 39);
    transition:
        border-color 150ms ease,
        box-shadow 150ms ease,
        background-color 150ms ease;
}

.form-input::placeholder {
    color: rgb(156 163 175);
}

.form-input:focus {
    border-color: rgb(99 102 241);
    outline: none;
    box-shadow: 0 0 0 3px rgb(99 102 241 / 12%);
}

.form-input:disabled {
    background-color: rgb(249 250 251);
}

.form-input-error {
    border-color: rgb(239 68 68);
}

.form-input-error:focus {
    border-color: rgb(239 68 68);
    box-shadow: 0 0 0 3px rgb(239 68 68 / 12%);
}

.field-error {
    margin-top: 0.375rem;
    font-size: 0.8125rem;
    line-height: 1.25rem;
    color: rgb(220 38 38);
}

@media (prefers-color-scheme: dark) {
    .form-input {
        border-color: rgb(75 85 99);
        background-color: rgb(17 24 39);
        color: rgb(243 244 246);
    }

    .form-input:focus {
        border-color: rgb(129 140 248);
        box-shadow: 0 0 0 3px rgb(129 140 248 / 15%);
    }

    .form-input:disabled {
        background-color: rgb(31 41 55);
    }

    .field-error {
        color: rgb(248 113 113);
    }
}
</style>
