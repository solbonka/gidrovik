<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import { toast } from 'vue-sonner'
import AdminLayout from '@/layouts/AdminLayout.vue'

defineOptions({
    layout: AdminLayout,
})

interface Country {
    id: number
    name: string
    code: string | null
    is_active: boolean
}

interface Props {
    country: Country
}

const props = defineProps<Props>()

const form = useForm({
    name: props.country.name,
    code: props.country.code || '',
    is_active: props.country.is_active,
})

const submit = (): void => {
    form.put(`/admin/countries/${props.country.id}`, {
        onSuccess: () => {
            toast.success('Страна успешно обновлена.')
        },
    })
}
</script>

<template>
    <Head :title="`Редактирование: ${country.name}`" />

    <div class="mx-auto max-w-2xl space-y-6">
        <div>
            <Link
                href="/admin/countries"
                class="text-sm text-gray-500 hover:text-gray-900"
            >
                ← К списку стран
            </Link>

            <h1 class="mt-3 text-2xl font-semibold text-gray-900">
                Редактирование страны
            </h1>

            <p class="mt-1 text-sm text-gray-500">
                {{ country.name }}
            </p>
        </div>

        <form
            class="space-y-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            @submit.prevent="submit"
        >
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
                    required
                    class="w-full rounded-lg border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
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
                    for="code"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Код (ISO)
                </label>

                <input
                    id="code"
                    v-model="form.code"
                    type="text"
                    maxlength="3"
                    placeholder="Например: RU, CN, DE"
                    class="w-full rounded-lg border-gray-300 px-3 py-2 text-sm uppercase focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                />

                <p class="mt-1 text-xs text-gray-500">
                    Трёхбуквенный код страны (опционально)
                </p>

                <p
                    v-if="form.errors.code"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.code }}
                </p>
            </div>

            <div>
                <label class="flex items-center gap-3">
                    <input
                        v-model="form.is_active"
                        type="checkbox"
                        class="h-4 w-4 rounded border-gray-300"
                    />

                    <span class="text-sm font-medium text-gray-700">
                        Активна
                    </span>
                </label>

                <p class="mt-1 text-xs text-gray-500">
                    Неактивные страны не будут доступны при выборе товара.
                </p>
            </div>

            <div class="flex justify-end gap-3 border-t border-gray-100 pt-5">
                <Link
                    href="/admin/countries"
                    class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                    Отмена
                </Link>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="rounded-lg bg-gray-900 px-5 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                >
                    {{ form.processing ? 'Сохранение...' : 'Сохранить' }}
                </button>
            </div>
        </form>
    </div>
</template>
