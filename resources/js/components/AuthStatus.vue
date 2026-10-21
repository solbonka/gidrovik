<script setup lang="ts">
import { CircleCheck } from '@lucide/vue';

defineProps<{
    message: string;
}>();
</script>

<template>
    <div
        role="status"
        class="mb-4 flex items-start gap-2 rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-3.5 py-3 text-sm font-medium text-emerald-800 dark:text-emerald-300"
    >
        <CircleCheck :size="17" class="mt-0.5 shrink-0" />
        <span>{{ message }}</span>
    </div>
</template>
