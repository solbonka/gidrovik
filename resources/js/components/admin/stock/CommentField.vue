<script setup lang="ts">
import StockField from '@/components/admin/stock/StockField.vue';

withDefaults(
    defineProps<{
        id: string;
        label?: string;
        placeholder?: string;
        hint?: string;
        error?: string;
        required?: boolean;
        rows?: number;
        maxlength?: number;
    }>(),
    {
        label: 'Комментарий',
        rows: 3,
        maxlength: 5000,
    },
);

const model = defineModel<string>({ required: true });
</script>

<template>
    <StockField
        :label="label"
        :for-id="id"
        :required="required"
        :error="error"
        :hint="hint"
    >
        <textarea
            :id="id"
            v-model="model"
            :rows="rows"
            :maxlength="maxlength"
            :required="required"
            :placeholder="placeholder"
            :aria-invalid="!!error"
            :aria-describedby="error ? `${id}-error` : undefined"
            class="w-full resize-y rounded-xl border border-input bg-background px-3 py-2.5 text-sm shadow-xs outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30 aria-invalid:border-destructive aria-invalid:ring-destructive/20"
        />

        <template #footer>
            <p class="text-right text-xs text-muted-foreground tabular-nums">
                {{ model.length }}/{{ maxlength }}
            </p>
        </template>
    </StockField>
</template>
