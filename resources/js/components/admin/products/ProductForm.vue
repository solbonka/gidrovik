<script setup lang="ts">
import { Link, router, useForm } from '@inertiajs/vue3';
import { computed, ref, watch } from 'vue';
import { toast } from 'vue-sonner';
import {
    CircleAlert,
    FileText,
    Layers3,
    LoaderCircle,
    Plug,
    Plus,
    Save,
    Settings2,
    Trash2,
} from '@lucide/vue';
import StockField from '@/components/admin/stock/StockField.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { store } from '@/routes/admin/products';

export interface ProductType {
    id: number;
    name: string;
    slug?: string;
}

export interface Characteristic {
    id: number;
    name: string;
    slug?: string;
    // Типы на бэкенде могут называться по-разному: integer/decimal/number/string/text/boolean/select
    type: string;
    unit: string | null;
    pivot?: {
        is_required: boolean;
        sort_order: number;
    };
}

export interface CharacteristicValue {
    id: number;
    value: string;
}

export interface Category {
    id: number;
    name: string;
    slug: string;
    product_types: ProductType[];
    characteristics: Characteristic[];
}

// Хранилище значений для select-характеристик: { characteristicId: [{ id, value }] }
const characteristicValues = ref<Record<number, CharacteristicValue[]>>({});

export interface Standard {
    id: number;
    code: string;
    name: string;
}

export interface Diameter {
    id: number;
    value: number;
    unit: string;
}

export interface Thread {
    id: number;
    system: string;
    designation: string;
    name: string;
}

export interface Manufacturer {
    id: number;
    name: string;
}

export interface Country {
    id: number;
    name: string;
}

export interface ConnectionData {
    position: number;
    standard_id: number | null;
    diameter_id: number | null;
    thread_id: number | null;
}

export interface ProductFormOptions {
    categories: Category[];
    standards: Standard[];
    diameters: Diameter[];
    threads: Thread[];
    manufacturers: Manufacturer[];
    countries: Country[];
}

export interface ProductFormInitial {
    category_id: number | null;
    product_type_id: number | null;
    name: string;
    code: string;
    article: string | null;
    minimum_stock: number | null;
    angle: number | null;
    description: string | null;
    is_active: boolean;
    published: boolean;
    unit: string;
    manufacturer_id: number | null;
    country_id: number | null;
    characteristics: Record<string, string>;
    connections: ConnectionData[];
}

interface Props extends ProductFormOptions {
    mode: 'create' | 'edit';
    productId?: number;
    initial?: ProductFormInitial;
    cancelHref: string;
}

const props = defineProps<Props>();

const fieldClass =
    'w-full rounded-xl border border-input bg-background px-3 py-2.5 text-sm shadow-xs outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30 disabled:cursor-not-allowed disabled:opacity-60 aria-invalid:border-destructive aria-invalid:ring-destructive/20';

const checkboxClass = 'size-4 rounded border-input accent-primary';

/* ---------- Состояние формы ---------- */

const buildCharacteristics = (
    categoryId: number | null,
    source: Record<string, string> = {},
): Record<string, string> => {
    const category = props.categories.find((item) => item.id === categoryId);
    const result: Record<string, string> = {};

    for (const characteristic of category?.characteristics ?? []) {
        result[characteristic.id] = source[characteristic.id] ?? '';
    }

    return result;
};

// Подключения нормализуем: сортируем по позиции и нумеруем подряд
const normalizeConnections = (items: ConnectionData[]): ConnectionData[] =>
    [...items]
        .sort((a, b) => a.position - b.position)
        .map((connection, index) => ({
            position: index + 1,
            standard_id: connection.standard_id,
            diameter_id: connection.diameter_id,
            thread_id: connection.thread_id,
        }));

