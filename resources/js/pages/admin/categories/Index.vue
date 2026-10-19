<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';
import { toast } from 'vue-sonner';
import {
    Folder,
    FolderOpen,
    Tag,
    List,
    Plus,
    Pencil,
    Trash2,
    Settings2,
    Package,
    ChevronRight,
    Layers3,
    Search,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { create, edit, destroy } from '@/routes/admin/categories';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';

defineOptions({
    layout: AdminLayout,
});

interface Category {
    id: number;
    name: string;
    slug: string;
    is_active: boolean;
    products_count: number;
    product_types_count: number;
    characteristics_count: number;
}

interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

interface PaginatedCategories {
    data: Category[];
    links: PaginationLink[];
    current_page: number;
    last_page: number;
    total: number;
}

const props = defineProps<{
    categories: PaginatedCategories;
}>();

const deleteDialog = ref({
    open: false,
    id: null as number | null,
    name: '',
    loading: false,
});

const search = ref('');

const filteredCategories = computed(() => {
    const query = search.value.trim().toLowerCase();

    if (!query) {
        return props.categories.data;
    }

    return props.categories.data.filter((category) =>
        [category.name, category.slug].some((value) =>
            value.toLowerCase().includes(query),
        ),
    );
});

const activeCategories = computed(
    () => props.categories.data.filter((category) => category.is_active).length,
);

const inactiveCategories = computed(
    () =>
        props.categories.data.filter((category) => !category.is_active).length,
);

const totalProducts = computed(() =>
    props.categories.data.reduce(
        (total, category) => total + category.products_count,
        0,
    ),
);

const openDeleteDialog = (category: Category): void => {
    if (category.products_count > 0) {
        toast.error('Нельзя удалить категорию, в которой есть товары.');
        return;
    }

    deleteDialog.value.id = category.id;
    deleteDialog.value.name = category.name;
    deleteDialog.value.open = true;
};

const confirmDelete = (): void => {
    if (deleteDialog.value.id === null) return;

    deleteDialog.value.loading = true;

    router.delete(destroy.url(deleteDialog.value.id), {
        onSuccess: () => {
            toast.success('Категория удалена.');
        },
        onError: () => {
            toast.error('Не удалось удалить категорию.');
        },
        onFinish: () => {
            deleteDialog.value.loading = false;
            deleteDialog.value.open = false;
        },
    });
};
</script>

<template>
    <Head title="Категории" />

    <div class="space-y-6 pb-8">
        <!-- Заголовок страницы -->
        <div
            class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-slate-800 to-indigo-950 px-5 py-6 shadow-lg sm:px-8 sm:py-8"
        >
            <div
                class="pointer-events-none absolute -top-20 -right-12 h-64 w-64 rounded-full bg-indigo-500/20 blur-3xl"
            />
            <div
                class="pointer-events-none absolute right-1/3 -bottom-24 h-48 w-48 rounded-full bg-blue-400/10 blur-3xl"
            />

            <div
                class="relative flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between"
            >
                <div class="flex items-start gap-4">
                    <div
                        class="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl border border-white/10 bg-white/10 text-white shadow-inner sm:h-14 sm:w-14"
                    >
                        <FolderOpen :size="27" />
                    </div>

                    <div>
                        <div
                            class="mb-1 flex items-center gap-2 text-xs font-medium text-slate-300"
                        >
                            <span>Склад</span>
                            <ChevronRight :size="13" />
                            <span class="text-white/90">Справочники</span>
                        </div>

                        <h1
                            class="text-2xl font-bold tracking-tight text-white sm:text-3xl"
                        >
                            Категории товаров
                        </h1>

                        <p
                            class="mt-2 max-w-xl text-sm leading-6 text-slate-300"
                        >
                            Управление категориями, типами товаров и их
                            характеристиками.
                        </p>
                    </div>
                </div>

                <Link
                    :href="create.url()"
                    class="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-white px-4 py-2.5 text-sm font-semibold text-slate-900 shadow-sm transition hover:bg-slate-100 focus:ring-2 focus:ring-white/70 focus:ring-offset-2 focus:ring-offset-slate-900 focus:outline-none"
                >
                    <Plus :size="17" />
                    Добавить категорию
                </Link>
            </div>
        </div>

        <!-- Статистика -->
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div
                class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-700 dark:bg-slate-900"
            >
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p
                            class="text-sm font-medium text-slate-500 dark:text-slate-400"
                        >
                            Всего категорий
                        </p>
                        <p
                            class="mt-2 text-3xl font-bold tracking-tight text-slate-900 dark:text-white"
                        >
                            {{ categories.total }}
                        </p>
                    </div>
                    <div
                        class="flex h-12 w-12 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400"
                    >
                        <Folder :size="23" />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    В справочнике категорий
                </p>
            </div>

            <div
                class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-700 dark:bg-slate-900"
            >
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p
                            class="text-sm font-medium text-slate-500 dark:text-slate-400"
                        >
                            Активные
                        </p>
                        <p
                            class="mt-2 text-3xl font-bold tracking-tight text-slate-900 dark:text-white"
                        >
                            {{ activeCategories }}
                        </p>
                    </div>
                    <div
                        class="flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-50 text-emerald-600 dark:bg-emerald-500/10 dark:text-emerald-400"
                    >
                        <Layers3 :size="23" />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    Доступны для использования
                </p>
            </div>

            <div
                class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-700 dark:bg-slate-900"
            >
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p
                            class="text-sm font-medium text-slate-500 dark:text-slate-400"
                        >
                            Неактивные
                        </p>
                        <p
                            class="mt-2 text-3xl font-bold tracking-tight text-slate-900 dark:text-white"
                        >
                            {{ inactiveCategories }}
                        </p>
                    </div>
                    <div
                        class="flex h-12 w-12 items-center justify-center rounded-xl bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400"
                    >
                        <FolderOpen :size="23" />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    Отключены от использования
                </p>
            </div>

            <div
                class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-700 dark:bg-slate-900"
            >
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p
                            class="text-sm font-medium text-slate-500 dark:text-slate-400"
                        >
                            Товары
                        </p>
                        <p
                            class="mt-2 text-3xl font-bold tracking-tight text-slate-900 dark:text-white"
                        >
                            {{ totalProducts }}
                        </p>
                    </div>
                    <div
                        class="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-50 text-blue-600 dark:bg-blue-500/10 dark:text-blue-400"
                    >
                        <Package :size="23" />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    В категориях текущей страницы
                </p>
            </div>
        </div>

        <!-- Таблица -->
        <div
            class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-700 dark:bg-slate-900"
        >
            <div
                class="flex flex-col gap-4 border-b border-slate-200 px-5 py-5 sm:flex-row sm:items-center sm:justify-between sm:px-6 dark:border-slate-700"
            >
                <div>
                    <h2
                        class="text-lg font-semibold text-slate-900 dark:text-white"
                    >
                        Список категорий
                    </h2>
                    <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
                        Найдено на странице: {{ filteredCategories.length }}
                    </p>
                </div>

                <div class="relative w-full sm:max-w-xs">
                    <Search
                        :size="17"
                        class="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-slate-400"
                    />
                    <input
                        v-model="search"
                        type="search"
                        placeholder="Поиск по названию или slug..."
                        class="w-full rounded-xl border border-slate-200 bg-slate-50 py-2.5 pr-10 pl-10 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:border-indigo-400 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 dark:border-slate-700 dark:bg-slate-800 dark:text-white dark:focus:border-indigo-500 dark:focus:bg-slate-800"
                    />
                    <button
                        v-if="search"
                        type="button"
                        aria-label="Очистить поиск"
                        class="absolute top-1/2 right-3 -translate-y-1/2 text-slate-400 transition hover:text-slate-700 dark:hover:text-white"
                        @click="search = ''"
                    >
                        <X :size="16" />
                    </button>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full min-w-[850px]">
                    <thead>
                        <tr
                            class="border-b border-slate-200 bg-slate-50/80 dark:border-slate-700 dark:bg-slate-800/60"
                        >
                            <th
                                class="px-6 py-4 text-left text-xs font-semibold tracking-wider text-slate-500 uppercase dark:text-slate-400"
                            >
                                Категория
                            </th>
                            <th
                                class="px-4 py-4 text-center text-xs font-semibold tracking-wider text-slate-500 uppercase dark:text-slate-400"
                            >
                                Товары
                            </th>
                            <th
                                class="px-4 py-4 text-center text-xs font-semibold tracking-wider text-slate-500 uppercase dark:text-slate-400"
                            >
                                Типы
                            </th>
                            <th
                                class="px-4 py-4 text-center text-xs font-semibold tracking-wider text-slate-500 uppercase dark:text-slate-400"
                            >
                                Характеристики
                            </th>
                            <th
                                class="px-4 py-4 text-left text-xs font-semibold tracking-wider text-slate-500 uppercase dark:text-slate-400"
                            >
                                Статус
                            </th>
                            <th
                                class="px-6 py-4 text-right text-xs font-semibold tracking-wider text-slate-500 uppercase dark:text-slate-400"
                            >
                                Действия
                            </th>
                        </tr>
                    </thead>

                    <tbody
                        class="divide-y divide-slate-100 dark:divide-slate-800"
                    >
                        <tr
                            v-for="category in filteredCategories"
                            :key="category.id"
                            class="group transition-colors hover:bg-slate-50/80 dark:hover:bg-slate-800/40"
                        >
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 transition group-hover:bg-indigo-100 dark:bg-indigo-500/10 dark:text-indigo-400 dark:group-hover:bg-indigo-500/20"
                                    >
                                        <FolderOpen :size="19" />
                                    </div>
                                    <div class="min-w-0">
                                        <p
                                            class="font-semibold text-slate-900 dark:text-white"
                                        >
                                            {{ category.name }}
                                        </p>
                                        <p
                                            class="mt-1 text-xs text-slate-500 dark:text-slate-400"
                                        >
                                            {{ category.slug }}
                                        </p>
                                    </div>
                                </div>
                            </td>

                            <td class="px-4 py-4 text-center">
                                <span
                                    class="inline-flex min-w-9 items-center justify-center rounded-lg bg-blue-50 px-2.5 py-1.5 text-sm font-semibold text-blue-700 tabular-nums dark:bg-blue-500/10 dark:text-blue-300"
                                >
                                    {{ category.products_count }}
                                </span>
                            </td>

                            <td class="px-4 py-4 text-center">
                                <span
                                    class="inline-flex min-w-9 items-center justify-center rounded-lg bg-violet-50 px-2.5 py-1.5 text-sm font-semibold text-violet-700 tabular-nums dark:bg-violet-500/10 dark:text-violet-300"
                                >
                                    {{ category.product_types_count }}
                                </span>
                            </td>

                            <td class="px-4 py-4 text-center">
                                <span
                                    class="inline-flex min-w-9 items-center justify-center rounded-lg bg-amber-50 px-2.5 py-1.5 text-sm font-semibold text-amber-700 tabular-nums dark:bg-amber-500/10 dark:text-amber-300"
                                >
                                    {{ category.characteristics_count }}
                                </span>
                            </td>

                            <td class="px-4 py-4">
                                <span
                                    class="inline-flex items-center gap-2 rounded-full px-2.5 py-1.5 text-xs font-semibold"
                                    :class="
                                        category.is_active
                                            ? 'bg-emerald-50 text-emerald-700 ring-1 ring-emerald-600/20 ring-inset dark:bg-emerald-500/10 dark:text-emerald-300 dark:ring-emerald-500/20'
                                            : 'bg-slate-100 text-slate-600 ring-1 ring-slate-500/20 ring-inset dark:bg-slate-800 dark:text-slate-400 dark:ring-slate-600/30'
                                    "
                                >
                                    <span
                                        class="h-1.5 w-1.5 rounded-full"
                                        :class="
                                            category.is_active
                                                ? 'bg-emerald-500'
                                                : 'bg-slate-400'
                                        "
                                    />
                                    {{
                                        category.is_active
                                            ? 'Активна'
                                            : 'Неактивна'
                                    }}
                                </span>
                            </td>

                            <td class="px-6 py-4">
                                <div
                                    class="flex items-center justify-end gap-1.5"
                                >
                                    <Link
                                        :href="`/admin/categories/${category.id}/characteristics`"
                                        title="Управление характеристиками"
                                        class="inline-flex h-9 items-center gap-2 rounded-lg border border-slate-200 px-3 text-sm font-medium text-slate-600 transition hover:border-indigo-200 hover:bg-indigo-50 hover:text-indigo-700 focus:ring-2 focus:ring-indigo-500/20 focus:outline-none dark:border-slate-700 dark:text-slate-300 dark:hover:border-indigo-500/40 dark:hover:bg-indigo-500/10 dark:hover:text-indigo-300"
                                    >
                                        <Settings2 :size="15" />
                                        <span class="hidden xl:inline"
                                            >Характеристики</span
                                        >
                                    </Link>

                                    <Link
                                        :href="edit.url(category.id)"
                                        title="Изменить категорию"
                                        class="inline-flex h-9 items-center justify-center gap-2 rounded-lg border border-slate-200 px-3 text-sm font-medium text-slate-600 transition hover:border-blue-200 hover:bg-blue-50 hover:text-blue-700 focus:ring-2 focus:ring-blue-500/20 focus:outline-none dark:border-slate-700 dark:text-slate-300 dark:hover:border-blue-500/40 dark:hover:bg-blue-500/10 dark:hover:text-blue-300"
                                    >
                                        <Pencil :size="15" />
                                        <span class="hidden xl:inline"
                                            >Изменить</span
                                        >
                                    </Link>

                                    <button
                                        type="button"
                                        title="Удалить категорию"
                                        :disabled="category.products_count > 0"
                                        class="inline-flex h-9 items-center justify-center gap-2 rounded-lg border border-slate-200 px-3 text-sm font-medium text-slate-500 transition hover:border-red-200 hover:bg-red-50 hover:text-red-600 focus:ring-2 focus:ring-red-500/20 focus:outline-none disabled:cursor-not-allowed disabled:opacity-40 disabled:hover:border-slate-200 disabled:hover:bg-transparent disabled:hover:text-slate-500 dark:border-slate-700 dark:text-slate-400 dark:hover:border-red-500/30 dark:hover:bg-red-500/10 dark:hover:text-red-400 dark:disabled:hover:border-slate-700"
                                        @click="openDeleteDialog(category)"
                                    >
                                        <Trash2 :size="15" />
                                        <span class="hidden xl:inline"
                                            >Удалить</span
                                        >
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <tr v-if="filteredCategories.length === 0">
                            <td colspan="6" class="px-6 py-16 text-center">
                                <div
                                    class="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-slate-100 text-slate-400 dark:bg-slate-800 dark:text-slate-500"
                                >
                                    <Search v-if="search" :size="28" />
                                    <Folder v-else :size="28" />
                                </div>

                                <h3
                                    class="mt-4 text-sm font-semibold text-slate-900 dark:text-white"
                                >
                                    {{
                                        search
                                            ? 'Ничего не найдено'
                                            : 'Категорий пока нет'
                                    }}
                                </h3>

                                <p
                                    class="mx-auto mt-1 max-w-sm text-sm text-slate-500 dark:text-slate-400"
                                >
                                    {{
                                        search
                                            ? 'Попробуйте изменить поисковый запрос.'
                                            : 'Создайте первую категорию, чтобы организовать товары склада.'
                                    }}
                                </p>

                                <button
                                    v-if="search"
                                    type="button"
                                    class="mt-4 inline-flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-semibold text-indigo-600 transition hover:bg-indigo-50 dark:text-indigo-400 dark:hover:bg-indigo-500/10"
                                    @click="search = ''"
                                >
                                    <X :size="15" />
                                    Очистить поиск
                                </button>

                                <Link
                                    v-else
                                    :href="create.url()"
                                    class="mt-4 inline-flex items-center gap-2 rounded-lg bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-slate-800 dark:bg-white dark:text-slate-900 dark:hover:bg-slate-100"
                                >
                                    <Plus :size="16" />
                                    Добавить категорию
                                </Link>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Пагинация -->
            <div
                v-if="categories.last_page > 1"
                class="flex flex-col gap-4 border-t border-slate-200 px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6 dark:border-slate-700"
            >
                <p class="text-sm text-slate-500 dark:text-slate-400">
                    Страница
                    <span class="font-semibold text-slate-900 dark:text-white">
                        {{ categories.current_page }}
                    </span>
                    из
                    <span class="font-semibold text-slate-900 dark:text-white">
                        {{ categories.last_page }}
                    </span>
                    <span class="mx-1 text-slate-300 dark:text-slate-600"
                        >·</span
                    >
                    Всего: {{ categories.total }}
                </p>

                <div class="flex flex-wrap items-center gap-1.5">
                    <template
                        v-for="(link, index) in categories.links"
                        :key="index"
                    >
                        <Link
                            v-if="link.url"
                            :href="link.url"
                            preserve-scroll
                            class="inline-flex min-h-9 min-w-9 items-center justify-center rounded-lg border px-3 text-sm font-medium transition focus:ring-2 focus:ring-indigo-500/20 focus:outline-none"
                            :class="
                                link.active
                                    ? 'border-indigo-600 bg-indigo-600 text-white shadow-sm'
                                    : 'border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800'
                            "
                        >
                            <span v-html="link.label" />
                        </Link>

                        <span
                            v-else
                            class="inline-flex min-h-9 min-w-9 cursor-not-allowed items-center justify-center rounded-lg border border-slate-100 px-3 text-sm text-slate-300 dark:border-slate-800 dark:text-slate-600"
                        >
                            <span v-html="link.label" />
                        </span>
                    </template>
                </div>
            </div>
        </div>

        <!-- Подтверждение удаления -->
        <ConfirmDeleteDialog
            :open="deleteDialog.open"
            title="Удаление категории"
            description="Вы уверены, что хотите удалить категорию"
            :item-name="deleteDialog.name"
            :loading="deleteDialog.loading"
            @confirm="confirmDelete"
            @cancel="deleteDialog.open = false"
        />
    </div>
</template>
