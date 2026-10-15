<script setup lang="ts">
import { computed, reactive, watch } from 'vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
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
    minimum_stock: number | null
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

const props = defineProps<Props>();

interface ConnectionForm {
    position: number;
    standard_id: number | null;
    diameter_id: number | null;
    thread_id: number | null;
}

const selectedCategory = computed<Category | undefined>(() => {
    return props.categories.find(
        (category) => category.id === form.category_id,
    );
});

const characteristics = computed<Characteristic[]>(() => {
    return selectedCategory.value?.characteristics ?? [];
});

const productTypes = computed<ProductType[]>(() => {
    return selectedCategory.value?.product_types ?? [];
});

const isFitting = computed<boolean>(() => {
    if (!selectedCategory.value) {
        return false
    }

    const slug = selectedCategory.value.slug.toLowerCase()
    const name = selectedCategory.value.name.toLowerCase()

    return (
        slug.includes('fitting') ||
        slug.includes('фитинг') ||
        slug.includes('фитин') ||
        name.includes('фитинг') ||
        name.includes('фитин')
    )
})

const isAdapter = computed<boolean>(() => {
    if (!selectedCategory.value) {
        return false
    }

    const slug = selectedCategory.value.slug.toLowerCase()
    const name = selectedCategory.value.name.toLowerCase()

    return (
        slug.includes('adapter') ||
        slug.includes('адаптер') ||
        name.includes('адаптер')
    )
})

const isCoupling = computed<boolean>(() => {
    if (!selectedCategory.value) {
        return false
    }

    const slug = selectedCategory.value.slug.toLowerCase()
    const name = selectedCategory.value.name.toLowerCase()

    return (
        slug.includes('hose') ||
        slug.includes('coupling') ||
        slug.includes('муфт') ||
        name.includes('муфт')
    )
})

const maxConnections = computed(() => {
    if (isFitting.value) return 1
    if (isAdapter.value) return 3
    if (isCoupling.value) return 1
    return 0
})

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

const visibleConnections = reactive<boolean[]>([
    false,
    false,
    false,
]);

for (const connection of props.product.connections) {
    const index = connection.position - 1;

    if (index >= 0 && index < 3) {
        form.connections[index] = {
            position: connection.position,
            standard_id: connection.standard_id,
            diameter_id: connection.diameter_id,
            thread_id: connection.thread_id,
        };

        visibleConnections[index] = true;
    }
}

watch(
    () => form.category_id,
    (categoryId, oldCategoryId) => {
        if (
            categoryId === oldCategoryId ||
            oldCategoryId === undefined
        ) {
            return;
        }

        form.product_type_id = null;
        form.characteristics = {};
    },
);

const showConnection = (index: number): void => {
    if (form.connections.filter(c => c.standard_id || c.diameter_id || c.thread_id).length >= maxConnections.value) {
        return
    }
    visibleConnections[index] = true;
};

const hideConnection = (index: number): void => {
    form.connections[index] = {
        position: index + 1,
        standard_id: null,
        diameter_id: null,
        thread_id: null,
    };

    visibleConnections[index] = false;
};

const characteristicError = (
    id: number,
): string | undefined => {
    const key = `characteristics.${id}` as keyof typeof form.errors;

    return form.errors[key];
};

const submit = (): void => {
    form.put(update(props.product.id).url)
};
</script>

