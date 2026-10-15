<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import { ref } from 'vue'
import { toast } from 'vue-sonner'
import AdminLayout from '@/layouts/AdminLayout.vue'

defineOptions({ layout: AdminLayout })

interface MovementType {
    value: string
    label: string
}

interface Movement {
    id: number
    type: string
    type_label: string
    quantity: number
    comment: string | null
    created_at: string | null
    product: {
        id: number
        name: string
        sku: string
    }
    from_location: {
        code: string
    } | null
    to_location: {
        code: string
    } | null
    user: string | null
}

interface PaginationLink {
    url: string | null
    label: string
    active: boolean
}

interface PaginatedMovements {
    data: Movement[]
    current_page: number
    last_page: number
    from: number | null
    to: number | null
    total: number
    links: PaginationLink[]
}

interface Filters {
    type: string
    search: string
    product_id: string
}

interface Props {
    movements: PaginatedMovements
    filters: Filters
    types: MovementType[]
}

const props = defineProps<Props>()

const search = ref(props.filters.search)
const type = ref(props.filters.type)

const applyFilters = (): void => {
    router.get(
        '/admin/stock/movements',
        {
            search: search.value || undefined,
            type: type.value || undefined,
            product_id: props.filters.product_id || undefined,
        },
        {
            preserveState: true,
            preserveScroll: true,
            replace: true,
        },
    )
}

const clearProductFilter = (): void => {
    router.get(
        '/admin/stock/movements',
        {
            search: search.value || undefined,
            type: type.value || undefined,
        },
        {
            preserveState: true,
            preserveScroll: true,
            replace: true,
        },
    )
}

const locationSummary = (movement: Movement): string => {
    if (movement.from_location && movement.to_location) {
        return `${movement.from_location.code} → ${movement.to_location.code}`
    }

    if (movement.to_location) {
        return `→ ${movement.to_location.code}`
    }

    if (movement.from_location) {
        return `${movement.from_location.code} → списание`
    }

    return '—'
}

const deleteMovement = (movement: Movement): void => {
    if (confirm('Вы уверены, что хотите удалить эту запись из журнала?')) {
        router.delete(`/admin/stock/movements/${movement.id}`, {
            onSuccess: () => {
                toast.success('Запись удалена из журнала.')
            },
        })
    }
}
</script>

