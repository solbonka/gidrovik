<script setup lang="ts">
import { Head, Link, router, useForm } from '@inertiajs/vue3';
import { computed, ref } from 'vue';

import {
    ArrowLeft,
    Edit,
    FileSpreadsheet,
    FileText,
    Hash,
    Plus,
    Search,
    Table,
    Trash2,
    Type,
    X,
    ChevronDown,
    ChevronUp,
    Eye,
    EyeOff,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';
import { Button } from '@/components/ui/button';

import {
    destroy as destroyTable,
    show as showTable,
} from '@/routes/admin/custom-tables';
import { csv as exportCsv, html as exportHtml } from '@/routes/admin/custom-tables/export';
import {
    create as createEntryRoute,
    destroy as destroyEntry,
    edit as editEntryRoute,
} from '@/routes/admin/custom-tables/entries';

defineOptions({
    layout: AdminLayout,
});

interface Column {
    key: string;
    name: string;
    type: string;
}

interface TableData {
    id: number;
    name: string;
    slug: string;
    description: string | null;
    columns: Column[];
}

interface Entry {
    id: number;
    data: Record<string, unknown>;
    created_at: string;
    updated_at: string;
}

interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

interface PaginatedEntries {
    data: Entry[];
    current_page: number;
    last_page: number;
    from: number | null;
    to: number | null;
    total: number;
    links: PaginationLink[];
}

interface Props {
    table: TableData;
    entries: PaginatedEntries;
    filters: {
        search: string;
        per_page: number;
    };
}

const props = defineProps<Props>();

const search = ref(props.filters.search);
const perPage = ref(props.filters.per_page);
const expandedEntries = ref<Set<number>>(new Set());

const filteredEntries = computed(() => {
    const query = search.value.trim().toLowerCase();

    if (!query) return props.entries.data;

    return props.entries.data.filter((entry) =>
        Object.values(entry.data).some((value) =>
            String(value ?? '').toLowerCase().includes(query),
        ),
    );
});

const paged = computed(() => props.entries.last_page > 1);

function applySearch() {
    router.get(
        showTable.url(props.table.id),
        { search: search.value, per_page: perPage.value },
        { preserveState: true, preserveScroll: true },
    );
}

function toggleEntry(entryId: number) {
    const newSet = new Set(expandedEntries.value);
    if (newSet.has(entryId)) {
        newSet.delete(entryId);
    } else {
        newSet.add(entryId);
    }
    expandedEntries.value = newSet;
}

function toggleAllEntries() {
    if (expandedEntries.value.size === filteredEntries.value.length) {
        expandedEntries.value = new Set();
    } else {
        expandedEntries.value = new Set(filteredEntries.value.map(e => e.id));
    }
}

function formatValue(value: unknown, type: string): string {
    if (value === null || value === undefined) return '—';
    if (value === '') return '—';

    if (type === 'boolean') {
        return (value as boolean) ? 'да' : 'нет';
    }

    if (type === 'date') {
        try {
            return new Date(value as string).toLocaleDateString('ru-RU');
        } catch {
            return String(value);
        }
    }

    if (type === 'json') {
        return JSON.stringify(value);
    }

    return String(value);
}

const typeBadge = (type: string): string => {
    const styles: Record<string, string> = {
        string: 'bg-blue-500/10 text-blue-700 ring-blue-600/20 dark:text-blue-400',
        integer: 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400',
        decimal: 'bg-violet-500/10 text-violet-700 ring-violet-600/20 dark:text-violet-400',
        boolean: 'bg-amber-500/10 text-amber-700 ring-amber-600/20 dark:text-amber-400',
        date: 'bg-sky-500/10 text-sky-700 ring-sky-600/20 dark:text-sky-400',
        text: 'bg-slate-500/10 text-slate-700 ring-slate-600/20 dark:text-slate-400',
        json: 'bg-rose-500/10 text-rose-700 ring-rose-600/20 dark:text-rose-400',
    };

    return styles[type] ?? 'bg-muted text-muted-foreground ring-border';
};

const typeLabel = (type: string): string => {
    const labels: Record<string, string> = {
        string: 'Строка',
        integer: 'Целое',
        decimal: 'Число',
        boolean: 'Булево',
        date: 'Дата',
        text: 'Текст',
        json: 'JSON',
    };

    return labels[type] ?? type;
};

/* ---------- Delete entry ---------- */

const deleteDialog = ref({
    open: false,
    entryId: null as number | null,
    loading: false,
});

const openDeleteDialog = (entryId: number): void => {
    deleteDialog.value.entryId = entryId;
    deleteDialog.value.open = true;
};

const closeDeleteDialog = (): void => {
    if (deleteDialog.value.loading) return;
    deleteDialog.value.open = false;
};

const confirmDeleteEntry = (): void => {
    if (deleteDialog.value.entryId === null || deleteDialog.value.loading) return;

    deleteDialog.value.loading = true;

    router.delete(
        destroyEntry.url({ custom_table: props.table.id, entry: deleteDialog.value.entryId }),
        {
            preserveScroll: true,
            onFinish: () => {
                deleteDialog.value.loading = false;
                deleteDialog.value.open = false;
            },
        },
    );
};

/* ---------- Delete table ---------- */

const deleteTableDialog = ref({
    open: false,
    loading: false,
});

const openDeleteTableDialog = (): void => {
    deleteTableDialog.value.open = true;
};

const closeDeleteTableDialog = (): void => {
    if (deleteTableDialog.value.loading) return;
    deleteTableDialog.value.open = false;
};

const confirmDeleteTable = (): void => {
    if (deleteTableDialog.value.loading) return;

    deleteTableDialog.value.loading = true;

    router.delete(destroyTable.url(props.table.id), {
        preserveScroll: true,
        onFinish: () => {
            deleteTableDialog.value.loading = false;
            deleteTableDialog.value.open = false;
        },
    });
};
</script>

<template>
    <Head :title="`${table.name} — Данные`" />

    <div class="space-y-6 pb-4">
        <!-- Header -->
        <header class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div class="flex items-center gap-4">
                <Link :href="route('admin.custom-tables.index')">
                    <Button variant="ghost" size="icon" class="size-9 shrink-0">
                        <ArrowLeft :size="20" />
                    </Button>
                </Link>
                <div class="min-w-0">
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl truncate">{{ table.name }}</h1>
                    <p class="mt-1 text-sm text-muted-foreground">
                        <span class="text-muted-foreground">{{ table.slug }}</span>
                        <span v-if="table.description" class="text-muted-foreground"> — {{ table.description }}</span>
                    </p>
                </div>
            </div>

            <div class="flex flex-wrap items-center gap-2">
                <Button as-child variant="outline" size="sm">
                    <Link :href="createEntryRoute.url({ custom_table: table.id })">
                        <Plus :size="16" class="mr-1.5" />
                        <span class="hidden sm:inline">Добавить строку</span>
                        <span class="sm:hidden">Добавить</span>
                    </Link>
                </Button>

                <a :href="exportCsv.url({ custom_table: table.id })">
                    <Button variant="outline" size="sm">
                        <FileSpreadsheet :size="16" class="mr-1.5" />
                        <span class="hidden sm:inline">CSV</span>
                    </Button>
                </a>

                <a :href="exportHtml.url({ custom_table: table.id })">
                    <Button variant="outline" size="sm">
                        <FileText :size="16" class="mr-1.5" />
                        <span class="hidden sm:inline">Excel</span>
                    </Button>
                </a>

                <Button variant="outline" size="sm" @click="openDeleteTableDialog">
                    <Trash2 :size="16" class="mr-1.5" />
                    <span class="hidden sm:inline">Удалить</span>
                </Button>
            </div>
        </header>

        <!-- Columns info -->
        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm">
            <div class="border-b px-5 py-4 sm:px-6">
                <h2 class="font-semibold">Структура таблицы</h2>
                <p class="mt-1 text-xs text-muted-foreground">
                    {{ table.columns.length }} колонок
                </p>
            </div>
            <div class="divide-y sm:grid sm:grid-cols-2 lg:grid-cols-3 sm:divide-y-0 sm:gap-4 sm:p-4">
                <div
                    v-for="col in table.columns"
                    :key="col.key"
                    class="flex items-center gap-3 rounded-xl border bg-background p-4 shadow-sm"
                >
                    <div class="flex size-10 shrink-0 items-center justify-center rounded-lg" :class="typeBadge(col.type)">
                        <component :is="col.type === 'string' || col.type === 'text' ? Type : Hash" :size="18" />
                    </div>
                    <div class="min-w-0">
                        <p class="truncate text-sm font-medium">{{ col.name || col.key }}</p>
                        <p class="text-xs text-muted-foreground">{{ typeLabel(col.type) }}</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Entries -->
        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm" aria-labelledby="entries-title">
            <div class="flex flex-col gap-4 border-b px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6">
                <div>
                    <h2 id="entries-title" class="font-semibold">Записи</h2>
                    <p class="mt-0.5 text-sm text-muted-foreground">
                        Показано:
                        <span class="font-medium text-foreground tabular-nums">{{ filteredEntries.length }}</span>
                        из
                        <span class="font-medium text-foreground tabular-nums">{{ entries.total }}</span>
                    </p>
                </div>

                <div class="flex flex-col gap-3 sm:flex-row sm:items-center">
                    <div class="relative w-full sm:max-w-xs">
                        <Search
                            :size="16"
                            class="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-muted-foreground"
                        />
                        <input
                            v-model="search"
                            type="search"
                            placeholder="Поиск записей"
                            aria-label="Поиск записей"
                            class="w-full rounded-xl border border-input bg-background py-2.5 pr-9 pl-9 text-sm shadow-xs outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                            @change="applySearch"
                        />
                        <button
                            v-if="search"
                            type="button"
                            aria-label="Очистить поиск"
                            class="absolute top-1/2 right-3 -translate-y-1/2 text-muted-foreground transition hover:text-foreground"
                            @click="search = ''; applySearch()"
                        >
                            <X :size="16" />
                        </button>
                    </div>

                    <select
                        v-model="perPage"
                        class="rounded-xl border border-input bg-background px-3 py-2.5 text-sm shadow-xs outline-none transition focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                        @change="applySearch"
                    >
                        <option :value="10">10 на странице</option>
                        <option :value="20">20 на странице</option>
                        <option :value="50">50 на странице</option>
                        <option :value="100">100 на странице</option>
                    </select>
                </div>
            </div>

            <!-- Empty state -->
            <div
                v-if="filteredEntries.length === 0"
                class="flex flex-col items-center px-6 py-16 text-center"
            >
                <div class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted">
                    <Search v-if="search" :size="28" class="text-muted-foreground" />
                    <Table v-else :size="28" class="text-muted-foreground" />
                </div>
                <p class="font-medium">{{ search ? 'Ничего не найдено' : 'Записей пока нет' }}</p>
                <p class="mt-1 max-w-sm text-sm text-muted-foreground">
                    {{ search ? 'Попробуйте изменить поисковый запрос.' : 'Добавьте первую запись.' }}
                </p>

                <Button v-if="search" variant="outline" class="mt-5" @click="search = ''; applySearch()">
                    <X :size="15" class="mr-1.5" />
                    Очистить поиск
                </Button>
                <Button v-else as-child class="mt-5">
                    <Link :href="createEntryRoute.url({ custom_table: table.id })">
                        <Plus :size="16" class="mr-2" />
                        Добавить запись
                    </Link>
                </Button>
            </div>

            <template v-else>
                <!-- Desktop table -->
                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full min-w-max text-left text-sm">
                        <thead>
                            <tr class="border-b bg-muted/40">
                                <th scope="col" class="px-6 py-3.5">
                                    <Button
                                        variant="ghost"
                                        size="sm"
                                        class="h-6 gap-1 px-2 text-xs font-medium text-muted-foreground"
                                        @click="toggleAllEntries"
                                    >
                                        <Eye v-if="expandedEntries.size === 0" :size="14" />
                                        <EyeOff v-else :size="14" />
                                    </Button>
                                </th>
                                <th scope="col" class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">#</th>
                                <th
                                    v-for="col in table.columns"
                                    :key="col.key"
                                    scope="col"
                                    class="px-4 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                                >
                                    <div class="flex items-center gap-1.5">
                                        <component :is="col.type === 'string' || col.type === 'text' ? Type : Hash" :size="12" />
                                        {{ col.name || col.key }}
                                    </div>
                                </th>
                                <th scope="col" class="px-6 py-3.5">
                                    <span class="sr-only">Действия</span>
                                </th>
                            </tr>
                        </thead>

                        <tbody class="divide-y">
                            <tr
                                v-for="entry in filteredEntries"
                                :key="entry.id"
                                class="transition-colors hover:bg-muted/40"
                            >
                                <td class="px-6 py-4">
                                    <Button
                                        variant="ghost"
                                        size="sm"
                                        class="h-6 w-6 p-0"
                                        @click="toggleEntry(entry.id)"
                                    >
                                        <ChevronDown v-if="expandedEntries.has(entry.id)" :size="16" />
                                        <ChevronUp v-else :size="16" />
                                    </Button>
                                </td>
                                <td class="px-6 py-4 font-semibold">#{{ entry.id }}</td>

                                <td
                                    v-for="col in table.columns"
                                    :key="col.key"
                                    class="px-4 py-4"
                                >
                                    <span class="whitespace-nowrap">{{ formatValue(entry.data[col.key], col.type) }}</span>
                                </td>

                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <Button as-child variant="outline" size="sm">
                                            <Link :href="editEntryRoute.url({ custom_table: table.id, entry: entry.id })">
                                                <Edit :size="14" class="mr-1.5" />
                                                Изменить
                                            </Link>
                                        </Button>

                                        <Button
                                            variant="outline"
                                            size="icon"
                                            class="size-8 text-destructive hover:bg-destructive/10 hover:text-destructive"
                                            @click="openDeleteDialog(entry.id)"
                                        >
                                            <Trash2 :size="14" />
                                            <span class="sr-only">Удалить</span>
                                        </Button>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Mobile cards -->
                <ul class="divide-y md:hidden">
                    <li v-for="entry in filteredEntries" :key="entry.id" class="space-y-3 p-4">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center gap-2">
                                <Button
                                    variant="ghost"
                                    size="sm"
                                    class="h-6 w-6 p-0"
                                    @click="toggleEntry(entry.id)"
                                >
                                    <ChevronDown v-if="expandedEntries.has(entry.id)" :size="16" />
                                    <ChevronUp v-else :size="16" />
                                </Button>
                                <span class="text-sm font-semibold">#{{ entry.id }}</span>
                            </div>
                            <div class="flex items-center gap-2">
                                <Button as-child variant="outline" size="sm">
                                    <Link :href="editEntryRoute.url({ custom_table: table.id, entry: entry.id })">
                                        <Edit :size="14" class="mr-1.5" />
                                        Изменить
                                    </Link>
                                </Button>
                                <Button
                                    variant="outline"
                                    size="icon"
                                    class="size-8 text-destructive hover:bg-destructive/10 hover:text-destructive"
                                    @click="openDeleteDialog(entry.id)"
                                >
                                    <Trash2 :size="14" />
                                </Button>
                            </div>
                        </div>

                        <!-- Collapsible details -->
                        <div v-if="expandedEntries.has(entry.id)" class="space-y-2 rounded-lg bg-muted p-3">
                            <div
                                v-for="col in table.columns"
                                :key="col.key"
                                class="flex items-start justify-between gap-2"
                            >
                                <span class="text-xs text-muted-foreground">{{ col.name || col.key }}:</span>
                                <span class="text-sm font-medium">{{ formatValue(entry.data[col.key], col.type) }}</span>
                            </div>
                        </div>
                    </li>
                </ul>
            </template>

            <!-- Pagination -->
            <div v-if="entries.last_page > 1" class="flex items-center justify-between border-t px-6 py-4">
                <p class="text-sm text-muted-foreground">
                    Показано
                    <span class="font-medium">{{ entries.from ?? 0 }}</span>
                    -
                    <span class="font-medium">{{ entries.to ?? 0 }}</span>
                    из
                    <span class="font-medium">{{ entries.total }}</span>
                </p>

                <div class="flex items-center gap-2">
                    <template v-for="(link, i) in entries.links" :key="i">
                        <Button
                            v-if="link.url"
                            as-child
                            :variant="link.active ? 'default' : 'outline'"
                            size="sm"
                            class="h-8 w-8 p-0"
                        >
                            <a v-html="link.label" :href="link.url" />
                        </Button>
                        <span
                            v-else
                            class="flex h-8 w-8 items-center justify-center text-muted-foreground"
                        >
                            <span v-html="link.label" />
                        </span>
                    </template>
                </div>
            </div>
        </section>

        <!-- Delete entry dialog -->
        <ConfirmDeleteDialog
            :open="deleteDialog.open"
            :loading="deleteDialog.loading"
            item-name="строку"
            @close="closeDeleteDialog"
            @confirm="confirmDeleteEntry"
        />

        <!-- Delete table dialog -->
        <ConfirmDeleteDialog
            :open="deleteTableDialog.open"
            :loading="deleteTableDialog.loading"
            :item-name="table.name"
            @close="closeDeleteTableDialog"
            @confirm="confirmDeleteTable"
        />
    </div>
</template>
