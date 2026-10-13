<script setup lang="ts">
import { Head, useForm } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { index, store } from '@/routes/admin/diameters'

defineOptions({
    layout: AdminLayout,
})

const form = useForm({
    value: null as number | null,
    unit: 'mm',
    is_active: true,
})

const submit = (): void => {
    form.post(store().url)
}
</script>

<template>
    <Head title="Добавление диаметра" />

    <div class="mx-auto max-w-2xl space-y-6">
        <div>
            <a
                :href="index().url"
                class="text-sm text-gray-500 hover:text-gray-900"
            >
                ← Назад к диаметрам
            </a>

            <h1 class="mt-3 text-2xl font-semibold text-gray-900">
                Добавить диаметр
            </h1>
        </div>

        <form
            class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            @submit.prevent="submit"
        >
            <div class="grid gap-5 sm:grid-cols-2">
                <div>
                    <label
                        for="value"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Диаметр
                    </label>

                    <input
                        id="value"
                        v-model.number="form.value"
                        type="number"
                        min="1"
                        max="1000"
                        class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                    />

                    <p
                        v-if="form.errors.value"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.value }}
                    </p>
                </div>

                <div>
                    <label
                        for="unit"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Единица
                    </label>

                    <input
                        id="unit"
                        v-model="form.unit"
                        type="text"
                        maxlength="10"
                        class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                    />

                    <p
                        v-if="form.errors.unit"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.unit }}
                    </p>
                </div>
            </div>

            <label class="mt-5 flex items-center gap-3">
                <input
                    v-model="form.is_active"
                    type="checkbox"
                    class="h-4 w-4 rounded border-gray-300"
                />

                <span class="text-sm text-gray-700">
                    Активен
                </span>
            </label>

            <div class="mt-6 flex justify-end gap-3">
                <a
                    :href="index().url"
                    class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                    Отмена
                </a>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="rounded-lg bg-gray-900 px-5 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                >
                    {{ form.processing ? 'Сохранение...' : 'Создать' }}
                </button>
            </div>
        </form>
    </div>
</template>
