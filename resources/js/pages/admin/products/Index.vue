<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, onBeforeUnmount, ref, watch } from 'vue';
import {
    ChevronDown,
    ChevronLeft,
    ChevronRight,
    Eye,
    Globe,
    Package,
    Pencil,
    Plus,
    Search,
    SlidersHorizontal,
    Star,
    Trash2,
    X,
} from '@lucide/vue';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';
import { create, destroy, edit, show } from '@/routes/admin/products';

defineOptions({
    layout: AdminLayout,
});

interface Category {
    id: number;
    name: string;
}

interface ProductType {
    id: number;
    category_id: number;
    name: string;
    category?: Category;
}

interface Product {
    id: number;
    name: string;
    code: string;
    article: string | null;
    is_active: boolean;
    published: boolean;
    is_featured: boolean;
    stock_quantity: number | null;
    retail_price: number | string | null;
    category: Category;
    product_type: ProductType | null;
}

interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

interface PaginatedProducts {
    data: Product[];
    current_page: number;
    last_page: number;
    from: number | null;
    to: number | null;
    total: number;
    links: PaginationLink[];
}

interface NamedOption {
    id: number;
    name: string;
}

interface Filters {
    search: string;
    category_id: number | null;
    product_type_id: number | null;
    manufacturer_id: number | null;
    country_id: number | null;
    is_active: string;
    published: string;
    price: string;
    stock: string;
    sort: string;
    direction: 'asc' | 'desc';
}

interface Props {
    products: PaginatedProducts;
    filters: Filters;
    categories: Category[];
    productTypes: ProductType[];
    manufacturers: NamedOption[];
    countries: NamedOption[];
}

const props = defineProps<Props>();

/* ---------- Форматирование ---------- */

const numberFormat = new Intl.NumberFormat('ru-RU', {
    maximumFractionDigits: 3,
});

const formatStock = (value: number | string | null | undefined): string =>
    numberFormat.format(Number(value ?? 0));

const priceFormat = new Intl.NumberFormat('ru-RU', {
    maximumFractionDigits: 2,
});

const formatPrice = (value: number | string | null | undefined): string => {
    const price = Number(value ?? 0);

    return price > 0 ? `${priceFormat.format(price)} ₽` : '—';
};

const hasStock = (product: Product): boolean =>
    Number(product.stock_quantity ?? 0) > 0;

/* ---------- Фильтры ---------- */

const search = ref(props.filters.search ?? '');
const categoryId = ref(props.filters.category_id?.toString() ?? 'all');
const productTypeId = ref(props.filters.product_type_id?.toString() ?? 'all');
const manufacturerId = ref(props.filters.manufacturer_id?.toString() ?? 'all');
const countryId = ref(props.filters.country_id?.toString() ?? 'all');
const isActive = ref(props.filters.is_active || 'all');
const publishedFilter = ref(props.filters.published || 'all');
const priceFilter = ref(props.filters.price || 'all');
const stockFilter = ref(props.filters.stock || 'all');
const sort = ref(
    props.filters.sort && props.filters.direction
        ? `${props.filters.sort}:${props.filters.direction}`
        : 'name:asc',
);

const sortOptions = [
    { value: 'name:asc', label: 'Название: А–Я' },
    { value: 'name:desc', label: 'Название: Я–А' },
    { value: 'code:asc', label: 'Код: по возрастанию' },
    { value: 'code:desc', label: 'Код: по убыванию' },
    { value: 'article:asc', label: 'Артикул: А–Я' },
    { value: 'article:desc', label: 'Артикул: Я–А' },
    { value: 'stock:desc', label: 'Остаток: больше' },
    { value: 'stock:asc', label: 'Остаток: меньше' },
    { value: 'price:asc', label: 'Цена: по возрастанию' },
    { value: 'price:desc', label: 'Цена: по убыванию' },
    { value: 'featured:desc', label: 'Популярные первыми' },
    { value: 'published:desc', label: 'Опубликованные первыми' },
    { value: 'created_at:desc', label: 'Сначала новые' },
    { value: 'created_at:asc', label: 'Сначала старые' },
];

