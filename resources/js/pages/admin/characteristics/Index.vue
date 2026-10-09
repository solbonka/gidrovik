<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'
import {
    create,
    destroy,
    edit,
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
    categories_count: number
}

interface PaginationLink {
    url: string | null
    label: string
    active: boolean
}

interface PaginatedCharacteristics {
    data: Characteristic[]
    current_page: number
    last_page: number
    from: number | null
    to: number | null
    total: number
    links: PaginationLink[]
}

interface Props {
    characteristics: PaginatedCharacteristics
}

const props = defineProps<Props>()

const typeLabels: Record<string, string> = {
    text: 'Текст',
    number: 'Число',
    select: 'Список',
    boolean: 'Да / Нет',
}

const remove = (characteristic: Characteristic): void => {
    if (
        !confirm(
            `Удалить характеристику «${characteristic.name}»?`,
        )
    ) {
        return
    }

    router.delete(destroy(characteristic.id).url)
}
</script>

<template>
    <Head title="Характеристики" />

    <div class="space-y-6 p-6">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-2xl font-semibold">
                    Характеристики
                </h1>

                <p class="mt-1 text-sm text-muted-foreground">
                    Общие характеристики, которые можно назначать
                    категориям товаров.
                </p>
            </div>

            <Link
                :href="create.url()"
                class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground"
            >
                Добавить характеристику
            </Link>
        </div>

        <div class="overflow-hidden rounded-xl border bg-card">
            <table class="w-full text-sm">
                <thead class="border-b bg-muted/40">
                <tr>
                    <th class="px-4 py-3 text-left">
                        Название
                    </th>
                    <th class="px-4 py-3 text-left">
                        Slug
                    </th>
                    <th class="px-4 py-3 text-left">
                        Тип
                    </th>
                    <th class="px-4 py-3 text-left">
                        Единица
                    </th>
                    <th class="px-4 py-3 text-center">
                        Категорий
                    </th>
                    <th class="px-4 py-3 text-center">
                        Статус
                    </th>
                    <th class="px-4 py-3 text-right">
                        Действия
                    </th>
                </tr>
                </thead>

                <tbody class="divide-y">
                <tr
                    v-for="characteristic in props.characteristics.data"
                    :key="characteristic.id"
                >
                    <td class="px-4 py-3 font-medium">
                        {{ characteristic.name }}
                    </td>

                    <td class="px-4 py-3 text-muted-foreground">
                        {{ characteristic.slug }}
                    </td>

                    <td class="px-4 py-3">
                        {{
                            typeLabels[characteristic.type]
                            ?? characteristic.type
                        }}
                    </td>

                    <td class="px-4 py-3">
                        {{ characteristic.unit ?? '—' }}
                    </td>

                    <td class="px-4 py-3 text-center">
                        {{ characteristic.categories_count }}
                    </td>

                    <td class="px-4 py-3 text-center">
                            <span
                                :class="
                                    characteristic.is_active
                                        ? 'text-green-600'
                                        : 'text-muted-foreground'
                                "
                            >
                                {{
                                    characteristic.is_active
                                        ? 'Активна'
                                        : 'Неактивна'
                                }}
                            </span>
                    </td>

                    <td class="px-4 py-3 text-right">
                        <div class="flex justify-end gap-2">
                            <Link
                                :href="
                                        edit(characteristic.id).url
                                    "
                                class="rounded-md border px-3 py-1.5"
                            >
                                Изменить
                            </Link>

                            <button
                                type="button"
                                class="rounded-md border border-red-300 px-3 py-1.5 text-red-600"
                                @click="remove(characteristic)"
                            >
                                Удалить
                            </button>
                        </div>
                    </td>
                </tr>

                <tr
                    v-if="
                            props.characteristics.data.length === 0
                        "
                >
                    <td
                        colspan="7"
                        class="px-4 py-10 text-center text-muted-foreground"
                    >
                        Характеристик пока нет.
                    </td>
                </tr>
                </tbody>
            </table>
        </div>

        <div
            v-if="props.characteristics.last_page > 1"
            class="flex flex-wrap gap-2"
        >
            <Link
                v-for="link in props.characteristics.links"
                :key="link.label"
                :href="link.url ?? '#'"
                :class="[
                    'rounded-md border px-3 py-1.5 text-sm',
                    link.active
                        ? 'bg-primary text-primary-foreground'
                        : 'bg-background',
                    !link.url
                        ? 'pointer-events-none opacity-50'
                        : '',
                ]"
                preserve-scroll
            >
                <span v-html="link.label" />
            </Link>
        </div>
    </div>
</template>
