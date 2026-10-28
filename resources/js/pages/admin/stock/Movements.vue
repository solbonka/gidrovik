<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, onBeforeUnmount, ref, watch } from 'vue';
import type { Component } from 'vue';
import { toast } from 'vue-sonner';
import {
    ArrowDownToLine,
    ArrowLeftRight,
    ArrowRight,
    ArrowUpFromLine,
    ChevronLeft,
    ChevronRight,
    ClipboardCheck,
    Filter,
    History,
    PackageMinus,
    PackagePlus,
    Search,
    Trash2,
    Undo2,
    User,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';
import { Button } from '@/components/ui/button';

defineOptions({ layout: AdminLayout });

interface MovementType {
    value: string;
    label: string;
}

interface Movement {
    id: number;
    type: string;
    type_label: string;
    quantity: number | string;
    comment: string | null;
    created_at: string | null;
    product: {
        id: number;
        name: string;
        code: string | null;
        article: string | null;
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

/* ---------- Форматирование ---------- */

const numberFormat = new Intl.NumberFormat('ru-RU', {
    maximumFractionDigits: 3,
});

function formatNumber(value: number | string | null | undefined): string {
    if (value === null || value === undefined || value === '') return '—';

    const number = Number(value);

    return Number.isNaN(number) ? String(value) : numberFormat.format(number);
}

/* ---------- Типы операций ---------- */

type MovementKind =
    | 'receipt'
    | 'transfer'
    | 'writeoff'
    | 'return'
    | 'inventory'
    | 'other';

const movementStyles: Record<
    MovementKind,
    { badge: string; icon: Component; quantity: string; sign: string }
> = {
    receipt: {
        badge: 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400',
        icon: ArrowDownToLine,
        quantity: 'text-emerald-700 dark:text-emerald-400',
        sign: '+',
    },
    transfer: {
        badge: 'bg-sky-500/10 text-sky-700 ring-sky-600/20 dark:text-sky-400',
        icon: ArrowLeftRight,
        quantity: 'text-foreground',
        sign: '',
    },
    writeoff: {
        badge: 'bg-rose-500/10 text-rose-700 ring-rose-600/20 dark:text-rose-400',
        icon: ArrowUpFromLine,
        quantity: 'text-rose-700 dark:text-rose-400',
        sign: '−',
    },
    return: {
        badge: 'bg-violet-500/10 text-violet-700 ring-violet-600/20 dark:text-violet-400',
        icon: Undo2,
        quantity: 'text-violet-700 dark:text-violet-400',
        sign: '+',
    },
    inventory: {
        badge: 'bg-amber-500/10 text-amber-700 ring-amber-600/20 dark:text-amber-400',
        icon: ClipboardCheck,
        quantity: 'text-foreground',
        sign: '',
    },
    other: {
        badge: 'bg-muted text-muted-foreground ring-border',
        icon: History,
        quantity: 'text-foreground',
        sign: '',
    },
};

function movementKind(movement: Movement): MovementKind {
    const text = `${movement.type} ${movement.type_label}`.toLowerCase();

    if (/inventor|инвентар/.test(text)) return 'inventory';
    if (/receipt|income|приход|поступ/.test(text)) return 'receipt';
    if (/transfer|перемещ/.test(text)) return 'transfer';
    if (/write|issue|спис|расход/.test(text)) return 'writeoff';
    if (/return|возврат/.test(text)) return 'return';

    return 'other';
}

const style = (movement: Movement) => movementStyles[movementKind(movement)];

function quantityText(movement: Movement): string {
    const base = formatNumber(Math.abs(Number(movement.quantity)));

    return base === '—' ? base : `${style(movement).sign}${base}`;
}

function route(movement: Movement): { from: string; to: string } {
    const kind = movementKind(movement);

    return {
        from:
            movement.from_location?.code ??
            (kind === 'receipt' || kind === 'return' ? 'Поступление' : '—'),
        to:
            movement.to_location?.code ??
            (kind === 'writeoff' ? 'Списание' : '—'),
    };
}

/* ---------- Фильтры ---------- */

const fieldClass =
    'w-full rounded-xl border border-input bg-background px-3 py-2.5 text-sm shadow-xs outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30';

const search = ref(props.filters.search ?? '');
const type = ref(props.filters.type ?? '');

const hasLocalFilters = computed(() => Boolean(search.value || type.value));

// Название товара берём из первой строки, если фильтр по товару включён
const productFilterLabel = computed(() => {
    if (!props.filters.product_id) return null;

    const match = props.movements.data.find(
        (movement) => String(movement.product.id) === props.filters.product_id,
    );

    return match?.product.name ?? `№${props.filters.product_id}`;
});

let debounceTimer: ReturnType<typeof setTimeout> | undefined;

const applyFilters = (): void => {
    clearTimeout(debounceTimer);

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

// Автоприменение фильтров с небольшой задержкой
watch([search, type], () => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(applyFilters, 350);
});

onBeforeUnmount(() => clearTimeout(debounceTimer));

const resetFilters = (): void => {
    search.value = '';
    type.value = '';
};

const clearProductFilter = (): void => {
    clearTimeout(debounceTimer);

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

/* ---------- Удаление ---------- */

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

/* ---------- Пагинация ---------- */

const prevLink = computed(() => props.movements.links[0] ?? null);
const nextLink = computed(
    () => props.movements.links[props.movements.links.length - 1] ?? null,
);
const pageLinks = computed(() => props.movements.links.slice(1, -1));
const hasPagination = computed(() => props.movements.links.length > 3);

const pageButtonBase =
    'inline-flex h-9 min-w-9 items-center justify-center rounded-xl border px-3 text-sm font-medium transition';
</script>

<template>
    <Head title="Журнал складских движений" />

    <div class="space-y-6">
        <!-- Заголовок -->
        <header
            class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between"
        >
            <div class="flex items-center gap-4">
                <div
                    class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                >
                    <History :size="24" />
                </div>
                <div>
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Журнал движений
                    </h1>
                    <p class="mt-1 text-sm text-muted-foreground">
                        История поступлений, перемещений, списаний и других
                        операций
                    </p>
                </div>
            </div>

            <div class="flex flex-wrap gap-2">
                <Button as-child>
                    <Link href="/admin/stock/receipt">
                        <PackagePlus :size="17" class="mr-2" />
                        Поступление
                    </Link>
                </Button>

                <Button as-child variant="outline">
                    <Link href="/admin/stock/transfer">
                        <ArrowLeftRight :size="17" class="mr-2" />
                        Перемещение
                    </Link>
                </Button>

                <Button as-child variant="outline">
                    <Link href="/admin/stock/write-off">
                        <PackageMinus :size="17" class="mr-2" />
                        Списание
                    </Link>
                </Button>
            </div>
        </header>

        <!-- Фильтр по товару -->
        <div
            v-if="productFilterLabel"
            class="flex flex-wrap items-center gap-3 rounded-2xl border border-primary/20 bg-primary/5 px-4 py-3"
        >
            <span class="inline-flex items-center gap-2 text-sm font-medium">
                <Filter :size="15" class="text-primary" />
                Показаны движения товара:
                <span class="text-primary">{{ productFilterLabel }}</span>
            </span>

            <Button
                variant="ghost"
                size="sm"
                class="ml-auto text-muted-foreground"
                @click="clearProductFilter"
            >
                <X :size="15" class="mr-1.5" />
                Показать все товары
            </Button>
        </div>

        <!-- Фильтры -->
        <form
            class="rounded-2xl border bg-card p-4 shadow-sm sm:p-5"
            @submit.prevent="applyFilters"
        >
            <div class="space-y-1.5">
                <label for="search" class="text-sm font-medium">
                    Поиск по товару
                </label>
                <div class="relative">
                    <Search
                        :size="16"
                        class="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-muted-foreground"
                    />
                    <input
                        id="search"
                        v-model="search"
                        type="search"
                        placeholder="Название или артикул"
                        class="pl-9"
                        :class="fieldClass"
                    />
                </div>
            </div>

            <div
                class="mt-4 flex flex-col gap-3 border-t pt-4 sm:flex-row sm:items-center sm:justify-between"
            >
                <div
                    class="flex flex-wrap gap-2"
                    role="group"
                    aria-label="Тип операции"
                >
                    <button
                        type="button"
                        class="rounded-full border px-3.5 py-1.5 text-sm font-medium transition focus-visible:ring-[3px] focus-visible:ring-ring/40 focus-visible:outline-none"
                        :class="
                            type === ''
                                ? 'border-primary bg-primary text-primary-foreground shadow-xs'
                                : 'bg-background text-muted-foreground hover:border-primary/30 hover:text-foreground'
                        "
                        :aria-pressed="type === ''"
                        @click="type = ''"
                    >
                        Все операции
                    </button>

                    <button
                        v-for="item in types"
                        :key="item.value"
                        type="button"
                        class="rounded-full border px-3.5 py-1.5 text-sm font-medium transition focus-visible:ring-[3px] focus-visible:ring-ring/40 focus-visible:outline-none"
                        :class="
                            type === item.value
                                ? 'border-primary bg-primary text-primary-foreground shadow-xs'
                                : 'bg-background text-muted-foreground hover:border-primary/30 hover:text-foreground'
                        "
                        :aria-pressed="type === item.value"
                        @click="type = item.value"
                    >
                        {{ item.label }}
                    </button>
                </div>

                <Button
                    v-if="hasLocalFilters"
                    type="button"
                    variant="ghost"
                    size="sm"
                    class="self-start text-muted-foreground sm:self-auto"
                    @click="resetFilters"
                >
                    <X :size="15" class="mr-1.5" />
                    Сбросить
                </Button>
            </div>
        </form>

        <!-- Журнал -->
        <section
            class="overflow-hidden rounded-2xl border bg-card shadow-sm"
            aria-labelledby="journal-title"
        >
            <div
                class="flex flex-col gap-1 border-b px-5 py-4 sm:flex-row sm:items-center sm:justify-between"
            >
                <h2 id="journal-title" class="font-semibold">Операции</h2>
                <p class="text-sm text-muted-foreground">
                    Найдено записей:
                    <span class="font-medium text-foreground tabular-nums">
                        {{ movements.total }}
                    </span>
                </p>
            </div>

            <!-- Пустое состояние -->
            <div
                v-if="movements.data.length === 0"
                class="flex flex-col items-center px-6 py-16 text-center"
            >
                <div
                    class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted"
                >
                    <History :size="30" class="text-muted-foreground" />
                </div>
                <p class="font-medium">Движений нет</p>
                <p class="mt-1 max-w-sm text-sm text-muted-foreground">
                    {{
                        hasLocalFilters || productFilterLabel
                            ? 'По заданным условиям ничего не найдено. Попробуйте изменить фильтры.'
                            : 'После первой складской операции она появится в журнале.'
                    }}
                </p>
                <Button
                    v-if="hasLocalFilters"
                    variant="outline"
                    class="mt-5"
                    @click="resetFilters"
                >
                    Сбросить фильтры
                </Button>
            </div>

            <template v-else>
                <!-- Мобильные карточки -->
                <ul class="divide-y md:hidden">
                    <li
                        v-for="movement in movements.data"
                        :key="movement.id"
                        class="space-y-3 p-4"
                    >
                        <div class="flex items-start justify-between gap-3">
                            <div class="min-w-0">
                                <span
                                    class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset"
                                    :class="style(movement).badge"
                                >
                                    <component :is="style(movement).icon" :size="13" />
                                    {{ movement.type_label }}
                                </span>
                                <h3 class="mt-2 break-words text-sm font-semibold">
                                    {{ movement.product.name }}
                                </h3>
                                <p class="mt-0.5 font-mono text-xs text-muted-foreground">
                                    {{ movement.product.code || movement.product.article || 'Без кода/артикула' }}
                                </p>
                            </div>

                            <p
                                class="shrink-0 text-lg font-bold tabular-nums"
                                :class="style(movement).quantity"
                            >
                                {{ quantityText(movement) }}
                            </p>
                        </div>

                        <div class="flex items-center gap-2 text-xs">
                            <span class="max-w-[42%] truncate rounded-md bg-muted px-2 py-1">
                                {{ route(movement).from }}
                            </span>
                            <ArrowRight :size="13" class="shrink-0 text-muted-foreground" />
                            <span class="max-w-[42%] truncate rounded-md bg-muted px-2 py-1">
                                {{ route(movement).to }}
                            </span>
                        </div>

                        <p v-if="movement.comment" class="text-xs text-muted-foreground">
                            {{ movement.comment }}
                        </p>

                        <div
                            class="flex items-center justify-between gap-3 border-t pt-3"
                        >
                            <div class="min-w-0 text-xs text-muted-foreground">
                                <p>{{ movement.created_at ?? '—' }}</p>
                                <p class="mt-0.5 flex items-center gap-1 truncate">
                                    <User :size="12" />
                                    {{ movement.user ?? '—' }}
                                </p>
                            </div>

                            <Button
                                variant="ghost"
                                size="sm"
                                class="text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
                                @click="openDeleteDialog(movement.id)"
                            >
                                <Trash2 :size="15" class="mr-1.5" />
                                Удалить
                            </Button>
                        </div>
                    </li>
                </ul>

                <!-- Таблица -->
                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full min-w-[980px] text-left text-sm">
                        <thead>
                        <tr class="border-b bg-muted/40">
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Дата</th>
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Операция</th>
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Товар</th>
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Ячейки</th>
                            <th scope="col" class="px-5 py-3.5 text-right text-xs font-semibold tracking-wider text-muted-foreground uppercase">Количество</th>
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Пользователь</th>
                            <th scope="col" class="px-5 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Комментарий</th>
                            <th scope="col" class="px-5 py-3.5">
                                <span class="sr-only">Действия</span>
                            </th>
                        </tr>
                        </thead>

                        <tbody class="divide-y">
                        <tr
                            v-for="movement in movements.data"
                            :key="movement.id"
                            class="transition-colors hover:bg-muted/40"
                        >
                            <td class="px-5 py-4 text-xs whitespace-nowrap text-muted-foreground">
                                {{ movement.created_at ?? '—' }}
                            </td>

                            <td class="px-5 py-4 whitespace-nowrap">
                                    <span
                                        class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset"
                                        :class="style(movement).badge"
                                    >
                                        <component :is="style(movement).icon" :size="13" />
                                        {{ movement.type_label }}
                                    </span>
                            </td>

                            <td class="px-5 py-4">
                                <div class="font-medium">
                                    {{ movement.product.name }}
                                </div>
                                <div class="mt-0.5 font-mono text-xs text-muted-foreground">
                                    {{ movement.product.code || movement.product.article || 'Без кода/артикула' }}
                                </div>
                            </td>

                            <td class="px-5 py-4">
                                <div class="flex items-center gap-2 text-xs">
                                        <span class="max-w-28 truncate rounded-md bg-muted px-2 py-1">
                                            {{ route(movement).from }}
                                        </span>
                                    <ArrowRight :size="13" class="shrink-0 text-muted-foreground" />
                                    <span class="max-w-28 truncate rounded-md bg-muted px-2 py-1">
                                            {{ route(movement).to }}
                                        </span>
                                </div>
                            </td>

                            <td
                                class="px-5 py-4 text-right font-bold whitespace-nowrap tabular-nums"
                                :class="style(movement).quantity"
                            >
                                {{ quantityText(movement) }}
                            </td>

                            <td class="px-5 py-4 text-muted-foreground">
                                {{ movement.user ?? '—' }}
                            </td>

                            <td class="max-w-xs px-5 py-4 text-muted-foreground">
                                    <span class="line-clamp-2" :title="movement.comment ?? undefined">
                                        {{ movement.comment ?? '—' }}
                                    </span>
                            </td>

                            <td class="px-5 py-4 text-right">
                                <Button
                                    variant="ghost"
                                    size="icon"
                                    class="size-9 text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
                                    title="Удалить запись"
                                    aria-label="Удалить запись"
                                    @click="openDeleteDialog(movement.id)"
                                >
                                    <Trash2 :size="16" />
                                </Button>
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
                    Показано {{ movements.from ?? 0 }}–{{ movements.to ?? 0 }}
                    из {{ movements.total }}
                </p>

                <nav
                    class="flex flex-wrap items-center justify-center gap-1"
                    aria-label="Навигация по страницам"
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
            :open="deleteDialogOpen"
            item-name="эту запись"
            :loading="deleting"
            @confirm="confirmDelete"
            @cancel="closeDeleteDialog"
        />
    </div>
</template>
