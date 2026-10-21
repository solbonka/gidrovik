<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';
import { toast } from 'vue-sonner';
import {
    Layers3,
    Package,
    Pencil,
    Plus,
    Search,
    Trash2,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';
import { Button } from '@/components/ui/button';
import { create, destroy, edit } from '@/routes/admin/manufacturers';

defineOptions({
    layout: AdminLayout,
});

interface Manufacturer {
    id: number;
    name: string;
    is_active: boolean;
    products_count: number;
}

interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

interface PaginatedManufacturers {
    data: Manufacturer[];
    current_page: number;
    last_page: number;
    from: number | null;
    to: number | null;
    total: number;
    links: PaginationLink[];
}

interface Props {
    manufacturers: PaginatedManufacturers;
}

const props = defineProps<Props>();

const search = ref('');

const filteredManufacturers = computed(() => {
    const query = search.value.trim().toLowerCase();

    if (!query) return props.manufacturers.data;

    return props.manufacturers.data.filter((manufacturer) =>
        manufacturer.name.toLowerCase().includes(query),
    );
});

const paged = computed(() => props.manufacturers.last_page > 1);
const pageSuffix = computed(() => (paged.value ? ' на странице' : ''));

const activeCount = computed(
    () => props.manufacturers.data.filter((item) => item.is_active).length,
);
const inactiveCount = computed(
    () => props.manufacturers.data.length - activeCount.value,
);
const productsCount = computed(() =>
    props.manufacturers.data.reduce(
        (total, item) => total + item.products_count,
        0,
    ),
);

const stats = computed(() => [
    {
        title: 'Всего производителей',
        value: props.manufacturers.total,
        icon: Package,
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
        icon: Package,
        tone: 'bg-muted text-muted-foreground',
    },
    {
        title: `Товары${pageSuffix.value}`,
        value: productsCount.value,
        icon: Package,
        tone: 'bg-sky-500/10 text-sky-600 dark:text-sky-400',
    },
]);

const deleteDialog = ref({
    open: false,
    id: null as number | null,
    name: '',
    loading: false,
});

const openDeleteDialog = (manufacturer: Manufacturer): void => {
    if (manufacturer.products_count > 0) {
        toast.error('Нельзя удалить производителя, у которого есть товары.');
        return;
    }

    deleteDialog.value.id = manufacturer.id;
    deleteDialog.value.name = manufacturer.name;
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
            toast.success('Производитель удалён.');
        },
        onError: () => {
            toast.error('Не удалось удалить производителя.');
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
    <Head title="Производители" />

    <div class="space-y-6 pb-4">
        <header class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div class="flex items-center gap-4">
                <div class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm">
                    <Package :size="24" />
                </div>
                <div>
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">Производители</h1>
                    <p class="mt-1 text-sm text-muted-foreground">Производители товаров</p>
                </div>
            </div>

            <Button as-child class="w-full sm:w-auto">
                <Link :href="create().url">
                    <Plus :size="18" class="mr-2" />
                    Добавить производителя
                </Link>
            </Button>
        </header>

        <section class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4" aria-label="Сводка">
            <div v-for="stat in stats" :key="stat.title" class="flex items-center gap-4 rounded-2xl border bg-card p-5 shadow-sm">
                <div class="flex size-11 shrink-0 items-center justify-center rounded-xl" :class="stat.tone">
                    <component :is="stat.icon" :size="22" />
                </div>
                <div class="min-w-0">
                    <p class="truncate text-sm text-muted-foreground">{{ stat.title }}</p>
                    <p class="mt-0.5 text-2xl font-bold tracking-tight tabular-nums">{{ stat.value }}</p>
                </div>
            </div>
        </section>

        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm" aria-labelledby="manufacturers-title">
            <div class="flex flex-col gap-4 border-b px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6">
                <div>
                    <h2 id="manufacturers-title" class="font-semibold">Список производителей</h2>
                    <p class="mt-0.5 text-sm text-muted-foreground">
                        Показано: <span class="font-medium text-foreground tabular-nums">{{ filteredManufacturers.length }}</span>
                        <template v-if="paged"> (поиск — по текущей странице)</template>
                    </p>
                </div>

                <div class="relative w-full sm:max-w-xs">
                    <Search :size="16" class="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-muted-foreground" />
                    <input v-model="search" type="search" placeholder="Название" aria-label="Поиск производителей" class="w-full rounded-xl border border-input bg-background py-2.5 pr-9 pl-9 text-sm shadow-xs outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30" />
                    <button v-if="search" type="button" aria-label="Очистить поиск" class="absolute top-1/2 right-3 -translate-y-1/2 text-muted-foreground transition hover:text-foreground" @click="search = ''">
                        <X :size="16" />
                    </button>
                </div>
            </div>

            <div v-if="filteredManufacturers.length === 0" class="flex flex-col items-center px-6 py-16 text-center">
                <div class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted">
                    <Search v-if="search" :size="28" class="text-muted-foreground" />
                    <Package v-else :size="28" class="text-muted-foreground" />
                </div>
                <p class="font-medium">{{ search ? 'Ничего не найдено' : 'Производителей пока нет' }}</p>
                <p class="mt-1 max-w-sm text-sm text-muted-foreground">{{ search ? 'Попробуйте изменить поисковый запрос.' : 'Создайте первого производителя для товаров.' }}</p>

                <Button v-if="search" variant="outline" class="mt-5" @click="search = ''">
                    <X :size="15" class="mr-1.5" />
                    Очистить поиск
                </Button>
                <Button v-else as-child class="mt-5">
                    <Link :href="create().url">
                        <Plus :size="16" class="mr-2" />
                        Добавить производителя
                    </Link>
                </Button>
            </div>

            <template v-else>
                <ul class="divide-y md:hidden">
                    <li v-for="manufacturer in filteredManufacturers" :key="manufacturer.id" class="space-y-3 p-4">
                        <div class="flex items-start justify-between gap-3">
                            <div class="flex min-w-0 items-center gap-3">
                                <div class="flex size-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                    <Package :size="17" />
                                </div>
                                <div class="min-w-0">
                                    <h3 class="text-sm font-semibold break-words">{{ manufacturer.name }}</h3>
                                </div>
                            </div>

                            <span class="inline-flex shrink-0 items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset" :class="manufacturer.is_active ? activeBadge : inactiveBadge">
                                <span class="size-1.5 rounded-full" :class="manufacturer.is_active ? 'bg-emerald-500' : 'bg-muted-foreground/50'" />
                                {{ manufacturer.is_active ? 'Активен' : 'Неактивен' }}
                            </span>
                        </div>

                        <div class="rounded-lg bg-sky-500/10 px-3 py-2 text-center">
                            <p class="text-[11px] text-muted-foreground">Товаров</p>
                            <p class="mt-0.5 text-sm font-bold text-sky-700 tabular-nums dark:text-sky-400">{{ manufacturer.products_count }}</p>
                        </div>

                        <div class="flex items-center gap-2">
                            <Button as-child variant="outline" size="sm" class="h-9 flex-1">
                                <Link :href="edit(manufacturer.id).url">
                                    <Pencil :size="14" class="mr-1.5" />
                                    Изменить
                                </Link>
                            </Button>

                            <Button variant="outline" size="icon" class="size-9 shrink-0 text-destructive hover:bg-destructive/10 hover:text-destructive" :disabled="manufacturer.products_count > 0" :title="manufacturer.products_count > 0 ? 'Нельзя удалить: у производителя есть товары' : 'Удалить'" @click="openDeleteDialog(manufacturer)">
                                <Trash2 :size="15" />
                                <span class="sr-only">Удалить</span>
                            </Button>
                        </div>
                    </li>
                </ul>

                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full min-w-[600px] text-left text-sm">
                        <thead>
                        <tr class="border-b bg-muted/40">
                            <th scope="col" class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Производитель</th>
                            <th scope="col" class="px-4 py-3.5 text-center text-xs font-semibold tracking-wider text-muted-foreground uppercase">Товаров</th>
                            <th scope="col" class="px-4 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Статус</th>
                            <th scope="col" class="px-6 py-3.5">
                                <span class="sr-only">Действия</span>
                            </th>
                        </tr>
                        </thead>

                        <tbody class="divide-y">
                        <tr v-for="manufacturer in filteredManufacturers" :key="manufacturer.id" class="transition-colors hover:bg-muted/40">
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
                                        <Package :size="19" />
                                    </div>
                                    <div class="min-w-0">
                                        <p class="font-semibold">{{ manufacturer.name }}</p>
                                    </div>
                                </div>
                            </td>

                            <td class="px-4 py-4 text-center">
                                <span class="inline-flex min-w-9 justify-center rounded-lg bg-sky-500/10 px-2.5 py-1.5 font-semibold text-sky-700 tabular-nums dark:text-sky-400">{{ manufacturer.products_count }}</span>
                            </td>

                            <td class="px-4 py-4">
                                <span class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset" :class="manufacturer.is_active ? activeBadge : inactiveBadge">
                                    <span class="size-1.5 rounded-full" :class="manufacturer.is_active ? 'bg-emerald-500' : 'bg-muted-foreground/50'" />
                                    {{ manufacturer.is_active ? 'Активен' : 'Неактивен' }}
                                </span>
                            </td>

                            <td class="px-6 py-4">
                                <div class="flex items-center justify-end gap-2">
                                    <Button as-child variant="ghost" size="icon" class="size-9">
                                        <Link :href="edit(manufacturer.id).url">
                                            <Pencil :size="16" />
                                            <span class="sr-only">Изменить</span>
                                        </Link>
                                    </Button>

                                    <Button variant="ghost" size="icon" class="size-9 text-destructive hover:bg-destructive/10 hover:text-destructive" :disabled="manufacturer.products_count > 0" :title="manufacturer.products_count > 0 ? 'Нельзя удалить: у производителя есть товары' : 'Удалить'" @click="openDeleteDialog(manufacturer)">
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

        <nav v-if="manufacturers.last_page > 1" class="flex flex-col gap-4 border-t border-border px-5 py-4 sm:flex-row sm:items-center sm:justify-between" aria-label="Пагинация производителей">
            <p class="text-sm text-muted-foreground">
                Показано <span class="font-medium text-foreground tabular-nums">{{ manufacturers.from }}–{{ manufacturers.to }}</span> из <span class="font-medium text-foreground tabular-nums">{{ manufacturers.total }}</span>
            </p>

            <div class="flex items-center gap-1">
                <Button v-if="manufacturers.links[0]?.url" as-child variant="outline" size="icon" class="size-9">
                    <Link :href="manufacturers.links[0].url" preserve-scroll>
                        <span class="sr-only">Предыдущая страница</span>
                        <span aria-hidden="true">←</span>
                    </Link>
                </Button>

                <template v-for="(link, index) in manufacturers.links.slice(1, -1)" :key="index">
                    <Button v-if="link.url" as-child :variant="link.active ? 'default' : 'outline'" size="icon" class="size-9">
                        <Link :href="link.url" preserve-scroll>{{ link.label }}</Link>
                    </Button>
                    <span v-else class="inline-flex size-9 items-center justify-center text-sm">{{ link.label }}</span>
                </template>

                <Button v-if="manufacturers.links[manufacturers.links.length - 1]?.url" as-child variant="outline" size="icon" class="size-9">
                    <Link :href="manufacturers.links[manufacturers.links.length - 1].url!" preserve-scroll>
                        <span class="sr-only">Следующая страница</span>
                        <span aria-hidden="true">→</span>
                    </Link>
                </Button>
            </div>
        </nav>
    </div>

    <ConfirmDeleteDialog :open="deleteDialog.open" :item-name="deleteDialog.name" :loading="deleteDialog.loading" @close="closeDeleteDialog" @confirm="confirmDelete" />
</template>
