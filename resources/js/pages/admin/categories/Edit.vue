<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { computed } from 'vue';
import { toast } from 'vue-sonner';
import {
    FolderPen,
    Info,
    LoaderCircle,
    RotateCcw,
    Save,
    Settings2,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import StockField from '@/components/admin/stock/StockField.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { index, update } from '@/routes/admin/categories';

defineOptions({
    layout: AdminLayout,
});

interface Category {
    id: number;
    name: string;
    slug: string;
    is_active: boolean;
}

const props = defineProps<{
    category: Category;
}>();

const form = useForm({
    name: props.category.name,
    slug: props.category.slug,
    is_active: props.category.is_active,
});

const slugChanged = computed(() => form.slug !== props.category.slug);

const submit = (): void => {
    form.put(update.url(props.category.id), {
        onSuccess: () => {
            toast.success('Категория успешно обновлена.');
        },
        onError: () => {
            toast.error('Не удалось обновить категорию. Проверьте поля формы.');
        },
    });
};

const resetForm = (): void => {
    form.reset();
    form.clearErrors();
};
</script>

<template>
    <Head :title="`Редактирование: ${category.name}`" />

    <div class="mx-auto max-w-5xl space-y-6 pb-4">
        <StockPageHeader
            title="Редактирование категории"
            :description="`Изменение настроек категории «${category.name}»`"
            :back-href="index.url()"
            back-label="К категориям"
            :icon="FolderPen"
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
                        Обновите название, идентификатор и статус категории
                    </p>
                </div>

                <div class="space-y-6 p-6">
                    <StockField
                        label="Название категории"
                        for-id="name"
                        required
                        :error="form.errors.name"
                        hint="Название, которое отображается в интерфейсе склада."
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

                    <StockField
                        label="Slug"
                        for-id="slug"
                        required
                        :error="form.errors.slug"
                        :warning="
                            slugChanged
                                ? 'Вы меняете slug. Если он используется в коде или ссылках, они могут перестать работать.'
                                : undefined
                        "
                        hint="Системный идентификатор категории."
                    >
                        <Input
                            id="slug"
                            v-model="form.slug"
                            type="text"
                            autocomplete="off"
                            placeholder="rukava"
                            class="h-11 rounded-xl font-mono"
                            :aria-invalid="!!form.errors.slug"
                            :aria-describedby="form.errors.slug ? 'slug-error' : undefined"
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
                                Категория активна
                            </span>
                            <span class="mt-1 block text-sm leading-5 text-muted-foreground">
                                Статус определяет, доступна ли категория в
                                интерфейсе.
                            </span>
                        </span>
                    </label>
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
                            <dt class="text-muted-foreground">ID категории</dt>
                            <dd class="font-semibold tabular-nums">
                                #{{ category.id }}
                            </dd>
                        </div>

                        <div class="flex items-center justify-between gap-3">
                            <dt class="text-muted-foreground">Статус</dt>
                            <dd>
                                <span
                                    class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset"
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
                                    {{ form.is_active ? 'Активна' : 'Неактивна' }}
                                </span>
                            </dd>
                        </div>
                    </dl>

                    <Button
                        as-child
                        variant="outline"
                        class="mt-5 w-full justify-start"
                    >
                        <Link :href="`/admin/categories/${category.id}/characteristics`">
                            <Settings2 :size="16" class="mr-2" />
                            Характеристики категории
                        </Link>
                    </Button>
                </div>

                <div class="flex items-start gap-3 rounded-2xl border bg-muted/40 p-4">
                    <Info :size="18" class="mt-0.5 shrink-0 text-primary" />
                    <div>
                        <p class="text-sm font-semibold">Обратите внимание</p>
                        <p class="mt-1 text-sm leading-relaxed text-muted-foreground">
                            Изменение названия не меняет автоматически
                            характеристики и типы товаров этой категории.
                        </p>
                    </div>
                </div>
            </aside>
        </div>
    </div>
</template>
