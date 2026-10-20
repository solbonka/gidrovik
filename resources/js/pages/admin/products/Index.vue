<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { ref } from 'vue';
import {
    Package,
    Search,
    X,
    Plus,
    Eye,
    Pencil,
    Trash2,
    ChevronLeft,
    ChevronRight,
    SlidersHorizontal,
    Boxes,
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
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
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
    sku: string;
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

const search = ref(props.filters.search);
const categoryId = ref(props.filters.category_id?.toString() ?? '');
const productTypeId = ref(props.filters.product_type_id?.toString() ?? '');

const deleteDialog = ref({
    open: false,
    id: null as number | null,
    name: '',
    loading: false,
});

const submitFilters = (): void => {
    router.get(
        '/admin/products',
        {
            search: search.value || undefined,
            category_id:
                categoryId.value && categoryId.value !== 'all'
                    ? categoryId.value
                    : undefined,
            product_type_id:
                productTypeId.value && productTypeId.value !== 'all'
                    ? productTypeId.value
                    : undefined,
        },
        {
            preserveState: true,
            preserveScroll: true,
        },
    );
};

const resetFilters = (): void => {
    search.value = '';
    categoryId.value = 'all';
    productTypeId.value = 'all';

    router.get('/admin/products');
};

const openDeleteDialog = (product: Product): void => {
    deleteDialog.value.id = product.id;
    deleteDialog.value.name = product.name;
    deleteDialog.value.open = true;
};

const confirmDelete = (): void => {
    if (deleteDialog.value.id === null) return;

    deleteDialog.value.loading = true;

    router.delete(destroy(deleteDialog.value.id).url, {
        preserveScroll: true,

        onSuccess: (page) => {
            const flash = page.props.flash as {
                success?: string | null;
                error?: string | null;
            };

            if (flash.error) {
                toast.error(flash.error);
                return;
            }

            if (flash.success) {
                toast.success(flash.success);
            }
        },

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
</script>

<template>
    <Head title="Товары" />

    <div class="space-y-8">
        <!-- Заголовок -->
        <header
            class="flex flex-col justify-between gap-4 sm:flex-row sm:items-center"
        >
            <div class="flex items-center gap-3">
                <div
                    class="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-primary to-indigo-600 text-white shadow-lg"
                >
                    <Package :size="24" />
                </div>

                <div>
                    <h1
                        class="bg-gradient-to-r from-foreground to-muted-foreground bg-clip-text text-3xl font-bold text-transparent"
                    >
                        Товары
                    </h1>

                    <p class="mt-1 text-sm text-muted-foreground">
                        Каталог товаров и их складские остатки.
                    </p>
                </div>
            </div>

            <Link
                :href="create().url"
                class="inline-flex items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-primary to-indigo-600 px-5 py-3 text-sm font-semibold text-white shadow-md transition-all duration-200 hover:-translate-y-0.5 hover:from-primary/90 hover:to-indigo-600/90 hover:shadow-lg focus-visible:ring-2 focus-visible:ring-primary/50 focus-visible:outline-none"
            >
                <Plus :size="18" />
                Добавить товар
            </Link>
        </header>

        <!-- Фильтры -->
        <Card
            class="overflow-hidden rounded-2xl border-border/50 bg-gradient-to-br from-white to-muted/20 shadow-sm"
        >
            <CardHeader class="border-b border-border/50 px-6 py-5">
                <CardTitle class="flex items-center gap-3 text-base">
                    <span
                        class="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary/10 to-indigo-500/10 text-primary"
                    >
                        <SlidersHorizontal :size="20" />
                    </span>
                    Фильтры товаров
                </CardTitle>
            </CardHeader>

            <CardContent class="p-6">
                <div class="grid gap-5 lg:grid-cols-4">
                    <div class="lg:col-span-2">
                        <Label
                            for="search"
                            class="font-semibold text-foreground"
                        >
                            Поиск
                        </Label>

                        <div class="relative mt-2">
                            <Search
                                :size="17"
                                class="absolute top-1/2 left-3 -translate-y-1/2 text-muted-foreground"
                            />

                            <Input
                                id="search"
                                v-model="search"
                                type="search"
                                placeholder="Название или артикул..."
                                class="h-11 rounded-xl border-border bg-background pr-10 pl-10 transition-all focus-visible:border-primary/50 focus-visible:ring-primary/20"
                                @keyup.enter="submitFilters"
                            />

                            <Button
                                v-if="search"
                                type="button"
                                variant="ghost"
                                size="icon"
                                class="absolute top-1/2 right-1 h-8 w-8 -translate-y-1/2 rounded-lg text-muted-foreground hover:bg-primary/10 hover:text-primary"
                                @click="
                                    search = '';
                                    submitFilters();
                                "
                            >
                                <X :size="16" />
                                <span class="sr-only">Очистить поиск</span>
                            </Button>
                        </div>
                    </div>

                    <div>
                        <Label
                            for="category"
                            class="font-semibold text-foreground"
                        >
                            Категория
                        </Label>

                        <Select
                            v-model="categoryId"
                            @update:model-value="submitFilters"
                        >
                            <SelectTrigger
                                id="category"
                                class="mt-2 h-11 rounded-xl border-border bg-background focus:ring-primary/20"
                            >
                                <SelectValue placeholder="Все категории" />
                            </SelectTrigger>

                            <SelectContent>
                                <SelectItem value="all">
                                    Все категории
                                </SelectItem>

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

                    <div>
                        <Label
                            for="product-type"
                            class="font-semibold text-foreground"
                        >
                            Тип товара
                        </Label>

                        <Select
                            v-model="productTypeId"
                            @update:model-value="submitFilters"
                        >
                            <SelectTrigger
                                id="product-type"
                                class="mt-2 h-11 rounded-xl border-border bg-background focus:ring-primary/20"
                            >
                                <SelectValue placeholder="Все типы" />
                            </SelectTrigger>

                            <SelectContent>
                                <SelectItem value="all"> Все типы </SelectItem>

                                <SelectItem
                                    v-for="productType in productTypes"
                                    :key="productType.id"
                                    :value="productType.id.toString()"
                                >
                                    {{ productType.name }}
                                </SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                </div>

                <div class="mt-5 flex flex-wrap gap-3">
                    <Button
                        type="button"
                        class="gap-2 rounded-xl bg-gradient-to-r from-primary to-indigo-600 px-5 shadow-sm transition-all hover:from-primary/90 hover:to-indigo-600/90"
                        @click="submitFilters"
                    >
                        <Search :size="16" />
                        Применить
                    </Button>

                    <Button
                        type="button"
                        variant="outline"
                        class="gap-2 rounded-xl border-primary/20 bg-gradient-to-r from-primary/5 to-indigo-500/5 hover:border-primary/40 hover:from-primary/10 hover:to-indigo-500/10"
                        @click="resetFilters"
                    >
                        <X :size="16" />
                        Сбросить
                    </Button>
                </div>
            </CardContent>
        </Card>

        <!-- Таблица товаров -->
        <Card
            class="overflow-hidden rounded-2xl border-border/50 bg-gradient-to-br from-white to-muted/20 shadow-sm"
        >
            <div
                class="flex flex-wrap items-center justify-between gap-3 border-b border-border/50 bg-white/50 px-6 py-5"
            >
                <div>
                    <h2 class="font-semibold text-foreground">
                        Список товаров
                    </h2>

                    <p class="mt-1 text-sm text-muted-foreground">
                        Всего товаров: {{ products.total }}
                    </p>
                </div>

                <div
                    class="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-primary/5 to-indigo-500/5 px-3 py-2 text-sm font-medium text-primary"
                >
                    <Boxes :size="17" />
                    Каталог склада
                </div>
            </div>

            <!-- Карточки на мобильных -->
            <div class="space-y-2 p-3 md:hidden">
                <div
                    v-for="product in products.data"
                    :key="product.id"
                    class="rounded-lg border border-border/50 bg-white p-3 shadow-sm transition-colors hover:border-primary/20"
                >
                    <!-- Заголовок карточки -->
                    <div class="flex items-start justify-between gap-2">
                        <div class="min-w-0 flex-1">
                            <h3 class="font-semibold text-foreground break-words text-xs">
                                {{ product.name }}
                            </h3>
                            <span
                                class="mt-0.5 inline-flex items-center rounded-md border border-primary/10 bg-gradient-to-r from-primary/5 to-indigo-500/5 px-1.5 py-0.5 font-mono text-[10px] font-medium text-primary"
                            >
                    {{ product.sku }}
                </span>
                        </div>

                        <!-- Статус -->
                        <span
                            class="inline-flex shrink-0 items-center gap-1 rounded-full border px-1.5 py-0.5 text-[10px] font-semibold"
                            :class="
                    product.is_active
                        ? 'border-emerald-200 bg-emerald-50 text-emerald-700'
                        : 'border-border bg-muted text-muted-foreground'
                "
                        >
                <span
                    class="h-1 w-1 rounded-full"
                    :class="
                        product.is_active
                            ? 'bg-emerald-500'
                            : 'bg-muted-foreground/50'
                    "
                />
                {{ product.is_active ? 'Активен' : 'Неактивен' }}
            </span>
                    </div>

                    <!-- Инфо-блок -->
                    <div class="mt-2 grid grid-cols-2 gap-1.5 text-xs">
                        <div>
                            <p class="text-[10px] text-muted-foreground">Категория</p>
                            <p class="text-foreground truncate">{{ product.category.name }}</p>
                        </div>
                        <div>
                            <p class="text-[10px] text-muted-foreground">Тип</p>
                            <p class="text-foreground truncate">
                                {{ product.product_type?.name ?? '—' }}
                            </p>
                        </div>
                        <div>
                            <p class="text-[10px] text-muted-foreground">Остаток</p>
                            <p
                                class="font-semibold"
                                :class="
                        Number(product.stock_quantity ?? 0) > 0
                            ? 'text-foreground'
                            : 'text-muted-foreground/60'
                    "
                            >
                                {{ product.stock_quantity ?? 0 }}
                            </p>
                        </div>
                    </div>

                    <!-- Действия -->
                    <div class="mt-3 flex items-center gap-1.5 border-t border-border/50 pt-2">
                        <Button
                            variant="outline"
                            size="sm"
                            as-child
                            class="flex-1 gap-1 rounded-md text-xs h-8"
                        >
                            <Link :href="show(product.id).url">
                                <Eye :size="13" />
                                Просмотр
                            </Link>
                        </Button>

                        <Button
                            variant="outline"
                            size="sm"
                            as-child
                            class="flex-1 gap-1 rounded-md text-xs h-8"
                        >
                            <Link :href="edit(product.id).url">
                                <Pencil :size="13" />
                                Изменить
                            </Link>
                        </Button>

                        <Button
                            variant="outline"
                            size="icon"
                            class="shrink-0 rounded-md text-red-600 hover:bg-red-50 hover:text-red-700 h-8 w-8"
                            @click="openDeleteDialog(product)"
                        >
                            <Trash2 :size="13" />
                            <span class="sr-only">Удалить</span>
                        </Button>
                    </div>
                </div>

                <!-- Пустое состояние -->
                <div
                    v-if="products.data.length === 0"
                    class="rounded-xl border border-border/50 bg-white p-8 text-center"
                >
                    <div
                        class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-primary/10 to-indigo-500/10 text-primary"
                    >
                        <Package :size="30" />
                    </div>
                    <p class="font-semibold text-foreground">Товары не найдены</p>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Измените параметры фильтров или добавьте новый товар.
                    </p>
                    <Link
                        :href="create().url"
                        class="mt-5 inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-primary to-indigo-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition-all hover:from-primary/90 hover:to-indigo-600/90"
                    >
                        <Plus :size="16" />
                        Добавить первый товар
                    </Link>
                </div>
            </div>

            <!-- Таблица на десктопе -->
            <div class="hidden overflow-x-auto md:block">
                <table class="w-full text-left text-sm">
                    <thead class="bg-muted/30">
                        <tr>
                            <th
                                class="px-6 py-4 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase"
                            >
                                Товар
                            </th>
                            <th
                                class="px-6 py-4 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase"
                            >
                                Артикул
                            </th>
                            <th
                                class="px-6 py-4 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase"
                            >
                                Категория
                            </th>
                            <th
                                class="px-6 py-4 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase"
                            >
                                Тип
                            </th>
                            <th
                                class="px-6 py-4 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase"
                            >
                                Остаток
                            </th>
                            <th
                                class="px-6 py-4 text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase"
                            >
                                Статус
                            </th>
                            <th
                                class="px-6 py-4 text-right text-xs font-semibold tracking-wider whitespace-nowrap text-muted-foreground uppercase"
                            >
                                Действия
                            </th>
                        </tr>
                    </thead>

                    <tbody class="divide-y divide-border/50">
                        <tr
                            v-for="product in products.data"
                            :key="product.id"
                            class="transition-colors hover:bg-primary/[0.03]"
                        >
                            <td class="px-6 py-4">
                                <div class="font-semibold text-foreground">
                                    {{ product.name }}
                                </div>
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap">
                                <span
                                    class="inline-flex items-center rounded-lg border border-primary/10 bg-gradient-to-r from-primary/5 to-indigo-500/5 px-2.5 py-1 font-mono text-xs font-medium text-primary"
                                >
                                    {{ product.sku }}
                                </span>
                            </td>

                            <td class="px-6 py-4 text-muted-foreground">
                                {{ product.category.name }}
                            </td>

                            <td class="px-6 py-4 text-muted-foreground">
                                {{ product.product_type?.name ?? '—' }}
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap">
                                <span
                                    class="font-semibold"
                                    :class="
                                        Number(product.stock_quantity ?? 0) > 0
                                            ? 'text-foreground'
                                            : 'text-muted-foreground/60'
                                    "
                                >
                                    {{ product.stock_quantity ?? 0 }}
                                </span>
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap">
                                <span
                                    class="inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-semibold"
                                    :class="
                                        product.is_active
                                            ? 'border-emerald-200 bg-emerald-50 text-emerald-700'
                                            : 'border-border bg-muted text-muted-foreground'
                                    "
                                >
                                    <span
                                        class="h-1.5 w-1.5 rounded-full"
                                        :class="
                                            product.is_active
                                                ? 'bg-emerald-500'
                                                : 'bg-muted-foreground/50'
                                        "
                                    />
                                    {{
                                        product.is_active
                                            ? 'Активен'
                                            : 'Неактивен'
                                    }}
                                </span>
                            </td>

                            <td class="px-6 py-4 text-right whitespace-nowrap">
                                <div
                                    class="flex items-center justify-end gap-1"
                                >
                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        as-child
                                        class="rounded-xl text-muted-foreground transition-colors hover:bg-primary/10 hover:text-primary"
                                    >
                                        <Link :href="show(product.id).url">
                                            <Eye :size="17" />
                                            <span class="sr-only"
                                                >Просмотр</span
                                            >
                                        </Link>
                                    </Button>

                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        as-child
                                        class="rounded-xl text-muted-foreground transition-colors hover:bg-primary/10 hover:text-primary"
                                    >
                                        <Link :href="edit(product.id).url">
                                            <Pencil :size="17" />
                                            <span class="sr-only"
                                                >Изменить</span
                                            >
                                        </Link>
                                    </Button>

                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        class="rounded-xl text-muted-foreground transition-colors hover:bg-red-50 hover:text-red-600"
                                        @click="openDeleteDialog(product)"
                                    >
                                        <Trash2 :size="17" />
                                        <span class="sr-only">Удалить</span>
                                    </Button>
                                </div>
                            </td>
                        </tr>

                        <tr v-if="products.data.length === 0">
                            <td colspan="7" class="px-6 py-16 text-center">
                                <div
                                    class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-primary/10 to-indigo-500/10 text-primary"
                                >
                                    <Package :size="30" />
                                </div>

                                <p class="font-semibold text-foreground">
                                    Товары не найдены
                                </p>

                                <p class="mt-1 text-sm text-muted-foreground">
                                    Измените параметры фильтров или добавьте
                                    новый товар.
                                </p>

                                <Link
                                    :href="create().url"
                                    class="mt-5 inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-primary to-indigo-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition-all hover:from-primary/90 hover:to-indigo-600/90"
                                >
                                    <Plus :size="16" />
                                    Добавить первый товар
                                </Link>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Пагинация -->
            <div
                v-if="products.links.length > 3"
                class="flex flex-col gap-4 border-t border-gray-100 px-4 py-5 sm:flex-row sm:items-center sm:justify-between dark:border-gray-800"
            >
                <!-- Информация о товарах -->
                <p class="text-sm text-gray-500 dark:text-gray-400">
                    <template v-if="products.total > 0">
                        Показано
                        <span
                            class="font-semibold text-gray-900 dark:text-gray-100"
                        >
                            {{ products.from }}–{{ products.to }}
                        </span>
                        из
                        <span
                            class="font-semibold text-gray-900 dark:text-gray-100"
                        >
                            {{ products.total }}
                        </span>
                        товаров
                    </template>

                    <template v-else> Товары не найдены </template>
                </p>

                <!-- Кнопки страниц -->
                <nav
                    v-if="products.total > 0"
                    class="flex flex-wrap items-center justify-center gap-1"
                    aria-label="Навигация по страницам товаров"
                >
                    <template
                        v-for="(link, index) in products.links"
                        :key="`${index}-${link.label}`"
                    >
                        <!-- Назад -->
                        <Link
                            v-if="index === 0 && link.url"
                            :href="link.url"
                            preserve-scroll
                            class="inline-flex h-9 items-center gap-2 rounded-xl border border-gray-200 px-3 text-sm font-medium text-gray-600 transition hover:border-primary/30 hover:bg-primary/5 hover:text-primary dark:border-gray-700 dark:text-gray-300"
                        >
                            <ChevronLeft class="h-4 w-4" />
                            <span>Назад</span>
                        </Link>

                        <span
                            v-else-if="index === 0"
                            class="inline-flex h-9 cursor-not-allowed items-center gap-2 rounded-xl border border-gray-100 px-3 text-sm text-gray-300 dark:border-gray-800 dark:text-gray-600"
                        >
                            <ChevronLeft class="h-4 w-4" />
                            <span>Назад</span>
                        </span>

                        <!-- Номера страниц -->
                        <Link
                            v-else-if="
                                index !== products.links.length - 1 && link.url
                            "
                            :href="link.url"
                            preserve-scroll
                            class="inline-flex h-9 min-w-9 items-center justify-center rounded-xl border px-3 text-sm font-medium transition"
                            :class="
                                link.active
                                    ? 'border-primary bg-gradient-to-r from-primary to-indigo-600 text-white shadow-sm'
                                    : 'border-gray-200 text-gray-600 hover:border-primary/30 hover:bg-primary/5 hover:text-primary dark:border-gray-700 dark:text-gray-300'
                            "
                            v-html="link.label"
                        />

                        <span
                            v-else-if="index !== products.links.length - 1"
                            class="inline-flex h-9 min-w-9 items-center justify-center px-2 text-sm text-gray-400"
                            v-html="link.label"
                        />

                        <!-- Далее -->
                        <Link
                            v-else-if="link.url"
                            :href="link.url"
                            preserve-scroll
                            class="inline-flex h-9 items-center gap-2 rounded-xl border border-gray-200 px-3 text-sm font-medium text-gray-600 transition hover:border-primary/30 hover:bg-primary/5 hover:text-primary dark:border-gray-700 dark:text-gray-300"
                        >
                            <span>Далее</span>
                            <ChevronRight class="h-4 w-4" />
                        </Link>

                        <span
                            v-else
                            class="inline-flex h-9 cursor-not-allowed items-center gap-2 rounded-xl border border-gray-100 px-3 text-sm text-gray-300 dark:border-gray-800 dark:text-gray-600"
                        >
                            <span>Далее</span>
                            <ChevronRight class="h-4 w-4" />
                        </span>
                    </template>
                </nav>
            </div>
        </Card>

        <ConfirmDeleteDialog
            :open="deleteDialog.open"
            title="Удаление товара"
            description="Вы уверены, что хотите удалить товар"
            :item-name="deleteDialog.name"
            :loading="deleteDialog.loading"
            @confirm="confirmDelete"
            @cancel="deleteDialog.open = false"
        />
    </div>
</template>