// Типы показываем только для выбранной категории
const availableTypes = computed(() =>
    categoryId.value === 'all'
        ? props.productTypes
        : props.productTypes.filter(
            (type) => String(type.category_id) === categoryId.value,
        ),
);

// Основные фильтры (всегда видны)
const mainFiltersCount = computed(
    () =>
        [
            search.value,
            categoryId.value !== 'all' ? categoryId.value : '',
            productTypeId.value !== 'all' ? productTypeId.value : '',
        ].filter(Boolean).length,
);

// Дополнительные фильтры (в раскрывающейся панели)
const extraFiltersCount = computed(
    () =>
        [
            manufacturerId.value !== 'all' ? manufacturerId.value : '',
            countryId.value !== 'all' ? countryId.value : '',
            isActive.value !== 'all' ? isActive.value : '',
            publishedFilter.value !== 'all' ? publishedFilter.value : '',
            priceFilter.value !== 'all' ? priceFilter.value : '',
            stockFilter.value !== 'all' ? stockFilter.value : '',
        ].filter(Boolean).length,
);

const activeFiltersCount = computed(
    () => mainFiltersCount.value + extraFiltersCount.value,
);

// Панель открыта сразу, если уже выбран какой-то дополнительный фильтр
const showExtra = ref(extraFiltersCount.value > 0);

let debounceTimer: ReturnType<typeof setTimeout> | undefined;

const submitFilters = (): void => {
    clearTimeout(debounceTimer);

    router.get(
        '/admin/products',
        {
            search: search.value || undefined,
            category_id:
                categoryId.value !== 'all' ? categoryId.value : undefined,
            product_type_id:
                productTypeId.value !== 'all' ? productTypeId.value : undefined,
            manufacturer_id:
                manufacturerId.value !== 'all'
                    ? manufacturerId.value
                    : undefined,
            country_id:
                countryId.value !== 'all' ? countryId.value : undefined,
            is_active: isActive.value !== 'all' ? isActive.value : undefined,
            published:
                publishedFilter.value !== 'all'
                    ? publishedFilter.value
                    : undefined,
            price: priceFilter.value !== 'all' ? priceFilter.value : undefined,
            stock: stockFilter.value !== 'all' ? stockFilter.value : undefined,
            ...(sort.value !== 'name:asc'
                ? {
                    sort: sort.value.split(':')[0],
                    direction: sort.value.split(':')[1],
                }
                : {}),
        },
        {
            preserveState: true,
            preserveScroll: true,
            replace: true,
        },
    );
};

// Если выбранный тип не относится к новой категории — сбрасываем его
watch(categoryId, () => {
    if (
        productTypeId.value !== 'all' &&
        !availableTypes.value.some(
            (type) => String(type.id) === productTypeId.value,
        )
    ) {
        productTypeId.value = 'all';
    }
});

// Применяем фильтры автоматически, с небольшой задержкой
watch(
    [
        search,
        categoryId,
        productTypeId,
        manufacturerId,
        countryId,
        isActive,
        publishedFilter,
        priceFilter,
        stockFilter,
        sort,
    ],
    () => {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(submitFilters, 350);
    },
);

onBeforeUnmount(() => clearTimeout(debounceTimer));

const resetFilters = (): void => {
    search.value = '';
    categoryId.value = 'all';
    productTypeId.value = 'all';
    manufacturerId.value = 'all';
    countryId.value = 'all';
    isActive.value = 'all';
    publishedFilter.value = 'all';
    priceFilter.value = 'all';
    stockFilter.value = 'all';
};

/* ---------- Удаление ---------- */

const deleteDialog = ref({
    open: false,
    id: null as number | null,
    name: '',
    loading: false,
});

const openDeleteDialog = (product: Product): void => {
    deleteDialog.value.id = product.id;
    deleteDialog.value.name = product.name;
    deleteDialog.value.open = true;
};

const closeDeleteDialog = (): void => {
    if (deleteDialog.value.loading) return;

    deleteDialog.value.open = false;
};

