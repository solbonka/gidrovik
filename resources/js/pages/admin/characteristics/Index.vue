<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';
import { toast } from 'vue-sonner';
import {
    FileText,
    Layers3,
    ListFilter,
    Pencil,
    Plus,
    Search,
    Settings2,
    Trash2,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';
import { Button } from '@/components/ui/button';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { create, destroy, edit } from '@/routes/admin/characteristics';

defineOptions({
    layout: AdminLayout,
});

interface Characteristic {
    id: number;
    name: string;
    slug: string;
    type: string;
    unit: string | null;
    is_active: boolean;
    categories_count: number;
}

interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

interface PaginatedCharacteristics {
    data: Characteristic[];
    current_page: number;
    last_page: number;
    from: number | null;
    to: number | null;
    total: number;
    links: PaginationLink[];
}

interface Props {
    characteristics: PaginatedCharacteristics;
}

const props = defineProps<Props>();

const typeLabels: Record<string, string> = {
    text: 'Текст',
    string: 'Текст',
    number: 'Число',
    integer: 'Целое число',
    decimal: 'Десятичное число',
    select: 'Список',
    boolean: 'Да / Нет',
};

/* ---------- Поиск и фильтры (по загруженной странице) ---------- */

const search = ref('');
const statusFilter = ref<'all' | 'active' | 'inactive'>('all');
const typeFilter = ref('all');

const filteredCharacteristics = computed(() => {
    const query = search.value.trim().toLowerCase();

    const result = props.characteristics.data.filter((item) => {
        const matchesSearch =
            !query ||
            item.name.toLowerCase().includes(query) ||
            item.slug.toLowerCase().includes(query) ||
            (item.unit ?? '').toLowerCase().includes(query) ||
            (typeLabels[item.type] ?? item.type).toLowerCase().includes(query);

        const matchesStatus =
            statusFilter.value === 'all' ||
            (statusFilter.value === 'active' && item.is_active) ||
            (statusFilter.value === 'inactive' && !item.is_active);

        const matchesType =
            typeFilter.value === 'all' || item.type === typeFilter.value;

        return matchesSearch && matchesStatus && matchesType;
    });

    return result;
});

const availableTypes = computed(() => {
    return [...new Set(props.characteristics.data.map((item) => item.type))];
});

const activeFiltersCount = computed(
    () =>
        [
            search.value,
            statusFilter.value !== 'all' ? statusFilter.value : '',
            typeFilter.value !== 'all' ? typeFilter.value : '',
        ].filter(Boolean).length,
);

const resetFilters = (): void => {
    search.value = '';
    statusFilter.value = 'all';
    typeFilter.value = 'all';
};

/* ---------- Статистика ---------- */

// Если страниц несколько, часть показателей считается только по текущей странице
const paged = computed(() => props.characteristics.last_page > 1);
const pageSuffix = computed(() => (paged.value ? ' на странице' : ''));

const activeCount = computed(
    () => props.characteristics.data.filter((item) => item.is_active).length,
);
const inactiveCount = computed(
    () => props.characteristics.data.length - activeCount.value,
);
const assignedCount = computed(
    () =>
        props.characteristics.data.filter((item) => item.categories_count > 0)
            .length,
);

const stats = computed(() => [
    {
        title: 'Всего характеристик',
        value: props.characteristics.total,
        icon: Settings2,
        tone: 'bg-primary/10 text-primary',
    },
    {
        title: `Активные${pageSuffix.value}`,
        value: activeCount.value,
        icon: Layers3,
        tone: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400',
    },
    {
        title: `Неактивные${pageSuffix.value}`,
        value: inactiveCount.value,
        icon: FileText,
        tone: 'bg-muted text-muted-foreground',
    },
    {
        title: `Используются${pageSuffix.value}`,
        value: assignedCount.value,
        icon: ListFilter,
        tone: 'bg-sky-500/10 text-sky-600 dark:text-sky-400',
    },
]);

/* ---------- Удаление ---------- */

const deleteDialog = ref({
    open: false,
    id: null as number | null,
    name: '',
    loading: false,
});

const openDeleteDialog = (characteristic: Characteristic): void => {
    if (characteristic.categories_count > 0) {
        toast.error('Нельзя удалить характеристику, которая привязана к категориям.');
        return;
    }

    deleteDialog.value.id = characteristic.id;
    deleteDialog.value.name = characteristic.name;
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
        onSuccess: () => {
            toast.success('Характеристика удалена.');
        },
        onError: () => {
            toast.error('Не удалось удалить характеристику.');
        },
        onFinish: () => {
            deleteDialog.value.loading = false;
            deleteDialog.value.open = false;
        },
    });
};

const activeBadge =
    'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400';
