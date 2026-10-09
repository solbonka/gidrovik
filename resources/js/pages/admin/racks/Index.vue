<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import { ref } from 'vue'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { create, destroy, edit } from '@/routes/admin/racks'
import {
    destroy as destroyLocation,
    store as storeLocation,
} from '@/routes/admin/racks/locations'

defineOptions({
    layout: AdminLayout,
})

interface Location {
    id: number
    rack_id: number
    number: number
    code: string
    stock_quantity: number | null
    incoming_movements_count: number
    outgoing_movements_count: number
}

interface Rack {
    id: number
    code: string
    name: string | null
    locations_count: number
    locations: Location[]
}

interface Props {
    racks: Rack[]
}

const props = defineProps<Props>()

const addingLocationRackId = ref<number | null>(null)
const newLocationNumber = ref<Record<number, string>>({})

const startAddLocation = (rackId: number): void => {
    addingLocationRackId.value = rackId

    const rack = props.racks.find(
        (item) => item.id === rackId,
    )

    if (!rack) {
        return
    }

    const numbers = rack.locations.map(
        (location) => location.number,
    )

    let nextNumber = 1

    while (numbers.includes(nextNumber)) {
        nextNumber++
    }

    newLocationNumber.value[rackId] = String(nextNumber)
}

const cancelAddLocation = (): void => {
    addingLocationRackId.value = null
}

const addLocation = (rack: Rack): void => {
    const value = newLocationNumber.value[rack.id] ?? ''

    if (!value) {
        return
    }

    router.post(
        storeLocation(rack.id).url,
        {
            number: Number(value),
        },
        {
            preserveScroll: true,
            onSuccess: () => {
                addingLocationRackId.value = null
            },
        },
    )
}

const deleteRack = (rack: Rack): void => {
    if (
        !window.confirm(
            `Удалить стеллаж «${rack.code}»?\n\n` +
            'Стеллаж можно удалить только если в его ячейках нет остатков и истории движений.',
        )
    ) {
        return
    }

    router.delete(destroy(rack.id).url)
}

const deleteLocation = (
    rack: Rack,
    location: Location,
): void => {
    if (
        !window.confirm(
            `Удалить ячейку «${location.code}»?\n\n` +
            'Это действие нельзя отменить.',
        )
    ) {
        return
    }

    router.delete(
        destroyLocation({
            rack: rack.id,
            location: location.id,
        }).url,
        {
            preserveScroll: true,
        },
    )
}
</script>

<template>
    <Head title="Стеллажи" />

    <div class="space-y-6">
        <div
            class="flex flex-col justify-between gap-4 sm:flex-row sm:items-center"
        >
            <div>
                <h1 class="text-2xl font-semibold text-gray-900">
                    Стеллажи
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    Управление стеллажами и складскими ячейками.
                </p>
            </div>

            <Link
                :href="create().url"
                class="inline-flex items-center justify-center rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white transition hover:bg-gray-800"
            >
                Добавить стеллаж
            </Link>
        </div>

        <div
            v-if="props.racks.length === 0"
            class="rounded-xl border border-gray-200 bg-white p-8 text-center"
        >
            <p class="text-sm text-gray-500">
                Стеллажи ещё не созданы.
            </p>

            <Link
                :href="create().url"
                class="mt-4 inline-flex text-sm font-medium text-gray-900 underline"
            >
                Создать первый стеллаж
            </Link>
        </div>

        <div
            v-for="rack in props.racks"
            :key="rack.id"
            class="overflow-hidden rounded-xl border border-gray-200 bg-white"
        >
            <div
                class="flex flex-col gap-4 border-b border-gray-200 p-5 sm:flex-row sm:items-center sm:justify-between"
            >
                <div>
                    <div class="flex items-center gap-3">
                        <h2 class="text-lg font-semibold text-gray-900">
                            {{ rack.code }}
                        </h2>

                        <span
                            class="rounded-full bg-gray-100 px-2.5 py-1 text-xs font-medium text-gray-600"
                        >
                            {{ rack.locations_count }} ячеек
                        </span>
                    </div>

                    <p
                        v-if="rack.name"
                        class="mt-1 text-sm text-gray-500"
                    >
                        {{ rack.name }}
                    </p>
                </div>

                <div class="flex items-center gap-3">
                    <Link
                        :href="edit(rack.id).url"
                        class="text-sm font-medium text-gray-600 hover:text-gray-900"
                    >
                        Изменить
                    </Link>

                    <button
                        type="button"
                        class="text-sm font-medium text-red-600 hover:text-red-800"
                        @click="deleteRack(rack)"
                    >
                        Удалить
                    </button>
                </div>
            </div>

            <div class="p-5">
                <div
                    v-if="rack.locations.length === 0"
                    class="rounded-lg border border-dashed border-gray-300 p-6 text-center"
                >
                    <p class="text-sm text-gray-500">
                        В этом стеллаже пока нет ячеек.
                    </p>

                    <button
                        type="button"
                        class="mt-3 text-sm font-medium text-gray-900 underline"
                        @click="startAddLocation(rack.id)"
                    >
                        Добавить ячейку
                    </button>
                </div>

                <div
                    v-else
                    class="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6"
                >
                    <div
                        v-for="location in rack.locations"
                        :key="location.id"
                        class="group rounded-lg border border-gray-200 p-4 transition hover:border-gray-300"
                    >
                        <div
                            class="flex items-start justify-between gap-2"
                        >
                            <div>
                                <div
                                    class="font-semibold text-gray-900"
                                >
                                    {{ location.code }}
                                </div>

                                <div class="mt-1 text-xs text-gray-500">
                                    Остаток:
                                    {{ location.stock_quantity ?? 0 }}
                                </div>
                            </div>

                            <button
                                type="button"
                                class="text-xs text-red-500 opacity-0 transition group-hover:opacity-100 hover:text-red-700"
                                title="Удалить ячейку"
                                @click="
                                    deleteLocation(
                                        rack,
                                        location,
                                    )
                                "
                            >
                                ×
                            </button>
                        </div>
                    </div>
                </div>

                <div
                    v-if="addingLocationRackId === rack.id"
                    class="mt-5 rounded-lg border border-gray-200 bg-gray-50 p-4"
                >
                    <div class="flex flex-col gap-3 sm:flex-row sm:items-end">
                        <div>
                            <label
                                :for="`location-number-${rack.id}`"
                                class="mb-1 block text-sm font-medium text-gray-700"
                            >
                                Номер ячейки
                            </label>

                            <input
                                :id="`location-number-${rack.id}`"
                                v-model="
                                    newLocationNumber[rack.id]
                                "
                                type="number"
                                min="1"
                                class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm outline-none focus:border-gray-500 focus:ring-1 focus:ring-gray-500 sm:w-40"
                            />
                        </div>

                        <div class="flex items-center gap-2">
                            <button
                                type="button"
                                class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800"
                                @click="addLocation(rack)"
                            >
                                Добавить
                            </button>

                            <button
                                type="button"
                                class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-white"
                                @click="cancelAddLocation"
                            >
                                Отмена
                            </button>
                        </div>
                    </div>
                </div>

                <button
                    v-else
                    type="button"
                    class="mt-5 text-sm font-medium text-gray-700 hover:text-gray-900"
                    @click="startAddLocation(rack.id)"
                >
                    + Добавить ячейку
                </button>
            </div>
        </div>
    </div>
</template>
