<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { ref } from 'vue';
import { toast } from 'vue-sonner';
import {
    ArrowLeft,
    ArrowRight,
    ArrowUpDown,
    Box,
    ChevronLeft,
    ChevronRight,
    FileText,
    Filter,
    Package,
    Plus,
    RotateCcw,
    Search,
    Trash2,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';

defineOptions({ layout: AdminLayout });

interface MovementType {
    value: string;
    label: string;
}

interface Movement {
    id: number;
    type: string;
    type_label: string;
    quantity: number;
    comment: string | null;
    created_at: string | null;
    product: {
        id: number;
        name: string;
        sku: string;
    };
    from_location: {
        code: string;
    } | null;
    to_location: {
        code: string;
    } | null;
    user: string | null;
}

interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

interface PaginatedMovements {
    data: Movement[];
    current_page: number;
    last_page: number;
    from: number | null;
    to: number | null;
    total: number;
    links: PaginationLink[];
}

interface Filters {
    type: string;
    search: string;
    product_id: string;
}

interface Props {
    movements: PaginatedMovements;
    filters: Filters;
    types: MovementType[];
}

const props = defineProps<Props>();

const search = ref(props.filters.search);
const type = ref(props.filters.type);

const applyFilters = (): void => {
    router.get(
        '/admin/stock/movements',
        {
            search: search.value || undefined,
            type: type.value || undefined,
            product_id: props.filters.product_id || undefined,
        },
        {
            preserveState: true,
            preserveScroll: true,
            replace: true,
        },
    );
};

const clearProductFilter = (): void => {
    router.get(
        '/admin/stock/movements',
        {
            search: search.value || undefined,
            type: type.value || undefined,
        },
        {
            preserveState: true,
            preserveScroll: true,
            replace: true,
        },
    );
};

const locationSummary = (movement: Movement): string => {
    if (movement.from_location && movement.to_location) {
        return `${movement.from_location.code} → ${movement.to_location.code}`;
    }

    if (movement.to_location) {
        return `→ ${movement.to_location.code}`;
    }

    if (movement.from_location) {
        return `${movement.from_location.code} → списание`;
    }

    return '—';
};

const deleteDialogOpen = ref(false);
const deletingItemId = ref<number | null>(null);
const deleting = ref(false);

const openDeleteDialog = (id: number): void => {
    deletingItemId.value = id;
    deleteDialogOpen.value = true;
};

const closeDeleteDialog = (): void => {
    if (deleting.value) return;

    deleteDialogOpen.value = false;
    deletingItemId.value = null;
};

const confirmDelete = (): void => {
    if (deletingItemId.value === null || deleting.value) return;

    deleting.value = true;

    router.delete(`/admin/stock/movements/${deletingItemId.value}`, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Запись удалена из журнала.');
            deleteDialogOpen.value = false;
            deletingItemId.value = null;
        },
        onFinish: () => {
            deleting.value = false;
        },
    });
};
</script>

