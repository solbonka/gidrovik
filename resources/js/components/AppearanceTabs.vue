
<script setup lang="ts">
import { Monitor, Moon, Sun } from '@lucide/vue';
import { useAppearance } from '@/composables/useAppearance';

const { appearance, updateAppearance } = useAppearance();

const tabs = [
    { value: 'light', Icon: Sun, label: 'Светлая' },
    { value: 'dark', Icon: Moon, label: 'Тёмная' },
    { value: 'system', Icon: Monitor, label: 'Системная' },
] as const;
</script>

<template>
    <div
        class="inline-flex max-w-full flex-wrap gap-1 rounded-xl border border-border bg-muted p-1"
        role="group"
        aria-label="Тема оформления"
    >
        <button
            v-for="{ value, Icon, label } in tabs"
            :key="value"
            type="button"
            :aria-pressed="appearance === value"
            @click="updateAppearance(value)"
            :class="[
                'inline-flex items-center justify-center gap-2 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background',
                appearance === value
                    ? 'border border-border bg-card text-foreground shadow-sm'
                    : 'border border-transparent text-muted-foreground hover:bg-accent hover:text-accent-foreground',
            ]"
        >
            <component :is="Icon" class="size-4 shrink-0" />
            <span>{{ label }}</span>
        </button>
    </div>
</template>