const inactiveBadge = 'bg-muted text-muted-foreground ring-border';
</script>

<template>
    <Head title="Характеристики" />

    <div class="space-y-6 pb-4">
        <!-- Заголовок -->
        <header
            class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between"
        >
            <div class="flex items-center gap-4">
                <div
                    class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                >
                    <Settings2 :size="24" />
                </div>
                <div>
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Характеристики
                    </h1>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Параметры, которые можно назначать категориям товаров
                    </p>
                </div>
            </div>

            <Button as-child class="w-full sm:w-auto">
                <Link :href="create.url()">
                    <Plus :size="18" class="mr-2" />
                    Добавить характеристику
                </Link>
            </Button>
        </header>

        <!-- Статистика -->
        <section
            class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4"
            aria-label="Сводка"
        >
            <div
                v-for="stat in stats"
                :key="stat.title"
                class="flex items-center gap-4 rounded-2xl border bg-card p-5 shadow-sm"
            >
                <div
                    class="flex size-11 shrink-0 items-center justify-center rounded-xl"
                    :class="stat.tone"
                >
                    <component :is="stat.icon" :size="22" />
                </div>
                <div class="min-w-0">
                    <p class="truncate text-sm text-muted-foreground">
                        {{ stat.title }}
                    </p>
                    <p class="mt-0.5 text-2xl font-bold tracking-tight tabular-nums">
                        {{ stat.value }}
                    </p>
                </div>
            </div>
        </section>

        <!-- Список -->
        <section
            class="overflow-hidden rounded-2xl border bg-card shadow-sm"
            aria-labelledby="characteristics-title"
        >
            <div
                class="flex flex-col gap-4 border-b px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6"
            >
                <div>
                    <h2 id="characteristics-title" class="font-semibold">
                        Список характеристик
                    </h2>
                    <p class="mt-0.5 text-sm text-muted-foreground">
                        Показано:
                        <span class="font-medium text-foreground tabular-nums">
                            {{ filteredCharacteristics.length }}
                        </span>
                        <template v-if="paged"> (поиск — по текущей странице)</template>
                    </p>
                </div>

                <div class="flex flex-col gap-3 sm:flex-row">
                    <div class="relative w-full sm:max-w-xs">
                        <Search
                            :size="16"
                            class="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-muted-foreground"
                        />
                        <input
                            v-model="search"
                            type="search"
                            placeholder="Название, slug, единица..."
                            aria-label="Поиск характеристик"
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

                    <Select v-model="statusFilter">
                        <SelectTrigger class="w-full sm:w-[140px]">
                            <SelectValue placeholder="Статус" />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="all">Все статусы</SelectItem>
                            <SelectItem value="active">Активные</SelectItem>
                            <SelectItem value="inactive">Неактивные</SelectItem>
                        </SelectContent>
                    </Select>

                    <Select v-model="typeFilter">
                        <SelectTrigger class="w-full sm:w-[140px]">
                            <SelectValue placeholder="Тип" />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="all">Все типы</SelectItem>
                            <SelectItem
                                v-for="type in availableTypes"
                                :key="type"
                                :value="type"
                            >
                                {{ typeLabels[type] ?? type }}
                            </SelectItem>
                        </SelectContent>
                    </Select>
                </div>
            </div>

            <div v-if="activeFiltersCount" class="border-t px-5 py-3 sm:px-6">
                <Button
                    variant="ghost"
                    size="sm"
                    class="text-muted-foreground"
                    @click="resetFilters"
                >
                    <X :size="15" class="mr-1.5" />
                    Сбросить ({{ activeFiltersCount }})
                </Button>
            </div>

            <!-- Пустое состояние -->
            <div
                v-if="filteredCharacteristics.length === 0"
                class="flex flex-col items-center px-6 py-16 text-center"
            >
                <div
                    class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted"
                >
                    <Search v-if="search || statusFilter !== 'all' || typeFilter !== 'all'" :size="28" class="text-muted-foreground" />
                    <Settings2 v-else :size="28" class="text-muted-foreground" />
                </div>
                <p class="font-medium">
                    {{ (search || statusFilter !== 'all' || typeFilter !== 'all') ? 'Ничего не найдено' : 'Характеристик пока нет' }}
                </p>
                <p class="mt-1 max-w-sm text-sm text-muted-foreground">
                    {{
                        (search || statusFilter !== 'all' || typeFilter !== 'all')
                            ? 'Попробуйте изменить параметры фильтров.'
                            : 'Создайте первую характеристику, чтобы задать параметры товаров.'
                    }}
                </p>

                <Button
                    v-if="search || statusFilter !== 'all' || typeFilter !== 'all'"
                    variant="outline"
                    class="mt-5"
                    @click="resetFilters"
                >
                    Сбросить фильтры
                </Button>
                <Button v-else as-child class="mt-5">
                    <Link :href="create.url()">
                        <Plus :size="16" class="mr-2" />
                        Добавить характеристику
                    </Link>
                </Button>
            </div>

            <template v-else>
                <!-- Мобильные карточки -->
                <ul class="divide-y md:hidden">
                    <li
                        v-for="characteristic in filteredCharacteristics"
                        :key="characteristic.id"
                        class="space-y-3 p-4"
                    >
                        <div class="flex items-start justify-between gap-3">
                            <div class="flex min-w-0 items-center gap-3">
                                <div
                                    class="flex size-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
                                >
                                    <FileText :size="17" />
                                </div>
                                <div class="min-w-0">
                                    <h3 class="text-sm font-semibold break-words">
                                        {{ characteristic.name }}
                                    </h3>
                                    <p class="truncate text-xs text-muted-foreground">
                                        {{ characteristic.slug }}
                                    </p>
                                </div>
                            </div>

                            <span
                                class="inline-flex shrink-0 items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset"
                                :class="characteristic.is_active ? activeBadge : inactiveBadge"
                            >
                                <span
                                    class="size-1.5 rounded-full"
                                    :class="characteristic.is_active ? 'bg-emerald-500' : 'bg-muted-foreground/50'"
                                />
                                {{ characteristic.is_active ? 'Активна' : 'Неактивна' }}
                            </span>
                        </div>

                        <div class="grid grid-cols-3 gap-2 text-center">
                            <div class="rounded-lg bg-violet-500/10 px-2 py-2">
                                <p class="text-[11px] text-muted-foreground">Тип</p>
                                <p class="mt-0.5 truncate text-xs font-medium text-violet-700 dark:text-violet-400">
                                    {{ typeLabels[characteristic.type] ?? characteristic.type }}
                                </p>
                            </div>
                            <div class="rounded-lg bg-amber-500/10 px-2 py-2">
                                <p class="text-[11px] text-muted-foreground">Единица</p>
                                <p class="mt-0.5 truncate text-xs font-medium text-amber-700 dark:text-amber-400">
                                    {{ characteristic.unit ?? '—' }}
                                </p>
                            </div>
                            <div class="rounded-lg bg-sky-500/10 px-2 py-2">
                                <p class="text-[11px] text-muted-foreground">Категорий</p>
                                <p class="mt-0.5 text-sm font-bold text-sky-700 tabular-nums dark:text-sky-400">
                                    {{ characteristic.categories_count }}
                                </p>
                            </div>
                        </div>

                        <div class="flex items-center gap-2">
                            <Button as-child variant="outline" size="sm" class="h-9 flex-1">
                                <Link :href="edit(characteristic.id).url">
                                    <Pencil :size="14" class="mr-1.5" />
                                    Изменить
                                </Link>
                            </Button>

                            <Button
                                variant="outline"
                                size="icon"
                                class="size-9 shrink-0 text-destructive hover:bg-destructive/10 hover:text-destructive"
                                :disabled="characteristic.categories_count > 0"
                                :title="characteristic.categories_count > 0 ? 'Нельзя удалить: характеристика привязана к категориям' : 'Удалить'"
                                @click="openDeleteDialog(characteristic)"
                            >
                                <Trash2 :size="15" />
                                <span class="sr-only">Удалить</span>
                            </Button>
                        </div>
                    </li>
                </ul>

                <!-- Таблица -->
                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full min-w-[900px] text-left text-sm">
                        <thead>
                        <tr class="border-b bg-muted/40">
                            <th scope="col" class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Характеристика</th>
                            <th scope="col" class="px-4 py-3.5 text-center text-xs font-semibold tracking-wider text-muted-foreground uppercase">Тип</th>
                            <th scope="col" class="px-4 py-3.5 text-center text-xs font-semibold tracking-wider text-muted-foreground uppercase">Единица</th>
                            <th scope="col" class="px-4 py-3.5 text-center text-xs font-semibold tracking-wider text-muted-foreground uppercase">Категорий</th>
                            <th scope="col" class="px-4 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Статус</th>
                            <th scope="col" class="px-6 py-3.5">
                                <span class="sr-only">Действия</span>
                            </th>
                        </tr>
                        </thead>

                        <tbody class="divide-y">
                        <tr
                            v-for="characteristic in filteredCharacteristics"
                            :key="characteristic.id"
                            class="transition-colors hover:bg-muted/40"
                        >
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary"
                                    >
                                        <FileText :size="19" />
                                    </div>
                                    <div class="min-w-0">
                                        <p class="font-semibold">
                                            {{ characteristic.name }}
                                        </p>
                                        <p class="mt-0.5 text-xs text-muted-foreground">
                                            {{ characteristic.slug }}
                                        </p>
                                    </div>
                                </div>
                            </td>

                            <td class="px-4 py-4 text-center">
                                    <span
                                        class="inline-flex min-w-9 justify-center rounded-lg bg-violet-500/10 px-2.5 py-1.5 font-semibold text-violet-700 tabular-nums dark:text-violet-400"
                                    >
                                        {{ typeLabels[characteristic.type] ?? characteristic.type }}
                                    </span>
                            </td>

                            <td class="px-4 py-4 text-center">
                                    <span
                                        class="inline-flex min-w-9 justify-center rounded-lg bg-amber-500/10 px-2.5 py-1.5 font-semibold text-amber-700 tabular-nums dark:text-amber-400"
                                    >
                                        {{ characteristic.unit ?? '—' }}
                                    </span>
                            </td>

                            <td class="px-4 py-4 text-center">
                                    <span
                                        class="inline-flex min-w-9 justify-center rounded-lg bg-sky-500/10 px-2.5 py-1.5 font-semibold text-sky-700 tabular-nums dark:text-sky-400"
                                    >
                                        {{ characteristic.categories_count }}
                                    </span>
                            </td>

                            <td class="px-4 py-4">
                                    <span
                                        class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset"
                                        :class="characteristic.is_active ? activeBadge : inactiveBadge"
                                    >
                                        <span
                                            class="size-1.5 rounded-full"
                                            :class="characteristic.is_active ? 'bg-emerald-500' : 'bg-muted-foreground/50'"
                                        />
                                        {{ characteristic.is_active ? 'Активна' : 'Неактивна' }}
                                    </span>
                            </td>

                            <td class="px-6 py-4">
                                <div class="flex items-center justify-end gap-2">
                                    <Button
                                        as-child
                                        variant="ghost"
                                        size="icon"
                                        class="size-9"
                                    >
                                        <Link :href="edit(characteristic.id).url">
                                            <Pencil :size="16" />
                                            <span class="sr-only">Изменить</span>
                                        </Link>
                                    </Button>

                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        class="size-9 text-destructive hover:bg-destructive/10 hover:text-destructive"
                                        :disabled="characteristic.categories_count > 0"
                                        :title="characteristic.categories_count > 0 ? 'Нельзя удалить: характеристика привязана к категориям' : 'Удалить'"
                                        @click="openDeleteDialog(characteristic)"
                                    >
                                        <Trash2 :size="16" />
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

        <!-- Пагинация -->
        <nav
            v-if="characteristics.last_page > 1"
            class="flex flex-col gap-4 border-t border-border px-5 py-4 sm:flex-row sm:items-center sm:justify-between"
            aria-label="Пагинация характеристик"
        >
            <p class="text-sm text-muted-foreground">
                Показано
                <span class="font-medium text-foreground tabular-nums">
                    {{ characteristics.from }}–{{ characteristics.to }}
                </span>
                из
                <span class="font-medium text-foreground tabular-nums">
                    {{ characteristics.total }}
                </span>
            </p>

            <div class="flex items-center gap-1">
                <Button
                    v-if="characteristics.links[0]?.url"
                    as-child
                    variant="outline"
                    size="icon"
                    class="size-9"
                >
                    <Link :href="characteristics.links[0].url" preserve-scroll>
                        <span class="sr-only">Предыдущая страница</span>
                        <span aria-hidden="true">←</span>
                    </Link>
                </Button>

                <template v-for="(link, index) in characteristics.links.slice(1, -1)" :key="index">
                    <Button
                        v-if="link.url"
                        as-child
                        :variant="link.active ? 'default' : 'outline'"
                        size="icon"
                        class="size-9"
                    >
                        <Link :href="link.url" preserve-scroll>
                            {{ link.label }}
                        </Link>
                    </Button>
                    <span
                        v-else
                        class="inline-flex size-9 items-center justify-center text-sm"
                    >
                        {{ link.label }}
                    </span>
                </template>

                <Button
                    v-if="characteristics.links[characteristics.links.length - 1]?.url"
                    as-child
                    variant="outline"
                    size="icon"
                    class="size-9"
                >
                    <Link :href="characteristics.links[characteristics.links.length - 1].url!" preserve-scroll>
                        <span class="sr-only">Следующая страница</span>
                        <span aria-hidden="true">→</span>
                    </Link>
                </Button>
            </div>
        </nav>
    </div>

    <!-- Диалог подтверждения удаления -->
    <ConfirmDeleteDialog
        :open="deleteDialog.open"
        :item-name="deleteDialog.name"
        :loading="deleteDialog.loading"
        @close="closeDeleteDialog"
        @confirm="confirmDelete"
    />
</template>