const form = useForm({
    category_id: (props.initial?.category_id ?? null) as number | null,
    product_type_id: (props.initial?.product_type_id ?? null) as number | null,
    name: props.initial?.name ?? '',
    code: props.initial?.code ?? '',
    article: props.initial?.article ?? '',
    // Строка, чтобы пустое поле превращалось в null, а не в ''
    minimum_stock:
        props.initial?.minimum_stock !== null &&
        props.initial?.minimum_stock !== undefined
            ? String(props.initial.minimum_stock)
            : '',
    angle: (props.initial?.angle ?? null) as number | null,
    description: props.initial?.description ?? '',
    is_active: props.initial?.is_active ?? true,
    published: props.initial?.published ?? false,
    unit: props.initial?.unit ?? 'шт.',
    manufacturer_id: (props.initial?.manufacturer_id ?? null) as number | null,
    country_id: (props.initial?.country_id ?? null) as number | null,
    characteristics: buildCharacteristics(
        props.initial?.category_id ?? null,
        props.initial?.characteristics,
    ),
    connections: normalizeConnections(props.initial?.connections ?? []),
});

const selectedCategory = computed<Category | null>(
    () =>
        props.categories.find((category) => category.id === form.category_id) ??
        null,
);

const productTypes = computed<ProductType[]>(
    () => selectedCategory.value?.product_types ?? [],
);

const characteristicList = computed<Characteristic[]>(
    () => selectedCategory.value?.characteristics ?? [],
);

/* ---------- Вид категории ---------- */

type CategoryKind = 'fitting' | 'adapter' | 'coupling' | 'hose';

const KIND_KEYWORDS: Record<CategoryKind, string[]> = {
    fitting: ['fitting', 'фитин'],
    adapter: ['adapter', 'адаптер'],
    coupling: ['ferrule', 'coupling', 'муфт'],
    hose: ['hose', 'rukav', 'рукав'],
};

const MAX_CONNECTIONS: Record<CategoryKind, number> = {
    fitting: 1,
    adapter: 3,
    coupling: 1,
    hose: 1,
};

const kind = computed<CategoryKind | null>(() => {
    const category = selectedCategory.value;

    if (!category) return null;

    const text = `${category.slug} ${category.name}`.toLowerCase();

    for (const [key, words] of Object.entries(KIND_KEYWORDS) as [
        CategoryKind,
        string[],
    ][]) {
        if (words.some((word) => text.includes(word))) {
            return key;
        }
    }

    return null;
});

const isFitting = computed(() => kind.value === 'fitting');

// У муфт и рукавов указывается только диаметр
const diameterOnly = computed(
    () => kind.value === 'coupling' || kind.value === 'hose',
);

const maxConnections = computed(() =>
    kind.value ? MAX_CONNECTIONS[kind.value] : 0,
);

const connectionsHint = computed(() => {
    switch (kind.value) {
        case 'fitting':
            return 'Одно подключение для фитинга';
        case 'coupling':
            return 'Укажите диаметр муфты';
        case 'hose':
            return 'Укажите диаметр рукава';
        case 'adapter':
            return `До ${maxConnections.value} подключений для адаптера`;
        default:
            return '';
    }
});

// Угол показываем для фитингов, а также если он уже задан у товара
const showAngle = computed(() => isFitting.value || form.angle !== null);

/* ---------- Реакция на смену категории ---------- */

watch(
    () => form.category_id,
    async () => {
        form.product_type_id = null;
        form.characteristics = buildCharacteristics(form.category_id);
        form.connections = [];

        // Загрузить значения для select-характеристик
        if (form.category_id) {
            await loadCharacteristicValues(form.category_id);
        }
    },
);

const loadCharacteristicValues = async (categoryId: number): Promise<void> => {
    try {
        const response = await fetch(`/admin/categories/${categoryId}/characteristics`);
        const data = await response.json();

        if (data.values) {
            characteristicValues.value = data.values;

            // Обновить характеристики с типом select
            for (const [charId, values] of Object.entries(data.values)) {
                const id = Number(charId);
                const cat = props.categories.find((c) => c.id === form.category_id);
                const char = cat?.characteristics.find((c) => c.id === id);
                if (char && char.type === 'select') {
                    // Если значение ещё не выбрано, сбросить
                    if (!form.characteristics[id]) {
                        form.characteristics[id] = '';
                    }
                }
            }
        }
    } catch (error) {
        console.error('Failed to load characteristic values:', error);
    }
};

