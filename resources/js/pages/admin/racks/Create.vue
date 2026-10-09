<script setup lang="ts">
import { Head, useForm } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { index, store } from '@/routes/admin/racks'

defineOptions({
    layout: AdminLayout,
})

const form = useForm({
    code: '',
    name: '',
})

const submit = (): void => {
    form.post(store().url)
}
</script>

<template>
    <Head title="Новый стеллаж" />

    <div class="mx-auto max-w-2xl">
        <div class="mb-6">
            <a
                :href="index().url"
                class="text-sm text-gray-500 hover:text-gray-900"
            >
                ← Назад к стеллажам
            </a>

            <h1 class="mt-3 text-2xl font-semibold text-gray-900">
                Новый стеллаж
            </h1>

            <p class="mt-1 text-sm text-gray-500">
                После создания стеллаж будет без ячеек.
            </p>
        </div>

        <form
            class="space-y-6 rounded-xl border border-gray-200 bg-white p-6"
            @submit.prevent="submit"
        >
            <div>
                <label
                    for="code"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Код стеллажа
                </label>

                <input
                    id="code"
                    v-model="form.code"
                    type="text"
                    maxlength="10"
                    placeholder="A"
                    class="w-full rounded-lg border border-gray-300 px-3 py-2 outline-none focus:border-gray-500 focus:ring-1 focus:ring-gray-500"
                    :class="{
                        'border-red-500': form.errors.code,
                    }"
                />

                <p
                    v-if="form.errors.code"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.code }}
                </p>

                <p class="mt-1 text-xs text-gray-500">
                    Например: A, B, C, D.
                </p>
            </div>

            <div>
                <label
                    for="name"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Название
                </label>

                <input
                    id="name"
                    v-model="form.name"
                    type="text"
                    maxlength="255"
                    placeholder="Стеллаж A"
                    class="w-full rounded-lg border border-gray-300 px-3 py-2 outline-none focus:border-gray-500 focus:ring-1 focus:ring-gray-500"
                    :class="{
                        'border-red-500': form.errors.name,
                    }"
                />

                <p
                    v-if="form.errors.name"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.name }}
                </p>
            </div>

            <div class="flex justify-end gap-3">
                <a
                    :href="index().url"
                    class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                    Отмена
                </a>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                >
                    {{ form.processing ? 'Создание...' : 'Создать' }}
                </button>
            </div>
        </form>
    </div>
</template>
