<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';
import { toast } from 'vue-sonner';
import {
    Building2,
    Pencil,
    Plus,
    Search,
    Trash2,
    X,
    Grid2X2,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';
import { Button } from '@/components/ui/button';
import { create, destroy, edit } from '@/routes/admin/warehouses';
import { index as racksIndex } from '@/routes/admin/racks';

defineOptions({
    layout: AdminLayout,
});

interface Rack {
    id: number;
    code: string;
    name: string | null;
    locations_count: number;
}

interface Warehouse {
    id: number;
    name: string;
    racks_count: number;
    racks: Rack[];
}

const props = defineProps<{
    warehouses: Warehouse[];
}>();

/* ---------- Поиск ---------- */

const search = ref('');

const filteredWarehouses = computed(() => {
    const query = search.value.trim().toLowerCase();

    if (!query) return props.warehouses;

    return props.warehouses.filter((warehouse) =>
        warehouse.name.toLowerCase().includes(query),
    );
});

/* ---------- Статистика ---------- */

const totalRacks = computed(() =>
    props.warehouses.reduce((total, warehouse) => total + warehouse.racks_count, 0),
);

const totalLocations = computed(() =>
    props.warehouses.reduce(
        (total, warehouse) =>
            total + warehouse.racks.reduce((sum, rack) => sum + rack.locations_count, 0),
        0,
    ),
);

const stats = computed(() => [
    {
        title: 'Всего складов',
        value: props.warehouses.length,
        icon: Building2,
        tone: 'bg-primary/10 text-primary',
    },
    {
        title: 'Стеллажей',
        value: totalRacks.value,
        icon: Building2,
        tone: 'bg-sky-500/10 text-sky-600 dark:text-sky-400',
    },
    {
        title: 'Ячеек',
        value: totalLocations.value,
        icon: Building2,
        tone: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400',
    },
]);

/* ---------- Удаление ---------- */

const deleteDialog = ref({
    open: false,
    id: null as number | null,
    name: '',
    loading: false,
});

const openDeleteDialog = (warehouse: Warehouse): void => {
    if (warehouse.racks_count > 0) {
        toast.error('Нельзя удалить склад, в котором есть стеллажи.');
        return;
    }

    deleteDialog.value.id = warehouse.id;
    deleteDialog.value.name = warehouse.name;
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
        onSuccess: () => {
            toast.success('Склад удалён.');
        },
        onError: () => {
            toast.error('Не удалось удалить склад.');
        },
        onFinish: () => {
            deleteDialog.value.loading = false;
            deleteDialog.value.open = false;
        },
    });
};
</script>

