<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { index, update } from '@/routes/admin/categories';

defineOptions({
    layout: AdminLayout,
});

interface Category {
    id: number;
    name: string;
    slug: string;
    is_active: boolean;
}

const props = defineProps<{
    category: Category;
}>();

const form = useForm({
    name: props.category.name,
    slug: props.category.slug,
    is_active: props.category.is_active,
});

const submit = (): void => {
    form.put(update.url(props.category.id));
};
</script>

<template>
    <Head :title="`Редактирование: ${category.name}`" />

    <div class="mx-auto max-w-2xl space-y-6">
        <div>
            <h1 class="text-2xl font-semibold text-gray-900 dark:text-white">
                Редактирование категории
            </h1>

            <p class="mt-1 text-sm text-gray-500">
                {{ category.name }}
            </p>
        </div>

        <form
            class="space-y-6 rounded-xl border border-gray-200 bg-white p-6 dark:border-gray-800 dark:bg-gray-900"
            @submit.prevent="submit"
        >
            <div>
                <label
                    for="name"
                    class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300"
                >
                    Название
                </label>

                <input
                    id="name"
                    v-model="form.name"
                    type="text"
                    class="w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm outline-none focus:border-gray-500 focus:ring-2 focus:ring-gray-200 dark:border-gray-700 dark:bg-gray-950 dark:text-white"
                />

                <p
                    v-if="form.errors.name"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.name }}
                </p>
            </div>

            <div>
                <label
                    for="slug"
                    class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300"
                >
                    Slug
                </label>

                <input
                    id="slug"
                    v-model="form.slug"
                    type="text"
                    class="w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm outline-none focus:border-gray-500 focus:ring-2 focus:ring-gray-200 dark:border-gray-700 dark:bg-gray-950 dark:text-white"
                />

                <p
                    v-if="form.errors.slug"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.slug }}
                </p>
            </div>

            <label class="flex items-center gap-3">
                <input
                    v-model="form.is_active"
                    type="checkbox"
                    class="size-4 rounded border-gray-300"
                />

                <span class="text-sm text-gray-700 dark:text-gray-300">
                    Категория активна
                </span>
            </label>

            <div class="flex justify-end gap-3">
                <Link
                    :href="index.url()"
                    class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-300 dark:hover:bg-gray-800"
                >
                    Отмена
                </Link>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:opacity-50 dark:bg-white dark:text-gray-900"
                >
                    {{ form.processing ? 'Сохранение...' : 'Сохранить' }}
                </button>
            </div>
        </form>
    </div>
</template>
