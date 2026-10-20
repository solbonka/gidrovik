<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';
import { toast } from 'vue-sonner';
import {
    ArrowDown,
    ArrowUp,
    ArrowUpDown,
    CheckCircle2,
    CirclePlus,
    Edit,
    Hash,
    Search,
    ShieldAlert,
    Trash2,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { create, destroy, edit } from '@/routes/admin/threads';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';

defineOptions({
    layout: AdminLayout,
});

interface Thread {
    id: number;
    system: string;
    designation: string;
    name: string;
    is_active: boolean;
    connections_count: number;
}

interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

interface PaginatedThreads {
    data: Thread[];
    current_page: number;
    last_page: number;
    from: number | null;
    to: number | null;
    total: number;
    links: PaginationLink[];
}

interface Props {
    threads: PaginatedThreads;
}

const props = defineProps<Props>();

const systemLabels: Record<string, string> = {
    metric: 'Метрическая',
    inch: 'Дюймовая',
};

const systemLabel = (system: string): string => {
    return systemLabels[system] ?? system.toUpperCase();
};

const search = ref('');
const statusFilter = ref<'all' | 'active' | 'inactive'>('all');
const sortBy = ref<'designation' | 'connections_count'>('designation');
const sortDirection = ref<'asc' | 'desc'>('asc');

const activeCount = computed(
    () => props.threads.data.filter((item) => item.is_active).length,
);

const inactiveCount = computed(
    () => props.threads.data.filter((item) => !item.is_active).length,
);

const connectionsCount = computed(() =>
    props.threads.data.reduce(
        (total, item) => total + item.connections_count,
        0,
    ),
);

const filteredThreads = computed(() => {
    const query = search.value.trim().toLocaleLowerCase('ru');

    const result = props.threads.data.filter((item) => {
        const matchesSearch =
            !query ||
            item.designation.toLocaleLowerCase('ru').includes(query) ||
            item.name.toLocaleLowerCase('ru').includes(query) ||
            systemLabel(item.system).toLocaleLowerCase('ru').includes(query);

        const matchesStatus =
            statusFilter.value === 'all' ||
            (statusFilter.value === 'active' && item.is_active) ||
            (statusFilter.value === 'inactive' && !item.is_active);

        return matchesSearch && matchesStatus;
    });

    return [...result].sort((a, b) => {
        let comparison = 0;

        if (sortBy.value === 'designation') {
            comparison = a.designation.localeCompare(b.designation, 'ru');
        } else {
            comparison = a.connections_count - b.connections_count;
        }

        return sortDirection.value === 'asc' ? comparison : -comparison;
    });
});

const toggleSort = (field: typeof sortBy.value): void => {
    if (sortBy.value === field) {
        sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc';
        return;
    }

    sortBy.value = field;
    sortDirection.value = 'asc';
};

const deleteDialogOpen = ref(false);
const deletingItemName = ref('');
const deletingItemId = ref<number | null>(null);
const deleting = ref(false);

const openDeleteDialog = (id: number, name: string): void => {
    deletingItemId.value = id;
    deletingItemName.value = name;
    deleteDialogOpen.value = true;
};

const closeDeleteDialog = (): void => {
    if (deleting.value) return;

    deleteDialogOpen.value = false;
    deletingItemId.value = null;
    deletingItemName.value = '';
};

const confirmDelete = (): void => {
    if (deletingItemId.value === null || deleting.value) return;

    deleting.value = true;

    router.delete(destroy(deletingItemId.value), {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Запись успешно удалена.');
            deleteDialogOpen.value = false;
            deletingItemId.value = null;
            deletingItemName.value = '';
        },
        onError: (errors) => {
            toast.error(errors.delete ?? 'Не удалось удалить резьбу.');
        },
        onFinish: () => {
            deleting.value = false;
        },
    });
};

const clearFilters = (): void => {
    search.value = '';
    statusFilter.value = 'all';
};
</script>

