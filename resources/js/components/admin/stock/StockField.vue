<script setup lang="ts">
import { Info } from '@lucide/vue';
import { Label } from '@/components/ui/label';

defineProps<{
    label: string;
    forId?: string;
    required?: boolean;
    error?: string;
    warning?: string;
    hint?: string;
}>();
</script>

<template>
    <div class="space-y-2">
        <Label :for="forId">
            {{ label }}
            <span v-if="required" class="text-destructive" aria-hidden="true">
                *
            </span>
        </Label>

        <slot />

        <p
            v-if="error"
            :id="forId ? `${forId}-error` : undefined"
            role="alert"
            class="flex items-start gap-1.5 text-sm text-destructive"
        >
            <Info :size="15" class="mt-0.5 shrink-0" />
            {{ error }}
        </p>

        <p
            v-else-if="warning"
            class="flex items-start gap-1.5 text-sm text-amber-700 dark:text-amber-400"
        >
            <Info :size="15" class="mt-0.5 shrink-0" />
            {{ warning }}
        </p>

        <p v-else-if="hint" class="text-xs text-muted-foreground">
            {{ hint }}
        </p>

        <slot name="footer" />
    </div>
</template>