<template>
    <Head title="Журнал складских движений" />

    <div class="space-y-6">
        <div class="flex flex-wrap items-start justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-900">
                    Журнал складских движений
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    История поступлений, перемещений, списаний и других операций.
                </p>

                <div
                    v-if="filters.product_id"
                    class="mt-3 flex flex-wrap items-center gap-2"
                >
                    <span
                        class="rounded-lg bg-blue-50 px-3 py-1.5 text-sm text-blue-700"
                    >
                        Фильтр по товару №{{ filters.product_id }}
                    </span>

                    <button
                        type="button"
                        class="text-sm font-medium text-gray-600 underline hover:text-gray-900"
                        @click="clearProductFilter"
                    >
                        Показать все товары
                    </button>
                </div>
            </div>

            <div class="flex flex-wrap gap-2">
                <Link
                    href="/admin/stock/receipt"
                    class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800"
                >
                    Поступление
                </Link>

                <Link
                    href="/admin/stock/transfer"
                    class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                    Перемещение
                </Link>

                <Link
                    href="/admin/stock/write-off"
                    class="rounded-lg border border-red-200 px-4 py-2 text-sm font-medium text-red-700 hover:bg-red-50"
                >
                    Списание
                </Link>
            </div>
        </div>

        <div class="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
            <div class="grid gap-4 md:grid-cols-[2fr_1fr_auto]">
                <div>
                    <label
                        for="search"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Поиск по товару
                    </label>

                    <input
                        id="search"
                        v-model="search"
                        type="search"
                        placeholder="Название или артикул"
                        class="w-full rounded-lg border-gray-300"
                        @keyup.enter="applyFilters"
                    />
                </div>

                <div>
                    <label
                        for="type"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Тип операции
                    </label>

                    <select
                        id="type"
                        v-model="type"
                        class="w-full rounded-lg border-gray-300"
                        @change="applyFilters"
                    >
                        <option value="">Все операции</option>

                        <option
                            v-for="item in types"
                            :key="item.value"
                            :value="item.value"
                        >
                            {{ item.label }}
                        </option>
                    </select>
                </div>

                <div class="flex items-end">
                    <button
                        type="button"
                        class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800"
                        @click="applyFilters"
                    >
                        Найти
                    </button>
                </div>
            </div>
        </div>

        <div class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead
                        class="border-b border-gray-200 bg-gray-50 text-xs uppercase text-gray-500"
                    >
                    <tr>
                        <th class="px-5 py-3">Дата</th>
                        <th class="px-5 py-3">Операция</th>
                        <th class="px-5 py-3">Товар</th>
                        <th class="px-5 py-3">Ячейки</th>
                        <th class="px-5 py-3">Количество</th>
                        <th class="px-5 py-3">Пользователь</th>
                        <th class="px-5 py-3">Комментарий</th>
                        <th class="px-5 py-3"></th>
                    </tr>
                    </thead>

                    <tbody class="divide-y divide-gray-200">
                    <tr
                        v-for="movement in movements.data"
                        :key="movement.id"
                        class="hover:bg-gray-50"
                    >
                        <td class="whitespace-nowrap px-5 py-4 text-gray-600">
                            {{ movement.created_at ?? '—' }}
                        </td>

                        <td class="whitespace-nowrap px-5 py-4">
                                <span
                                    class="rounded-full bg-gray-100 px-2.5 py-1 text-xs font-medium text-gray-700"
                                >
                                    {{ movement.type_label }}
                                </span>
                        </td>

                        <td class="px-5 py-4">
                            <div class="font-medium text-gray-900">
                                {{ movement.product.name }}
                            </div>

                            <div class="mt-1 font-mono text-xs text-gray-500">
                                {{ movement.product.sku }}
                            </div>
                        </td>

                        <td class="whitespace-nowrap px-5 py-4 text-gray-600">
                            {{ locationSummary(movement) }}
                        </td>

                        <td class="px-5 py-4 font-semibold text-gray-900">
                            {{ movement.quantity }}
                        </td>

                        <td class="px-5 py-4 text-gray-600">
                            {{ movement.user ?? '—' }}
                        </td>

                        <td class="max-w-xs px-5 py-4 text-gray-600">
                                <span class="line-clamp-2">
                                    {{ movement.comment ?? '—' }}
                                </span>
                        </td>

                        <td class="px-5 py-4">
                            <button
                                type="button"
                                class="text-sm font-medium text-red-600 hover:text-red-900"
                                @click="deleteMovement(movement)"
                            >
                                Удалить
                            </button>
                        </td>
                    </tr>

                    <tr v-if="movements.data.length === 0">
                        <td
                            colspan="8"
                            class="px-5 py-12 text-center text-gray-500"
                        >
                            Движения по заданным условиям не найдены.
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <div
                v-if="movements.last_page > 1"
                class="flex flex-wrap items-center justify-between gap-3 border-t border-gray-200 px-5 py-4"
            >
                <p class="text-sm text-gray-500">
                    Показано {{ movements.from }}–{{ movements.to }}
                    из {{ movements.total }}
                </p>

                <div class="flex flex-wrap gap-1">
                    <template
                        v-for="(link, index) in movements.links"
                        :key="index"
                    >
                        <Link
                            v-if="link.url"
                            :href="link.url"
                            class="rounded-md px-3 py-1.5 text-sm"
                            :class="link.active
                                ? 'bg-gray-900 text-white'
                                : 'text-gray-600 hover:bg-gray-100'"
                            v-html="link.label"
                        />

                        <span
                            v-else
                            class="rounded-md px-3 py-1.5 text-sm text-gray-300"
                            v-html="link.label"
                        />
                    </template>
                </div>
            </div>
        </div>
    </div>
</template>
