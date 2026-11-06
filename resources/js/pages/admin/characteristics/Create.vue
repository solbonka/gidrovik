<script setup lang="ts">
import { Head, useForm } from '@inertiajs/vue3';
import { Info, Type } from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import CharacteristicForm from '@/components/admin/characteristics/CharacteristicForm.vue';
import { index, store } from '@/routes/admin/characteristics';

defineOptions({ layout: AdminLayout });

const form = useForm({
    name: '',
    slug: '',
    type: 'text',
    values: [] as string[],
    unit: '',
    is_active: true,
});

const submit = (): void => {
    form.transform((data) => ({
        ...data,
        values: data.type === 'select' ? data.values.map((v) => v.trim()).filter(Boolean) : [],
    })).post(store.url());
};
</script>

<template>
    <Head title="Добавление характеристики" />

    <div class="mx-auto max-w-5xl space-y-6 pb-4">
        <StockPageHeader
            title="Новая характеристика"
            description="Создайте параметр товара для категорий"
            :back-href="index.url()"
            back-label="К характеристикам"
            :icon="Type"
        />

        <CharacteristicForm :form="form" auto-slug submit-label="Создать характеристику" :cancel-href="index.url()" @submit="submit" />

        <div class="flex items-start gap-3 rounded-2xl border bg-muted/40 p-4">
            <Info :size="18" class="mt-0.5 shrink-0 text-primary" />
            <div>
                <p class="text-sm font-semibold">Что дальше?</p>
                <p class="mt-1 text-sm leading-relaxed text-muted-foreground">После создания вы сможете назначить эту характеристику категориям товаров.</p>
            </div>
        </div>
    </div>
</template>