/* ---------- Характеристики ---------- */

const NUMBER_TYPES = ['integer', 'decimal', 'number'];

const isNumberCharacteristic = (characteristic: Characteristic): boolean =>
    NUMBER_TYPES.includes(characteristic.type);

const numberStep = (characteristic: Characteristic): string =>
    characteristic.type === 'integer' ? '1' : 'any';

const errors = computed(() => form.errors as Record<string, string | undefined>);

const characteristicError = (id: number): string | undefined =>
    errors.value[`characteristics.${id}`];

const getCharacteristicOptions = (id: number): CharacteristicValue[] => {
    return characteristicValues.value[id] ?? [];
};

const connectionError = (index: number, field: string): string | undefined =>
    errors.value[`connections.${index}.${field}`];

/* ---------- Подключения ---------- */

const addConnection = (): void => {
    if (form.connections.length >= maxConnections.value) return;

    form.connections.push({
        position: form.connections.length + 1,
        standard_id: null,
        diameter_id: null,
        thread_id: null,
    });
};

const removeConnection = (index: number): void => {
    form.connections.splice(index, 1);

    form.connections.forEach((connection, position) => {
        connection.position = position + 1;
    });
};

// При редактировании бэкенд ожидает все три позиции, пустые — с null
const padConnections = (items: ConnectionData[]): ConnectionData[] =>
    [1, 2, 3].map(
        (position) =>
            items.find((connection) => connection.position === position) ?? {
                position,
                standard_id: null,
                diameter_id: null,
                thread_id: null,
            },
    );

/* ---------- Отправка ---------- */

const submit = (): void => {
    form.transform((data) => ({
        ...data,
        minimum_stock:
            data.minimum_stock === '' ? null : Number(data.minimum_stock),
        connections:
            props.mode === 'edit'
                ? padConnections(data.connections)
                : data.connections,
    }));

    const options = {
        onError: () => {
            toast.error('Проверьте поля формы.');
        },
    };

    if (props.mode === 'edit' && props.productId !== undefined) {
        form.put(`/admin/products/${props.productId}`, options);
        return;
    }

    form.post(store.url(), options);
};

const hasErrors = computed(() => Object.keys(form.errors).length > 0);
</script>

