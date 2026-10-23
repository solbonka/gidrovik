<script setup lang="ts">
import { computed } from 'vue';
import StockField from '@/components/admin/stock/StockField.vue';
import { Input } from '@/components/ui/input';

const INTEGER_UNITS = ['шт.', 'упаковка', 'комплект'];

const props = withDefaults(
    defineProps<{
        id: string;
        unit?: string | null;
        label?: string;
        error?: string;
        warning?: string;
        required?: boolean;
    }>(),
    {
        label: 'Количество',
        required: true,
    },
);

const model = defineModel<string>({ required: true });

const isInteger = computed(() => INTEGER_UNITS.includes(props.unit ?? ''));
const step = computed(() => (isInteger.value ? '1' : '0.001'));
const min = computed(() => (isInteger.value ? '1' : '0.001'));

const fullLabel = computed(() =>
    props.unit ? `${props.label} (${props.unit})` : props.label,
);

const hint = computed(() => {
    if (!props.unit) return undefined;

    return isInteger.value
        ? 'Для этой единицы измерения допускаются только целые количества.'
        : 'Можно указать до трёх знаков после десятичного разделителя.';
});
</script>

<template>
    <StockField
        :label="fullLabel"
        :for-id="id"
        :required="required"
        :error="error"
        :warning="warning"
        :hint="hint"
    >
        <Input
            :id="id"
            v-model="model"
            type="number"
            inputmode="decimal"
            :min="min"
            max="999999999.999"
            :step="step"
            :required="required"
            class="h-11 rounded-xl"
            :aria-invalid="!!error"
            :aria-describedby="error ? `${id}-error` : undefined"
        />
    </StockField>
</template>
