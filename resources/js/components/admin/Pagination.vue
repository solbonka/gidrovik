<script setup lang="ts">
import { Link } from '@inertiajs/vue3';
import { computed } from 'vue';
import { ChevronLeft, ChevronRight } from '@lucide/vue';

export interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

const props = defineProps<{
    links: PaginationLink[];
    total?: number;
    from?: number | null;
    to?: number | null;
    currentPage?: number;
    lastPage?: number;
    noun?: string;
}>();

// Первая и последняя ссылки — «Назад» и «Далее», между ними номера страниц
const prev = computed(() => props.links[0] ?? null);
const next = computed(() => props.links[props.links.length - 1] ?? null);
const pages = computed(() => props.links.slice(1, -1));
const visible = computed(() => props.links.length > 3);

const summary = computed(() => {
    const noun = props.noun ? ` ${props.noun}` : '';

    if (props.from !== undefined && props.total !== undefined) {
        return `Показано ${props.from ?? 0}–${props.to ?? 0} из ${props.total}${noun}`;
    }

    if (props.currentPage && props.lastPage) {
        const total =
            props.total !== undefined ? ` · Всего: ${props.total}` : '';

        return `Страница ${props.currentPage} из ${props.lastPage}${total}`;
    }

    return '';
});

const base =
    'inline-flex h-9 min-w-9 items-center justify-center rounded-xl border px-3 text-sm font-medium transition';
const idle =
    'text-muted-foreground hover:border-primary/30 hover:text-primary';
const disabled =
    'cursor-not-allowed border-transparent text-muted-foreground/40';
</script>

<template>
    <div
        v-if="visible"
        class="flex flex-col gap-4 border-t px-5 py-4 sm:flex-row sm:items-center sm:justify-between"
    >
        <p class="text-sm text-muted-foreground">{{ summary }}</p>

        <nav
            class="flex flex-wrap items-center justify-center gap-1"
            aria-label="Навигация по страницам"
        >
            <Link
                v-if="prev?.url"
                :href="prev.url"
                preserve-scroll
                preserve-state
                :class="[base, 'gap-1', idle]"
            >
                <ChevronLeft :size="16" />
                Назад
            </Link>
            <span v-else :class="[base, 'gap-1', disabled]">
                <ChevronLeft :size="16" />
                Назад
            </span>

            <template
                v-for="(link, index) in pages"
                :key="`${index}-${link.label}`"
            >
                <Link
                    v-if="link.url"
                    :href="link.url"
                    preserve-scroll
                    preserve-state
                    :class="[
                        base,
                        link.active
                            ? 'border-primary bg-primary text-primary-foreground shadow-xs'
                            : idle,
                    ]"
                    :aria-current="link.active ? 'page' : undefined"
                >
                    {{ link.label }}
                </Link>
                <span
                    v-else
                    class="inline-flex h-9 min-w-9 items-center justify-center px-2 text-sm text-muted-foreground"
                >
                    {{ link.label }}
                </span>
            </template>

            <Link
                v-if="next?.url"
                :href="next.url"
                preserve-scroll
                preserve-state
                :class="[base, 'gap-1', idle]"
            >
                Далее
                <ChevronRight :size="16" />
            </Link>
            <span v-else :class="[base, 'gap-1', disabled]">
                Далее
                <ChevronRight :size="16" />
            </span>
        </nav>
    </div>
</template>
