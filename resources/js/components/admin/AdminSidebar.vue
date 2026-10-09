<script setup lang="ts">
import { Link } from '@inertiajs/vue3'
import { dashboard } from '@/routes/admin'
import { create as createProduct } from '@/routes/admin/products'

interface Props {
    open: boolean
}

interface NavigationItem {
    name: string
    href: string
    icon: string
}

interface NavigationGroup {
    title: string
    items: NavigationItem[]
}

defineProps<Props>()

const emit = defineEmits<{
    close: []
}>()

const navigationGroups: NavigationGroup[] = [
    {
        title: 'Основное',
        items: [
            {
                name: 'Dashboard',
                href: dashboard.url(),
                icon: '▦',
            },
        ],
    },
    {
        title: 'Каталог',
        items: [
            {
                name: 'Добавить товар',
                href: createProduct.url(),
                icon: '+',
            },
        ],
    },
]
</script>

<template>
    <div>
        <div
            v-if="open"
            class="fixed inset-0 z-40 bg-black/50 lg:hidden"
            @click="emit('close')"
        />

        <aside
            class="fixed inset-y-0 left-0 z-50 flex w-64 flex-col border-r border-gray-200 bg-white transition-transform duration-200 lg:translate-x-0"
            :class="open ? 'translate-x-0' : '-translate-x-full'"
        >
            <div class="flex h-16 items-center border-b border-gray-200 px-6">
                <Link
                    :href="dashboard.url()"
                    class="text-lg font-bold text-gray-900"
                    @click="emit('close')"
                >
                    Склад
                </Link>

                <button
                    type="button"
                    class="ml-auto text-gray-500 lg:hidden"
                    @click="emit('close')"
                >
                    ✕
                </button>
            </div>

            <nav class="flex-1 overflow-y-auto p-4">
                <div
                    v-for="group in navigationGroups"
                    :key="group.title"
                    class="mb-6"
                >
                    <div
                        class="mb-2 px-3 text-xs font-semibold uppercase tracking-wider text-gray-400"
                    >
                        {{ group.title }}
                    </div>

                    <div class="space-y-1">
                        <Link
                            v-for="item in group.items"
                            :key="item.href"
                            :href="item.href"
                            class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-gray-700 transition hover:bg-gray-100"
                            :class="{
                                'bg-gray-900 text-white':
                                    item.href === dashboard.url(),
                            }"
                            @click="emit('close')"
                        >
                            <span class="w-5 text-center">
                                {{ item.icon }}
                            </span>

                            <span>
                                {{ item.name }}
                            </span>
                        </Link>
                    </div>
                </div>
            </nav>

            <div class="border-t border-gray-200 p-4">
                <div class="text-xs text-gray-500">
                    Warehouse Admin
                </div>
            </div>
        </aside>
    </div>
</template>
