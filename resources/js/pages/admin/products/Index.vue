<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, onBeforeUnmount, ref, watch } from 'vue';
import {
    ChevronLeft,
    ChevronRight,
    Eye,
    Package,
    Pencil,
    Plus,
    Search,
    Trash2,
    X,
} from '@lucide/vue';
import { toast } from 'vue-sonner';
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
    stock_quantity: number | null;
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

interface Filters {
    search: string;
    category_id: number | null;
    product_type_id: number | null;
}

interface Props {
    products: PaginatedProducts;
    filters: Filters;
    categories: Category[];
    productTypes: ProductType[];
}

const props = defineProps<Props>();

/* ---------- Форматирование ---------- */

const numberFormat = new Intl.NumberFormat('ru-RU', {
    maximumFractionDigits: 3,
});

const formatStock = (value: number | string | null | undefined): string =>
    numberFormat.format(Number(value ?? 0));

const hasStock = (product: Product): boolean =>
    Number(product.stock_quantity ?? 0) > 0;

/* ---------- Фильтры ---------- */

const search = ref(props.filters.search ?? '');
const categoryId = ref(props.filters.category_id?.toString() ?? 'all');
const productTypeId = ref(props.filters.product_type_id?.toString() ?? 'all');

// Типы показываем только для выбранной категории
const availableTypes = computed(() =>
    categoryId.value === 'all'
        ? props.productTypes
        : props.productTypes.filter(
            (type) => String(type.category_id) === categoryId.value,
        ),
);

const activeFiltersCount = computed(
    () =>
        [
            search.value,
            categoryId.value !== 'all' ? categoryId.value : '',
            productTypeId.value !== 'all' ? productTypeId.value : '',
        ].filter(Boolean).length,
);

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
watch([search, categoryId, productTypeId], () => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(submitFilters, 350);
});

onBeforeUnmount(() => clearTimeout(debounceTimer));

const resetFilters = (): void => {
    search.value = '';
    categoryId.value = 'all';
    productTypeId.value = 'all';
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
            toast.error(
                'Не удалось удалить товар. Проверьте данные и попробуйте ещё раз.',
            );
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

const activeBadge =
    'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400';
const inactiveBadge = 'bg-muted text-muted-foreground ring-border';
</script>

<template>
    <Head title="Товары" />

    <div class="space-y-6">
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
            <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-[2fr_1fr_1fr]">
                <div class="space-y-1.5 md:col-span-2 lg:col-span-1">
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
                            placeholder="Название или артикул"
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

                <div class="space-y-1.5">
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

                <div class="space-y-1.5">
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
            </div>

            <div v-if="activeFiltersCount" class="mt-4 flex justify-end border-t pt-3">
                <Button
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
                    >
                        <div class="flex items-start justify-between gap-3">
                            <div class="min-w-0">
                                <h3 class="break-words text-sm font-semibold">
                                    {{ product.name }}
                                </h3>
                                <p v-if="product.code" class="mt-1 font-mono text-xs text-muted-foreground">
                                        Код: {{ product.code }}
                                    </p>
                                <p v-if="product.article" class="font-mono text-xs text-muted-foreground">
                                        Артикул: {{ product.article }}
                                    </p>
                            </div>

                            <span
                                class="inline-flex shrink-0 items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset"
                                :class="product.is_active ? activeBadge : inactiveBadge"
                            >
                                <span
                                    class="size-1.5 rounded-full"
                                    :class="product.is_active ? 'bg-emerald-500' : 'bg-muted-foreground/50'"
                                />
                                {{ product.is_active ? 'Активен' : 'Неактивен' }}
                            </span>
                        </div>

                        <div class="grid grid-cols-3 gap-2 text-center">
                            <div class="min-w-0 rounded-lg bg-muted/50 px-2 py-2">
                                <p class="text-[11px] text-muted-foreground">Категория</p>
                                <p class="mt-0.5 truncate text-xs font-medium">
                                    {{ product.category.name }}
                                </p>
                            </div>
                            <div class="min-w-0 rounded-lg bg-muted/50 px-2 py-2">
                                <p class="text-[11px] text-muted-foreground">Тип</p>
                                <p class="mt-0.5 truncate text-xs font-medium">
                                    {{ product.product_type?.name ?? '—' }}
                                </p>
                            </div>
                            <div class="rounded-lg bg-muted/50 px-2 py-2">
                                <p class="text-[11px] text-muted-foreground">Остаток</p>
                                <p
                                    class="mt-0.5 text-xs font-bold tabular-nums"
                                    :class="hasStock(product) ? '' : 'text-muted-foreground'"
                                >
                                    {{ formatStock(product.stock_quantity) }}
                                </p>
                            </div>
                        </div>

                        <div class="flex items-center gap-2">
                            <Button
                                as-child
                                variant="outline"
                                size="sm"
                                class="h-9 flex-1"
                            >
                                <Link :href="show(product.id).url">
                                    <Eye :size="14" class="mr-1.5" />
                                    Просмотр
                                </Link>
                            </Button>

                            <Button
                                as-child
                                variant="outline"
                                size="sm"
                                class="h-9 flex-1"
                            >
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
                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full text-left text-sm">
                        <thead>
                        <tr class="border-b bg-muted/40">
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase">Товар</th>
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase">Код товара</th>
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase">Артикул</th>
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase">Категория</th>
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase">Тип</th>
                            <th scope="col" class="px-5 py-3.5 text-right text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase">Остаток</th>
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase">Статус</th>
                            <th scope="col" class="px-5 py-3.5">
                                <span class="sr-only">Действия</span>
                            </th>
                        </tr>
                        </thead>

                        <tbody class="divide-y">
                        <tr
                            v-for="product in products.data"
                            :key="product.id"
                            class="transition-colors hover:bg-muted/40"
                        >
                            <td class="px-5 py-4">
                                <div class="font-semibold">
                                    {{ product.name }}
                                </div>
                            </td>

                            <td class="px-5 py-4 whitespace-nowrap">
                                    <span
                                        class="inline-flex rounded-md border bg-muted/50 px-2 py-1 font-mono text-xs"
                                    >
                                    {{ product.code }}
                                    </span>
                            </td>

                            <td class="px-5 py-4 whitespace-nowrap text-muted-foreground">
                                    <span
                                        v-if="product.article"
                                        class="inline-flex rounded-md border bg-muted/50 px-2 py-1 font-mono text-xs"
                                    >
                                    {{ product.article }}
                                    </span>
                                    <span v-else>—</span>
                            </td>

                            <td class="px-5 py-4 text-muted-foreground">
                                {{ product.category.name }}
                            </td>

                            <td class="px-5 py-4 text-muted-foreground">
                                {{ product.product_type?.name ?? '—' }}
                            </td>

                            <td
                                class="px-5 py-4 text-right font-bold whitespace-nowrap tabular-nums"
                                :class="hasStock(product) ? '' : 'text-muted-foreground/60'"
                            >
                                {{ formatStock(product.stock_quantity) }}
                            </td>

                            <td class="px-5 py-4 whitespace-nowrap">
                                    <span
                                        class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset"
                                        :class="product.is_active ? activeBadge : inactiveBadge"
                                    >
                                        <span
                                            class="size-1.5 rounded-full"
                                            :class="product.is_active ? 'bg-emerald-500' : 'bg-muted-foreground/50'"
                                        />
                                        {{ product.is_active ? 'Активен' : 'Неактивен' }}
                                    </span>
                            </td>

                            <td class="px-5 py-4 text-right whitespace-nowrap">
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