<template>
    <Head title="Резьбы" />

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
                        <Hash class="h-4 w-4" />
                        <span>Справочники</span>
                    </div>

                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Резьбы
                    </h1>

                    <p
                        class="mt-2 max-w-xl text-sm text-slate-300 sm:text-base"
                    >
                        Обозначения резьбовых соединений.
                    </p>
                </div>

                <Link
                    :href="create().url"
                    class="inline-flex shrink-0 items-center justify-center gap-2 rounded-xl bg-white px-5 py-3 text-sm font-semibold text-slate-900 shadow-lg transition hover:bg-indigo-50 focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-2 focus-visible:ring-offset-indigo-950 focus-visible:outline-none"
                >
                    <CirclePlus class="h-5 w-5" />
                    Добавить резьбу
                </Link>
            </div>
        </div>

        <!-- Статистика -->
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div
                class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-800 dark:bg-slate-900"
            >
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p class="text-sm text-slate-500 dark:text-slate-400">
                            Всего резьб
                        </p>
                        <p
                            class="mt-2 text-3xl font-bold text-slate-900 dark:text-white"
                        >
                            {{ props.threads.total }}
                        </p>
                    </div>
                    <div
                        class="rounded-xl bg-indigo-50 p-3 dark:bg-indigo-500/10"
                    >
                        <Hash
                            class="h-6 w-6 text-indigo-600 dark:text-indigo-400"
                        />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    В справочнике резьб
                </p>
            </div>

            <div
                class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-800 dark:bg-slate-900"
            >
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p class="text-sm text-slate-500 dark:text-slate-400">
                            Активные
                        </p>
                        <p
                            class="mt-2 text-3xl font-bold text-emerald-600 dark:text-emerald-400"
                        >
                            {{ activeCount }}
                        </p>
                    </div>
                    <div
                        class="rounded-xl bg-emerald-50 p-3 dark:bg-emerald-500/10"
                    >
                        <CheckCircle2
                            class="h-6 w-6 text-emerald-600 dark:text-emerald-400"
                        />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    На текущей странице
                </p>
            </div>

            <div
                class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-800 dark:bg-slate-900"
            >
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p class="text-sm text-slate-500 dark:text-slate-400">
                            Неактивные
                        </p>
                        <p
                            class="mt-2 text-3xl font-bold text-amber-600 dark:text-amber-400"
                        >
                            {{ inactiveCount }}
                        </p>
                    </div>
                    <div
                        class="rounded-xl bg-amber-50 p-3 dark:bg-amber-500/10"
                    >
                        <ShieldAlert
                            class="h-6 w-6 text-amber-600 dark:text-amber-400"
                        />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    На текущей странице
                </p>
            </div>

            <div
                class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-800 dark:bg-slate-900"
            >
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p class="text-sm text-slate-500 dark:text-slate-400">
                            Связей
                        </p>
                        <p
                            class="mt-2 text-3xl font-bold text-slate-900 dark:text-white"
                        >
                            {{ connectionsCount }}
                        </p>
                    </div>
                    <div class="rounded-xl bg-sky-50 p-3 dark:bg-sky-500/10">
                        <Hash class="h-6 w-6 text-sky-600 dark:text-sky-400" />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    На текущей странице
                </p>
            </div>
        </div>

        <!-- Таблица -->
        <div
            class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900"
        >
            <div
                class="border-b border-slate-200 p-4 sm:p-5 dark:border-slate-800"
            >
                <div
                    class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between"
                >
                    <div>
                        <h2
                            class="text-lg font-semibold text-slate-900 dark:text-white"
                        >
                            Список резьб
                        </h2>
                        <p
                            class="mt-1 text-sm text-slate-500 dark:text-slate-400"
                        >
                            Найдено: {{ filteredThreads.length }}
                            <span class="text-slate-400">
                                из {{ props.threads.data.length }} на странице
                            </span>
                        </p>
                    </div>

                    <div class="flex flex-col gap-3 sm:flex-row">
                        <div class="relative min-w-0 sm:min-w-64">
                            <Search
                                class="pointer-events-none absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-slate-400"
                            />
                            <input
                                v-model="search"
                                type="search"
                                placeholder="Обозначение, название..."
                                class="w-full rounded-xl border border-slate-200 bg-slate-50 py-2.5 pr-9 pl-9 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 dark:border-slate-700 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                            />
                            <button
                                v-if="search"
                                type="button"
                                aria-label="Очистить поиск"
                                class="absolute top-1/2 right-3 -translate-y-1/2 text-slate-400 transition hover:text-slate-700 dark:hover:text-slate-200"
                                @click="search = ''"
                            >
                                <X class="h-4 w-4" />
                            </button>
                        </div>

                        <select
                            v-model="statusFilter"
                            aria-label="Фильтр по статусу"
                            class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm text-slate-700 transition outline-none focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-200"
                        >
                            <option value="all">Все статусы</option>
                            <option value="active">Активные</option>
                            <option value="inactive">Неактивные</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Карточки на мобильных -->
            <div class="space-y-2 p-3 md:hidden">
                <div
                    v-for="thread in filteredThreads"
                    :key="thread.id"
                    class="rounded-lg border border-slate-200 bg-white p-3 shadow-sm transition-colors hover:border-indigo-200 dark:border-slate-700 dark:bg-slate-900 dark:hover:border-indigo-500/40"
                >
                    <div class="flex items-start justify-between gap-2">
                        <div class="min-w-0 flex-1">
                            <h3 class="font-semibold text-slate-900 dark:text-white break-words text-xs">{{ thread.designation }}</h3>
                            <p class="mt-0.5 text-[10px] text-slate-500 dark:text-slate-400">{{ thread.thread_system }}</p>
                        </div>
                        <span
                            class="inline-flex shrink-0 items-center gap-1 rounded-full border px-1.5 py-0.5 text-[10px] font-medium"
                            :class="thread.is_active ? 'border-emerald-200 bg-emerald-50 text-emerald-700 dark:border-emerald-500/30 dark:bg-emerald-500/10 dark:text-emerald-400' : 'border-slate-200 bg-slate-100 text-slate-600 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-400'"
                        >
                            <span class="h-1 w-1 rounded-full" :class="thread.is_active ? 'bg-emerald-500' : 'bg-slate-400'" />
                            {{ thread.is_active ? 'Активен' : 'Неактивен' }}
                        </span>
                    </div>
                    <div class="mt-2 grid grid-cols-2 gap-1.5 text-xs">
                        <div><p class="text-[10px] text-slate-500 dark:text-slate-400">Название</p><p class="text-slate-700 dark:text-slate-300 truncate text-[10px]">{{ thread.name }}</p></div>
                        <div><p class="text-[10px] text-slate-500 dark:text-slate-400">Связей</p><p class="font-semibold text-slate-700 dark:text-slate-300">{{ thread.connections_count }}</p></div>
                    </div>
                    <div class="mt-3 flex items-center gap-1.5 border-t border-slate-200 pt-2 dark:border-slate-700">
                        <Link :href="edit(thread.id).url" class="flex-1 inline-flex items-center justify-center gap-1 rounded-md border border-slate-200 px-2 py-1.5 text-xs font-medium text-slate-600 transition hover:border-indigo-200 hover:bg-indigo-50 hover:text-indigo-700 dark:border-slate-700 dark:text-slate-300 dark:hover:border-indigo-500/40 dark:hover:bg-indigo-500/10 dark:hover:text-indigo-300"><Edit class="h-3 w-3" />Изменить</Link>
                        <button type="button" :disabled="thread.connections_count > 0" class="inline-flex h-8 w-8 items-center justify-center rounded-md border border-slate-200 text-slate-500 transition hover:border-red-200 hover:bg-red-50 hover:text-red-600 disabled:cursor-not-allowed disabled:opacity-40 dark:border-slate-700 dark:text-slate-400 dark:hover:border-red-500/30 dark:hover:bg-red-500/10 dark:hover:text-red-400" @click="openDeleteDialog(thread.id, thread.designation)"><Trash2 class="h-3 w-3" /></button>
                    </div>
                </div>
                <div v-if="filteredThreads.length === 0" class="rounded-lg border border-slate-200 bg-white p-6 text-center dark:border-slate-700 dark:bg-slate-900">
                    <div class="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-xl bg-slate-100 text-slate-400 dark:bg-slate-800 dark:text-slate-500"><Search class="h-6 w-6" /></div>
                    <p class="font-semibold text-slate-900 dark:text-white text-xs">Резьбы не найдены</p>
                    <button v-if="search || statusFilter !== 'all'" type="button" class="mt-3 inline-flex items-center gap-1.5 rounded-lg border border-slate-200 px-3 py-1.5 text-xs font-medium text-slate-700 transition hover:bg-slate-50 dark:border-slate-700 dark:text-slate-300 dark:hover:bg-slate-800" @click="clearFilters"><X class="h-3 w-3" />Сбросить</button>
                </div>
            </div>
            <div class="hidden overflow-x-auto md:block">
                <table class="w-full min-w-[700px] text-sm">
                    <thead class="bg-slate-50 dark:bg-slate-950/60">
                        <tr
                            class="border-b border-slate-200 dark:border-slate-800"
                        >
                            <th
                                class="px-5 py-4 text-left font-semibold text-slate-600 dark:text-slate-300"
                            >
                                <button
                                    type="button"
                                    class="inline-flex items-center gap-2 transition hover:text-indigo-600 dark:hover:text-indigo-400"
                                    @click="toggleSort('designation')"
                                >
                                    Обозначение
                                    <ArrowUp
                                        v-if="
                                            sortBy === 'designation' &&
                                            sortDirection === 'asc'
                                        "
                                        class="h-3.5 w-3.5"
                                    />
                                    <ArrowDown
                                        v-else-if="
                                            sortBy === 'designation' &&
                                            sortDirection === 'desc'
                                        "
                                        class="h-3.5 w-3.5"
                                    />
                                    <ArrowUpDown
                                        v-else
                                        class="h-3.5 w-3.5 opacity-40"
                                    />
                                </button>
                            </th>

                            <th
                                class="px-5 py-4 text-left font-semibold text-slate-600 dark:text-slate-300"
                            >
                                Система
                            </th>

                            <th
                                class="px-5 py-4 text-left font-semibold text-slate-600 dark:text-slate-300"
                            >
                                Название
                            </th>

                            <th
                                class="px-5 py-4 text-center font-semibold text-slate-600 dark:text-slate-300"
                            >
                                <button
                                    type="button"
                                    class="inline-flex items-center gap-2 transition hover:text-indigo-600 dark:hover:text-indigo-400"
                                    @click="toggleSort('connections_count')"
                                >
                                    Связей
                                    <ArrowUp
                                        v-if="
                                            sortBy === 'connections_count' &&
                                            sortDirection === 'asc'
                                        "
                                        class="h-3.5 w-3.5"
                                    />
                                    <ArrowDown
                                        v-else-if="
                                            sortBy === 'connections_count' &&
                                            sortDirection === 'desc'
                                        "
                                        class="h-3.5 w-3.5"
                                    />
                                    <ArrowUpDown
                                        v-else
                                        class="h-3.5 w-3.5 opacity-40"
                                    />
                                </button>
                            </th>

                            <th
                                class="px-5 py-4 text-center font-semibold text-slate-600 dark:text-slate-300"
                            >
                                Статус
                            </th>

                            <th
                                class="px-5 py-4 text-right font-semibold text-slate-600 dark:text-slate-300"
                            >
                                Действия
                            </th>
                        </tr>
                    </thead>

                    <tbody
                        class="divide-y divide-slate-100 dark:divide-slate-800"
                    >
                        <tr
                            v-for="thread in filteredThreads"
                            :key="thread.id"
                            class="transition-colors hover:bg-slate-50/80 dark:hover:bg-slate-800/40"
                        >
                            <td class="px-5 py-4">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400"
                                    >
                                        <Hash class="h-5 w-5" />
                                    </div>
                                    <div>
                                        <p
                                            class="font-mono font-semibold text-slate-900 dark:text-white"
                                        >
                                            {{ thread.designation }}
                                        </p>
                                        <p
                                            class="mt-0.5 text-xs text-slate-500 dark:text-slate-400"
                                        >
                                            ID: {{ thread.id }}
                                        </p>
                                    </div>
                                </div>
                            </td>

                            <td class="px-5 py-4">
                                <span
                                    class="inline-flex items-center rounded-lg bg-slate-100 px-3 py-1.5 text-xs font-medium text-slate-700 dark:bg-slate-800 dark:text-slate-300"
                                >
                                    {{ systemLabel(thread.system) }}
                                </span>
                            </td>

                            <td class="px-5 py-4">
                                <p class="text-slate-700 dark:text-slate-300">
                                    {{ thread.name }}
                                </p>
                            </td>

                            <td class="px-5 py-4 text-center">
                                <span
                                    :class="[
                                        'inline-flex min-w-10 items-center justify-center rounded-lg px-2.5 py-1.5 font-semibold tabular-nums',
                                        thread.connections_count > 0
                                            ? 'bg-sky-50 text-sky-700 dark:bg-sky-500/10 dark:text-sky-300'
                                            : 'bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400',
                                    ]"
                                >
                                    {{ thread.connections_count }}
                                </span>
                            </td>

                            <td class="px-5 py-4 text-center">
                                <span
                                    :class="[
                                        'inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium',
                                        thread.is_active
                                            ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400'
                                            : 'bg-slate-200 text-slate-600 dark:bg-slate-800 dark:text-slate-400',
                                    ]"
                                >
                                    <CheckCircle2
                                        v-if="thread.is_active"
                                        class="h-3.5 w-3.5"
                                    />
                                    <ShieldAlert v-else class="h-3.5 w-3.5" />
                                    {{
                                        thread.is_active
                                            ? 'Активна'
                                            : 'Неактивна'
                                    }}
                                </span>
                            </td>

                            <td class="px-5 py-4 text-right">
                                <div
                                    class="flex items-center justify-end gap-1.5"
                                >
                                    <Link
                                        :href="edit(thread.id).url"
                                        class="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-500 transition hover:border-indigo-200 hover:bg-indigo-50 hover:text-indigo-700 focus-visible:ring-2 focus-visible:ring-indigo-500/20 focus-visible:outline-none dark:border-slate-700 dark:bg-slate-900 dark:text-slate-400 dark:hover:border-indigo-500/40 dark:hover:bg-indigo-500/10 dark:hover:text-indigo-300"
                                    >
                                        <Edit class="h-4 w-4" />
                                    </Link>

                                    <button
                                        type="button"
                                        :disabled="thread.connections_count > 0"
                                        class="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-500 transition hover:border-red-200 hover:bg-red-50 hover:text-red-600 focus-visible:ring-2 focus-visible:ring-red-500/20 focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-40 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-400 dark:hover:border-red-500/30 dark:hover:bg-red-500/10 dark:hover:text-red-400"
                                        @click="
                                            openDeleteDialog(
                                                thread.id,
                                                thread.designation,
                                            )
                                        "
                                    >
                                        <Trash2 class="h-4 w-4" />
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <ConfirmDeleteDialog
            :open="deleteDialogOpen"
            :item-name="deletingItemName"
            :loading="deleting"
            @confirm="confirmDelete"
            @cancel="closeDeleteDialog"
        />
    </div>
</template>
