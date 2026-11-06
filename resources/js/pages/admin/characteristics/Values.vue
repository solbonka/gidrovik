<script setup lang="ts">
import { Head, useForm } from '@inertiajs/vue3';
import { Info, Type } from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import CharacteristicForm from '@/components/admin/characteristics/CharacteristicForm.vue';
import { index, update } from '@/routes/admin/characteristics';

defineOptions({ layout: AdminLayout });

interface CharacteristicValue {
    id: number;
    value: string;
    sort_order: number;
}

interface Characteristic {
    id: number;
    name: string;
    slug: string;
    type: string;
    unit: string | null;
    is_active: boolean;
    values?: CharacteristicValue[] | null;
}

const props = defineProps<{ characteristic: Characteristic }>();

const form = useForm({
    name: props.characteristic.name,
    slug: props.characteristic.slug,
    type: props.characteristic.type,
    values: [...(props.characteristic.values ?? [])]
        .sort((a, b) => a.sort_order - b.sort_order)
        .map((v) => v.value),
    unit: props.characteristic.unit ?? '',
    is_active: props.characteristic.is_active,
});

const submit = (): void => {
    form.transform((data) => ({
        ...data,
        values: data.type === 'select' ? data.values.map((v) => v.trim()).filter(Boolean) : [],
    })).put(update(props.characteristic.id).url, { preserveScroll: true });
};
</script>

<template>
    <Head :title="`Редактирование: ${characteristic.name}`" />

    <div class="mx-auto max-w-5xl space-y-6 pb-4">
        <StockPageHeader
            :title="`Редактирование: ${characteristic.name}`"
            description="Измените параметры характеристики"
            :back-href="index.url()"
            back-label="К характеристикам"
            :icon="Type"
        />

        <CharacteristicForm :form="form" submit-label="Сохранить изменения" :cancel-href="index.url()" @submit="submit" />

        <div class="flex items-start gap-3 rounded-2xl border bg-muted/40 p-4">
            <Info :size="18" class="mt-0.5 shrink-0 text-primary" />
            <div>
                <p class="text-sm font-semibold">ID характеристики</p>
                <p class="mt-1 text-sm text-muted-foreground">#{{ characteristic.id }}</p>
            </div>
        </div>
    </div>
</template>
