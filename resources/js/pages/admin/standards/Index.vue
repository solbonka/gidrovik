<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { ref } from 'vue';
import { toast } from 'vue-sonner';
import {
    Plus,
    Ruler,
    Pencil,
    Trash2,
    CheckCircle2,
    XCircle,
    Layers3,
} from '@lucide/vue';

import AdminLayout from '@/layouts/AdminLayout.vue';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';
import { create, destroy, edit } from '@/routes/admin/standards';

defineOptions({
    layout: AdminLayout,
});

interface Standard {
    id: number;
    code: string;
    name: string;
    is_active: boolean;
    connections_count: number;
}

interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

interface PaginatedStandards {
    data: Standard[];
    current_page: number;
    last_page: number;
    from: number | null;
    to: number | null;
    total: number;
    links: PaginationLink[];
}

interface Props {
    standards: PaginatedStandards;
}

defineProps<Props>();

const deleteDialogOpen = ref(false);
const deletingStandard = ref<Standard | null>(null);
const deleting = ref(false);

const openDeleteDialog = (standard: Standard): void => {
    if (deleting.value) return;

    deletingStandard.value = standard;
    deleteDialogOpen.value = true;
};

const closeDeleteDialog = (): void => {
    if (deleting.value) return;

    deleteDialogOpen.value = false;
    deletingStandard.value = null;
};

const confirmDelete = (): void => {
    if (!deletingStandard.value || deleting.value) return;

    const standard = deletingStandard.value;

    deleting.value = true;

    router.delete(destroy(standard.id).url, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Стандарт удалён.');
            deleteDialogOpen.value = false;
            deletingStandard.value = null;
        },
        onError: (errors) => {
            const message = errors.delete;

            toast.error(
                typeof message === 'string'
                    ? message
                    : 'Не удалось удалить стандарт.',
            );
        },
        onFinish: () => {
            deleting.value = false;
        },
    });
};
</script>

