<script setup lang="ts">
import { Link, usePage } from '@inertiajs/vue3'
import {
    LayoutDashboard,
    Package,
    PackagePlus,
    Tags,
    Shapes,
    ListChecks,
    CircleDot,
    Waypoints,
    Boxes,
    ArrowDownToLine,
    ArrowLeftRight,
    PackageMinus,
    RotateCcw,
    ClipboardCheck,
    History,
    Grid2X2,
    X,
    Building2,
    Globe,
} from '@lucide/vue'

interface Props {
    open: boolean
}

interface NavigationItem {
    name: string
    href: string
    icon: typeof LayoutDashboard
}

interface NavigationGroup {
    title: string
    items: NavigationItem[]
}

defineProps<Props>()

const emit = defineEmits<{
    close: []
}>()

const page = usePage()

const navigationGroups: NavigationGroup[] = [
    {
        title: 'Основное',
        items: [
            {
                name: 'Обзор склада',
                href: '/admin',
                icon: LayoutDashboard,
            },
        ],
    },
    {
        title: 'Хранение',
        items: [
            {
                name: 'Стеллажи и ячейки',
                href: '/admin/racks',
                icon: Grid2X2,
            },
        ],
    },
    {
        title: 'Каталог',
        items: [
            {
                name: 'Все товары',
                href: '/admin/products',
                icon: Package,
            },
            {
                name: 'Добавить товар',
                href: '/admin/products/create',
                icon: PackagePlus,
            },
            {
                name: 'Категории',
                href: '/admin/categories',
                icon: Tags,
            },
            {
                name: 'Типы товаров',
                href: '/admin/product-types',
                icon: Shapes,
            },
            {
                name: 'Характеристики',
                href: '/admin/characteristics',
                icon: ListChecks,
            },
            {
                name: 'Стандарты',
                href: '/admin/standards',
                icon: ClipboardCheck,
            },
            {
                name: 'Диаметры',
                href: '/admin/diameters',
                icon: CircleDot,
            },
            {
                name: 'Резьбы',
                href: '/admin/threads',
                icon: Waypoints,
            },
            {
                name: 'Производители',
                href: '/admin/manufacturers',
                icon: Building2,
            },
            {
                name: 'Страны',
                href: '/admin/countries',
                icon: Globe,
            },
        ],
    },
    {
        title: 'Склад',
        items: [
            {
                name: 'Остатки',
                href: '/admin/stock',
                icon: Boxes,
            },
            {
                name: 'Приход товара',
                href: '/admin/stock/receipt',
                icon: ArrowDownToLine,
            },
            {
                name: 'Перемещение',
                href: '/admin/stock/transfer',
                icon: ArrowLeftRight,
            },
            {
                name: 'Списание',
                href: '/admin/stock/write-off',
                icon: PackageMinus,
            },
            {
                name: 'Возврат',
                href: '/admin/stock/return',
                icon: RotateCcw,
            },
            {
                name: 'Инвентаризация',
                href: '/admin/stock/inventory',
                icon: ClipboardCheck,
            },
            {
                name: 'История движений',
                href: '/admin/stock/movements',
                icon: History,
            },
        ],
    },
]

function isActive(item: NavigationItem): boolean {
    const currentUrl = page.url.split('?')[0].replace(/\/+$/, '') || '/'
    const itemUrl = item.href.replace(/\/+$/, '') || '/'

    if (itemUrl === '/admin') {
        return currentUrl === '/admin'
    }

    if (itemUrl === '/admin/products') {
        return (
            currentUrl === itemUrl ||
            (currentUrl.startsWith(`${itemUrl}/`) &&
                currentUrl !== '/admin/products/create')
        )
    }

    return currentUrl === itemUrl || currentUrl.startsWith(`${itemUrl}/`)
}
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
            <div
                class="flex h-16 shrink-0 items-center justify-between border-b border-gray-200 px-6"
            >
                <Link
                    href="/admin"
                    class="text-lg font-bold text-gray-900"
                    @click="emit('close')"
                >
                    Склад
                </Link>

                <button
                    type="button"
                    aria-label="Закрыть меню"
                    class="text-gray-500 transition hover:text-gray-900 lg:hidden"
                    @click="emit('close')"
                >
                    <X :size="20" />
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
                            class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition"
                            :class="
                                isActive(item)
                                    ? 'bg-gray-900 text-white'
                                    : 'text-gray-700 hover:bg-gray-100'
                            "
                            :aria-current="isActive(item) ? 'page' : undefined"
                            @click="emit('close')"
                        >
                            <component
                                :is="item.icon"
                                :size="18"
                                :stroke-width="1.8"
                                class="shrink-0"
                            />

                            <span>{{ item.name }}</span>
                        </Link>
                    </div>
                </div>
            </nav>

            <div class="shrink-0 border-t border-gray-200 p-4">
                <div class="text-xs text-gray-500">
                    Warehouse Admin
                </div>
            </div>
        </aside>
    </div>
</template>
