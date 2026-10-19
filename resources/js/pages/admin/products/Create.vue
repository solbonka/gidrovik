
<script setup lang="ts">
import AdminLayout from '@/layouts/AdminLayout.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import { computed, ref, watch } from 'vue';
import {
    ArrowLeft,
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
import { store } from '@/routes/admin/products';
import { dashboard } from '@/routes/admin';

defineOptions({
    layout: AdminLayout,
});

interface ProductType {
    id: number;
    name: string;
    slug: string;
}

interface Characteristic {
    id: number;
    name: string;
    slug: string;
    type: 'string' | 'integer' | 'decimal' | 'boolean' | 'select';
    unit: string | null;
    pivot: {
        is_required: boolean;
        sort_order: number;
    };
}

interface Category {
    id: number;
    name: string;
    slug: string;
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

interface ConnectionForm {
    position: number;
    standard_id: number | null;
    diameter_id: number | null;
    thread_id: number | null;
}

interface Props {
    categories: Category[];
    standards: Standard[];
    diameters: Diameter[];
    threads: Thread[];
    manufacturers: Manufacturer[];
    countries: Country[];
}

const props = defineProps<Props>();

const loadingCharacteristics = ref<boolean>(false);

const form = useForm({
    category_id: null as number | null,
    product_type_id: null as number | null,
    name: '',
    sku: '',
    minimum_stock: null as number | null,
    angle: null as number | null,
    description: '',
    is_active: true,
    unit: 'шт.' as string,
    manufacturer_id: null as number | null,
    country_id: null as number | null,
    characteristics: {} as Record<number, string>,
    connections: [] as ConnectionForm[],
});

const selectedCategory = computed<Category | null>(() => {
    if (!form.category_id) {
        return null;
    }

    return (
        props.categories.find(
            (category) => category.id === form.category_id,
        ) ?? null
    );
});

const productTypes = computed<ProductType[]>(
    () => selectedCategory.value?.product_types ?? [],
);

const characteristicList = computed<Characteristic[]>(
    () => selectedCategory.value?.characteristics ?? [],
);

const isFitting = computed<boolean>(() => {
    if (!selectedCategory.value) {
        return false;
    }

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
    if (!selectedCategory.value) {
        return false;
    }

    const slug = selectedCategory.value.slug.toLowerCase();
    const name = selectedCategory.value.name.toLowerCase();

    return (
        slug.includes('adapter') ||
        slug.includes('адаптер') ||
        name.includes('адаптер')
    );
});

const isCoupling = computed<boolean>(() => {
    if (!selectedCategory.value) {
        return false;
    }

    const slug = selectedCategory.value.slug.toLowerCase();
    const name = selectedCategory.value.name.toLowerCase();

    return (
        slug.includes('ferrule') ||
        slug.includes('coupling') ||
        slug.includes('муфт') ||
        name.includes('муфт')
    );
});

const isHose = computed<boolean>(() => {
    if (!selectedCategory.value) {
        return false;
    }

    const slug = selectedCategory.value.slug.toLowerCase();
    const name = selectedCategory.value.name.toLowerCase();

    return (
        slug.includes('hose') ||
        slug.includes('rukav') ||
        slug.includes('рукав') ||
        name.includes('рукав')
    );
});

const maxConnections = computed(() => {
    if (isFitting.value) return 1;
    if (isAdapter.value) return 3;
    if (isCoupling.value) return 1;
    if (isHose.value) return 1

    return 0;
});

const resetCharacteristics = (): void => {
    form.characteristics = {};

    for (const characteristic of characteristicList.value) {
        form.characteristics[characteristic.id] = '';
    }
};

const resetConnections = (): void => {
    form.connections = [];
};

const initializeCategoryData = (): void => {
    resetCharacteristics();
    resetConnections();
};

watch(
    () => form.category_id,
    () => {
        form.product_type_id = null;

        if (!form.category_id) {
            form.characteristics = {};
            resetConnections();
            return;
        }

        initializeCategoryData();
    },
);

const characteristicError = (id: number): string | undefined => {
    const key = `characteristics.${id}` as keyof typeof form.errors;

    return form.errors[key];
};

const addConnection = (): void => {
    if (form.connections.length >= maxConnections.value) {
        return;
    }

    form.connections.push({
        position: form.connections.length + 1,
        standard_id: null,
        diameter_id: null,
        thread_id: null,
    });
};

const removeConnection = (index: number): void => {
    form.connections.splice(index, 1);

    form.connections.forEach((connection, connectionIndex) => {
        connection.position = connectionIndex + 1;
    });
};

const submit = (): void => {
    form.post(store.url());
};
</script>

<template>
    <Head title="Новый товар" />

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
                        :href="dashboard.url()"
                        class="transition hover:text-indigo-600 dark:hover:text-indigo-400"
                    >
                        Панель управления
                    </Link>

                    <ChevronRight class="h-4 w-4" />

                    <span class="text-gray-700 dark:text-gray-200">
                        Новый товар
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

                        <div>
                            <h1
                                class="text-2xl font-bold tracking-tight text-gray-900 dark:text-white sm:text-3xl"
                            >
                                Новый товар
                            </h1>

                            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
                                Создание товара с характеристиками и параметрами подключения
                            </p>
                        </div>
                    </div>

                    <Link
                        :href="dashboard.url()"
                        class="inline-flex shrink-0 items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-gray-700 transition hover:border-gray-300 hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-200 dark:hover:bg-gray-700"
                    >
                        <ArrowLeft class="h-4 w-4" />
                        Назад
                    </Link>
                </div>
            </div>
        </header>

        <form class="space-y-6" @submit.prevent="submit">
            <!-- Основная информация -->
            <section class="form-card">
                <div class="form-card-heading">
                    <div
                        class="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400"
                    >
                        <FileText class="h-5 w-5" />
                    </div>

                    <div>
                        <h2 class="form-card-title">
                            Основная информация
                        </h2>

                        <p class="form-card-subtitle">
                            Название, категория и параметры учёта
                        </p>
                    </div>
                </div>

                <div class="grid gap-x-6 gap-y-5 p-5 sm:grid-cols-2 sm:p-6">
                    <div>
                        <label for="category" class="form-label">
                            Категория <span class="text-red-500">*</span>
                        </label>

                        <select
                            id="category"
                            v-model="form.category_id"
                            class="form-input"
                            :class="{ 'form-input-error': form.errors.category_id }"
                        >
                            <option :value="null">
                                Выберите категорию
                            </option>

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
                        <label for="product_type" class="form-label">
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
                            <option :value="null">
                                Выберите тип
                            </option>

                            <option
                                v-for="type in productTypes"
                                :key="type.id"
                                :value="type.id"
                            >
                                {{ type.name }}
                            </option>
                        </select>

                        <p v-if="form.errors.product_type_id" class="field-error">
                            {{ form.errors.product_type_id }}
                        </p>
                    </div>

                    <div class="sm:col-span-2">
                        <label for="name" class="form-label">
                            Название товара <span class="text-red-500">*</span>
                        </label>

                        <input
                            id="name"
                            v-model="form.name"
                            type="text"
                            autocomplete="off"
                            class="form-input"
                            :class="{ 'form-input-error': form.errors.name }"
                            placeholder="Например: Фитинг BSP 90°"
                        />

                        <p v-if="form.errors.name" class="field-error">
                            {{ form.errors.name }}
                        </p>
                    </div>

                    <div>
                        <label for="sku" class="form-label">
                            Артикул <span class="text-red-500">*</span>
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
                        <label for="minimum_stock" class="form-label">
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
                                    'form-input-error': form.errors.minimum_stock,
                                }"
                                placeholder="Не задан"
                            />

                            <span
                                class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-xs text-gray-400"
                            >
                                {{ form.unit }}
                            </span>
                        </div>

                        <p class="mt-1.5 text-xs leading-5 text-gray-500 dark:text-gray-400">
                            При остатке ниже указанного значения товар попадёт
                            в список дефицита. Оставьте поле пустым, чтобы
                            отключить контроль.
                        </p>

                        <p v-if="form.errors.minimum_stock" class="field-error">
                            {{ form.errors.minimum_stock }}
                        </p>
                    </div>

                    <div v-if="isFitting">
                        <label for="angle" class="form-label">
                            Угол
                        </label>

                        <select
                            id="angle"
                            v-model="form.angle"
                            class="form-input"
                            :class="{ 'form-input-error': form.errors.angle }"
                        >
                            <option :value="null">
                                Не указан
                            </option>

                            <option :value="45">45°</option>
                            <option :value="90">90°</option>
                        </select>

                        <p v-if="form.errors.angle" class="field-error">
                            {{ form.errors.angle }}
                        </p>
                    </div>

                    <div>
                        <label for="unit" class="form-label">
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
                        <label for="manufacturer" class="form-label">
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

                        <p v-if="form.errors.manufacturer_id" class="field-error">
                            {{ form.errors.manufacturer_id }}
                        </p>
                    </div>

                    <div>
                        <label for="country" class="form-label">
                            Страна производства
                        </label>

                        <select
                            id="country"
                            v-model="form.country_id"
                            class="form-input"
                            :class="{ 'form-input-error': form.errors.country_id }"
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
                        <label for="description" class="form-label">
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
                            placeholder="Дополнительное описание товара..."
                        />

                        <p v-if="form.errors.description" class="field-error">
                            {{ form.errors.description }}
                        </p>
                    </div>

                    <div
                        class="rounded-xl border border-gray-200 bg-gray-50/80 p-4 dark:border-gray-700 dark:bg-gray-800/50 sm:col-span-2"
                    >
                        <label class="flex cursor-pointer items-start gap-3">
                            <input
                                v-model="form.is_active"
                                type="checkbox"
                                class="mt-0.5 h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 dark:border-gray-600 dark:bg-gray-800"
                            />

                            <span>
                                <span class="block text-sm font-semibold text-gray-800 dark:text-gray-200">
                                    Товар активен
                                </span>

                                <span class="mt-1 block text-xs leading-5 text-gray-500 dark:text-gray-400">
                                    Активный товар будет доступен в тех разделах,
                                    где используются активные товары.
                                </span>
                            </span>
                        </label>
                    </div>
                </div>
            </section>

            <!-- Характеристики -->
            <section
                v-if="form.category_id"
                class="form-card"
            >
                <div class="form-card-heading">
                    <div
                        class="flex h-10 w-10 items-center justify-center rounded-xl bg-violet-50 text-violet-600 dark:bg-violet-500/10 dark:text-violet-400"
                    >
                        <Settings2 class="h-5 w-5" />
                    </div>

                    <div>
                        <h2 class="form-card-title">
                            Характеристики
                        </h2>

                        <p class="form-card-subtitle">
                            Параметры определяются выбранной категорией
                        </p>
                    </div>
                </div>

                <div
                    v-if="characteristicList.length"
                    class="grid gap-x-6 gap-y-5 p-5 sm:grid-cols-2 sm:p-6"
                >
                    <div
                        v-for="characteristic in characteristicList"
                        :key="characteristic.id"
                    >
                        <label
                            :for="`characteristic-${characteristic.id}`"
                            class="form-label"
                        >
                            {{ characteristic.name }}

                            <span
                                v-if="characteristic.pivot.is_required"
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
                                    v-model="form.characteristics[characteristic.id]"
                                    type="checkbox"
                                    :true-value="'1'"
                                    :false-value="'0'"
                                    class="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 dark:border-gray-600 dark:bg-gray-800"
                                />

                                <span class="text-sm text-gray-700 dark:text-gray-300">
                                    Да
                                </span>
                            </label>
                        </template>

                        <template v-else>
                            <input
                                :id="`characteristic-${characteristic.id}`"
                                v-model="form.characteristics[characteristic.id]"
                                :type="
                                    characteristic.type === 'integer' ||
                                    characteristic.type === 'decimal'
                                        ? 'number'
                                        : 'text'
                                "
                                :step="
                                    characteristic.type === 'decimal'
                                        ? 'any'
                                        : undefined
                                "
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
                    <div class="rounded-xl border border-dashed border-gray-300 px-4 py-8 text-center dark:border-gray-700">
                        <Layers3 class="mx-auto h-8 w-8 text-gray-400" />

                        <p class="mt-3 text-sm font-medium text-gray-700 dark:text-gray-300">
                            Характеристики не настроены
                        </p>

                        <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">
                            Для этой категории нет дополнительных параметров.
                        </p>
                    </div>
                </div>
            </section>

            <!-- Подключения -->
            <section
                v-if="isFitting || isAdapter || isCoupling || isHose"
                class="form-card"
            >
                <div class="form-card-heading">
                    <div
                        class="flex h-10 w-10 items-center justify-center rounded-xl bg-amber-50 text-amber-600 dark:bg-amber-500/10 dark:text-amber-400"
                    >
                        <Plug class="h-5 w-5" />
                    </div>

                    <div class="min-w-0 flex-1">
                        <h2 class="form-card-title">
                            Подключения
                        </h2>

                        <p class="form-card-subtitle">
                            {{
                                isFitting
                                    ? 'Одно подключение для фитинга'
                                    : isCoupling
                                        ? 'Укажите диаметр муфты'
                                        : isHose
                                            ? 'Укажите диаметр рукава'
                                            : `До ${maxConnections} подключений для адаптера`
                            }}
                        </p>
                    </div>

                    <button
                        v-if="form.connections.length < maxConnections"
                        type="button"
                        class="inline-flex shrink-0 items-center justify-center gap-2 rounded-xl bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white transition hover:bg-indigo-700"
                        @click="addConnection"
                    >
                        <Plug class="h-4 w-4" />
                        <span class="hidden sm:inline">Добавить</span>
                        <span class="sm:hidden">+</span>
                    </button>
                </div>

                <div class="space-y-4 p-5 sm:p-6">
                    <div
                        v-for="(connection, connectionIndex) in form.connections"
                        :key="connection.position"
                        class="overflow-hidden rounded-xl border border-gray-200 dark:border-gray-700"
                    >
                        <div class="flex items-center justify-between gap-3 bg-gray-50/80 px-4 py-3 dark:bg-gray-800/50">
                            <div class="flex items-center gap-3">
                                <div class="flex h-9 w-9 items-center justify-center rounded-xl bg-indigo-100 text-sm font-bold text-indigo-700 dark:bg-indigo-500/20 dark:text-indigo-300">
                                    {{ connection.position }}
                                </div>

                                <div>
                                    <h3 class="text-sm font-semibold text-gray-900 dark:text-white">
                                        Подключение {{ connection.position }}
                                    </h3>

                                    <p class="mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                                        Укажите необходимые параметры
                                    </p>
                                </div>
                            </div>

                            <button
                                type="button"
                                class="inline-flex items-center gap-1.5 rounded-lg px-2.5 py-2 text-sm font-medium text-red-600 transition hover:bg-red-50 dark:text-red-400 dark:hover:bg-red-500/10"
                                @click="removeConnection(connectionIndex)"
                            >
                                <Trash2 class="h-4 w-4" />
                                <span class="hidden sm:inline">Удалить</span>
                            </button>
                        </div>

                        <div
                            class="grid gap-4 p-4"
                            :class="
                                isCoupling || isHose
                                    ? 'sm:grid-cols-1'
                                    : 'sm:grid-cols-2 lg:grid-cols-3'
                            "
                        >
                            <div v-if="!isCoupling && !isHose">
                                <label
                                    :for="`connection-standard-${connectionIndex}`"
                                    class="form-label"
                                >
                                    Стандарт
                                </label>

                                <select
                                    :id="`connection-standard-${connectionIndex}`"
                                    v-model="connection.standard_id"
                                    class="form-input"
                                    :class="{
                                        'form-input-error':
                                            form.errors[
                                                `connections.${connectionIndex}.standard_id`
                                            ],
                                    }"
                                >
                                    <option :value="null">Не указан</option>

                                    <option
                                        v-for="standard in standards"
                                        :key="standard.id"
                                        :value="standard.id"
                                    >
                                        {{ standard.code }} — {{ standard.name }}
                                    </option>
                                </select>

                                <p
                                    v-if="form.errors[`connections.${connectionIndex}.standard_id`]"
                                    class="field-error"
                                >
                                    {{ form.errors[`connections.${connectionIndex}.standard_id`] }}
                                </p>
                            </div>

                            <div>
                                <label
                                    :for="`connection-diameter-${connectionIndex}`"
                                    class="form-label"
                                >
                                    Диаметр
                                </label>

                                <select
                                    :id="`connection-diameter-${connectionIndex}`"
                                    v-model="connection.diameter_id"
                                    class="form-input"
                                    :class="{
                                        'form-input-error':
                                            form.errors[
                                                `connections.${connectionIndex}.diameter_id`
                                            ],
                                    }"
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

                                <p
                                    v-if="form.errors[`connections.${connectionIndex}.diameter_id`]"
                                    class="field-error"
                                >
                                    {{ form.errors[`connections.${connectionIndex}.diameter_id`] }}
                                </p>
                            </div>

                            <div v-if="!isCoupling && !isHose">
                                <label
                                    :for="`connection-thread-${connectionIndex}`"
                                    class="form-label"
                                >
                                    Резьба
                                </label>

                                <select
                                    :id="`connection-thread-${connectionIndex}`"
                                    v-model="connection.thread_id"
                                    class="form-input"
                                    :class="{
                                        'form-input-error':
                                            form.errors[
                                                `connections.${connectionIndex}.thread_id`
                                            ],
                                    }"
                                >
                                    <option :value="null">Не указана</option>

                                    <option
                                        v-for="thread in threads"
                                        :key="thread.id"
                                        :value="thread.id"
                                    >
                                        {{ thread.designation }} — {{ thread.name }}
                                    </option>
                                </select>

                                <p
                                    v-if="form.errors[`connections.${connectionIndex}.thread_id`]"
                                    class="field-error"
                                >
                                    {{ form.errors[`connections.${connectionIndex}.thread_id`] }}
                                </p>
                            </div>

                            <p
                                v-if="form.errors[`connections.${connectionIndex}.position`]"
                                class="field-error sm:col-span-2 lg:col-span-3"
                            >
                                {{ form.errors[`connections.${connectionIndex}.position`] }}
                            </p>
                        </div>
                    </div>

                    <div
                        v-if="!form.connections.length"
                        class="rounded-xl border border-dashed border-gray-300 px-4 py-8 text-center dark:border-gray-700"
                    >
                        <Plug class="mx-auto h-8 w-8 text-gray-400" />

                        <p class="mt-3 text-sm font-medium text-gray-700 dark:text-gray-300">
                            Подключения не добавлены
                        </p>

                        <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">
                            Добавьте подключение, чтобы указать стандарт, диаметр и резьбу.
                        </p>

                        <button
                            type="button"
                            class="mt-4 rounded-lg border border-indigo-200 px-4 py-2 text-sm font-semibold text-indigo-700 transition hover:bg-indigo-50 dark:border-indigo-500/30 dark:text-indigo-300 dark:hover:bg-indigo-500/10"
                            @click="addConnection"
                        >
                            Добавить подключение
                        </button>
                    </div>
                </div>
            </section>

            <!-- Общие ошибки -->
            <div
                v-if="Object.keys(form.errors).length"
                class="flex items-start gap-3 rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-700 dark:border-red-500/30 dark:bg-red-500/10 dark:text-red-300"
            >
                <CircleAlert class="mt-0.5 h-5 w-5 shrink-0" />

                <div>
                    <p class="font-semibold">
                        Проверьте заполнение формы
                    </p>

                    <p class="mt-1">
                        Некоторые поля содержат ошибки. Исправьте их перед созданием товара.
                    </p>
                </div>
            </div>

            <!-- Кнопки -->
            <div
                class="flex flex-col-reverse gap-3 rounded-2xl border border-gray-200 bg-white p-4 shadow-sm dark:border-gray-700 dark:bg-gray-900 sm:flex-row sm:items-center sm:justify-between sm:px-6"
            >
                <p class="hidden items-center gap-2 text-xs text-gray-500 dark:text-gray-400 md:flex">
                    <Warehouse class="h-4 w-4" />
                    Новый товар появится в каталоге после сохранения
                </p>

                <div class="flex flex-col-reverse gap-3 sm:flex-row">
                    <Link
                        :href="dashboard.url()"
                        class="inline-flex items-center justify-center rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-semibold text-gray-700 transition hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-200 dark:hover:bg-gray-700"
                    >
                        Отмена
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing"
                        class="inline-flex items-center justify-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 dark:focus:ring-offset-gray-900"
                    >
                        <span
                            v-if="form.processing"
                            class="h-4 w-4 animate-spin rounded-full border-2 border-white/30 border-t-white"
                        />

                        <Save v-else class="h-4 w-4" />

                        {{
                            form.processing
                                ? 'Создание...'
                                : 'Создать товар'
                        }}
                    </button>
                </div>
            </div>
        </form>
    </div>
</template>

<style scoped>
.form-card {
    overflow: hidden;
    border: 1px solid rgb(229 231 235);
    border-radius: 1rem;
    background-color: white;
    box-shadow: 0 1px 2px rgb(0 0 0 / 4%);
}

.form-card-heading {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    border-bottom: 1px solid rgb(243 244 246);
    padding: 1rem 1.25rem;
}

.form-card-title {
    font-size: 1rem;
    font-weight: 600;
    color: rgb(17 24 39);
}

.form-card-subtitle {
    margin-top: 0.125rem;
    font-size: 0.75rem;
    color: rgb(107 114 128);
}

.form-label {
    display: block;
    margin-bottom: 0.375rem;
    font-size: 0.875rem;
    font-weight: 500;
    color: rgb(55 65 81);
}

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
    .form-card {
        border-color: rgb(55 65 81);
        background-color: rgb(17 24 39);
    }

    .form-card-heading {
        border-color: rgb(31 41 55);
    }

    .form-card-title {
        color: rgb(249 250 251);
    }

    .form-card-subtitle {
        color: rgb(156 163 175);
    }

    .form-label {
        color: rgb(209 213 219);
    }

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
