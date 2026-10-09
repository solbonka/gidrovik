<script setup lang="ts">
import { computed } from 'vue'
import { Head, Link, useForm } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { index as categoriesIndex } from '@/routes/admin/categories'

defineOptions({
    layout: AdminLayout,
})

interface Category {
    id: number
    name: string
    slug: string
}

interface Characteristic {
    id: number
    name: string
    slug: string
    type: string
    unit: string | null
    assigned: boolean
    is_required: boolean
    sort_order: number
}

interface Props {
    category: Category
    characteristics: Characteristic[]
}

const props = defineProps<Props>()

const form = useForm({
    characteristics: props.characteristics.map((characteristic) => ({
        id: characteristic.id,
        enabled: characteristic.assigned,
        is_required: characteristic.is_required,
        sort_order: characteristic.sort_order,
    })),
})

const typeLabels: Record<string, string> = {
    text: 'Текст',
    number: 'Число',
    select: 'Список',
    boolean: 'Да / Нет',
}

const selectedCount = computed(() => {
    return form.characteristics.filter(
        (characteristic) => characteristic.enabled,
    ).length
})

const save = (): void => {
    const selectedCharacteristics = form.characteristics
        .filter((characteristic) => characteristic.enabled)
        .map((characteristic) => ({
            id: characteristic.id,
            is_required: characteristic.is_required,
            sort_order: characteristic.sort_order,
        }))

    form.transform(() => ({
        characteristics: selectedCharacteristics,
    })).put(`/admin/categories/${props.category.id}/characteristics`, {
        preserveScroll: true,
    })
}
</script>

<template>
    <Head :title="`Характеристики — ${category.name}`" />

    <div class="space-y-6">
        <div class="flex items-center justify-between gap-4">
            <div>
                <div class="mb-2 flex items-center gap-2 text-sm text-gray-500">
                    <Link
                        :href="categoriesIndex().url"
                        class="hover:text-gray-900"
                    >
                        Категории
                    </Link>

                    <span>/</span>

                    <span>{{ category.name }}</span>
                </div>

                <h1 class="text-2xl font-semibold text-gray-900">
                    Характеристики категории
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    Настройте характеристики, доступные для категории
                    «{{ category.name }}».
                </p>
            </div>

            <Link
                :href="categoriesIndex().url"
                class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
                Назад
            </Link>
        </div>

        <div
            class="rounded-xl border border-gray-200 bg-white shadow-sm"
        >
            <div
                class="flex items-center justify-between border-b border-gray-200 px-6 py-4"
            >
                <div>
                    <h2 class="font-medium text-gray-900">
                        Доступные характеристики
                    </h2>

                    <p class="mt-1 text-sm text-gray-500">
                        Выбрано: {{ selectedCount }}
                    </p>
                </div>

                <button
                    type="button"
                    :disabled="form.processing"
                    class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                    @click="save"
                >
                    {{ form.processing ? 'Сохранение...' : 'Сохранить' }}
                </button>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead
                        class="border-b border-gray-200 bg-gray-50 text-xs uppercase text-gray-500"
                    >
                    <tr>
                        <th class="w-16 px-6 py-3">
                            Использовать
                        </th>

                        <th class="px-6 py-3">
                            Характеристика
                        </th>

                        <th class="px-6 py-3">
                            Тип
                        </th>

                        <th class="px-6 py-3">
                            Единица
                        </th>

                        <th class="w-48 px-6 py-3">
                            Обязательная
                        </th>

                        <th class="w-32 px-6 py-3">
                            Порядок
                        </th>
                    </tr>
                    </thead>

                    <tbody class="divide-y divide-gray-200">
                    <tr
                        v-for="(characteristic, index) in characteristics"
                        :key="characteristic.id"
                        class="hover:bg-gray-50"
                    >
                        <td class="px-6 py-4">
                            <input
                                v-model="
                                        form.characteristics[index].enabled
                                    "
                                type="checkbox"
                                class="h-4 w-4 rounded border-gray-300"
                            />
                        </td>

                        <td class="px-6 py-4">
                            <div class="font-medium text-gray-900">
                                {{ characteristic.name }}
                            </div>

                            <div class="mt-1 text-xs text-gray-500">
                                {{ characteristic.slug }}
                            </div>
                        </td>

                        <td class="px-6 py-4 text-gray-600">
                            {{
                                typeLabels[characteristic.type]
                                ?? characteristic.type
                            }}
                        </td>

                        <td class="px-6 py-4 text-gray-600">
                            {{ characteristic.unit || '—' }}
                        </td>

                        <td class="px-6 py-4">
                            <label
                                class="inline-flex items-center gap-2"
                            >
                                <input
                                    v-model="
                                            form.characteristics[index]
                                                .is_required
                                        "
                                    type="checkbox"
                                    :disabled="
                                            !form.characteristics[index]
                                                .enabled
                                        "
                                    class="h-4 w-4 rounded border-gray-300"
                                />

                                <span class="text-gray-700">
                                        Да
                                    </span>
                            </label>
                        </td>

                        <td class="px-6 py-4">
                            <input
                                v-model.number="
                                        form.characteristics[index].sort_order
                                    "
                                type="number"
                                min="0"
                                :disabled="
                                        !form.characteristics[index].enabled
                                    "
                                class="w-24 rounded-lg border-gray-300 text-sm shadow-sm focus:border-gray-500 focus:ring-gray-500"
                            />
                        </td>
                    </tr>

                    <tr v-if="characteristics.length === 0">
                        <td
                            colspan="6"
                            class="px-6 py-12 text-center text-gray-500"
                        >
                            Активных характеристик пока нет.
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <div
                class="flex justify-end border-t border-gray-200 px-6 py-4"
            >
                <button
                    type="button"
                    :disabled="form.processing"
                    class="rounded-lg bg-gray-900 px-5 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                    @click="save"
                >
                    {{ form.processing ? 'Сохранение...' : 'Сохранить изменения' }}
                </button>
            </div>
        </div>
    </div>
</template>
