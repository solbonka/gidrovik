
<script setup lang="ts">
import { computed, ref, watch } from 'vue';
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
    Settings,
    User,
    Shield,
    Palette,
    ChevronDown,
    Users,
} from '@lucide/vue';
import { Button } from '@/components/ui/button';
import type { Permission } from '@/types/auth';

interface Props {
    open: boolean;
}

interface NavigationItem {
    name: string;
    href: string;
    icon: typeof LayoutDashboard;
    permission?: Permission;
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

const permissions = computed<string[]>(() => {
    const props = page.props as { permissions?: string[] };

    return props.permissions ?? [];
});

const settingsItems: NavigationItem[] = [
    { name: 'Профиль', href: '/settings/profile', icon: User },
    { name: 'Безопасность', href: '/settings/security', icon: Shield },
    { name: 'Внешний вид', href: '/settings/appearance', icon: Palette },
];

function isSettingsPage(): boolean {
    const currentUrl = page.url.split('?')[0].replace(/\/+$/, '') || '/';

    return settingsItems.some((item) => currentUrl === item.href);
}

const settingsOpen = ref(isSettingsPage());

watch(
    () => page.url,
    () => {
        if (isSettingsPage()) {
            settingsOpen.value = true;
        }
    },
);

function toggleSettings(): void {
    settingsOpen.value = !settingsOpen.value;
}

const navigationGroups: NavigationGroup[] = [
    {
        title: 'Основное',
        items: [
            { name: 'Обзор склада', href: '/admin', icon: LayoutDashboard, permission: 'view' },
        ],
    },
    {
        title: 'Хранение',
        items: [
            { name: 'Стеллажи и ячейки', href: '/admin/racks', icon: Grid2X2, permission: 'catalog.manage' },
        ],
    },
    {
        title: 'Склад',
        items: [
            { name: 'Остатки', href: '/admin/stock', icon: Boxes, permission: 'view' },
            { name: 'Приход товара', href: '/admin/stock/receipt', icon: ArrowDownToLine, permission: 'stock.operate' },
            { name: 'Перемещение', href: '/admin/stock/transfer', icon: ArrowLeftRight, permission: 'stock.operate' },
            { name: 'Списание', href: '/admin/stock/write-off', icon: PackageMinus, permission: 'stock.operate' },
            { name: 'Возврат', href: '/admin/stock/return', icon: RotateCcw, permission: 'stock.operate' },
            { name: 'Инвентаризация', href: '/admin/stock/inventory', icon: ClipboardCheck, permission: 'stock.operate' },
            { name: 'История движений', href: '/admin/stock/movements', icon: History, permission: 'view' },
        ],
    },
    {
        title: 'Каталог',
        items: [
            { name: 'Все товары', href: '/admin/products', icon: Package, permission: 'view' },
            { name: 'Добавить товар', href: '/admin/products/create', icon: PackagePlus, permission: 'catalog.manage' },
            { name: 'Категории', href: '/admin/categories', icon: Tags, permission: 'catalog.manage' },
            { name: 'Типы товаров', href: '/admin/product-types', icon: Shapes, permission: 'catalog.manage' },
            { name: 'Характеристики', href: '/admin/characteristics', icon: ListChecks, permission: 'catalog.manage' },
            { name: 'Стандарты', href: '/admin/standards', icon: ClipboardCheck, permission: 'catalog.manage' },
            { name: 'Диаметры', href: '/admin/diameters', icon: CircleDot, permission: 'catalog.manage' },
            { name: 'Резьбы', href: '/admin/threads', icon: Waypoints, permission: 'catalog.manage' },
            { name: 'Производители', href: '/admin/manufacturers', icon: Building2, permission: 'catalog.manage' },
            { name: 'Страны', href: '/admin/countries', icon: Globe, permission: 'catalog.manage' },
        ],
    },
    {
        title: 'Управление доступом',
        items: [
            { name: 'Пользователи', href: '/admin/users', icon: Users, permission: 'users.manage' },
        ],
    },
];

function canAccess(permission?: Permission): boolean {
    if (!permission) {
        return true;
    }

    return permissions.value.includes(permission);
}

const visibleGroups = computed<NavigationGroup[]>(() =>
    navigationGroups
        .map((group) => ({
            ...group,
            items: group.items.filter((item) => canAccess(item.permission)),
        }))
        .filter((group) => group.items.length > 0),
);

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

function closeSidebar(): void {
    emit('close');
}
</script>

<template>
    <div>
        <!-- Затемнение на мобильных устройствах -->
        <div
            v-if="open"
            class="fixed inset-0 z-40 bg-black/60 backdrop-blur-sm lg:hidden"
            aria-hidden="true"
            @click="closeSidebar"
        />

        <aside
            class="fixed inset-y-0 left-0 z-50 flex w-64 flex-col border-r border-sidebar-border bg-sidebar text-sidebar-foreground shadow-xl transition-transform duration-300 ease-out lg:translate-x-0"
            :class="open ? 'translate-x-0' : '-translate-x-full'"
        >
            <!-- Логотип -->
            <div
                class="flex h-16 shrink-0 items-center justify-between border-b border-sidebar-border px-5"
            >
                <Link
                    href="/admin"
                    class="flex min-w-0 items-center gap-3 rounded-md text-lg font-bold text-sidebar-foreground transition-opacity hover:opacity-80"
                    @click="closeSidebar"
                >
                    <div
                        class="flex size-9 shrink-0 items-center justify-center rounded-xl bg-primary text-primary-foreground shadow-sm"
                    >
                        <LayoutDashboard :size="19" />
                    </div>

                    <span>Гидровик</span>
                </Link>

