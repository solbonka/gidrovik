<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { ref } from 'vue';
import { toast } from 'vue-sonner';
import { Folder, FolderOpen, Tag, List } from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { create, edit, destroy } from '@/routes/admin/categories';
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue';

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

const props = defineProps<{
    categories: PaginatedCategories;
}>();

const deleteDialog = ref({
    open: false,
    id: null as number | null,
    name: '',
    loading: false,
});

const openDeleteDialog = (category: Category): void => {
    if (category.products_count > 0) {
        alert('Нельзя удалить категорию, в которой есть товары.');
        return;
    }
    deleteDialog.value.id = category.id;
    deleteDialog.value.name = category.name;
    deleteDialog.value.open = true;
};

const confirmDelete = (): void => {
    if (deleteDialog.value.id === null) return;
    deleteDialog.value.loading = true;
    router.delete(destroy.url(deleteDialog.value.id), {
        onSuccess: () => {
            toast.success('Категория удалена.');
        },
        onFinish: () => {
            deleteDialog.value.loading = false;
            deleteDialog.value.open = false;
        },
    });
};
</script>

<template>
    <Head title="Категории" />

    <div class="space-y-6">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-2xl font-semibold text-gray-900">
                    Категории
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    Категории товаров склада
                </p>
            </div>

            <Link
                :href="create.url()"
                class="inline-flex items-center gap-2 rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800 transition-colors"
            >
                <Folder :size="16" />
                Добавить категорию
            </Link>
        </div>

        <div
            class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm"
        >
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
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

                    <tbody class="divide-y divide-gray-200">
                    <tr
                        v-for="category in categories.data"
                        :key="category.id"
                        class="hover:bg-gray-50 transition-colors"
                    >
                        <td class="px-6 py-4">
                            <div class="flex items-center gap-2">
                                <FolderOpen :size="16" class="text-gray-400" />
                                <div>
                                    <div class="font-medium text-gray-900">
                                        {{ category.name }}
                                    </div>

                                    <div class="mt-1 text-sm text-gray-500">
                                        {{ category.slug }}
                                    </div>
                                </div>
                            </div>
                        </td>

                        <td class="px-6 py-4">
                            <div class="flex items-center gap-2 text-sm text-gray-600">
                                <Folder :size="14" />
                                {{ category.products_count }}
                            </div>
                        </td>

                        <td class="px-6 py-4">
                            <div class="flex items-center gap-2 text-sm text-gray-600">
                                <Tag :size="14" />
                                {{ category.product_types_count }}
                            </div>
                        </td>

                        <td class="px-6 py-4">
                            <div class="flex items-center gap-2 text-sm text-gray-600">
                                <List :size="14" />
                                {{ category.characteristics_count }}
                            </div>
                        </td>

                        <td class="px-6 py-4">
                                <span
                                    class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium"
                                    :class="
                                        category.is_active
                                            ? 'bg-green-100 text-green-700'
                                            : 'bg-gray-100 text-gray-600'
                                    "
                                >
                                    <span
                                        class="h-1.5 w-1.5 rounded-full"
                                        :class="
                                            category.is_active
                                                ? 'bg-green-600'
                                                : 'bg-gray-400'
                                        "
                                    />
                                    {{ category.is_active ? 'Активна' : 'Неактивна' }}
                                </span>
                        </td>

                        <td class="px-6 py-4 text-right">
                            <div class="flex justify-end gap-2">
                                <Link
                                    :href="`/admin/categories/${category.id}/characteristics`"
                                    class="text-sm font-medium text-gray-600 hover:text-gray-900 transition-colors"
                                >
                                    Характеристики
                                </Link>

                                <Link
                                    :href="edit.url(category.id)"
                                    class="text-sm font-medium text-gray-600 hover:text-gray-900 transition-colors"
                                >
                                    Изменить
                                </Link>

                                <button
                                    type="button"
                                    class="text-sm font-medium text-red-600 hover:text-red-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                                    :disabled="category.products_count > 0"
                                    @click="openDeleteDialog(category)"
                                >
                                    Удалить
                                </button>
                            </div>
                        </td>
                    </tr>

                    <tr v-if="categories.data.length === 0">
                        <td
                            colspan="6"
                            class="px-6 py-12 text-center"
                        >
                            <Folder :size="48" class="mx-auto text-gray-300 mb-4" />
                            <p class="text-sm text-gray-500">
                                Категории не найдены.
                            </p>
                            <Link
                                :href="create.url()"
                                class="mt-4 inline-block text-sm font-medium text-gray-900 hover:text-gray-700"
                            >
                                Добавить первую категорию
                            </Link>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <ConfirmDeleteDialog
            :open="deleteDialog.open"
            title="Удаление категории"
            description="Вы уверены, что хотите удалить категорию"
            :item-name="deleteDialog.name"
            :loading="deleteDialog.loading"
            @confirm="confirmDelete"
            @cancel="deleteDialog.open = false"
        />
    </div>
</template>