<template>
    <Head title="Склады" />

    <div class="space-y-6 pb-4">
        <!-- Заголовок -->
        <header
            class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between"
        >
            <div class="flex items-center gap-4">
                <div
                    class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                >
                    <Building2 :size="24" />
                </div>
                <div>
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Склады
                    </h1>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Управление складами и их стеллажами
                    </p>
                </div>
            </div>

            <Button as-child class="w-full sm:w-auto">
                <Link :href="create.url()">
                    <Plus :size="18" class="mr-2" />
                    Добавить склад
                </Link>
            </Button>
        </header>

        <!-- Статистика -->
        <section
            class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3"
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
            aria-labelledby="warehouses-title"
        >
            <div
                class="flex flex-col gap-4 border-b px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6"
            >
                <div>
                    <h2 id="warehouses-title" class="font-semibold">
                        Список складов
                    </h2>
                    <p class="mt-0.5 text-sm text-muted-foreground">
                        Показано:
                        <span class="font-medium text-foreground tabular-nums">
                            {{ filteredWarehouses.length }}
                        </span>
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
                        placeholder="Название склада"
                        aria-label="Поиск складов"
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

            <!-- Пустое состояние -->
            <div
                v-if="filteredWarehouses.length === 0"
                class="flex flex-col items-center px-6 py-16 text-center"
            >
                <div
                    class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted"
                >
                    <Search v-if="search" :size="28" class="text-muted-foreground" />
                    <Building2 v-else :size="28" class="text-muted-foreground" />
                </div>
                <p class="font-medium">
                    {{ search ? 'Ничего не найдено' : 'Складов пока нет' }}
                </p>
                <p class="mt-1 max-w-sm text-sm text-muted-foreground">
                    {{
                        search
                            ? 'Попробуйте изменить поисковый запрос.'
                            : 'Создайте первый склад, чтобы организовать стеллажи.'
                    }}
                </p>

                <Button
                    v-if="search"
                    variant="outline"
                    class="mt-5"
                    @click="search = ''"
                >
                    <X :size="15" class="mr-1.5" />
                    Очистить поиск
                </Button>
                <Button v-else as-child class="mt-5">
                    <Link :href="create.url()">
                        <Plus :size="16" class="mr-2" />
                        Добавить склад
                    </Link>
                </Button>
            </div>

            <template v-else>
                <!-- Мобильные карточки -->
                <ul class="divide-y md:hidden">
                    <li
                        v-for="warehouse in filteredWarehouses"
                        :key="warehouse.id"
                        class="space-y-3 p-4"
                    >
                        <div class="flex items-start justify-between gap-3">
                            <div class="flex min-w-0 items-center gap-3">
                                <div
                                    class="flex size-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
                                >
                                    <Building2 :size="17" />
                                </div>
                                <div class="min-w-0">
                                    <h3 class="text-sm font-semibold break-words">
                                        {{ warehouse.name }}
                                    </h3>
                                </div>
                            </div>
                        </div>

                        <div class="grid grid-cols-2 gap-2 text-center">
                            <div class="rounded-lg bg-sky-500/10 px-2 py-2">
                                <p class="text-[11px] text-muted-foreground">Стеллажей</p>
                                <p class="mt-0.5 text-sm font-bold text-sky-700 tabular-nums dark:text-sky-400">
                                    {{ warehouse.racks_count }}
                                </p>
                            </div>
                            <div class="rounded-lg bg-emerald-500/10 px-2 py-2">
                                <p class="text-[11px] text-muted-foreground">Ячеек</p>
                                <p class="mt-0.5 text-sm font-bold text-emerald-700 tabular-nums dark:text-emerald-400">
                                    {{ warehouse.racks.reduce((sum, rack) => sum + rack.locations_count, 0) }}
                                </p>
                            </div>
                        </div>

                        <div class="flex items-center gap-2">
                            <Button as-child variant="outline" size="sm" class="h-9 flex-1">
                                <Link :href="`${racksIndex().url}?warehouse_id=${warehouse.id}`">
                                    <Grid2X2 :size="14" class="mr-1.5" />
                                    Стеллажи
                                </Link>
                            </Button>

                            <Button as-child variant="outline" size="sm" class="h-9 flex-1">
                                <Link :href="edit.url(warehouse.id)">
                                    <Pencil :size="14" class="mr-1.5" />
                                    Изменить
                                </Link>
                            </Button>

                            <Button
                                variant="outline"
                                size="icon"
                                class="size-9 shrink-0 text-destructive hover:bg-destructive/10 hover:text-destructive"
                                :disabled="warehouse.racks_count > 0"
                                :title="warehouse.racks_count > 0 ? 'Нельзя удалить: на складе есть стеллажи' : 'Удалить'"
                                @click="openDeleteDialog(warehouse)"
                            >
                                <Trash2 :size="15" />
                                <span class="sr-only">Удалить</span>
                            </Button>
                        </div>
                    </li>
                </ul>

                <!-- Таблица -->
                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full min-w-[600px] text-left text-sm">
                        <thead>
                        <tr class="border-b bg-muted/40">
                            <th scope="col" class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Склад</th>
                            <th scope="col" class="px-4 py-3.5 text-center text-xs font-semibold tracking-wider text-muted-foreground uppercase">Стеллажей</th>
                            <th scope="col" class="px-4 py-3.5 text-center text-xs font-semibold tracking-wider text-muted-foreground uppercase">Ячеек</th>
                            <th scope="col" class="px-6 py-3.5">
                                <span class="sr-only">Действия</span>
                            </th>
                        </tr>
                        </thead>

                        <tbody class="divide-y">
                        <tr
                            v-for="warehouse in filteredWarehouses"
                            :key="warehouse.id"
                            class="transition-colors hover:bg-muted/40"
                        >
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary"
                                    >
                                        <Building2 :size="19" />
                                    </div>
                                    <div class="min-w-0">
                                        <p class="font-semibold">
                                            {{ warehouse.name }}
                                        </p>
                                    </div>
                                </div>
                            </td>

                            <td class="px-4 py-4 text-center">
                                    <span
                                        class="inline-flex min-w-9 justify-center rounded-lg bg-sky-500/10 px-2.5 py-1.5 font-semibold text-sky-700 tabular-nums dark:text-sky-400"
                                    >
                                        {{ warehouse.racks_count }}
                                    </span>
                            </td>

                            <td class="px-4 py-4 text-center">
                                    <span
                                        class="inline-flex min-w-9 justify-center rounded-lg bg-emerald-500/10 px-2.5 py-1.5 font-semibold text-emerald-700 tabular-nums dark:text-emerald-400"
                                    >
                                        {{ warehouse.racks.reduce((sum, rack) => sum + rack.locations_count, 0) }}
                                    </span>
                            </td>

                            <td class="px-6 py-4">
                                <div class="flex items-center justify-end gap-2">
                                    <Button as-child variant="outline" size="sm">
                                        <Link :href="`${racksIndex().url}?warehouse_id=${warehouse.id}`">
                                            <Grid2X2 :size="14" class="mr-1.5" />
                                            Стеллажи
                                        </Link>
                                    </Button>

                                    <Button as-child variant="outline" size="sm">
                                        <Link :href="edit.url(warehouse.id)">
                                            <Pencil :size="14" class="mr-1.5" />
                                            Изменить
                                        </Link>
                                    </Button>

                                    <Button
                                        variant="outline"
                                        size="icon"
                                        class="size-8 text-destructive hover:bg-destructive/10 hover:text-destructive"
                                        :disabled="warehouse.racks_count > 0"
                                        :title="warehouse.racks_count > 0 ? 'Нельзя удалить: на складе есть стеллажи' : 'Удалить'"
                                        @click="openDeleteDialog(warehouse)"
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

        <!-- Диалог удаления -->
        <ConfirmDeleteDialog
            :open="deleteDialog.open"
            :loading="deleteDialog.loading"
            :item-name="deleteDialog.name"
            @close="closeDeleteDialog"
            @confirm="confirmDelete"
        />
    </div>
</template>