<template>
    <Head title="Журнал складских движений" />

    <div class="space-y-6 p-4 sm:p-6">
        <!-- Заголовок -->
        <div
            class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-indigo-950 to-violet-900 p-6 text-white shadow-lg sm:p-8"
        >
            <div
                class="pointer-events-none absolute -top-16 -right-12 h-56 w-56 rounded-full bg-violet-400/20 blur-3xl"
            />
            <div
                class="pointer-events-none absolute right-1/3 -bottom-20 h-48 w-48 rounded-full bg-blue-400/10 blur-3xl"
            />

            <div
                class="relative flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between"
            >
                <div>
                    <div
                        class="mb-3 flex items-center gap-2 text-sm text-indigo-200"
                    >
                        <ArrowUpDown class="h-4 w-4" />
                        <span>Склад</span>
                    </div>

                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Журнал складских движений
                    </h1>

                    <p
                        class="mt-2 max-w-xl text-sm text-slate-300 sm:text-base"
                    >
                        История поступлений, перемещений, списаний и других
                        операций.
                    </p>

                    <div
                        v-if="filters.product_id"
                        class="mt-3 flex flex-wrap items-center gap-2"
                    >
                        <span
                            class="inline-flex items-center gap-1.5 rounded-full bg-indigo-500/20 px-3 py-1.5 text-sm text-indigo-100"
                        >
                            <Filter class="h-3.5 w-3.5" />
                            Фильтр по товару №{{ filters.product_id }}
                        </span>

                        <button
                            type="button"
                            class="text-sm font-medium text-indigo-200 underline hover:text-white"
                            @click="clearProductFilter"
                        >
                            Показать все товары
                        </button>
                    </div>
                </div>

                <div class="flex flex-wrap gap-2">
                    <Link
                        href="/admin/stock/receipt"
                        class="inline-flex items-center justify-center gap-2 rounded-xl bg-white px-4 py-2.5 text-sm font-semibold text-slate-900 shadow-lg transition hover:bg-indigo-50 dark:bg-slate-900 dark:text-white dark:hover:bg-slate-800"
                    >
                        <Plus class="h-4 w-4" />
                        Поступление
                    </Link>

                    <Link
                        href="/admin/stock/transfer"
                        class="inline-flex items-center justify-center gap-2 rounded-xl border border-white/20 bg-white/10 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-white/20"
                    >
                        <Box class="h-4 w-4" />
                        Перемещение
                    </Link>

                    <Link
                        href="/admin/stock/write-off"
                        class="inline-flex items-center justify-center gap-2 rounded-xl border border-white/20 bg-white/10 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-white/20"
                    >
                        <X class="h-4 w-4" />
                        Списание
                    </Link>
                </div>
            </div>
        </div>

        <!-- Фильтры -->
        <div
            class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900"
        >
            <div class="grid gap-4 p-5 sm:p-6 md:grid-cols-[2fr_1fr_auto]">
                <div>
                    <label
                        for="search"
                        class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                    >
                        Поиск по товару
                    </label>

                    <div class="relative">
                        <Search
                            class="pointer-events-none absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-slate-400"
                        />

                        <input
                            id="search"
                            v-model="search"
                            type="search"
                            placeholder="Название или артикул"
                            class="w-full rounded-xl border border-slate-200 bg-slate-50 py-2.5 pr-4 pl-9 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 dark:border-slate-700 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                            @keyup.enter="applyFilters"
                        />
                    </div>
                </div>

                <div>
                    <label
                        for="type"
                        class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                    >
                        Тип операции
                    </label>

                    <select
                        id="type"
                        v-model="type"
                        class="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-2.5 text-sm text-slate-900 transition outline-none focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 dark:border-slate-700 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                        @change="applyFilters"
                    >
                        <option value="">Все операции</option>

                        <option
                            v-for="item in types"
                            :key="item.value"
                            :value="item.value"
                        >
                            {{ item.label }}
                        </option>
                    </select>
                </div>

                <div class="flex items-end">
                    <button
                        type="button"
                        class="inline-flex items-center justify-center gap-2 rounded-xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 focus-visible:outline-none dark:focus-visible:ring-offset-slate-900"
                        @click="applyFilters"
                    >
                        <Filter class="h-4 w-4" />
                        Найти
                    </button>
                </div>
            </div>
        </div>

        <!-- Таблица -->
        <div
            class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900"
        >
            <!-- Карточки на мобильных -->
            <div class="space-y-2 p-3 md:hidden">
                <div
                    v-for="movement in movements.data"
                    :key="movement.id"
                    class="rounded-lg border border-slate-200 bg-white p-3 shadow-sm transition-colors hover:border-indigo-200 dark:border-slate-700 dark:bg-slate-900 dark:hover:border-indigo-500/40"
                >
                    <div class="flex items-start justify-between gap-2">
                        <div class="min-w-0 flex-1">
                            <span class="inline-flex items-center gap-1.5 rounded-full bg-slate-100 px-1.5 py-0.5 text-[10px] font-medium text-slate-700 dark:bg-slate-800 dark:text-slate-300">{{ movement.type_label }}</span>
                            <h3 class="mt-1 font-semibold text-slate-900 dark:text-white break-words text-xs">{{ movement.product.name }}</h3>
                            <p class="mt-0.5 text-[10px] text-slate-500 dark:text-slate-400">{{ movement.created_at ?? '—' }}</p>
                        </div>
                    </div>
                    <div class="mt-2 grid grid-cols-2 gap-1.5 text-xs">
                        <div><p class="text-[10px] text-slate-500 dark:text-slate-400">Количество</p><p class="font-semibold text-slate-700 dark:text-slate-300">{{ movement.quantity }}</p></div>
                        <div><p class="text-[10px] text-slate-500 dark:text-slate-400">Пользователь</p><p class="text-slate-700 dark:text-slate-300 truncate text-[10px]">{{ movement.user_name }}</p></div>
                    </div>
                    <div v-if="movement.comment" class="mt-2 text-xs"><p class="text-[10px] text-slate-500 dark:text-slate-400">Комментарий</p><p class="text-slate-700 dark:text-slate-300 truncate text-[10px]">{{ movement.comment }}</p></div>
                </div>
                <div v-if="movements.data.length === 0" class="rounded-lg border border-slate-200 bg-white p-6 text-center dark:border-slate-700 dark:bg-slate-900">
                    <p class="font-semibold text-slate-900 dark:text-white text-xs">Движений нет</p>
                </div>
            </div>
            <div class="hidden overflow-x-auto md:block">
                <table class="w-full text-left text-sm">
                    <thead
                        class="border-b border-slate-200 bg-slate-50 text-xs font-semibold tracking-wide text-slate-500 uppercase dark:border-slate-800 dark:bg-slate-950/60 dark:text-slate-400"
                    >
                        <tr>
                            <th class="px-5 py-4">Дата</th>
                            <th class="px-5 py-4">Операция</th>
                            <th class="px-5 py-4">Товар</th>
                            <th class="px-5 py-4">Ячейки</th>
                            <th class="px-5 py-4">Количество</th>
                            <th class="px-5 py-4">Пользователь</th>
                            <th class="px-5 py-4">Комментарий</th>
                            <th class="px-5 py-4"></th>
                        </tr>
                    </thead>

                    <tbody
                        class="divide-y divide-slate-100 dark:divide-slate-800"
                    >
                        <tr
                            v-for="movement in movements.data"
                            :key="movement.id"
                            class="transition hover:bg-slate-50/80 dark:hover:bg-slate-800/40"
                        >
                            <td
                                class="px-5 py-4 whitespace-nowrap text-slate-600 dark:text-slate-400"
                            >
                                {{ movement.created_at ?? '—' }}
                            </td>

                            <td class="px-5 py-4 whitespace-nowrap">
                                <span
                                    class="inline-flex items-center gap-1.5 rounded-full bg-slate-100 px-2.5 py-1 text-xs font-medium text-slate-700 dark:bg-slate-800 dark:text-slate-300"
                                >
                                    {{ movement.type_label }}
                                </span>
                            </td>

                            <td class="px-5 py-4">
                                <div
                                    class="font-medium text-slate-900 dark:text-white"
                                >
                                    {{ movement.product.name }}
                                </div>

                                <div
                                    class="mt-1 font-mono text-xs text-slate-500 dark:text-slate-400"
                                >
                                    {{ movement.product.sku }}
                                </div>
                            </td>

                            <td
                                class="px-5 py-4 whitespace-nowrap text-slate-600 dark:text-slate-400"
                            >
                                {{ locationSummary(movement) }}
                            </td>

                            <td
                                class="px-5 py-4 font-semibold text-slate-900 dark:text-white"
                            >
                                {{ movement.quantity }}
                            </td>

                            <td
                                class="px-5 py-4 text-slate-600 dark:text-slate-400"
                            >
                                {{ movement.user ?? '—' }}
                            </td>

                            <td
                                class="max-w-xs px-5 py-4 text-slate-600 dark:text-slate-400"
                            >
                                <span class="line-clamp-2">
                                    {{ movement.comment ?? '—' }}
                                </span>
                            </td>

                            <td class="px-5 py-4">
                                <button
                                    type="button"
                                    class="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-500 transition hover:border-red-200 hover:bg-red-50 hover:text-red-600 focus-visible:ring-2 focus-visible:ring-red-500/20 focus-visible:outline-none dark:border-slate-700 dark:bg-slate-900 dark:text-slate-400 dark:hover:border-red-500/30 dark:hover:bg-red-500/10 dark:hover:text-red-400"
                                    @click="openDeleteDialog(movement.id)"
                                >
                                    <Trash2 class="h-4 w-4" />
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div
                v-if="movements.links.length > 3"
                class="flex flex-col gap-4 border-t border-slate-200 px-5 py-5 sm:flex-row sm:items-center sm:justify-between dark:border-slate-800"
            >
                <p class="text-sm text-slate-500 dark:text-slate-400">
                    Показано {{ movements.from }}–{{ movements.to }} из
                    {{ movements.total }}
                </p>

                <nav
                    v-if="movements.total > 0"
                    class="flex flex-wrap items-center justify-center gap-1"
                    aria-label="Навигация по страницам"
                >
                    <template
                        v-for="(link, index) in movements.links"
                        :key="`${index}-${link.label}`"
                    >
                        <!-- Назад -->
                        <Link
                            v-if="index === 0 && link.url"
                            :href="link.url"
                            preserve-scroll
                            class="inline-flex h-9 items-center gap-2 rounded-xl border border-slate-200 px-3 text-sm font-medium text-slate-600 transition hover:border-indigo-500/30 hover:bg-indigo-500/5 hover:text-indigo-600 dark:border-slate-700 dark:text-slate-300"
                        >
                            <ChevronLeft class="h-4 w-4" />
                            <span>Назад</span>
                        </Link>

                        <span
                            v-else-if="index === 0"
                            class="inline-flex h-9 cursor-not-allowed items-center gap-2 rounded-xl border border-slate-100 px-3 text-sm text-slate-300 dark:border-slate-800 dark:text-slate-600"
                        >
                            <ChevronLeft class="h-4 w-4" />
                            <span>Назад</span>
                        </span>

                        <!-- Номера страниц -->
                        <Link
                            v-else-if="
                                index !== movements.links.length - 1 && link.url
                            "
                            :href="link.url"
                            preserve-scroll
                            class="inline-flex h-9 min-w-9 items-center justify-center rounded-xl border px-3 text-sm font-medium transition"
                            :class="
                                link.active
                                    ? 'border-indigo-600 bg-gradient-to-r from-indigo-600 to-violet-600 text-white shadow-sm'
                                    : 'border-slate-200 text-slate-600 hover:border-indigo-500/30 hover:bg-indigo-500/5 hover:text-indigo-600 dark:border-slate-700 dark:text-slate-300'
                            "
                            v-html="link.label"
                        />

                        <span
                            v-else-if="index !== movements.links.length - 1"
                            class="inline-flex h-9 min-w-9 items-center justify-center px-2 text-sm text-slate-400"
                            v-html="link.label"
                        />

                        <!-- Далее -->
                        <Link
                            v-else-if="link.url"
                            :href="link.url"
                            preserve-scroll
                            class="inline-flex h-9 items-center gap-2 rounded-xl border border-slate-200 px-3 text-sm font-medium text-slate-600 transition hover:border-indigo-500/30 hover:bg-indigo-500/5 hover:text-indigo-600 dark:border-slate-700 dark:text-slate-300"
                        >
                            <span>Далее</span>
                            <ChevronRight class="h-4 w-4" />
                        </Link>

                        <span
                            v-else
                            class="inline-flex h-9 cursor-not-allowed items-center gap-2 rounded-xl border border-slate-100 px-3 text-sm text-slate-300 dark:border-slate-800 dark:text-slate-600"
                        >
                            <span>Далее</span>
                            <ChevronRight class="h-4 w-4" />
                        </span>
                    </template>
                </nav>
            </div>
        </div>

        <ConfirmDeleteDialog
            :open="deleteDialogOpen"
            item-name="эту запись"
            :loading="deleting"
            @confirm="confirmDelete"
            @cancel="closeDeleteDialog"
        />
    </div>
</template>