const confirmDelete = (): void => {
    if (deleteDialog.value.id === null || deleteDialog.value.loading) return;

    deleteDialog.value.loading = true;

    router.delete(destroy(deleteDialog.value.id).url, {
        preserveScroll: true,

        onError: (errors) => {
            console.error('Ошибка удаления:', errors);
        },

        onFinish: () => {
            deleteDialog.value.loading = false;
            deleteDialog.value.open = false;
        },
    });
};

/* ---------- Пагинация ---------- */

const prevLink = computed(() => props.products.links[0] ?? null);
const nextLink = computed(
    () => props.products.links[props.products.links.length - 1] ?? null,
);
const pageLinks = computed(() => props.products.links.slice(1, -1));
const hasPagination = computed(() => props.products.links.length > 3);

const pageButtonBase =
    'inline-flex h-9 min-w-9 items-center justify-center rounded-xl border px-3 text-sm font-medium transition';

/* ---------- Публикация / Популярные ---------- */

function togglePublished(product: Product) {
    router.put(
        `/admin/products/${product.id}/toggle-published`,
        { published: !product.published },
        { preserveScroll: true, preserveState: true },
    );
}

function toggleFeatured(product: Product) {
    router.put(
        `/admin/products/${product.id}/toggle-featured`,
        { is_featured: !product.is_featured },
        { preserveScroll: true, preserveState: true },
    );
}

// Общие стили кнопок-переключателей
const toggleBase =
    'inline-flex size-8 items-center justify-center rounded-lg border transition focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none';
const publishedOn =
    'border-blue-600/20 bg-blue-500/10 text-blue-700 hover:bg-blue-500/20 dark:text-blue-400';
const publishedOff =
    'border-border bg-transparent text-muted-foreground/60 hover:bg-muted';
const featuredOn =
    'border-orange-600/20 bg-orange-500/10 text-orange-600 hover:bg-orange-500/20 dark:text-orange-400';
const featuredOff =
    'border-border bg-transparent text-muted-foreground/60 hover:bg-muted';
</script>

