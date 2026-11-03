<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';

import {
    Database,
    Edit,
    FileSpreadsheet,
    FileText,
    Grid3X3,
    Hash,
    Layers,
    Plus,
    Search,
    Table,
    Trash2,
    Type,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';
import { Button } from '@/components/ui/button';
import {
    create as createTable,
    destroy,
    edit as editTable,
    index as tablesIndex,
    show as showTable,
} from '@/routes/admin/custom-tables';
import {
    csv as exportCsv,
    html as exportHtml,
} from '@/routes/admin/custom-tables/export';

defineOptions({
    layout: AdminLayout,
});

interface Column {
    key: string;
    name: string;
    type: string;
}

interface TableItem {
    id: number;
    name: string;
    slug: string;
    description: string | null;
    columns: Column[];
    entries_count: number;
    created_at: string;
}

interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

interface PaginatedTables {
    data: TableItem[];
    current_page: number;
    last_page: number;
    from: number | null;
    to: number | null;
    total: number;
    links: PaginationLink[];
}

interface Props {
    tables: PaginatedTables;
}

const props = defineProps<Props>();

const search = ref('');

const filteredTables = computed(() => {
    const query = search.value.trim().toLowerCase();

    if (!query) return props.tables.data;

    return props.tables.data.filter((table) =>
        [table.name, table.slug, table.description ?? ''].some((value) =>
            value.toLowerCase().includes(query),
        ),
    );
});

const paged = computed(() => props.tables.last_page > 1);
const pageSuffix = computed(() => (paged.value ? ' на странице' : ''));

const totalColumns = computed(() =>
    props.tables.data.reduce((sum, table) => sum + table.columns.length, 0),
);

const totalEntries = computed(() =>
    props.tables.data.reduce((sum, table) => sum + table.entries_count, 0),
);

const stats = computed(() => [
    {
        title: 'Всего таблиц',
        value: props.tables.total,
        icon: Database,
        tone: 'bg-primary/10 text-primary',
    },
    {
        title: `Колонок${pageSuffix.value}`,
        value: totalColumns.value,
        icon: Grid3X3,
        tone: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400',
    },
    {
        title: `Строк${pageSuffix.value}`,
        value: totalEntries.value,
        icon: Layers,
        tone: 'bg-blue-500/10 text-blue-600 dark:text-blue-400',
    },
]);

const deleteDialog = ref({
    open: false,
    id: null as number | null,
    name: '',
    slug: '',
    entriesCount: 0,
    loading: false,
});

const openDeleteDialog = (table: TableItem): void => {
    deleteDialog.value.id = table.id;
    deleteDialog.value.name = table.name;
    deleteDialog.value.slug = table.slug;
    deleteDialog.value.entriesCount = table.entries_count;
    deleteDialog.value.open = true;
};

const closeDeleteDialog = (): void => {
    if (deleteDialog.value.loading) return;
    deleteDialog.value.open = false;
};

const confirmDelete = (): void => {
    if (deleteDialog.value.id === null || deleteDialog.value.loading) return;

    deleteDialog.value.loading = true;

    router.delete(destroy.url(deleteDialog.value.id), {
        preserveScroll: true,
        onFinish: () => {
            deleteDialog.value.loading = false;
            deleteDialog.value.open = false;
        },
    });
};

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

const activeBadge =
    'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400';
const inactiveBadge = 'bg-muted text-muted-foreground ring-border';
</script>

<template>
    <Head title="Пользовательские таблицы" />

    <div class="space-y-6 pb-4">
        <!-- Header -->
        <header class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div class="flex items-center gap-4">
                <div class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm">
                    <Table :size="24" />
                </div>
                <div>
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">Пользовательские таблицы</h1>
                    <p class="mt-1 text-sm text-muted-foreground">Конструктор произвольных таблиц данных</p>
                </div>
            </div>

            <Button as-child>
                <Link :href="createTable().url">
                    <Plus :size="18" class="mr-2" />
                    Создать таблицу
                </Link>
            </Button>
        </header>

        <!-- Stats -->
        <section class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3" aria-label="Сводка">
            <div
                v-for="stat in stats"
                :key="stat.title"
                class="flex items-center gap-4 rounded-2xl border bg-card p-5 shadow-sm"
            >
                <div class="flex size-11 shrink-0 items-center justify-center rounded-xl" :class="stat.tone">
                    <component :is="stat.icon" :size="22" />
                </div>
                <div class="min-w-0">
                    <p class="truncate text-sm text-muted-foreground">{{ stat.title }}</p>
                    <p class="mt-0.5 text-2xl font-bold tracking-tight tabular-nums">{{ stat.value }}</p>
                </div>
            </div>
        </section>

        <!-- Tables list -->
        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm" aria-labelledby="tables-title">
            <div class="flex flex-col gap-4 border-b px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6">
                <div>
                    <h2 id="tables-title" class="font-semibold">Список таблиц</h2>
                    <p class="mt-0.5 text-sm text-muted-foreground">
                        Показано:
                        <span class="font-medium text-foreground tabular-nums">{{ filteredTables.length }}</span>
                    </p>
                </div>

                <div class="relative w-full sm:max-w-xs">
                    <Search
                        :size="16"
                        class="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-muted-foreground"
                    />
                    <input
                        v-model="search"
                        type="search"
                        placeholder="Поиск таблиц"
                        aria-label="Поиск таблиц"
                        class="w-full rounded-xl border border-input bg-background py-2.5 pr-9 pl-9 text-sm shadow-xs outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                    />
                    <button
                        v-if="search"
                        type="button"
                        aria-label="Очистить поиск"
                        class="absolute top-1/2 right-3 -translate-y-1/2 text-muted-foreground transition hover:text-foreground"
                        @click="search = ''"
                    >
                        <X :size="16" />
                    </button>
                </div>
            </div>

            <!-- Empty state -->
            <div
                v-if="filteredTables.length === 0"
                class="flex flex-col items-center px-6 py-16 text-center"
            >
                <div class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted">
                    <Search v-if="search" :size="28" class="text-muted-foreground" />
                    <Table v-else :size="28" class="text-muted-foreground" />
                </div>
                <p class="font-medium">{{ search ? 'Ничего не найдено' : 'Таблиц пока нет' }}</p>
                <p class="mt-1 max-w-sm text-sm text-muted-foreground">
                    {{ search ? 'Попробуйте изменить поисковый запрос.' : 'Создайте первую таблицу для работы со справочниками.' }}
                </p>

                <Button v-if="search" variant="outline" class="mt-5" @click="search = ''">
                    <X :size="15" class="mr-1.5" />
                    Очистить поиск
                </Button>
                <Button v-else as-child class="mt-5">
                    <Link :href="createTable().url">
                        <Plus :size="16" class="mr-2" />
                        Создать таблицу
                    </Link>
                </Button>
            </div>

            <template v-else>
                <!-- Mobile cards -->
                <ul class="divide-y md:hidden">
                    <li v-for="table in filteredTables" :key="table.id" class="space-y-3 p-4">
                        <div class="flex items-start justify-between gap-3">
                            <div class="flex min-w-0 items-center gap-3">
                                <div class="flex size-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                    <Table :size="17" />
                                </div>
                                <div class="min-w-0">
                                    <h3 class="text-sm font-semibold break-words">{{ table.name }}</h3>
                                    <p class="text-xs text-muted-foreground">{{ table.slug }}</p>
                                </div>
                            </div>
                        </div>

                        <p v-if="table.description" class="text-sm text-muted-foreground line-clamp-2">
                            {{ table.description }}
                        </p>

                        <div class="flex flex-wrap gap-1.5">
                            <span
                                v-for="col in table.columns.slice(0, 3)"
                                :key="col.key"
                                class="inline-flex rounded-md px-2 py-1 text-xs font-medium"
                                :class="typeBadge(col.type)"
                            >
                                {{ col.name || col.key }}
                            </span>
                            <span v-if="table.columns.length > 3" class="inline-flex items-center px-2 py-1 text-xs text-muted-foreground">
                                +{{ table.columns.length - 3 }}
                            </span>
                        </div>

                        <div class="flex items-center justify-between text-xs text-muted-foreground">
                            <span>Записей: {{ table.entries_count }}</span>
                            <span>Колонок: {{ table.columns.length }}</span>
                        </div>

                        <div class="flex items-center gap-2">
                            <Button as-child variant="outline" size="sm" class="h-9 flex-1">
                                <Link :href="showTable.url(table.id)">
                                    <FileText :size="14" class="mr-1.5" />
                                    Данные
                                </Link>
                            </Button>

                            <Button as-child variant="outline" size="sm" class="h-9 flex-1">
                                <Link :href="editTable.url(table.id)">
                                    <Edit :size="14" class="mr-1.5" />
                                    Изменить
                                </Link>
                            </Button>

                            <Button
                                variant="outline"
                                size="icon"
                                class="size-9 shrink-0 text-destructive hover:bg-destructive/10 hover:text-destructive"
                                @click="openDeleteDialog(table)"
                            >
                                <Trash2 :size="15" />
                                <span class="sr-only">Удалить</span>
                            </Button>
                        </div>
                    </li>
                </ul>

                <!-- Table -->
                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full min-w-[700px] text-left text-sm">
                        <thead>
                            <tr class="border-b bg-muted/40">
                                <th scope="col" class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Название</th>
                                <th scope="col" class="px-4 py-3.5 text-center text-xs font-semibold tracking-wider text-muted-foreground uppercase">Колонок</th>
                                <th scope="col" class="px-4 py-3.5 text-center text-xs font-semibold tracking-wider text-muted-foreground uppercase">Записей</th>
                                <th scope="col" class="px-4 py-3.5 text-center text-xs font-semibold tracking-wider text-muted-foreground uppercase">Колонки</th>
                                <th scope="col" class="px-6 py-3.5">
                                    <span class="sr-only">Действия</span>
                                </th>
                            </tr>
                        </thead>

                        <tbody class="divide-y">
                            <tr
                                v-for="table in filteredTables"
                                :key="table.id"
                                class="transition-colors hover:bg-muted/40"
                            >
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        <div class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
                                            <Table :size="19" />
                                        </div>
                                        <div class="min-w-0">
                                            <p class="font-semibold">{{ table.name }}</p>
                                            <p class="text-xs text-muted-foreground">{{ table.slug }}</p>
                                            <p v-if="table.description" class="mt-0.5 line-clamp-1 text-xs text-muted-foreground">
                                                {{ table.description }}
                                            </p>
                                        </div>
                                    </div>
                                </td>

                                <td class="px-4 py-4 text-center">
                                    <span class="inline-flex min-w-9 justify-center rounded-lg bg-blue-500/10 px-2.5 py-1.5 font-semibold text-blue-700 tabular-nums dark:text-blue-400">
                                        {{ table.columns.length }}
                                    </span>
                                </td>

                                <td class="px-4 py-4 text-center">
                                    <span class="inline-flex min-w-9 justify-center rounded-lg bg-emerald-500/10 px-2.5 py-1.5 font-semibold text-emerald-700 tabular-nums dark:text-emerald-400">
                                        {{ table.entries_count }}
                                    </span>
                                </td>

                                <td class="px-4 py-4">
                                    <div class="flex flex-wrap justify-center gap-1">
                                        <span
                                            v-for="col in table.columns.slice(0, 4)"
                                            :key="col.key"
                                            class="inline-flex rounded-md px-1.5 py-0.5 text-[11px] font-medium"
                                            :class="typeBadge(col.type)"
                                        >
                                            {{ col.name || col.key }}
                                        </span>
                                        <span v-if="table.columns.length > 4" class="text-xs text-muted-foreground">
                                            +{{ table.columns.length - 4 }}
                                        </span>
                                    </div>
                                </td>

                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-end gap-2">
                                        <Button as-child variant="outline" size="sm">
                                            <Link :href="showTable.url(table.id)">
                                                <FileText :size="14" class="mr-1.5" />
                                                Данные
                                            </Link>
                                        </Button>

                                        <Button as-child variant="outline" size="sm">
                                            <Link :href="editTable.url(table.id)">
                                                <Edit :size="14" class="mr-1.5" />
                                                Изменить
                                            </Link>
                                        </Button>

                                        <Button
                                            variant="outline"
                                            size="icon"
                                            class="size-8 text-destructive hover:bg-destructive/10 hover:text-destructive"
                                            @click="openDeleteDialog(table)"
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
            </template>
        </section>

        <!-- Delete dialog -->
        <ConfirmDeleteDialog
            :open="deleteDialog.open"
            :loading="deleteDialog.loading"
            :item-name="deleteDialog.name"
            @close="closeDeleteDialog"
            @confirm="confirmDelete"
        />
    </div>
</template>
