<script setup lang="ts">
import { Check } from '@lucide/vue';

interface SummaryRow {
    label: string;
    value?: string | null;
    tone?: 'default' | 'positive' | 'negative';
}

withDefaults(
    defineProps<{
        rows: SummaryRow[];
        tips?: string[];
        title?: string;
    }>(),
    { title: 'Сводка операции' },
);

const toneClass = {
    default: '',
    positive: 'text-emerald-600 dark:text-emerald-400',
    negative: 'text-rose-600 dark:text-rose-400',
};
</script>

<template>
    <div class="space-y-4">
        <div class="rounded-2xl border bg-card p-5 shadow-sm">
            <h2 class="font-semibold">{{ title }}</h2>

            <dl class="mt-4 space-y-3">
                <div
                    v-for="row in rows"
                    :key="row.label"
                    class="flex items-start justify-between gap-4 text-sm"
                >
                    <dt class="shrink-0 text-muted-foreground">
                        {{ row.label }}
                    </dt>
                    <dd
                        class="min-w-0 text-right font-medium break-words tabular-nums"
                        :class="
                            row.value
                                ? toneClass[row.tone ?? 'default']
                                : 'text-muted-foreground/60'
                        "
                    >
                        {{ row.value || '—' }}
                    </dd>
                </div>
            </dl>
        </div>

        <div
            v-if="tips?.length"
            class="rounded-2xl border bg-muted/40 p-5"
        >
            <h3 class="text-sm font-semibold">Полезно знать</h3>

            <ul class="mt-3 space-y-3 text-sm text-muted-foreground">
                <li
                    v-for="tip in tips"
                    :key="tip"
                    class="flex items-start gap-2.5"
                >
                    <Check :size="16" class="mt-0.5 shrink-0 text-primary" />
                    <span>{{ tip }}</span>
                </li>
            </ul>
        </div>
    </div>
</template>
