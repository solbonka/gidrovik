<script setup lang="ts">
import { Loader2 } from '@lucide/vue'

interface Props {
    size?: number
    text?: string
}

withDefaults(defineProps<Props>(), {
    size: 24,
    text: '',
})
</script>

<template>
    <div class="flex flex-col items-center justify-center space-y-3">
        <Loader2
            :size="size"
            class="animate-spin text-gray-400"
        />
        <p
            v-if="text"
            class="text-sm text-gray-500"
        >
            {{ text }}
        </p>
    </div>
</template>
