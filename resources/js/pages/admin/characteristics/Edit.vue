<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import { toast } from 'vue-sonner'
import AdminLayout from '@/layouts/AdminLayout.vue'
import {
    index,
    update,
} from '@/routes/admin/characteristics'

defineOptions({
    layout: AdminLayout,
})

interface Characteristic {
    id: number
    name: string
    slug: string
    type: string
    unit: string | null
    is_active: boolean
}

interface Props {
    characteristic: Characteristic
}

const props = defineProps<Props>()

const form = useForm({
    name: props.characteristic.name,
    slug: props.characteristic.slug,
    type: props.characteristic.type,
    unit: props.characteristic.unit ?? '',
    is_active: props.characteristic.is_active,
})

const submit = (): void => {
    form.put(update(props.characteristic.id).url, {
        onSuccess: () => {
            toast.success('Характеристика успешно обновлена.')
        },
    })
}
</script>

<template>
    <Head
        :title="`Редактирование: ${characteristic.name}`"
    />

    <div class="max-w-2xl space-y-6 p-6">
        <div>
            <h1 class="text-2xl font-semibold">
                Редактирование характеристики
            </h1>
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
                    Сохранить
                </button>
            </div>
        </form>
    </div>
</template>
