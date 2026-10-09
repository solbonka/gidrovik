<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { create, edit, destroy } from '@/routes/admin/categories';

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

defineProps<{
    categories: PaginatedCategories;
}>();

const remove = (category: Category): void => {
    if (
        !window.confirm(
            `Удалить категорию «${category.name}»?`,
        )
    ) {
        return;
    }

    router.delete(destroy.url(category.id));
};
</script>

<template>
    <Head title="Категории" />

    <div class="space-y-6">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-2xl font-semibold text-gray-900 dark:text-white">
                    Категории
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    Категории товаров склада
                </p>
            </div>

            <Link
                :href="create.url()"
                class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800 dark:bg-white dark:text-gray-900 dark:hover:bg-gray-100"
            >
                Добавить категорию
            </Link>
        </div>

        <div
            class="overflow-hidden rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900"
        >
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-800">
                    <thead class="bg-gray-50 dark:bg-gray-800/50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                            Категория
                        </th>

                        <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                            Товары
                        </th>

                        <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                            Типы
                        </th>

                        <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                            Характеристики
                        </th>

                        <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                            Статус
                        </th>

                        <th class="px-6 py-3 text-right text-xs font-medium uppercase tracking-wider text-gray-500">
                            Действия
                        </th>
                    </tr>
                    </thead>

                    <tbody class="divide-y divide-gray-200 dark:divide-gray-800">
                    <tr
                        v-for="category in categories.data"
                        :key="category.id"
                        class="hover:bg-gray-50 dark:hover:bg-gray-800/50"
                    >
                        <td class="px-6 py-4">
                            <div class="font-medium text-gray-900 dark:text-white">
                                {{ category.name }}
                            </div>

                            <div class="mt-1 text-sm text-gray-500">
                                {{ category.slug }}
                            </div>
                        </td>

                        <td class="px-6 py-4 text-sm text-gray-600 dark:text-gray-300">
                            {{ category.products_count }}
                        </td>

                        <td class="px-6 py-4 text-sm text-gray-600 dark:text-gray-300">
                            {{ category.product_types_count }}
                        </td>

                        <td class="px-6 py-4 text-sm text-gray-600 dark:text-gray-300">
                            {{ category.characteristics_count }}
                        </td>

                        <td class="px-6 py-4">
                                <span
                                    class="inline-flex rounded-full px-2.5 py-1 text-xs font-medium"
                                    :class="
                                        category.is_active
                                            ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400'
                                            : 'bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400'
                                    "
                                >
                                    {{ category.is_active ? 'Активна' : 'Неактивна' }}
                                </span>
                        </td>

                        <td class="px-6 py-4 text-right">
                            <div class="flex justify-end gap-2">
                                <Link
                                    :href="`/admin/categories/${category.id}/characteristics`"
                                    class="text-gray-600 hover:text-gray-900"
                                >
                                    Характеристики
                                </Link>

                                <Link
                                    :href="edit.url(category.id)"
                                    class="rounded-md px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800"
                                >
                                    Изменить
                                </Link>

                                <button
                                    type="button"
                                    class="rounded-md px-3 py-1.5 text-sm text-red-600 hover:bg-red-50 dark:hover:bg-red-950/30"
                                    @click="remove(category)"
                                >
                                    Удалить
                                </button>
                            </div>
                        </td>
                    </tr>

                    <tr v-if="categories.data.length === 0">
                        <td
                            colspan="6"
                            class="px-6 py-12 text-center text-sm text-gray-500"
                        >
                            Категорий пока нет.
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <div
                v-if="categories.links.length > 3"
                class="flex flex-wrap gap-2 border-t border-gray-200 px-6 py-4 dark:border-gray-800"
            >
                <Link
                    v-for="link in categories.links"
                    :key="link.label"
                    :href="link.url ?? '#'"
                    class="rounded-md px-3 py-1.5 text-sm"
                    :class="[
                        link.active
                            ? 'bg-gray-900 text-white dark:bg-white dark:text-gray-900'
                            : 'text-gray-600 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800',
                        !link.url
                            ? 'pointer-events-none opacity-40'
                            : '',
                    ]"
                    v-html="link.label"
                />
            </div>
        </div>
    </div>
</template>