<template>
    <Head title="Товары" />

    <div class="space-y-5">
        <!-- Заголовок -->
        <header
            class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between"
        >
            <div class="flex items-center gap-4">
                <div
                    class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                >
                    <Package :size="24" />
                </div>
                <div>
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Товары
                    </h1>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Каталог товаров и их складские остатки
                    </p>
                </div>
            </div>

            <Button as-child class="w-full sm:w-auto">
                <Link :href="create().url">
                    <Plus :size="18" class="mr-2" />
                    Добавить товар
                </Link>
            </Button>
        </header>

        <!-- Фильтры -->
        <form
            class="rounded-2xl border bg-card p-4 shadow-sm sm:p-5"
            @submit.prevent="submitFilters"
        >
            <!-- Основная строка -->
            <div class="grid gap-3 md:grid-cols-2 lg:grid-cols-12">
                <div class="space-y-1.5 md:col-span-2 lg:col-span-4">
                    <Label for="search">Поиск</Label>

                    <div class="relative">
                        <Search
                            :size="16"
                            class="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-muted-foreground"
                        />

                        <Input
                            id="search"
                            v-model="search"
                            type="search"
                            placeholder="Название, код или артикул"
                            class="h-10 rounded-xl pr-10 pl-9"
                        />

                        <Button
                            v-if="search"
                            type="button"
                            variant="ghost"
                            size="icon"
                            class="absolute top-1/2 right-1 size-8 -translate-y-1/2 rounded-lg text-muted-foreground"
                            @click="search = ''"
                        >
                            <X :size="15" />
                            <span class="sr-only">Очистить поиск</span>
                        </Button>
                    </div>
                </div>

                <div class="space-y-1.5 lg:col-span-3">
                    <Label for="category">Категория</Label>

                    <Select v-model="categoryId">
                        <SelectTrigger id="category" class="h-10 w-full rounded-xl">
                            <SelectValue placeholder="Все категории" />
                        </SelectTrigger>

                        <SelectContent>
                            <SelectItem value="all">Все категории</SelectItem>

                            <SelectItem
                                v-for="category in categories"
                                :key="category.id"
                                :value="category.id.toString()"
                            >
                                {{ category.name }}
                            </SelectItem>
                        </SelectContent>
                    </Select>
                </div>

                <div class="space-y-1.5 lg:col-span-3">
                    <Label for="product-type">Тип товара</Label>

                    <Select v-model="productTypeId">
                        <SelectTrigger id="product-type" class="h-10 w-full rounded-xl">
                            <SelectValue placeholder="Все типы" />
                        </SelectTrigger>

                        <SelectContent>
                            <SelectItem value="all">Все типы</SelectItem>

                            <SelectItem
                                v-for="productType in availableTypes"
                                :key="productType.id"
                                :value="productType.id.toString()"
                            >
                                {{ productType.name }}
                            </SelectItem>
                        </SelectContent>
                    </Select>
                </div>

                <div class="space-y-1.5 lg:col-span-2">
                    <Label for="sort">Сортировка</Label>

                    <Select v-model="sort">
                        <SelectTrigger id="sort" class="h-10 w-full rounded-xl">
                            <SelectValue placeholder="Сортировка" />
                        </SelectTrigger>

                        <SelectContent>
                            <SelectItem
                                v-for="option in sortOptions"
                                :key="option.value"
                                :value="option.value"
                            >
                                {{ option.label }}
                            </SelectItem>
                        </SelectContent>
                    </Select>
                </div>
            </div>

            <!-- Дополнительные фильтры -->
            <div v-if="showExtra" class="mt-3 grid gap-3 border-t pt-4 sm:grid-cols-2 lg:grid-cols-6">
                <div class="space-y-1.5">
                    <Label for="manufacturer">Производитель</Label>

                    <Select v-model="manufacturerId">
                        <SelectTrigger id="manufacturer" class="h-10 w-full rounded-xl">
                            <SelectValue placeholder="Все" />
                        </SelectTrigger>

                        <SelectContent>
                            <SelectItem value="all">Все производители</SelectItem>

                            <SelectItem
                                v-for="manufacturer in manufacturers"
                                :key="manufacturer.id"
                                :value="manufacturer.id.toString()"
                            >
                                {{ manufacturer.name }}
                            </SelectItem>
                        </SelectContent>
                    </Select>
                </div>

                <div class="space-y-1.5">
                    <Label for="country">Страна</Label>

                    <Select v-model="countryId">
                        <SelectTrigger id="country" class="h-10 w-full rounded-xl">
                            <SelectValue placeholder="Все" />
                        </SelectTrigger>

                        <SelectContent>
                            <SelectItem value="all">Все страны</SelectItem>

                            <SelectItem
                                v-for="country in countries"
                                :key="country.id"
                                :value="country.id.toString()"
                            >
                                {{ country.name }}
                            </SelectItem>
                        </SelectContent>
                    </Select>
                </div>

                <div class="space-y-1.5">
                    <Label for="is-active">Активность</Label>

                    <Select v-model="isActive">
                        <SelectTrigger id="is-active" class="h-10 w-full rounded-xl">
                            <SelectValue placeholder="Все" />
                        </SelectTrigger>

                        <SelectContent>
                            <SelectItem value="all">Все</SelectItem>
                            <SelectItem value="1">Активные</SelectItem>
                            <SelectItem value="0">Неактивные</SelectItem>
                        </SelectContent>
                    </Select>
                </div>

                <div class="space-y-1.5">
                    <Label for="published-filter">Публикация</Label>

                    <Select v-model="publishedFilter">
                        <SelectTrigger id="published-filter" class="h-10 w-full rounded-xl">
                            <SelectValue placeholder="Все" />
                        </SelectTrigger>

                        <SelectContent>
                            <SelectItem value="all">Все</SelectItem>
                            <SelectItem value="1">Опубликованные</SelectItem>
                            <SelectItem value="0">Не опубликованные</SelectItem>
                        </SelectContent>
                    </Select>
                </div>

                <div class="space-y-1.5">
                    <Label for="price-filter">Цена</Label>

                    <Select v-model="priceFilter">
                        <SelectTrigger id="price-filter" class="h-10 w-full rounded-xl">
                            <SelectValue placeholder="Все" />
                        </SelectTrigger>

                        <SelectContent>
                            <SelectItem value="all">Все</SelectItem>
                            <SelectItem value="with">С ценой</SelectItem>
                            <SelectItem value="without">Без цены</SelectItem>
                        </SelectContent>
                    </Select>
                </div>

                <div class="space-y-1.5">
                    <Label for="stock-filter">Остаток</Label>

                    <Select v-model="stockFilter">
                        <SelectTrigger id="stock-filter" class="h-10 w-full rounded-xl">
                            <SelectValue placeholder="Все" />
                        </SelectTrigger>

                        <SelectContent>
                            <SelectItem value="all">Все</SelectItem>
                            <SelectItem value="yes">В наличии</SelectItem>
                            <SelectItem value="no">Нет в наличии</SelectItem>
                        </SelectContent>
                    </Select>
                </div>
            </div>

            <!-- Панель управления фильтрами -->
            <div class="mt-4 flex flex-wrap items-center justify-between gap-2 border-t pt-3">
                <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    class="text-muted-foreground"
                    @click="showExtra = !showExtra"
                >
                    <SlidersHorizontal :size="15" class="mr-1.5" />
                    Больше фильтров
                    <span
                        v-if="extraFiltersCount"
                        class="ml-1.5 inline-flex size-5 items-center justify-center rounded-full bg-primary text-[11px] font-semibold text-primary-foreground"
                    >
                        {{ extraFiltersCount }}
                    </span>
                    <ChevronDown
                        :size="15"
                        class="ml-1 transition-transform"
                        :class="showExtra ? 'rotate-180' : ''"
                    />
                </Button>

                <Button
                    v-if="activeFiltersCount"
                    type="button"
                    variant="ghost"
                    size="sm"
                    class="text-muted-foreground"
                    @click="resetFilters"
                >
                    <X :size="15" class="mr-1.5" />
                    Сбросить ({{ activeFiltersCount }})
                </Button>
            </div>
        </form>

        <!-- Список -->
        <section
            class="overflow-hidden rounded-2xl border bg-card shadow-sm"
            aria-labelledby="products-title"
        >
            <div
                class="flex flex-col gap-1 border-b px-5 py-4 sm:flex-row sm:items-center sm:justify-between"
            >
                <h2 id="products-title" class="font-semibold">Список товаров</h2>
                <p class="text-sm text-muted-foreground">
                    Всего товаров:
                    <span class="font-medium text-foreground tabular-nums">
                        {{ products.total }}
                    </span>
                </p>
            </div>

            <!-- Пустое состояние -->
            <div
                v-if="products.data.length === 0"
                class="flex flex-col items-center px-6 py-16 text-center"
            >
                <div
                    class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted"
                >
                    <Package :size="30" class="text-muted-foreground" />
                </div>
                <p class="font-medium">Товары не найдены</p>
                <p class="mt-1 max-w-sm text-sm text-muted-foreground">
                    {{
                        activeFiltersCount
                            ? 'Измените параметры фильтров или добавьте новый товар.'
                            : 'Каталог пока пуст. Добавьте первый товар.'
                    }}
                </p>

                <div class="mt-5 flex flex-wrap justify-center gap-2">
                    <Button
                        v-if="activeFiltersCount"
                        variant="outline"
                        @click="resetFilters"
                    >
                        Сбросить фильтры
                    </Button>

                    <Button as-child>
                        <Link :href="create().url">
                            <Plus :size="16" class="mr-2" />
                            Добавить товар
                        </Link>
                    </Button>
                </div>
            </div>

            <template v-else>
                <!-- Мобильные карточки -->
                <ul class="divide-y md:hidden">
                    <li
                        v-for="product in products.data"
                        :key="product.id"
                        class="space-y-3 p-4"
                        :class="product.is_active ? '' : 'bg-muted/30'"
                    >
                        <div class="flex items-start justify-between gap-3">
                            <div class="min-w-0">
                                <h3 class="text-sm font-semibold break-words">
                                    {{ product.name }}
                                </h3>
                                <p class="mt-1 font-mono text-xs text-muted-foreground">
                                    <span v-if="product.code">{{ product.code }}</span>
                                    <span v-if="product.code && product.article"> · </span>
                                    <span v-if="product.article">{{ product.article }}</span>
                                </p>
                                <p class="mt-1 text-xs text-muted-foreground">
                                    {{ product.category.name }}
                                    <span v-if="product.product_type"> / {{ product.product_type.name }}</span>
                                </p>
                            </div>

                            <div class="flex shrink-0 gap-1.5">
                                <button
                                    type="button"
                                    :class="[toggleBase, product.published ? publishedOn : publishedOff]"
                                    :title="product.published ? 'Опубликован' : 'Не опубликован'"
                                    :aria-pressed="product.published"
                                    @click="togglePublished(product)"
                                >
                                    <Globe :size="15" />
                                    <span class="sr-only">Публикация</span>
                                </button>

                                <button
                                    type="button"
                                    :class="[toggleBase, product.is_featured ? featuredOn : featuredOff]"
                                    :title="product.is_featured ? 'Популярный' : 'Не популярный'"
                                    :aria-pressed="product.is_featured"
                                    @click="toggleFeatured(product)"
                                >
                                    <Star :size="15" :class="product.is_featured ? 'fill-current' : ''" />
                                    <span class="sr-only">Популярный</span>
                                </button>
                            </div>
                        </div>

                        <div class="flex items-center justify-between gap-3 rounded-lg bg-muted/50 px-3 py-2">
                            <div>
                                <p class="text-[11px] text-muted-foreground">Остаток</p>
                                <p
                                    class="text-sm font-bold tabular-nums"
                                    :class="hasStock(product) ? '' : 'text-muted-foreground'"
                                >
                                    {{ formatStock(product.stock_quantity) }}
                                </p>
                            </div>
                            <div class="text-right">
                                <p class="text-[11px] text-muted-foreground">Цена</p>
                                <p class="text-sm font-bold tabular-nums">
                                    {{ formatPrice(product.retail_price) }}
                                </p>
                            </div>
                            <span
                                class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset"
                                :class="
                                    product.is_active
                                        ? 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400'
                                        : 'bg-muted text-muted-foreground ring-border'
                                "
                            >
                                {{ product.is_active ? 'Активен' : 'Неактивен' }}
                            </span>
                        </div>

                        <div class="flex items-center gap-2">
                            <Button as-child variant="outline" size="sm" class="h-9 flex-1">
                                <Link :href="show(product.id).url">
                                    <Eye :size="14" class="mr-1.5" />
                                    Просмотр
                                </Link>
                            </Button>

                            <Button as-child variant="outline" size="sm" class="h-9 flex-1">
                                <Link :href="edit(product.id).url">
                                    <Pencil :size="14" class="mr-1.5" />
                                    Изменить
                                </Link>
                            </Button>

                            <Button
                                variant="outline"
                                size="icon"
                                class="size-9 shrink-0 text-destructive hover:bg-destructive/10 hover:text-destructive"
                                @click="openDeleteDialog(product)"
                            >
                                <Trash2 :size="15" />
                                <span class="sr-only">Удалить</span>
                            </Button>
                        </div>
                    </li>
                </ul>

                <!-- Таблица -->
                <div class="hidden md:block">
                    <table class="w-full text-left text-sm">
                        <thead>
                        <tr class="border-b bg-muted/40">
                            <th scope="col" class="px-4 py-3 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase">Товар</th>
                            <th scope="col" class="hidden px-4 py-3 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase lg:table-cell">Категория</th>
                            <th scope="col" class="px-4 py-3 text-right text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase">Остаток</th>
                            <th scope="col" class="px-4 py-3 text-right text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase">Цена</th>
                            <th scope="col" class="px-4 py-3 text-center text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase">Статус</th>
                            <th scope="col" class="px-4 py-3">
                                <span class="sr-only">Действия</span>
                            </th>
                        </tr>
                        </thead>

                        <tbody class="divide-y">
                        <tr
                            v-for="product in products.data"
                            :key="product.id"
                            class="transition-colors hover:bg-muted/40"
                            :class="product.is_active ? '' : 'bg-muted/20'"
                        >
                            <!-- Товар: название + код + артикул + (категория на узких экранах) -->
                            <td class="max-w-[22rem] px-4 py-3">
                                <div class="flex items-start gap-2">
                                        <span
                                            class="mt-1.5 size-2 shrink-0 rounded-full"
                                            :class="product.is_active ? 'bg-emerald-500' : 'bg-muted-foreground/40'"
                                            :title="product.is_active ? 'Активен' : 'Неактивен'"
                                        />
                                    <div class="min-w-0">
                                        <div
                                            class="line-clamp-2 font-semibold"
                                            :class="product.is_active ? '' : 'text-muted-foreground'"
                                            :title="product.name"
                                        >
                                            {{ product.name }}
                                        </div>

                                        <div class="mt-1 flex flex-wrap gap-1.5">
                                                <span
                                                    v-if="product.code"
                                                    class="inline-flex items-center rounded-md border bg-muted/50 px-1.5 py-0.5 font-mono text-[11px]"
                                                    title="Код товара"
                                                >
                                                    {{ product.code }}
                                                </span>
                                            <span
                                                v-if="product.article"
                                                class="inline-flex items-center rounded-md border bg-muted/50 px-1.5 py-0.5 font-mono text-[11px] text-muted-foreground"
                                                title="Артикул"
                                            >
                                                    {{ product.article }}
                                                </span>
                                        </div>

                                        <div class="mt-1 text-xs text-muted-foreground lg:hidden">
                                            {{ product.category.name }}
                                            <span v-if="product.product_type"> / {{ product.product_type.name }}</span>
                                        </div>
                                    </div>
                                </div>
                            </td>

                            <!-- Категория + тип -->
                            <td class="hidden px-4 py-3 lg:table-cell">
                                <div class="font-medium">{{ product.category.name }}</div>
                                <div class="text-xs text-muted-foreground">
                                    {{ product.product_type?.name ?? '—' }}
                                </div>
                            </td>

                            <td class="px-4 py-3 text-right whitespace-nowrap tabular-nums">
                                    <span
                                        v-if="hasStock(product)"
                                        class="font-bold"
                                    >
                                        {{ formatStock(product.stock_quantity) }}
                                    </span>
                                <span
                                    v-else
                                    class="inline-flex rounded-full bg-muted px-2 py-0.5 text-xs font-medium text-muted-foreground"
                                >
                                        Нет
                                    </span>
                            </td>

                            <td class="px-4 py-3 text-right whitespace-nowrap tabular-nums">
                                {{ formatPrice(product.retail_price) }}
                            </td>

                            <!-- Быстрые переключатели -->
                            <td class="px-4 py-3">
                                <div class="flex items-center justify-center gap-1.5">
                                    <button
                                        type="button"
                                        :class="[toggleBase, product.published ? publishedOn : publishedOff]"
                                        :title="product.published ? 'Опубликован — нажмите, чтобы скрыть' : 'Не опубликован — нажмите, чтобы опубликовать'"
                                        :aria-pressed="product.published"
                                        @click="togglePublished(product)"
                                    >
                                        <Globe :size="15" />
                                        <span class="sr-only">Публикация</span>
                                    </button>

                                    <button
                                        type="button"
                                        :class="[toggleBase, product.is_featured ? featuredOn : featuredOff]"
                                        :title="product.is_featured ? 'Популярный — нажмите, чтобы убрать' : 'Отметить популярным'"
                                        :aria-pressed="product.is_featured"
                                        @click="toggleFeatured(product)"
                                    >
                                        <Star :size="15" :class="product.is_featured ? 'fill-current' : ''" />
                                        <span class="sr-only">Популярный</span>
                                    </button>
                                </div>
                            </td>

                            <td class="px-4 py-3 text-right whitespace-nowrap">
                                <div class="flex items-center justify-end gap-0.5">
                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        as-child
                                        class="size-9 text-muted-foreground hover:text-primary"
                                    >
                                        <Link :href="show(product.id).url" title="Просмотр">
                                            <Eye :size="17" />
                                            <span class="sr-only">Просмотр</span>
                                        </Link>
                                    </Button>

                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        as-child
                                        class="size-9 text-muted-foreground hover:text-primary"
                                    >
                                        <Link :href="edit(product.id).url" title="Изменить">
                                            <Pencil :size="17" />
                                            <span class="sr-only">Изменить</span>
                                        </Link>
                                    </Button>

                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        class="size-9 text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
                                        title="Удалить"
                                        @click="openDeleteDialog(product)"
                                    >
                                        <Trash2 :size="17" />
                                        <span class="sr-only">Удалить</span>
                                    </Button>
                                </div>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </template>

            <!-- Пагинация -->
            <div
                v-if="hasPagination"
                class="flex flex-col gap-4 border-t px-5 py-4 sm:flex-row sm:items-center sm:justify-between"
            >
                <p class="text-sm text-muted-foreground">
                    Показано
                    <span class="font-medium text-foreground">
                        {{ products.from ?? 0 }}–{{ products.to ?? 0 }}
                    </span>
                    из
                    <span class="font-medium text-foreground">{{ products.total }}</span>
                    товаров
                </p>

                <nav
                    class="flex flex-wrap items-center justify-center gap-1"
                    aria-label="Навигация по страницам товаров"
                >
                    <Link
                        v-if="prevLink?.url"
                        :href="prevLink.url"
                        preserve-scroll
                        preserve-state
                        :class="[pageButtonBase, 'gap-1 text-muted-foreground hover:border-primary/30 hover:text-primary']"
                    >
                        <ChevronLeft :size="16" />
                        Назад
                    </Link>
                    <span
                        v-else
                        :class="[pageButtonBase, 'cursor-not-allowed gap-1 border-transparent text-muted-foreground/40']"
                    >
                        <ChevronLeft :size="16" />
                        Назад
                    </span>

                    <template
                        v-for="(link, index) in pageLinks"
                        :key="`${index}-${link.label}`"
                    >
                        <Link
                            v-if="link.url"
                            :href="link.url"
                            preserve-scroll
                            preserve-state
                            :class="[
                                pageButtonBase,
                                link.active
                                    ? 'border-primary bg-primary text-primary-foreground shadow-xs'
                                    : 'text-muted-foreground hover:border-primary/30 hover:text-primary',
                            ]"
                            :aria-current="link.active ? 'page' : undefined"
                        >
                            {{ link.label }}
                        </Link>
                        <span
                            v-else
                            class="inline-flex h-9 min-w-9 items-center justify-center px-2 text-sm text-muted-foreground"
                        >
                            {{ link.label }}
                        </span>
                    </template>

                    <Link
                        v-if="nextLink?.url"
                        :href="nextLink.url"
                        preserve-scroll
                        preserve-state
                        :class="[pageButtonBase, 'gap-1 text-muted-foreground hover:border-primary/30 hover:text-primary']"
                    >
                        Далее
                        <ChevronRight :size="16" />
                    </Link>
                    <span
                        v-else
                        :class="[pageButtonBase, 'cursor-not-allowed gap-1 border-transparent text-muted-foreground/40']"
                    >
                        Далее
                        <ChevronRight :size="16" />
                    </span>
                </nav>
            </div>
        </section>

        <ConfirmDeleteDialog
            :open="deleteDialog.open"
            title="Удаление товара"
            description="Вы уверены, что хотите удалить товар"
            :item-name="deleteDialog.name"
            :loading="deleteDialog.loading"
            @confirm="confirmDelete"
            @cancel="closeDeleteDialog"
        />
    </div>
</template>
