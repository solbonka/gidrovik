<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { computed } from 'vue';
import { toast } from 'vue-sonner';
import {
    Building2,
    Info,
    LoaderCircle,
    RotateCcw,
    Save,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import StockField from '@/components/admin/stock/StockField.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { index, update } from '@/routes/admin/warehouses';

defineOptions({
    layout: AdminLayout,
});

interface Rack {
    id: number;
    code: string;
    name: string | null;
}

interface Warehouse {
    id: number;
    name: string;
    racks: Rack[];
}

const props = defineProps<{
    warehouse: Warehouse;
}>();

const form = useForm({
    name: props.warehouse.name,
});

const nameChanged = computed(() => form.name !== props.warehouse.name);

const submit = (): void => {
    form.put(update.url(props.warehouse.id), {
        onSuccess: () => {
            toast.success('Склад успешно обновлён.');
        },
        onError: () => {
            toast.error('Не удалось обновить склад. Проверьте поля формы.');
        },
    });
};

const resetForm = (): void => {
    form.reset();
    form.clearErrors();
};
</script>

<template>
    <Head :title="`Редактирование: ${warehouse.name}`" />

    <div class="mx-auto max-w-5xl space-y-6 pb-4">
        <StockPageHeader
            title="Редактирование склада"
            :description="`Изменение настроек склада «${warehouse.name}»`"
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
                        Обновите название склада
                    </p>
                </div>

                <div class="space-y-6 p-6">
                    <StockField
                        label="Название склада"
                        for-id="name"
                        required
                        :error="form.errors.name"
                        hint="Название, которое отображается в интерфейсе."
                    >
                        <Input
                            id="name"
                            v-model="form.name"
                            type="text"
                            autocomplete="off"
                            placeholder="Например, Рукава"
                            class="h-11 rounded-xl"
                            :aria-invalid="!!form.errors.name"
                            :aria-describedby="form.errors.name ? 'name-error' : undefined"
                        />
                    </StockField>
                </div>

                <div
                    class="flex flex-col-reverse gap-3 border-t bg-muted/30 px-6 py-4 sm:flex-row sm:items-center sm:justify-between"
                >
                    <Button
                        v-if="form.isDirty"
                        type="button"
                        variant="ghost"
                        class="text-muted-foreground"
                        :disabled="form.processing"
                        @click="resetForm"
                    >
                        <RotateCcw :size="15" class="mr-2" />
                        Вернуть как было
                    </Button>
                    <span v-else />

                    <div class="flex flex-col-reverse gap-3 sm:flex-row">
                        <Button as-child variant="outline" :disabled="form.processing">
                            <Link :href="index.url()">Отмена</Link>
                        </Button>

                        <Button
                            type="submit"
                            :disabled="form.processing || !form.isDirty"
                        >
                            <LoaderCircle
                                v-if="form.processing"
                                :size="17"
                                class="mr-2 animate-spin"
                            />
                            <Save v-else :size="17" class="mr-2" />
                            {{ form.processing ? 'Сохранение...' : 'Сохранить изменения' }}
                        </Button>
                    </div>
                </div>
            </form>

            <aside class="space-y-4 lg:sticky lg:top-6">
                <div class="rounded-2xl border bg-card p-5 shadow-sm">
                    <dl class="space-y-3 text-sm">
                        <div class="flex items-center justify-between gap-3">
                            <dt class="text-muted-foreground">ID склада</dt>
                            <dd class="font-semibold tabular-nums">
                                #{{ warehouse.id }}
                            </dd>
                        </div>

                        <div class="flex items-center justify-between gap-3">
                            <dt class="text-muted-foreground">Стеллажей</dt>
                            <dd class="font-semibold tabular-nums">
                                {{ warehouse.racks.length }}
                            </dd>
                        </div>
                    </dl>
                </div>

                <div class="flex items-start gap-3 rounded-2xl border bg-muted/40 p-4">
                    <Info :size="18" class="mt-0.5 shrink-0 text-primary" />
                    <div>
                        <p class="text-sm font-semibold">Обратите внимание</p>
                        <p class="mt-1 text-sm leading-relaxed text-muted-foreground">
                            Удаление склада невозможно, пока на нём есть стеллажи.
                        </p>
                    </div>
                </div>
            </aside>
        </div>
    </div>
</template>
