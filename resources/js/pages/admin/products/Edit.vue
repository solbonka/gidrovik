<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import { ArrowLeft, Package } from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import ProductForm from '@/components/admin/products/ProductForm.vue';
import type {
    ProductFormInitial,
    ProductFormOptions,
} from '@/components/admin/products/ProductForm.vue';
import { index } from '@/routes/admin/products';

defineOptions({
    layout: AdminLayout,
});

type Props = {
    product: ProductFormInitial & { id: number };
} & ProductFormOptions;

defineProps<Props>();
</script>

<template>
    <Head :title="`Редактирование: ${product.name}`" />

    <div class="mx-auto max-w-5xl space-y-6 pb-4">
        <header>
            <Link
                :href="index().url"
                class="mb-4 inline-flex items-center gap-2 text-sm font-medium text-muted-foreground transition-colors hover:text-primary"
            >
                <ArrowLeft :size="16" />
                К товарам
            </Link>

            <div class="flex items-start gap-4">
                <div
                    class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                >
                    <Package :size="24" />
                </div>

                <div class="min-w-0">
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Редактирование товара
                    </h1>
                    <p class="mt-1 text-sm break-words text-muted-foreground">
                        {{ product.name }}
                    </p>

                    <div class="mt-3 flex flex-wrap items-center gap-2">
                        <span
                            class="inline-flex rounded-md border bg-muted/50 px-2 py-1 font-mono text-xs"
                        >
                            {{ product.sku }}
                        </span>

                        <span
                            class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset"
                            :class="
                                product.is_active
                                    ? 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400'
                                    : 'bg-muted text-muted-foreground ring-border'
                            "
                        >
                            <span
                                class="size-1.5 rounded-full"
                                :class="
                                    product.is_active
                                        ? 'bg-emerald-500'
                                        : 'bg-muted-foreground/50'
                                "
                            />
                            {{ product.is_active ? 'Активен' : 'Неактивен' }}
                        </span>
                    </div>
                </div>
            </div>
        </header>

        <ProductForm
            mode="edit"
            :product-id="product.id"
            :initial="product"
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
