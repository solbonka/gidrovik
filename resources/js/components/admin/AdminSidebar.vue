<script setup lang="ts">
import { Link, usePage } from '@inertiajs/vue3';
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
} from '@lucide/vue';
import { Button } from '@/components/ui/button';

interface Props {
    open: boolean;
}

interface NavigationItem {
    name: string;
    href: string;
    icon: typeof LayoutDashboard;
}

interface NavigationGroup {
    title: string;
    items: NavigationItem[];
}

defineProps<Props>();

const emit = defineEmits<{
    close: [];
}>();

const page = usePage();

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
];

function isActive(item: NavigationItem): boolean {
    const currentUrl = page.url.split('?')[0].replace(/\/+$/, '') || '/';
    const itemUrl = item.href.replace(/\/+$/, '') || '/';

    if (itemUrl === '/admin') {
        return currentUrl === '/admin';
    }

    if (itemUrl === '/admin/products') {
        return (
            currentUrl === itemUrl ||
            (currentUrl.startsWith(`${itemUrl}/`) &&
                currentUrl !== '/admin/products/create')
        );
    }

    return currentUrl === itemUrl || currentUrl.startsWith(`${itemUrl}/`);
}
</script>

<template>
    <div>
        <div
            v-if="open"
            class="fixed inset-0 z-40 bg-black/40 backdrop-blur-sm lg:hidden"
            @click="emit('close')"
        />

        <aside
            class="fixed inset-y-0 left-0 z-50 flex w-64 flex-col border-r border-border/10 bg-gradient-to-b from-white to-slate-50/50 shadow-xl transition-transform duration-300 ease-out lg:translate-x-0"
            :class="open ? 'translate-x-0' : '-translate-x-full'"
        >
            <div
                class="flex h-16 shrink-0 items-center justify-between border-b border-border/10 bg-white/50 px-6 backdrop-blur-sm"
            >
                <Link
                    href="/admin"
                    class="flex items-center gap-2 bg-gradient-to-r from-primary to-indigo-600 bg-clip-text text-lg font-bold text-transparent"
                    @click="emit('close')"
                >
                    <div
                        class="flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-primary to-indigo-600 text-white shadow-lg"
                    >
                        <LayoutDashboard :size="18" />
                    </div>
                    Гидровик
                </Link>

                <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    aria-label="Закрыть меню"
                    class="text-muted-foreground hover:text-foreground lg:hidden"
                    @click="emit('close')"
                >
                    <X :size="20" />
                </Button>
            </div>

            <nav class="flex-1 overflow-y-auto p-4">
                <div
                    v-for="group in navigationGroups"
                    :key="group.title"
                    class="mb-6"
                >
                    <div
                        class="mb-3 px-3 text-xs font-semibold tracking-wider text-muted-foreground/70 uppercase"
                    >
                        {{ group.title }}
                    </div>

                    <div class="space-y-1">
                        <Link
                            v-for="item in group.items"
                            :key="item.href"
                            :href="item.href"
                            class="group flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all duration-200"
                            :class="
                                isActive(item)
                                    ? 'border border-primary/20 bg-gradient-to-r from-primary/10 to-indigo-500/10 text-primary shadow-sm'
                                    : 'text-muted-foreground hover:bg-muted/50 hover:text-foreground'
                            "
                            :aria-current="isActive(item) ? 'page' : undefined"
                            @click="emit('close')"
                        >
                            <component
                                :is="item.icon"
                                :size="18"
                                :stroke-width="2"
                                class="shrink-0 transition-colors"
                                :class="
                                    isActive(item)
                                        ? 'text-primary'
                                        : 'text-muted-foreground group-hover:text-foreground'
                                "
                            />

                            <span class="relative">
                                {{ item.name }}
                                <span
                                    v-if="isActive(item)"
                                    class="absolute bottom-0 left-0 h-0.5 w-full rounded-full bg-gradient-to-r from-primary to-indigo-600"
                                />
                            </span>
                        </Link>
                    </div>
                </div>
            </nav>

            <div
                class="shrink-0 border-t border-border/10 bg-gradient-to-t from-white/50 to-transparent p-4"
            >
                <div
                    class="rounded-xl border border-border/10 bg-gradient-to-br from-muted/50 to-muted/30 p-4"
                >
                    <div class="flex items-center gap-3">
                        <div
                            class="flex h-10 w-10 items-center justify-center rounded-full bg-gradient-to-br from-primary/20 to-indigo-500/20 text-primary"
                        >
                            <Building2 :size="18" />
                        </div>
                        <div>
                            <div class="text-sm font-semibold text-foreground">
                                Большой склад
                            </div>
                            <div class="text-xs text-muted-foreground">
                                Admin Panel
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </aside>
    </div>
</template>