<template>
    <Head :title="`Редактирование: ${product.name}`" />

    <div class="mx-auto max-w-6xl space-y-6">
        <div
            class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between"
        >
            <div>
                <div class="mb-2 text-sm text-gray-500">
                    <Link
                        :href="index().url"
                        class="hover:text-gray-900"
                    >
                        Товары
                    </Link>

                    <span class="mx-2">/</span>

                    <span>Редактирование</span>
                </div>

                <h1 class="text-2xl font-semibold text-gray-900">
                    Редактирование товара
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    {{ product.name }}
                </p>
            </div>

            <Link
                :href="index().url"
                class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
                Назад
            </Link>
        </div>

        <form
            class="space-y-6"
            @submit.prevent="submit"
        >
            <!-- Основная информация -->
            <section
                class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            >
                <h2 class="text-lg font-semibold text-gray-900">
                    Основная информация
                </h2>

                <div class="mt-6 grid gap-5 md:grid-cols-2">
                    <div class="md:col-span-2">
                        <label
                            for="name"
                            class="mb-1 block text-sm font-medium text-gray-700"
                        >
                            Название
                        </label>

                        <input
                            id="name"
                            v-model="form.name"
                            type="text"
                            class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                        />

                        <p
                            v-if="form.errors.name"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.name }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="sku"
                            class="mb-1 block text-sm font-medium text-gray-700"
                        >
                            Артикул
                        </label>

                        <input
                            id="sku"
                            v-model="form.sku"
                            type="text"
                            class="w-full rounded-lg border border-gray-300 px-3 py-2 font-mono text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                        />

                        <p
                            v-if="form.errors.sku"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.sku }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="minimum_stock"
                            class="mb-1 block text-sm font-medium text-gray-700"
                        >
                            Минимальный остаток
                        </label>

                        <input
                            id="minimum_stock"
                            v-model.number="form.minimum_stock"
                            type="number"
                            min="0"
                            step="0.001"
                            class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                            placeholder="Например: 10"
                        />

                        <p class="mt-1 text-xs text-gray-500">
                            Оставьте пустым, если контроль минимального остатка не нужен.
                        </p>

                        <p
                            v-if="form.errors.minimum_stock"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.minimum_stock }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="angle"
                            class="mb-1 block text-sm font-medium text-gray-700"
                        >
                            Угол
                        </label>

                        <select
                            id="angle"
                            v-model="form.angle"
                            class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                        >
                            <option :value="null">
                                Не указан
                            </option>

                            <option :value="45">
                                45°
                            </option>

                            <option :value="90">
                                90°
                            </option>
                        </select>

                        <p
                            v-if="form.errors.angle"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.angle }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="category"
                            class="mb-1 block text-sm font-medium text-gray-700"
                        >
                            Категория
                        </label>

                        <select
                            id="category"
                            v-model="form.category_id"
                            class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                        >
                            <option :value="0">
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

                        <p
                            v-if="form.errors.category_id"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.category_id }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="product_type"
                            class="mb-1 block text-sm font-medium text-gray-700"
                        >
                            Тип товара
                        </label>

                        <select
                            id="product_type"
                            v-model="form.product_type_id"
                            class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                            :disabled="!form.category_id"
                        >
                            <option :value="null">
                                Не указан
                            </option>

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
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.product_type_id }}
                        </p>
                    </div>

                    <div class="md:col-span-2">
                        <label
                            for="description"
                            class="mb-1 block text-sm font-medium text-gray-700"
                        >
                            Описание
                        </label>

                        <textarea
                            id="description"
                            v-model="form.description"
                            rows="4"
                            class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                        />

                        <p
                            v-if="form.errors.description"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.description }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="unit"
                            class="mb-1 block text-sm font-medium text-gray-700"
                        >
                            Единица измерения
                        </label>

                        <select
                            id="unit"
                            v-model="form.unit"
                            class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                        >
                            <option value="шт.">шт.</option>
                            <option value="упаковка">упаковка</option>
                            <option value="комплект">комплект</option>
                            <option value="м">м</option>
                            <option value="л">л</option>
                        </select>

                        <p
                            v-if="form.errors.unit"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.unit }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="manufacturer"
                            class="mb-1 block text-sm font-medium text-gray-700"
                        >
                            Производитель
                        </label>

                        <select
                            id="manufacturer"
                            v-model="form.manufacturer_id"
                            class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                        >
                            <option :value="null">
                                Не выбран
                            </option>

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
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.manufacturer_id }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="country"
                            class="mb-1 block text-sm font-medium text-gray-700"
                        >
                            Страна
                        </label>

                        <select
                            id="country"
                            v-model="form.country_id"
                            class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                        >
                            <option :value="null">
                                Не выбрана
                            </option>

                            <option
                                v-for="country in countries"
                                :key="country.id"
                                :value="country.id"
                            >
                                {{ country.name }}
                            </option>
                        </select>

                        <p
                            v-if="form.errors.country_id"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.country_id }}
                        </p>
                    </div>

                    <div class="md:col-span-2">
                        <label class="flex cursor-pointer items-center gap-3">
                            <input
                                v-model="form.is_active"
                                type="checkbox"
                                class="h-4 w-4 rounded border-gray-300"
                            />

                            <span class="text-sm font-medium text-gray-700">
                                Товар активен
                            </span>
                        </label>

                        <p class="mt-1 text-xs text-gray-500">
                            Неактивные товары не будут использоваться как
                            доступные товары в дальнейшем.
                        </p>
                    </div>
                </div>
            </section>

            <!-- Характеристики -->
            <section
                class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            >
                <div>
                    <h2 class="text-lg font-semibold text-gray-900">
                        Характеристики
                    </h2>

                    <p class="mt-1 text-sm text-gray-500">
                        Характеристики зависят от выбранной категории.
                    </p>
                </div>

                <div
                    v-if="characteristics.length"
                    class="mt-6 grid gap-5 md:grid-cols-2"
                >
                    <div
                        v-for="characteristic in characteristics"
                        :key="characteristic.id"
                    >
                        <label
                            :for="`characteristic-${characteristic.id}`"
                            class="mb-1 block text-sm font-medium text-gray-700"
                        >
                            {{ characteristic.name }}

                            <span
                                v-if="characteristic.pivot?.is_required"
                                class="text-red-500"
                            >
                                *
                            </span>
                        </label>

                        <template
                            v-if="characteristic.type === 'boolean'"
                        >
                            <label
                                class="flex items-center gap-3 rounded-lg border border-gray-300 px-3 py-2"
                            >
                                <input
                                    v-model="
                                        form.characteristics[
                                            characteristic.id
                                        ]
                                    "
                                    type="checkbox"
                                    :true-value="'1'"
                                    :false-value="'0'"
                                    class="h-4 w-4 rounded border-gray-300"
                                />

                                <span class="text-sm text-gray-700">
                                    Да
                                </span>
                            </label>
                        </template>

                        <template
                            v-else-if="characteristic.type === 'number'"
                        >
                            <input
                                :id="`characteristic-${characteristic.id}`"
                                v-model="
                                    form.characteristics[
                                        characteristic.id
                                    ]
                                "
                                type="number"
                                step="any"
                                class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                            />
                        </template>

                        <template v-else>
                            <input
                                :id="`characteristic-${characteristic.id}`"
                                v-model="
                                    form.characteristics[
                                        characteristic.id
                                    ]
                                "
                                type="text"
                                class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                            />
                        </template>

                        <p
                            v-if="characteristic.unit"
                            class="mt-1 text-xs text-gray-500"
                        >
                            Единица измерения: {{ characteristic.unit }}
                        </p>

                        <p
                            v-if="characteristicError(characteristic.id)"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ characteristicError(characteristic.id) }}
                        </p>
                    </div>
                </div>

                <div
                    v-else
                    class="mt-6 rounded-lg bg-gray-50 px-4 py-6 text-center text-sm text-gray-500"
                >
                    Для выбранной категории характеристики не настроены.
                </div>
            </section>

            <!-- Подключения -->
            <section
                v-if="isFitting || isAdapter || isCoupling"
                class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            >
                <div>
                    <h2 class="text-lg font-semibold text-gray-900">
                        Подключения
                    </h2>

                    <p class="mt-1 text-sm text-gray-500">
                        {{
                            isFitting
                                ? 'Одно подключение для фитинга.'
                                : isCoupling
                                  ? 'Укажите диаметр муфты.'
                                  : `До ${maxConnections} подключений для адаптера.`
                        }}
                    </p>
                </div>

                <div class="mt-6 space-y-4">
                    <div
                        v-for="(connection, index) in form.connections"
                        :key="connection.position"
                        class="rounded-lg border border-gray-200 p-4"
                    >
                        <div
                            class="flex items-center justify-between gap-4"
                        >
                            <div>
                                <div
                                    class="text-sm font-semibold text-gray-900"
                                >
                                    Подключение {{ connection.position }}
                                </div>

                                <div
                                    v-if="visibleConnections[index]"
                                    class="mt-1 text-xs text-gray-500"
                                >
                                    {{
                                        connection.standard_id ||
                                        connection.diameter_id ||
                                        connection.thread_id
                                            ? 'Параметры указаны'
                                            : 'Параметры не указаны'
                                    }}
                                </div>
                            </div>

                            <button
                                v-if="!visibleConnections[index]"
                                type="button"
                                class="rounded-lg border border-gray-300 px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
                                @click="showConnection(index)"
                            >
                                Добавить
                            </button>

                            <button
                                v-else
                                type="button"
                                class="text-sm font-medium text-red-600 hover:text-red-700"
                                @click="hideConnection(index)"
                            >
                                Удалить
                            </button>
                        </div>

                        <div
                            v-if="visibleConnections[index]"
                            class="mt-4 grid gap-4"
                            :class="
                                isCoupling
                                    ? 'md:grid-cols-1'
                                    : 'md:grid-cols-3'
                            "
                        >
                            <div v-if="!isCoupling">
                                <label
                                    class="mb-1 block text-sm font-medium text-gray-700"
                                >
                                    Стандарт
                                </label>

                                <select
                                    v-model="connection.standard_id"
                                    class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                                >
                                    <option :value="null">
                                        Не указан
                                    </option>

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
                                    class="mb-1 block text-sm font-medium text-gray-700"
                                >
                                    Диаметр
                                </label>

                                <select
                                    v-model="connection.diameter_id"
                                    class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                                >
                                    <option :value="null">
                                        Не указан
                                    </option>

                                    <option
                                        v-for="diameter in diameters"
                                        :key="diameter.id"
                                        :value="diameter.id"
                                    >
                                        {{ diameter.value }}
                                        {{ diameter.unit }}
                                    </option>
                                </select>
                            </div>

                            <div v-if="!isCoupling">
                                <label
                                    class="mb-1 block text-sm font-medium text-gray-700"
                                >
                                    Резьба
                                </label>

                                <select
                                    v-model="connection.thread_id"
                                    class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                                >
                                    <option :value="null">
                                        Не указана
                                    </option>

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
                        </div>

                        <div
                            v-if="form.errors[`connections.${index}.position`]"
                            class="mt-2 text-sm text-red-600"
                        >
                            {{
                                form.errors[
                                    `connections.${index}.position`
                                    ]
                            }}
                        </div>
                    </div>
                </div>
            </section>

            <!-- Ошибки -->
            <div
                v-if="Object.keys(form.errors).length"
                class="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700"
            >
                Проверьте заполнение формы. Некоторые поля содержат ошибки.
            </div>

            <!-- Кнопки -->
            <div
                class="flex flex-col-reverse gap-3 sm:flex-row sm:justify-end"
            >
                <Link
                    :href="index().url"
                    class="rounded-lg border border-gray-300 px-5 py-2.5 text-center text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                    Отмена
                </Link>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="rounded-lg bg-gray-900 px-5 py-2.5 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                >
                    {{
                        form.processing
                            ? 'Сохранение...'
                            : 'Сохранить изменения'
                    }}
                </button>
            </div>
        </form>
    </div>
</template>
