<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import { ref } from 'vue'
import { toast } from 'vue-sonner'
import { Globe, MapPin } from '@lucide/vue'
import AdminLayout from '@/layouts/AdminLayout.vue'
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue'

defineOptions({
    layout: AdminLayout,
})

interface Country {
    id: number
    name: string
    code: string | null
    is_active: boolean
    products_count: number
}

interface Props {
    countries: {
        data: Country[]
        links: any[]
    }
}

const props = defineProps<Props>()

const deleteDialog = ref({
    open: false,
    id: null as number | null,
    name: '',
    loading: false,
})

const confirmDelete = (): void => {
    deleteDialog.value.loading = true
    router.delete(`/admin/countries/${deleteDialog.value.id}`, {
        onSuccess: () => {
            toast.success('Страна удалена.')
        },
        onFinish: () => {
            deleteDialog.value.loading = false
            deleteDialog.value.open = false
        },
    })
}

const openDeleteDialog = (country: Country): void => {
    if (country.products_count > 0) {
        alert('Нельзя удалить страну, которая используется в товарах.')
        return
    }
    deleteDialog.value.id = country.id
    deleteDialog.value.name = country.name
    deleteDialog.value.open = true
}
</script>

<template>
    <Head title="Страны" />

    <div class="mx-auto max-w-7xl space-y-6">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-2xl font-semibold text-gray-900">
                    Страны
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    Управление списком стран производителей
                </p>
            </div>

            <Link
                href="/admin/countries/create"
                class="inline-flex items-center gap-2 rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800 transition-colors"
            >
                <Globe :size="16" />
                Добавить страну
            </Link>
        </div>

        <div class="rounded-xl border border-gray-200 bg-white shadow-sm overflow-hidden">
            <table class="w-full text-left text-sm">
                <thead class="border-b border-gray-100 bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 font-medium text-gray-700">
                            Название
                        </th>

                        <th class="px-6 py-3 font-medium text-gray-700">
                            Код
                        </th>

                        <th class="px-6 py-3 font-medium text-gray-700">
                            Статус
                        </th>

                        <th class="px-6 py-3 font-medium text-gray-700">
                            Товаров
                        </th>

                        <th class="px-6 py-3 text-right font-medium text-gray-700">
                            Действия
                        </th>
                    </tr>
                </thead>

                <tbody class="divide-y divide-gray-100">
                    <tr
                        v-for="country in countries.data"
                        :key="country.id"
                        class="hover:bg-gray-50 transition-colors"
                    >
                        <td class="px-6 py-4 font-medium text-gray-900">
                            {{ country.name }}
                        </td>

                        <td class="px-6 py-4">
                            <span
                                v-if="country.code"
                                class="inline-flex items-center gap-1 rounded bg-gray-100 px-2 py-0.5 text-xs font-mono text-gray-700"
                            >
                                {{ country.code }}
                            </span>
                            <span v-else class="text-gray-400">—</span>
                        </td>

                        <td class="px-6 py-4">
                            <span
                                class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium"
                                :class="
                                    country.is_active
                                        ? 'bg-green-100 text-green-700'
                                        : 'bg-gray-100 text-gray-600'
                                "
                            >
                                <span
                                    class="h-1.5 w-1.5 rounded-full"
                                    :class="
                                        country.is_active
                                            ? 'bg-green-600'
                                            : 'bg-gray-400'
                                    "
                                />
                                {{
                                    country.is_active
                                        ? 'Активна'
                                        : 'Неактивна'
                                }}
                            </span>
                        </td>

                        <td class="px-6 py-4">
                            <div class="flex items-center gap-2 text-gray-600">
                                <MapPin :size="14" />
                                {{ country.products_count }}
                            </div>
                        </td>

                        <td class="px-6 py-4 text-right">
                            <div class="flex items-center justify-end gap-2">
                                <Link
                                    :href="`/admin/countries/${country.id}/edit`"
                                    class="text-sm font-medium text-gray-600 hover:text-gray-900 transition-colors"
                                >
                                    Редактировать
                                </Link>

                                <button
                                    class="text-sm font-medium text-red-600 hover:text-red-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                                    :disabled="country.products_count > 0"
                                    @click="openDeleteDialog(country)"
                                >
                                    Удалить
                                </button>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>

            <div
                v-if="countries.data.length === 0"
                class="px-6 py-12 text-center"
            >
                <Globe :size="48" class="mx-auto text-gray-300 mb-4" />
                <p class="text-sm text-gray-500">
                    Страны не найдены.
                </p>
                <Link
                    href="/admin/countries/create"
                    class="mt-4 inline-block text-sm font-medium text-gray-900 hover:text-gray-700"
                >
                    Добавить первую страну
                </Link>
            </div>
        </div>

        <div
            v-if="countries.links.length > 3"
            class="flex items-center justify-center gap-2"
        >
            <Link
                v-for="(link, index) in countries.links"
                :key="index"
                :href="link.url || '#'"
                class="rounded-lg border px-3 py-2 text-sm transition-colors"
                :class="
                    link.active
                        ? 'border-gray-900 bg-gray-900 text-white'
                        : 'border-gray-300 text-gray-700 hover:bg-gray-50'
                "
                v-html="link.label"
            />
        </div>

        <ConfirmDeleteDialog
            :open="deleteDialog.open"
            title="Удаление страны"
            description="Вы уверены, что хотите удалить страну"
            :item-name="deleteDialog.name"
            :loading="deleteDialog.loading"
            @confirm="confirmDelete"
            @cancel="deleteDialog.open = false"
        />
    </div>
</template>
