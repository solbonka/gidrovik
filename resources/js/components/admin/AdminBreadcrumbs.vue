
<script setup lang="ts">
import { computed } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import { ChevronRight, House } from '@lucide/vue';

type Breadcrumb = {
    label: string;
    href?: string;
};

const page = usePage();

const breadcrumbs = computed<Breadcrumb[]>(() => {
    const path = page.url.split('?')[0].replace(/\/+$/, '') || '/';

    const pages: Record<string, Breadcrumb[]> = {
        '/settings/profile': [
            { label: 'Настройки' },
            { label: 'Профиль' },
        ],
        '/settings/security': [
            { label: 'Настройки' },
            { label: 'Безопасность' },
        ],
        '/settings/appearance': [
            { label: 'Настройки' },
            { label: 'Оформление' },
        ],
    };

    return pages[path] ?? [];
});
</script>

<template>
    <nav
        v-if="breadcrumbs.length"
        aria-label="Хлебные крошки"
        class="flex min-w-0 items-center gap-2 overflow-hidden text-sm"
    >
        <Link
            href="/dashboard"
            aria-label="Панель управления"
            class="flex shrink-0 items-center gap-2 text-muted-foreground transition-colors hover:text-foreground"
        >
            <House class="size-4" />
            <span class="hidden sm:inline">Панель управления</span>
        </Link>

        <template
            v-for="(breadcrumb, index) in breadcrumbs"
            :key="`${breadcrumb.label}-${index}`"
        >
            <ChevronRight
                class="size-4 shrink-0 text-muted-foreground/60"
                aria-hidden="true"
            />

            <Link
                v-if="breadcrumb.href"
                :href="breadcrumb.href"
                class="truncate text-muted-foreground transition-colors hover:text-foreground"
            >
                {{ breadcrumb.label }}
            </Link>

            <span
                v-else
                :aria-current="index === breadcrumbs.length - 1 ? 'page' : undefined"
                :class="[
                    'truncate',
                    index === breadcrumbs.length - 1
                        ? 'font-medium text-foreground'
                        : 'text-muted-foreground',
                ]"
            >
                {{ breadcrumb.label }}
            </span>
        </template>
    </nav>
</template>
