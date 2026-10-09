<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'
import {
    index,
    store,
} from '@/routes/admin/characteristics'

defineOptions({
    layout: AdminLayout,
})

const form = useForm({
    name: '',
    slug: '',
    type: 'text',
    unit: '',
    is_active: true,
})

const submit = (): void => {
    form.post(store.url())
}
</script>

<template>
    <Head title="Создание характеристики" />

    <div class="max-w-2xl space-y-6 p-6">
        <div>
            <h1 class="text-2xl font-semibold">
                Новая характеристика
            </h1>

            <p class="mt-1 text-sm text-muted-foreground">
                Создайте характеристику, которую можно будет
                назначить категории.
            </p>
        </div>

        <form
            class="space-y-5 rounded-xl border bg-card p-6"
            @submit.prevent="submit"
        >
            <div>
                <label class="mb-2 block text-sm font-medium">
                    Название
                </label>

                <input
                    v-model="form.name"
                    type="text"
                    class="w-full rounded-lg border bg-background px-3 py-2"
                    placeholder="Например: Рабочее давление"
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
                    placeholder="working_pressure"
                />

                <p
                    v-if="form.errors.slug"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.slug }}
                </p>
            </div>

            <div>
                <label class="mb-2 block text-sm font-medium">
                    Тип значения
                </label>

                <select
                    v-model="form.type"
                    class="w-full rounded-lg border bg-background px-3 py-2"
                >
                    <option value="text">
                        Текст
                    </option>

                    <option value="number">
                        Число
                    </option>

                    <option value="select">
                        Список
                    </option>

                    <option value="boolean">
                        Да / Нет
                    </option>
                </select>

                <p
                    v-if="form.errors.type"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.type }}
                </p>
            </div>

            <div>
                <label class="mb-2 block text-sm font-medium">
                    Единица измерения
                </label>

                <input
                    v-model="form.unit"
                    type="text"
                    class="w-full rounded-lg border bg-background px-3 py-2"
                    placeholder="бар, мм, кг"
                />

                <p
                    v-if="form.errors.unit"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.unit }}
                </p>
            </div>

            <label class="flex items-center gap-2">
                <input
                    v-model="form.is_active"
                    type="checkbox"
                />

                <span class="text-sm">
                    Активна
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
