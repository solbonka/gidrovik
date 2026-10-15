<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import { toast } from 'vue-sonner'
import AdminLayout from '@/layouts/AdminLayout.vue'
import {
    create,
    destroy,
    edit,
} from '@/routes/admin/threads'

defineOptions({
    layout: AdminLayout,
})

interface Thread {
    id: number
    system: string
    designation: string
    name: string
    is_active: boolean
    connections_count: number
}

interface PaginationLink {
    url: string | null
    label: string
    active: boolean
}

interface PaginatedThreads {
    data: Thread[]
    current_page: number
    last_page: number
    from: number | null
    to: number | null
    total: number
    links: PaginationLink[]
}

interface Props {
    threads: PaginatedThreads
}

defineProps<Props>()

const systemLabels: Record<string, string> = {
    metric: 'Метрическая',
    inch: 'Дюймовая',
}

const systemLabel = (system: string): string => {
    return systemLabels[system] ?? system.toUpperCase()
}

const deleteThread = (thread: Thread): void => {
    if (
        !confirm(
            `Удалить резьбу «${thread.designation}»?`,
        )
    ) {
        return
    }

    router.delete(destroy(thread.id), {
        onSuccess: () => {
            toast.success('Резьба удалена.')
        },
    })
}
</script>

<template>
    <Head title="Резьбы" />

    <div class="space-y-6">
        <div class="flex items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-900">
                    Резьбы
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    Обозначения резьбовых соединений.
                </p>
            </div>

            <Link
                :href="create().url"
                class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800"
            >
                Добавить резьбу
            </Link>
        </div>

        <div
            class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm"
        >
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead
                        class="border-b border-gray-200 bg-gray-50 text-xs uppercase text-gray-500"
                    >
                    <tr>
                        <th class="px-6 py-3">
                            Система
                        </th>

                        <th class="px-6 py-3">
                            Обозначение
                        </th>

                        <th class="px-6 py-3">
                            Название
                        </th>

                        <th class="px-6 py-3">
                            Товаров
                        </th>

                        <th class="px-6 py-3">
                            Статус
                        </th>

                        <th class="px-6 py-3 text-right">
                            Действия
                        </th>
                    </tr>
                    </thead>

                    <tbody class="divide-y divide-gray-200">
                    <tr
                        v-for="thread in threads.data"
                        :key="thread.id"
                        class="hover:bg-gray-50"
                    >
                        <td class="px-6 py-4">
                                <span
                                    class="rounded-md bg-gray-100 px-2 py-1 text-xs font-medium text-gray-700"
                                >
                                    {{ systemLabel(thread.system) }}
                                </span>
                        </td>

                        <td class="px-6 py-4">
                                <span
                                    class="font-mono font-medium text-gray-900"
                                >
                                    {{ thread.designation }}
                                </span>
                        </td>

                        <td class="px-6 py-4 text-gray-700">
                            {{ thread.name }}
                        </td>

                        <td class="px-6 py-4 text-gray-600">
                            {{ thread.connections_count }}
                        </td>

                        <td class="px-6 py-4">
                                <span
                                    class="inline-flex rounded-full px-2.5 py-1 text-xs font-medium"
                                    :class="
                                        thread.is_active
                                            ? 'bg-green-100 text-green-700'
                                            : 'bg-gray-100 text-gray-600'
                                    "
                                >
                                    {{
                                        thread.is_active
                                            ? 'Активна'
                                            : 'Неактивна'
                                    }}
                                </span>
                        </td>

                        <td class="px-6 py-4">
                            <div class="flex justify-end gap-3">
                                <Link
                                    :href="edit(thread.id).url"
                                    class="text-gray-600 hover:text-gray-900"
                                >
                                    Изменить
                                </Link>

                                <button
                                    type="button"
                                    class="text-red-600 hover:text-red-800"
                                    @click="deleteThread(thread)"
                                >
                                    Удалить
                                </button>
                            </div>
                        </td>
                    </tr>

                    <tr v-if="threads.data.length === 0">
                        <td
                            colspan="6"
                            class="px-6 py-12 text-center text-gray-500"
                        >
                            Резьб пока нет.
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <div
                v-if="threads.last_page > 1"
                class="flex items-center justify-between border-t border-gray-200 px-6 py-4"
            >
                <div class="text-sm text-gray-500">
                    Показано {{ threads.from }}–{{ threads.to }}
                    из {{ threads.total }}
                </div>

                <div class="flex gap-1">
                    <template
                        v-for="(link, index) in threads.links"
                        :key="index"
                    >
                        <Link
                            v-if="link.url"
                            :href="link.url"
                            class="rounded-md px-3 py-1.5 text-sm"
                            :class="
                                link.active
                                    ? 'bg-gray-900 text-white'
                                    : 'text-gray-600 hover:bg-gray-100'
                            "
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
