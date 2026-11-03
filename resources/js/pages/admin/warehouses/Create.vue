<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { toast } from 'vue-sonner';
import { Building2, LoaderCircle, Save } from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import StockField from '@/components/admin/stock/StockField.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { index, store } from '@/routes/admin/warehouses';

defineOptions({
    layout: AdminLayout,
});

const form = useForm({
    name: '',
});

const submit = (): void => {
    form.post(store.url(), {
        onSuccess: () => {
            toast.success('Склад успешно создан.');
        },
        onError: () => {
            toast.error('Проверьте правильность заполнения формы.');
        },
    });
};
</script>

<template>
    <Head title="Добавление склада" />

    <div class="mx-auto max-w-5xl space-y-6 pb-4">
        <StockPageHeader
            title="Новый склад"
            description="Создайте склад для организации стеллажей"
            :back-href="index.url()"
            back-label="К складам"
            :icon="Building2"
        />

        <div class="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_280px]">
            <form
                class="overflow-hidden rounded-2xl border bg-card shadow-sm"
                novalidate
                @submit.prevent="submit"
            >
                <div class="border-b px-6 py-5">
                    <h2 class="font-semibold">Основная информация</h2>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Укажите название склада
                    </p>
                </div>

                <div class="space-y-6 p-6">
                    <StockField
                        label="Название склада"
                        for-id="name"
                        required
                        :error="form.errors.name"
                        hint="Понятное название, которое будет отображаться в интерфейсе."
                    >
                        <Input
                            id="name"
                            v-model="form.name"
                            type="text"
                            autofocus
                            autocomplete="off"
                            placeholder="Например, Рукава"
                            class="h-11 rounded-xl"
                            :aria-invalid="!!form.errors.name"
                            :aria-describedby="form.errors.name ? 'name-error' : undefined"
                        />
                    </StockField>
                </div>

                <div
                    class="flex flex-col-reverse gap-3 border-t bg-muted/30 px-6 py-4 sm:flex-row sm:justify-end"
                >
                    <Button as-child variant="outline" :disabled="form.processing">
                        <Link :href="index.url()">Отмена</Link>
                    </Button>

                    <Button type="submit" :disabled="form.processing">
                        <LoaderCircle
                            v-if="form.processing"
                            :size="17"
                            class="mr-2 animate-spin"
                        />
                        <Save v-else :size="17" class="mr-2" />
                        {{ form.processing ? 'Сохранение...' : 'Создать склад' }}
                    </Button>
                </div>
            </form>

            <aside class="space-y-4 lg:sticky lg:top-6">
                <div>
                    <p
                        class="mb-2 text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                    >
                        Предпросмотр
                    </p>

                    <div class="rounded-2xl border bg-card p-5 shadow-sm">
                        <div class="flex items-start gap-3">
                            <div
                                class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary"
                            >
                                <Building2 :size="19" />
                            </div>
                            <div class="min-w-0">
                                <h3
                                    class="truncate font-bold"
                                    :class="form.name ? '' : 'text-muted-foreground/60'"
                                >
                                    {{ form.name || 'Название склада' }}
                                </h3>
                            </div>
                        </div>
                    </div>
                </div>
            </aside>
        </div>
    </div>
</template>
