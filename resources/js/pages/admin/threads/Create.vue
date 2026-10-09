<script setup lang="ts">
import { Head, useForm } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { index, store } from '@/routes/admin/threads'

defineOptions({
    layout: AdminLayout,
})

const form = useForm({
    system: 'metric',
    designation: '',
    name: '',
    is_active: true,
})

const submit = (): void => {
    form.post(store().url)
}
</script>

<template>
    <Head title="Добавление резьбы" />

    <div class="mx-auto max-w-2xl space-y-6">
        <div>
            <a
                :href="index().url"
                class="text-sm text-gray-500 hover:text-gray-900"
            >
                ← Назад к резьбам
            </a>

            <h1 class="mt-3 text-2xl font-semibold text-gray-900">
                Добавить резьбу
            </h1>
        </div>

        <form
            class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            @submit.prevent="submit"
        >
            <div class="space-y-5">
                <div>
                    <label
                        for="system"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Система
                    </label>

                    <select
                        id="system"
                        v-model="form.system"
                        class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                    >
                        <option value="metric">
                            Метрическая
                        </option>

                        <option value="bsp">
                            BSP
                        </option>

                        <option value="npt">
                            NPT
                        </option>

                        <option value="other">
                            Другая
                        </option>
                    </select>

                    <p
                        v-if="form.errors.system"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.system }}
                    </p>
                </div>

                <div>
                    <label
                        for="designation"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Обозначение
                    </label>

                    <input
                        id="designation"
                        v-model="form.designation"
                        type="text"
                        maxlength="100"
                        placeholder="M18x1.5"
                        class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                    />

                    <p class="mt-1 text-xs text-gray-500">
                        Например: M18x1.5, G1/4, G1/2, G1 1/4, G2, 1 1/4.
                    </p>

                    <p
                        v-if="form.errors.designation"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.designation }}
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
                        placeholder="M18x1.5"
                        class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                    />

                    <p
                        v-if="form.errors.name"
                        class="mt-1 text-sm text-red-600"
                    >
                        {{ form.errors.name }}
                    </p>
                </div>

                <label class="flex items-center gap-3">
                    <input
                        v-model="form.is_active"
                        type="checkbox"
                        class="h-4 w-4 rounded border-gray-300"
                    />

                    <span class="text-sm text-gray-700">
                        Активна
                    </span>
                </label>
            </div>

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
