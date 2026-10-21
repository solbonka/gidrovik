<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { ref, watch } from 'vue';
import { toast } from 'vue-sonner';
import { Hash, Info, LoaderCircle, Save } from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import StockField from '@/components/admin/stock/StockField.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { index, store } from '@/routes/admin/standards';

defineOptions({
    layout: AdminLayout,
});

const form = useForm({
    code: '',
    name: '',
    is_active: true,
});

const submit = (): void => {
    form.post(store().url, {
        onSuccess: () => {
            toast.success('Стандарт успешно создан.');
        },
        onError: () => {
            toast.error('Проверьте правильность заполнения формы.');
        },
    });
};
</script>

<template>
    <Head title="Добавление стандарта" />

    <div class="mx-auto max-w-5xl space-y-6 pb-4">
        <StockPageHeader
            title="Новый стандарт"
            description="Создайте стандарт соединения для справочника"
            :back-href="index().url"
            back-label="К стандартам"
            :icon="Hash"
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
                        Укажите код и название стандарта
                    </p>
                </div>

                <div class="space-y-6 p-6">
                    <StockField
                        label="Код стандарта"
                        for-id="code"
                        required
                        :error="form.errors.code"
                        hint="Например: BSP, JIC, DK, DKOL, ALI, ARI, ORFS."
                    >
                        <Input
                            id="code"
                            v-model="form.code"
                            type="text"
                            maxlength="50"
                            autofocus
                            autocomplete="off"
                            placeholder="BSP"
                            class="h-11 rounded-xl font-mono"
                            :aria-invalid="!!form.errors.code"
                            :aria-describedby="form.errors.code ? 'code-error' : undefined"
                        />
                    </StockField>

                    <StockField
                        label="Название"
                        for-id="name"
                        required
                        :error="form.errors.name"
                        hint="Полное название стандарта на русском языке."
                    >
                        <Input
                            id="name"
                            v-model="form.name"
                            type="text"
                            maxlength="255"
                            autocomplete="off"
                            placeholder="British Standard Pipe"
                            class="h-11 rounded-xl"
                            :aria-invalid="!!form.errors.name"
                            :aria-describedby="form.errors.name ? 'name-error' : undefined"
                        />
                    </StockField>

                    <label
                        class="flex cursor-pointer items-start gap-3 rounded-xl border bg-muted/40 p-4"
                    >
                        <input
                            v-model="form.is_active"
                            type="checkbox"
                            class="mt-0.5 size-4 rounded border-input accent-primary"
                        />
                        <span>
                            <span class="block text-sm font-semibold">
                                Стандарт активен
                            </span>
                            <span class="mt-1 block text-sm leading-5 text-muted-foreground">
                                Активный стандарт доступен при работе с
                                товарами.
                            </span>
                        </span>
                    </label>
                </div>

                <div
                    class="flex flex-col-reverse gap-3 border-t bg-muted/30 px-6 py-4 sm:flex-row sm:justify-end"
                >
                    <Button as-child variant="outline" :disabled="form.processing">
                        <Link :href="index().url">Отмена</Link>
                    </Button>

                    <Button type="submit" :disabled="form.processing">
                        <LoaderCircle
                            v-if="form.processing"
                            :size="17"
                            class="mr-2 animate-spin"
                        />
                        <Save v-else :size="17" class="mr-2" />
                        {{ form.processing ? 'Сохранение...' : 'Создать стандарт' }}
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
                        <div class="flex items-start justify-between gap-3">
                            <div class="min-w-0">
                                <h3
                                    class="truncate font-bold"
                                    :class="form.name ? '' : 'text-muted-foreground/60'"
                                >
                                    {{ form.name || 'Название стандарта' }}
                                </h3>
                                <p
                                    class="mt-0.5 truncate font-mono text-xs"
                                    :class="form.code ? 'text-muted-foreground' : 'text-muted-foreground/60'"
                                >
                                    {{ form.code || 'CODE' }}
                                </p>
                            </div>

                            <span
                                class="inline-flex shrink-0 items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset"
                                :class="
                                    form.is_active
                                        ? 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400'
                                        : 'bg-muted text-muted-foreground ring-border'
                                "
                            >
                                <span
                                    class="size-1.5 rounded-full"
                                    :class="form.is_active ? 'bg-emerald-500' : 'bg-muted-foreground/50'"
                                />
                                {{ form.is_active ? 'Активен' : 'Неактивен' }}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="flex items-start gap-3 rounded-2xl border bg-muted/40 p-4">
                    <Info :size="18" class="mt-0.5 shrink-0 text-primary" />
                    <div>
                        <p class="text-sm font-semibold">Что дальше?</p>
                        <p class="mt-1 text-sm leading-relaxed text-muted-foreground">
                            После создания вы сможете связать стандарт с
                            диаметрами и резьбами.
                        </p>
                    </div>
                </div>
            </aside>
        </div>
    </div>
</template>