<template>
    <Head title="Стандарты" />

    <div class="space-y-6">
        <!-- Заголовок страницы -->
        <div
            class="relative overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm sm:p-7 dark:border-gray-800 dark:bg-gray-900"
        >
            <div
                class="pointer-events-none absolute -top-16 -right-12 h-48 w-48 rounded-full bg-violet-500/10 blur-3xl"
            />

            <div
                class="relative flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between"
            >
                <div class="flex items-start gap-4">
                    <div
                        class="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-violet-600 to-indigo-600 text-white shadow-lg shadow-violet-500/20"
                    >
                        <Ruler class="h-6 w-6" />
                    </div>

                    <div>
                        <h1
                            class="bg-gradient-to-r from-gray-950 via-violet-900 to-indigo-700 bg-clip-text text-2xl font-bold tracking-tight text-transparent sm:text-3xl dark:from-white dark:via-violet-200 dark:to-indigo-300"
                        >
                            Стандарты
                        </h1>

                        <p
                            class="mt-1.5 max-w-xl text-sm leading-6 text-gray-500 dark:text-gray-400"
                        >
                            Управление стандартами присоединительных соединений,
                            используемыми в характеристиках товаров.
                        </p>
                    </div>
                </div>

                <Link
                    :href="create().url"
                    class="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-violet-600 to-indigo-600 px-5 py-2.5 text-sm font-semibold text-white shadow-md shadow-violet-500/20 transition hover:-translate-y-0.5 hover:from-violet-700 hover:to-indigo-700 hover:shadow-lg focus-visible:ring-2 focus-visible:ring-violet-500 focus-visible:ring-offset-2 focus-visible:outline-none dark:focus-visible:ring-offset-gray-900"
                >
                    <Plus class="h-4 w-4" />
                    Добавить стандарт
                </Link>
            </div>
        </div>

        <!-- Статистика -->
        <div class="grid gap-4 sm:grid-cols-2">
            <div
                class="flex items-center gap-4 rounded-2xl border border-gray-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-gray-800 dark:bg-gray-900"
            >
                <div
                    class="flex h-11 w-11 items-center justify-center rounded-xl bg-violet-50 text-violet-600 dark:bg-violet-500/10 dark:text-violet-300"
                >
                    <Ruler class="h-5 w-5" />
                </div>

                <div>
                    <p class="text-sm text-gray-500 dark:text-gray-400">
                        Всего стандартов
                    </p>
                    <p
                        class="mt-0.5 text-2xl font-bold text-gray-900 dark:text-white"
                    >
                        {{ standards.total }}
                    </p>
                </div>
            </div>

            <div
                class="flex items-center gap-4 rounded-2xl border border-gray-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-gray-800 dark:bg-gray-900"
            >
                <div
                    class="flex h-11 w-11 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-300"
                >
                    <Layers3 class="h-5 w-5" />
                </div>

                <div>
                    <p class="text-sm text-gray-500 dark:text-gray-400">
                        Связей на текущей странице
                    </p>
                    <p
                        class="mt-0.5 text-2xl font-bold text-gray-900 dark:text-white"
                    >
                        {{
                            standards.data.reduce(
                                (sum, standard) =>
                                    sum + standard.connections_count,
                                0,
                            )
                        }}
                    </p>
                </div>
            </div>
        </div>

        <!-- Таблица -->
        <div
            class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-800 dark:bg-gray-900"
        >
            <div
                class="flex flex-col gap-1 border-b border-gray-200 px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6 dark:border-gray-800"
            >
                <div>
                    <h2 class="font-semibold text-gray-900 dark:text-white">
                        Список стандартов
                    </h2>
                    <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">
                        Коды, названия и использование в товарах
                    </p>
                </div>

                <span
                    class="inline-flex w-fit items-center rounded-lg border border-gray-200 bg-gray-50 px-3 py-1.5 text-xs font-medium text-gray-600 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-300"
                >
                    {{ standards.total }} записей
                </span>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full min-w-[720px] text-left text-sm">
                    <thead
                        class="border-b border-gray-200 bg-gray-50/80 text-xs font-semibold tracking-wider text-gray-500 uppercase dark:border-gray-800 dark:bg-gray-800/50 dark:text-gray-400"
                    >
                        <tr>
                            <th class="px-6 py-4">Код</th>
                            <th class="px-6 py-4">Название</th>
                            <th class="px-6 py-4">Связи с товарами</th>
                            <th class="px-6 py-4">Статус</th>
                            <th class="px-6 py-4 text-right">Действия</th>
                        </tr>
                    </thead>

                    <tbody
                        class="divide-y divide-gray-100 dark:divide-gray-800"
                    >
                        <tr
                            v-for="standard in standards.data"
                            :key="standard.id"
                            class="transition-colors hover:bg-violet-50/40 dark:hover:bg-violet-500/5"
                        >
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span
                                    class="inline-flex items-center rounded-lg border border-violet-200 bg-violet-50 px-2.5 py-1.5 font-mono text-xs font-semibold text-violet-700 dark:border-violet-500/20 dark:bg-violet-500/10 dark:text-violet-300"
                                >
                                    {{ standard.code }}
                                </span>
                            </td>

                            <td class="px-6 py-4">
                                <span
                                    class="font-medium text-gray-900 dark:text-white"
                                >
                                    {{ standard.name }}
                                </span>
                            </td>

                            <td class="px-6 py-4">
                                <span
                                    class="inline-flex items-center gap-2 text-gray-600 dark:text-gray-300"
                                >
                                    <Layers3 class="h-4 w-4 text-gray-400" />
                                    {{ standard.connections_count }}
                                </span>
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap">
                                <span
                                    v-if="standard.is_active"
                                    class="inline-flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50 px-2.5 py-1 text-xs font-semibold text-emerald-700 dark:border-emerald-500/20 dark:bg-emerald-500/10 dark:text-emerald-300"
                                >
                                    <CheckCircle2 class="h-3.5 w-3.5" />
                                    Активен
                                </span>

                                <span
                                    v-else
                                    class="inline-flex items-center gap-1.5 rounded-full border border-gray-200 bg-gray-100 px-2.5 py-1 text-xs font-semibold text-gray-600 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-400"
                                >
                                    <XCircle class="h-3.5 w-3.5" />
                                    Неактивен
                                </span>
                            </td>

                            <td class="px-6 py-4">
                                <div
                                    class="flex items-center justify-end gap-2"
                                >
                                    <Link
                                        :href="edit(standard.id).url"
                                        :aria-label="`Изменить стандарт ${standard.name}`"
                                        class="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-gray-200 bg-white text-gray-500 transition hover:border-violet-300 hover:bg-violet-50 hover:text-violet-700 focus-visible:ring-2 focus-visible:ring-violet-500 focus-visible:outline-none dark:border-gray-700 dark:bg-gray-900 dark:text-gray-400 dark:hover:border-violet-500/40 dark:hover:bg-violet-500/10 dark:hover:text-violet-300"
                                    >
                                        <Pencil class="h-4 w-4" />
                                    </Link>

                                    <button
                                        type="button"
                                        :aria-label="`Удалить стандарт ${standard.name}`"
                                        class="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-gray-200 bg-white text-gray-500 transition hover:border-red-200 hover:bg-red-50 hover:text-red-600 focus-visible:ring-2 focus-visible:ring-red-500 focus-visible:outline-none dark:border-gray-700 dark:bg-gray-900 dark:text-gray-400 dark:hover:border-red-500/30 dark:hover:bg-red-500/10 dark:hover:text-red-400"
                                        @click="openDeleteDialog(standard)"
                                    >
                                        <Trash2 class="h-4 w-4" />
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <tr v-if="standards.data.length === 0">
                            <td colspan="5" class="px-6 py-16 text-center">
                                <div
                                    class="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-gray-100 text-gray-400 dark:bg-gray-800"
                                >
                                    <Ruler class="h-7 w-7" />
                                </div>

                                <p
                                    class="mt-4 font-semibold text-gray-900 dark:text-white"
                                >
                                    Стандартов пока нет
                                </p>

                                <p
                                    class="mt-1 text-sm text-gray-500 dark:text-gray-400"
                                >
                                    Добавьте первый стандарт присоединительного
                                    соединения.
                                </p>

                                <Link
                                    :href="create().url"
                                    class="mt-4 inline-flex items-center gap-2 rounded-lg bg-violet-600 px-4 py-2 text-sm font-medium text-white transition hover:bg-violet-700"
                                >
                                    <Plus class="h-4 w-4" />
                                    Добавить стандарт
                                </Link>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Пагинация -->
            <div
                v-if="standards.last_page > 1"
                class="flex flex-col gap-4 border-t border-gray-200 px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6 dark:border-gray-800"
            >
                <p class="text-sm text-gray-500 dark:text-gray-400">
                    Показано
                    <span class="font-semibold text-gray-900 dark:text-white">
                        {{ standards.from }}–{{ standards.to }}
                    </span>
                    из
                    <span class="font-semibold text-gray-900 dark:text-white">
                        {{ standards.total }}
                    </span>
                </p>

                <nav
                    aria-label="Пагинация стандартов"
                    class="flex flex-wrap items-center gap-1"
                >
                    <template
                        v-for="(link, index) in standards.links"
                        :key="index"
                    >
                        <Link
                            v-if="link.url"
                            :href="link.url"
                            preserve-scroll
                            :aria-current="link.active ? 'page' : undefined"
                            class="inline-flex min-h-9 min-w-9 items-center justify-center rounded-lg border px-3 text-sm font-medium transition"
                            :class="
                                link.active
                                    ? 'border-violet-600 bg-violet-600 text-white shadow-sm'
                                    : 'border-gray-200 bg-white text-gray-600 hover:border-violet-300 hover:bg-violet-50 hover:text-violet-700 dark:border-gray-700 dark:bg-gray-900 dark:text-gray-300 dark:hover:border-violet-500/40 dark:hover:bg-violet-500/10 dark:hover:text-violet-300'
                            "
                            v-html="link.label"
                        />

                        <span
                            v-else
                            class="inline-flex min-h-9 min-w-9 cursor-not-allowed items-center justify-center rounded-lg border border-gray-100 px-3 text-sm text-gray-300 dark:border-gray-800 dark:text-gray-600"
                            v-html="link.label"
                        />
                    </template>
                </nav>
            </div>
        </div>
    </div>

    <ConfirmDeleteDialog
        :open="deleteDialogOpen"
        :item-name="deletingStandard?.name ?? ''"
        description="Стандарт нельзя будет восстановить после удаления. Если он используется в товарах, сервер может запретить удаление."
        :processing="deleting"
        @confirm="confirmDelete"
        @cancel="closeDeleteDialog"
    />
</template>
