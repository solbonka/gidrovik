<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { index, store } from '@/routes/admin/product-types'

defineOptions({
    layout: AdminLayout,
})

interface Category {
    id: number
    name: string
}

interface Props {
    categories: Category[]
}

defineProps<Props>()

const form = useForm({
    category_id: '',
    name: '',
    slug: '',
    is_active: true,
})

const submit = (): void => {
    form.post(store.url())
}
</script>

<template>
    <Head title="Создание типа товара" />

    <div class="max-w-2xl space-y-6 p-6">
        <div>
            <h1 class="text-2xl font-semibold">
                Новый тип товара
            </h1>

            <p class="mt-1 text-sm text-muted-foreground">
                Создайте тип товара и привяжите его к категории.
            </p>
        </div>

        <form
            class="space-y-5 rounded-xl border bg-card p-6"
            @submit.prevent="submit"
        >
            <div>
                <label class="mb-2 block text-sm font-medium">
                    Категория
                </label>

                <select
                    v-model="form.category_id"
                    class="w-full rounded-lg border bg-background px-3 py-2"
                >
                    <option value="">Выберите категорию</option>

                    <option
                        v-for="category in categories"
                        :key="category.id"
                        :value="category.id"
                    >
                        {{ category.name }}
                    </option>
                </select>

                <p
                    v-if="form.errors.category_id"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.category_id }}
                </p>
            </div>

            <div>
                <label class="mb-2 block text-sm font-medium">
                    Название
                </label>

                <input
                    v-model="form.name"
                    type="text"
                    class="w-full rounded-lg border bg-background px-3 py-2"
                    placeholder="Например: Фитинги"
                />

                <p
                    v-if="form.errors.name"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.name }}
                </p>
            </div>

            <div>
                <label class="mb-2 block text-sm font-medium">
                    Slug
                </label>

                <input
                    v-model="form.slug"
                    type="text"
                    class="w-full rounded-lg border bg-background px-3 py-2"
                    placeholder="fittings"
                />

                <p
                    v-if="form.errors.slug"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.slug }}
                </p>
            </div>

            <label class="flex items-center gap-2">
                <input
                    v-model="form.is_active"
                    type="checkbox"
                />

                <span class="text-sm">
                    Активен
                </span>
            </label>

            <div class="flex justify-end gap-3">
                <Link
                    :href="index.url()"
                    class="rounded-lg border px-4 py-2"
                >
                    Отмена
                </Link>

                <button
                    type="submit"
                    class="rounded-lg bg-primary px-4 py-2 text-primary-foreground disabled:opacity-50"
                    :disabled="form.processing"
                >
                    Создать
                </button>
            </div>
        </form>
    </div>
</template>