<template>
    <form class="space-y-6" novalidate @submit.prevent="submit">
        <!-- Основная информация -->
        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm">
            <div class="flex items-center gap-3 border-b px-5 py-4 sm:px-6">
                <div
                    class="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary"
                >
                    <FileText :size="20" />
                </div>
                <div>
                    <h2 class="font-semibold">Основная информация</h2>
                    <p class="mt-0.5 text-xs text-muted-foreground">
                        Название, категория и параметры учёта
                    </p>
                </div>
            </div>

            <div class="grid gap-x-6 gap-y-5 p-5 sm:grid-cols-2 sm:p-6">
                <StockField
                    label="Категория"
                    for-id="category"
                    required
                    :error="form.errors.category_id"
                >
                    <select
                        id="category"
                        v-model="form.category_id"
                        :class="fieldClass"
                        :aria-invalid="!!form.errors.category_id"
                    >
                        <option :value="null">Выберите категорию</option>
                        <option
                            v-for="category in categories"
                            :key="category.id"
                            :value="category.id"
                        >
                            {{ category.name }}
                        </option>
                    </select>
                </StockField>

                <StockField
                    label="Тип товара"
                    for-id="product_type"
                    :error="form.errors.product_type_id"
                >
                    <select
                        id="product_type"
                        v-model="form.product_type_id"
                        :class="fieldClass"
                        :disabled="!form.category_id"
                        :aria-invalid="!!form.errors.product_type_id"
                    >
                        <option :value="null">
                            {{ form.category_id ? 'Не указан' : 'Сначала выберите категорию' }}
                        </option>
                        <option
                            v-for="type in productTypes"
                            :key="type.id"
                            :value="type.id"
                        >
                            {{ type.name }}
                        </option>
                    </select>
                </StockField>

                <div class="sm:col-span-2">
                    <StockField
                        label="Название товара"
                        for-id="name"
                        required
                        :error="form.errors.name"
                    >
                        <Input
                            id="name"
                            v-model="form.name"
                            type="text"
                            autocomplete="off"
                            placeholder="Например: Фитинг BSP 90°"
                            class="h-11 rounded-xl"
                            :aria-invalid="!!form.errors.name"
                        />
                    </StockField>
                </div>

                <div class="grid gap-6 md:grid-cols-2">
                    <StockField
                        label="Код товара"
                        for-id="code"
                        required
                        :error="form.errors.code"
                    >
                        <Input
                            id="code"
                            v-model="form.code"
                            type="text"
                            autocomplete="off"
                            placeholder="Например: FIT-001"
                            class="h-11 rounded-xl font-mono"
                            :aria-invalid="!!form.errors.code"
                        />
                    </StockField>
                    <StockField
                        label="Артикул"
                        for-id="article"
                        :error="form.errors.article"
                    >
                        <Input
                            id="article"
                            v-model="form.article"
                            type="text"
                            autocomplete="off"
                            class="h-11 rounded-xl font-mono"
                            :aria-invalid="!!form.errors.article"
                        />
                    </StockField>
                </div>

                <StockField
                    label="Минимальный остаток"
                    for-id="minimum_stock"
                    :error="form.errors.minimum_stock"
                    hint="При остатке ниже этого значения товар попадёт в список дефицита. Пустое поле отключает контроль."
                >
                    <div class="relative">
                        <Input
                            id="minimum_stock"
                            v-model="form.minimum_stock"
                            type="number"
                            inputmode="decimal"
                            min="0"
                            step="0.001"
                            placeholder="Не задан"
                            class="h-11 rounded-xl pr-16"
                            :aria-invalid="!!form.errors.minimum_stock"
                        />
                        <span
                            class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-xs text-muted-foreground"
                        >
                            {{ form.unit }}
                        </span>
                    </div>
                </StockField>

                <StockField
                    label="Единица измерения"
                    for-id="unit"
                    :error="form.errors.unit"
                >
                    <select
                        id="unit"
                        v-model="form.unit"
                        :class="fieldClass"
                        :aria-invalid="!!form.errors.unit"
                    >
                        <option value="шт.">шт.</option>
                        <option value="упаковка">упаковка</option>
                        <option value="комплект">комплект</option>
                        <option value="м">м</option>
                        <option value="л">л</option>
                    </select>
                </StockField>

                <StockField
                    v-if="showAngle"
                    label="Угол"
                    for-id="angle"
                    :error="form.errors.angle"
                >
                    <select
                        id="angle"
                        v-model="form.angle"
                        :class="fieldClass"
                        :aria-invalid="!!form.errors.angle"
                    >
                        <option :value="null">Не указан</option>
                        <option :value="0">0°</option>
                        <option :value="45">45°</option>
                        <option :value="90">90°</option>
                        <option :value="180">180°</option>
                    </select>
                </StockField>

                <StockField
                    label="Производитель"
                    for-id="manufacturer"
                    :error="form.errors.manufacturer_id"
                >
                    <select
                        id="manufacturer"
                        v-model="form.manufacturer_id"
                        :class="fieldClass"
                        :aria-invalid="!!form.errors.manufacturer_id"
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
                </StockField>

                <StockField
                    label="Страна производства"
                    for-id="country"
                    :error="form.errors.country_id"
                >
                    <select
                        id="country"
                        v-model="form.country_id"
                        :class="fieldClass"
                        :aria-invalid="!!form.errors.country_id"
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
                </StockField>

                <div class="sm:col-span-2">
                    <StockField
                        label="Описание"
                        for-id="description"
                        :error="form.errors.description"
                    >
                        <textarea
                            id="description"
                            v-model="form.description"
                            rows="4"
                            placeholder="Дополнительная информация о товаре..."
                            class="min-h-28 resize-y"
                            :class="fieldClass"
                            :aria-invalid="!!form.errors.description"
                        />
                    </StockField>
                </div>

                <label
                    class="flex cursor-pointer items-start gap-3 rounded-xl border bg-muted/40 p-4 sm:col-span-2"
                >
                    <input
                        v-model="form.is_active"
                        type="checkbox"
                        class="mt-0.5"
                        :class="checkboxClass"
                    />
                    <span>
                        <span class="block text-sm font-semibold">
                            Товар активен
                        </span>
                        <span class="mt-1 block text-xs leading-5 text-muted-foreground">
                            Неактивный товар останется в системе, но не будет
                            доступен там, где используются только активные
                            товары.
                        </span>
                    </span>
                </label>

                <label
                    class="flex cursor-pointer items-start gap-3 rounded-xl border bg-muted/40 p-4 sm:col-span-2"
                >
                    <input
                        v-model="form.published"
                        type="checkbox"
                        class="mt-0.5"
                        :class="checkboxClass"
                    />
                    <span>
                        <span class="block text-sm font-semibold">
                            Опубликован в магазине
                        </span>
                        <span class="mt-1 block text-xs leading-5 text-muted-foreground">
                            Опубликованный товар будет виден в каталоге и поиске интернет-магазина.
                            Неопубликованные товары скрыты от покупателей.
                        </span>
                    </span>
                </label>
            </div>
        </section>

        <!-- Характеристики -->
        <section
            v-if="form.category_id"
            class="overflow-hidden rounded-2xl border bg-card shadow-sm"
        >
            <div class="flex items-center gap-3 border-b px-5 py-4 sm:px-6">
                <div
                    class="flex size-10 items-center justify-center rounded-xl bg-violet-500/10 text-violet-600 dark:text-violet-400"
                >
                    <Settings2 :size="20" />
                </div>
                <div>
                    <h2 class="font-semibold">Характеристики</h2>
                    <p class="mt-0.5 text-xs text-muted-foreground">
                        Параметры определяются выбранной категорией
                    </p>
                </div>
            </div>

            <div
                v-if="characteristicList.length"
                class="grid gap-x-6 gap-y-5 p-5 sm:grid-cols-2 sm:p-6"
            >
                <StockField
                    v-for="characteristic in characteristicList"
                    :key="characteristic.id"
                    :label="characteristic.name"
                    :for-id="`characteristic-${characteristic.id}`"
                    :required="!!characteristic.pivot?.is_required"
                    :error="characteristicError(characteristic.id)"
                    :hint="
                        characteristic.unit
                            ? `Единица измерения: ${characteristic.unit}`
                            : undefined
                    "
                >
                    <label
                        v-if="characteristic.type === 'boolean'"
                        :for="`characteristic-${characteristic.id}`"
                        class="flex min-h-11 cursor-pointer items-center gap-3 rounded-xl border bg-background px-3"
                    >
                        <input
                            :id="`characteristic-${characteristic.id}`"
                            v-model="form.characteristics[characteristic.id]"
                            type="checkbox"
                            true-value="1"
                            false-value="0"
                            :class="checkboxClass"
                        />
                        <span class="text-sm">Да</span>
                    </label>

                    <select
                        v-else-if="characteristic.type === 'select'"
                        :id="`characteristic-${characteristic.id}`"
                        v-model="form.characteristics[characteristic.id]"
                        :class="fieldClass"
                        :aria-invalid="!!characteristicError(characteristic.id)"
                    >
                        <option value="">Выберите значение</option>
                        <option
                            v-for="option in getCharacteristicOptions(characteristic.id)"
                            :key="option.id"
                            :value="option.value"
                        >
                            {{ option.value }}
                        </option>
                    </select>

                    <Input
                        v-else
                        :id="`characteristic-${characteristic.id}`"
                        v-model="form.characteristics[characteristic.id]"
                        :type="isNumberCharacteristic(characteristic) ? 'number' : 'text'"
                        :step="
                            isNumberCharacteristic(characteristic)
                                ? numberStep(characteristic)
                                : undefined
                        "
                        class="h-11 rounded-xl"
                        :aria-invalid="!!characteristicError(characteristic.id)"
                    />
                </StockField>
            </div>

            <div v-else class="p-5 sm:p-6">
                <div
                    class="rounded-xl border border-dashed px-4 py-8 text-center"
                >
                    <Layers3 :size="32" class="mx-auto text-muted-foreground" />
                    <p class="mt-3 text-sm font-medium">
                        Характеристики не настроены
                    </p>
                    <p class="mt-1 text-xs text-muted-foreground">
                        Для этой категории нет дополнительных параметров.
                    </p>
                </div>
            </div>
        </section>

        <!-- Подключения -->
        <section
            v-if="kind"
            class="overflow-hidden rounded-2xl border bg-card shadow-sm"
        >
            <div class="flex items-center gap-3 border-b px-5 py-4 sm:px-6">
                <div
                    class="flex size-10 items-center justify-center rounded-xl bg-amber-500/10 text-amber-600 dark:text-amber-400"
                >
                    <Plug :size="20" />
                </div>

                <div class="min-w-0 flex-1">
                    <h2 class="font-semibold">Подключения</h2>
                    <p class="mt-0.5 text-xs text-muted-foreground">
                        {{ connectionsHint }}
                    </p>
                </div>

                <Button
                    v-if="form.connections.length < maxConnections"
                    type="button"
                    variant="outline"
                    size="sm"
                    @click="addConnection"
                >
                    <Plus :size="15" class="mr-1.5" />
                    Добавить
                </Button>
            </div>

            <div class="space-y-4 p-5 sm:p-6">
                <div
                    v-for="(connection, connectionIndex) in form.connections"
                    :key="connection.position"
                    class="overflow-hidden rounded-xl border"
                >
                    <div
                        class="flex items-center justify-between gap-3 bg-muted/40 px-4 py-3"
                    >
                        <div class="flex items-center gap-3">
                            <div
                                class="flex size-9 items-center justify-center rounded-xl bg-primary/10 text-sm font-bold text-primary"
                            >
                                {{ connection.position }}
                            </div>
                            <h3 class="text-sm font-semibold">
                                Подключение {{ connection.position }}
                            </h3>
                        </div>

                        <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            class="text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
                            @click="removeConnection(connectionIndex)"
                        >
                            <Trash2 :size="15" class="mr-1.5" />
                            Удалить
                        </Button>
                    </div>

                    <div
                        class="grid gap-4 p-4"
                        :class="
                            diameterOnly
                                ? 'sm:grid-cols-1'
                                : 'sm:grid-cols-2 lg:grid-cols-3'
                        "
                    >
                        <StockField
                            v-if="!diameterOnly"
                            label="Стандарт"
                            :for-id="`connection-standard-${connectionIndex}`"
                            :error="connectionError(connectionIndex, 'standard_id')"
                        >
                            <select
                                :id="`connection-standard-${connectionIndex}`"
                                v-model="connection.standard_id"
                                :class="fieldClass"
                                :aria-invalid="!!connectionError(connectionIndex, 'standard_id')"
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
                        </StockField>

                        <StockField
                            label="Диаметр"
                            :for-id="`connection-diameter-${connectionIndex}`"
                            :error="connectionError(connectionIndex, 'diameter_id')"
                        >
                            <select
                                :id="`connection-diameter-${connectionIndex}`"
                                v-model="connection.diameter_id"
                                :class="fieldClass"
                                :aria-invalid="!!connectionError(connectionIndex, 'diameter_id')"
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
                        </StockField>

                        <StockField
                            v-if="!diameterOnly"
                            label="Резьба"
                            :for-id="`connection-thread-${connectionIndex}`"
                            :error="connectionError(connectionIndex, 'thread_id')"
                        >
                            <select
                                :id="`connection-thread-${connectionIndex}`"
                                v-model="connection.thread_id"
                                :class="fieldClass"
                                :aria-invalid="!!connectionError(connectionIndex, 'thread_id')"
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
                        </StockField>

                        <p
                            v-if="connectionError(connectionIndex, 'position')"
                            class="text-sm text-destructive sm:col-span-2 lg:col-span-3"
                        >
                            {{ connectionError(connectionIndex, 'position') }}
                        </p>
                    </div>
                </div>

                <div
                    v-if="!form.connections.length"
                    class="rounded-xl border border-dashed px-4 py-8 text-center"
                >
                    <Plug :size="32" class="mx-auto text-muted-foreground" />
                    <p class="mt-3 text-sm font-medium">
                        Подключения не добавлены
                    </p>
                    <p class="mt-1 text-xs text-muted-foreground">
                        Добавьте подключение, чтобы указать
                        {{ diameterOnly ? 'диаметр' : 'стандарт, диаметр и резьбу' }}.
                    </p>
                    <Button
                        type="button"
                        variant="outline"
                        class="mt-4"
                        @click="addConnection"
                    >
                        <Plus :size="15" class="mr-1.5" />
                        Добавить подключение
                    </Button>
                </div>
            </div>
        </section>

        <!-- Общая ошибка -->
        <div
            v-if="hasErrors"
            role="alert"
            class="flex items-start gap-3 rounded-xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive"
        >
            <CircleAlert :size="20" class="mt-0.5 shrink-0" />
            <div>
                <p class="font-semibold">
                    {{
                        mode === 'edit'
                            ? 'Не удалось сохранить изменения'
                            : 'Проверьте заполнение формы'
                    }}
                </p>
                <p class="mt-1">
                    Некоторые поля содержат ошибки. Исправьте их и повторите
                    попытку.
                </p>
            </div>
        </div>

        <!-- Панель действий -->
        <div
            class="sticky bottom-4 z-10 flex flex-col-reverse gap-3 rounded-2xl border bg-card/95 p-4 shadow-lg backdrop-blur sm:flex-row sm:items-center sm:justify-between sm:px-6"
        >
            <p class="text-xs text-muted-foreground">
                <template v-if="mode === 'edit' && form.isDirty">
                    Есть несохранённые изменения
                </template>
                <template v-else-if="mode === 'edit'">
                    Изменения применятся после сохранения
                </template>
                <template v-else>
                    Новый товар появится в каталоге после сохранения
                </template>
            </p>

            <div class="flex flex-col-reverse gap-3 sm:flex-row">
                <Button as-child variant="outline" :disabled="form.processing">
                    <Link :href="cancelHref">Отмена</Link>
                </Button>

                <Button
                    type="submit"
                    :disabled="form.processing || (mode === 'edit' && !form.isDirty)"
                >
                    <LoaderCircle
                        v-if="form.processing"
                        :size="17"
                        class="mr-2 animate-spin"
                    />
                    <Save v-else :size="17" class="mr-2" />
                    {{
                        form.processing
                            ? mode === 'edit'
                                ? 'Сохранение...'
                                : 'Создание...'
                            : mode === 'edit'
                                ? 'Сохранить изменения'
                                : 'Создать товар'
                    }}
                </Button>
            </div>
        </div>
    </form>
</template>
