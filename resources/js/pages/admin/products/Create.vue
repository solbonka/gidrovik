<script setup lang="ts">
import { Head } from '@inertiajs/vue3';
import { Package } from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ProductForm from '@/components/admin/products/ProductForm.vue';
import type { ProductFormOptions } from '@/components/admin/products/ProductForm.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import { index } from '@/routes/admin/products';

defineOptions({
    layout: AdminLayout,
});

defineProps<ProductFormOptions>();
</script>

<template>
    <Head title="Новый товар" />

    <div class="mx-auto max-w-5xl space-y-6 pb-4">
        <StockPageHeader
            title="Новый товар"
            description="Создание товара с характеристиками и параметрами подключения"
            :back-href="index().url"
            back-label="К товарам"
            :icon="Package"
        />

        <ProductForm
            mode="create"
            :cancel-href="index().url"
            :categories="categories"
            :standards="standards"
            :diameters="diameters"
            :threads="threads"
            :manufacturers="manufacturers"
            :countries="countries"
        />
    </div>
</template>