                <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    aria-label="Закрыть меню"
                    class="shrink-0 text-sidebar-foreground/70 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground lg:hidden"
                    @click="closeSidebar"
                >
                    <X :size="20" />
                </Button>
            </div>

            <!-- Навигация -->
            <nav
                class="min-h-0 flex-1 overflow-y-auto p-3"
                aria-label="Основная навигация"
            >
                <div
                    v-for="group in visibleGroups"
                    :key="group.title"
                    class="mb-6 last:mb-2"
                >
                    <div
                        class="mb-2 px-3 text-xs font-semibold uppercase tracking-wider text-sidebar-foreground/60"
                    >
                        {{ group.title }}
                    </div>

                    <div class="space-y-1">
                        <Link
                            v-for="item in group.items"
                            :key="item.href"
                            :href="item.href"
                            class="group flex items-center gap-3 rounded-lg border px-3 py-2.5 text-sm font-medium transition-colors duration-150"
                            :class="
                                isActive(item)
                                    ? 'border-sidebar-border bg-sidebar-accent text-sidebar-accent-foreground shadow-sm'
                                    : 'border-transparent text-sidebar-foreground/80 hover:bg-sidebar-accent/70 hover:text-sidebar-accent-foreground'
                            "
                            :aria-current="isActive(item) ? 'page' : undefined"
                            @click="closeSidebar"
                        >
                            <component
                                :is="item.icon"
                                :size="18"
                                :stroke-width="1.9"
                                class="shrink-0 transition-colors"
                                :class="
                                    isActive(item)
                                        ? 'text-primary'
                                        : 'text-sidebar-foreground/60 group-hover:text-sidebar-accent-foreground'
                                "
                            />

                            <span class="min-w-0 flex-1 truncate">
                                {{ item.name }}
                            </span>

                            <span
                                v-if="isActive(item)"
                                class="size-1.5 shrink-0 rounded-full bg-primary"
                                aria-hidden="true"
                            />
                        </Link>
                    </div>
                </div>

                <!-- Раскрывающиеся настройки -->
                <div class="mb-2">
                    <div
                        class="mb-2 px-3 text-xs font-semibold uppercase tracking-wider text-sidebar-foreground/60"
                    >
                        Система
                    </div>

                    <button
                        type="button"
                        class="group flex w-full items-center gap-3 rounded-lg border px-3 py-2.5 text-left text-sm font-medium transition-colors duration-150"
                        :class="
                            isSettingsPage()
                                ? 'border-sidebar-border bg-sidebar-accent text-sidebar-accent-foreground'
                                : 'border-transparent text-sidebar-foreground/80 hover:bg-sidebar-accent/70 hover:text-sidebar-accent-foreground'
                        "
                        :aria-expanded="settingsOpen"
                        aria-controls="admin-settings-navigation"
                        @click="toggleSettings"
                    >
                        <Settings
                            :size="18"
                            :stroke-width="1.9"
                            class="shrink-0"
                            :class="
                                isSettingsPage()
                                    ? 'text-primary'
                                    : 'text-sidebar-foreground/60 group-hover:text-sidebar-accent-foreground'
                            "
                        />

                        <span class="min-w-0 flex-1">Настройки</span>

                        <ChevronDown
                            :size="16"
                            class="shrink-0 text-sidebar-foreground/60 transition-transform duration-200"
                            :class="{ 'rotate-180': settingsOpen }"
                        />
                    </button>

                    <div
                        v-if="settingsOpen"
                        id="admin-settings-navigation"
                        class="ml-5 mt-1 space-y-1 border-l border-sidebar-border pl-3"
                    >
                        <Link
                            v-for="item in settingsItems"
                            :key="item.href"
                            :href="item.href"
                            class="group flex items-center gap-3 rounded-lg border px-3 py-2.5 text-sm transition-colors duration-150"
                            :class="
                                isActive(item)
                                    ? 'border-sidebar-border bg-sidebar-accent text-sidebar-accent-foreground font-medium'
                                    : 'border-transparent text-sidebar-foreground/75 hover:bg-sidebar-accent/70 hover:text-sidebar-accent-foreground'
                            "
                            :aria-current="isActive(item) ? 'page' : undefined"
                            @click="closeSidebar"
                        >
                            <component
                                :is="item.icon"
                                :size="17"
                                :stroke-width="1.9"
                                class="shrink-0"
                                :class="
                                    isActive(item)
                                        ? 'text-primary'
                                        : 'text-sidebar-foreground/60 group-hover:text-sidebar-accent-foreground'
                                "
                            />

                            <span class="min-w-0 flex-1 truncate">
                                {{ item.name }}
                            </span>

                            <span
                                v-if="isActive(item)"
                                class="size-1.5 shrink-0 rounded-full bg-primary"
                                aria-hidden="true"
                            />
                        </Link>
                    </div>
                </div>
            </nav>

            <!-- Нижний блок -->
            <div class="shrink-0 border-t border-sidebar-border p-4">
                <div
                    class="rounded-xl border border-sidebar-border bg-sidebar-accent/50 p-3"
                >
                    <div class="flex items-center gap-3">
                        <div
                            class="flex size-10 shrink-0 items-center justify-center rounded-lg bg-sidebar-accent text-sidebar-accent-foreground"
                        >
                            <Building2 :size="19" />
                        </div>

                        <div class="min-w-0">
                            <div
                                class="truncate text-sm font-semibold text-sidebar-accent-foreground"
                            >
                                Большой склад
                            </div>

                            <div
                                class="mt-0.5 text-xs text-sidebar-foreground/60"
                            >
                                Панель управления
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </aside>
    </div>
</template>
