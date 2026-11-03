<script setup lang="ts">
import { Head, Link, router, useForm } from '@inertiajs/vue3';

import { ref } from 'vue';
import {
    ArrowLeft,
    Check,
    ChevronsUpDown,
    CircleHelp,
    Hash,
    Loader2,
    Plus,
    Trash2,
    Type,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { Button } from '@/components/ui/button';
import { update } from '@/routes/admin/custom-tables';

defineOptions({
    layout: AdminLayout,
});

interface Column {
    key: string;
    name: string;
    type: string;
}

interface Props {
    table: {
        id: number;
        name: string;
        slug: string;
        description: string | null;
        columns: Column[];
    };
}

const props = defineProps<Props>();

const form = useForm({
    name: props.table.name,
    slug: props.table.slug,
    description: props.table.description ?? '',
    columns: [...props.table.columns],
});

const types = [
    { value: 'string', label: 'Строка', icon: Type },
    { value: 'text', label: 'Текст', icon: Type },
    { value: 'integer', label: 'Целое число', icon: Hash },
    { value: 'decimal', label: 'Число с запятой', icon: Hash },
    { value: 'boolean', label: 'Да/Нет', icon: Type },
    { value: 'date', label: 'Дата', icon: Type },
    { value: 'json', label: 'JSON', icon: Type },
];

function generateSlug() {
    form.slug = form.name
        .toLowerCase()
        .replace(/[^a-zа-яё0-9\s]/gi, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-');
}

function addColumn() {
    form.columns.push({ key: '', name: '', type: 'string' });
}

function removeColumn(index: number) {
    if (form.columns.length <= 1) return;
    form.columns.splice(index, 1);
}

function moveColumn(index: number, direction: 'up' | 'down') {
    const newIndex = direction === 'up' ? index - 1 : index + 1
    if (newIndex < 0 || newIndex >= form.columns.length) return
    const temp = form.columns[index]
    form.columns[index] = form.columns[newIndex]
    form.columns[newIndex] = temp
}

function submit() {
    const filteredColumns = form.columns.filter((c) => c.key.trim());

    if (filteredColumns.length === 0) {
        return;
    }

    form.put(update.url(props.table.id), {
        preserveScroll: true,
    });
}

const typeBadge = (type: string): string => {
    const styles: Record<string, string> = {
        string: 'bg-blue-500/10 text-blue-700 ring-blue-600/20 dark:text-blue-400',
        integer: 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400',
        decimal: 'bg-violet-500/10 text-violet-700 ring-violet-600/20 dark:text-violet-400',
        boolean: 'bg-amber-500/10 text-amber-700 ring-amber-600/20 dark:text-amber-400',
        date: 'bg-sky-500/10 text-sky-700 ring-sky-600/20 dark:text-sky-400',
        text: 'bg-slate-500/10 text-slate-700 ring-slate-600/20 dark:text-slate-400',
        json: 'bg-rose-500/10 text-rose-700 ring-rose-600/20 dark:text-rose-400',
    };

    return styles[type] ?? 'bg-muted text-muted-foreground ring-border';
};

const typeLabel = (type: string): string => {
    const labels: Record<string, string> = {
        string: 'Строка',
        integer: 'Целое',
        decimal: 'Число',
        boolean: 'Булево',
        date: 'Дата',
        text: 'Текст',
        json: 'JSON',
    };

    return labels[type] ?? type;
};

function getTypeInfo(type: string) {
    return types.find(t => t.value === type) || types[0]
}
</script>

<template>
    <Head title="Редактировать таблицу" />

    <div class="space-y-6 pb-4">
        <!-- Header -->
        <header class="flex items-center gap-4">
            <Link :href="route('admin.custom-tables.show', { custom_table: table.id })">
                <Button variant="ghost" size="icon" class="size-9">
                    <ArrowLeft :size="20" />
                </Button>
            </Link>
            <div>
                <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">Редактировать таблицу</h1>
                <p class="mt-1 text-sm text-muted-foreground">{{ table.name }}</p>
            </div>
        </header>

        <div class="mx-auto max-w-3xl space-y-6">
            <!-- Basic info -->
            <div class="overflow-hidden rounded-2xl border bg-card shadow-sm">
                <div class="border-b px-6 py-4">
                    <h2 class="font-semibold">Основная информация</h2>
                </div>
                <div class="space-y-4 p-6">
                    <div>
                        <label for="name" class="mb-2 block text-sm font-medium">Название</label>
                        <input
                            id="name"
                            v-model="form.name"
                            @input="generateSlug"
                            placeholder="Например: Справочник производителей"
                            class="w-full rounded-xl border border-input bg-background px-4 py-3 text-sm shadow-sm outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                        />
                    </div>
                    <div>
                        <label for="slug" class="mb-2 block text-sm font-medium">Slug</label>
                        <input
                            id="slug"
                            v-model="form.slug"
                            placeholder="automatically-generated-slug"
                            class="w-full rounded-xl border border-input bg-background px-4 py-3 text-sm shadow-sm outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                        />
                    </div>
                    <div>
                        <label for="description" class="mb-2 block text-sm font-medium">Описание</label>
                        <input
                            id="description"
                            v-model="form.description"
                            placeholder="Краткое описание назначения таблицы"
                            class="w-full rounded-xl border border-input bg-background px-4 py-3 text-sm shadow-sm outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                        />
                    </div>
                </div>
            </div>

            <!-- Columns -->
            <div class="overflow-hidden rounded-2xl border bg-card shadow-sm">
                <div class="flex items-center justify-between border-b px-6 py-4">
                    <h2 class="font-semibold">Колонки</h2>
                    <Button variant="outline" size="sm" class="gap-1.5" @click="addColumn">
                        <Plus :size="16" />
                        Добавить колонку
                    </Button>
                </div>
                <div class="space-y-4 p-6">
                    <div
                        v-for="(column, index) in form.columns"
                        :key="index"
                        class="group relative rounded-xl border border-input bg-background p-4 shadow-sm transition-all hover:border-primary/50 hover:shadow-md"
                    >
                        <!-- Column header -->
                        <div class="mb-3 flex items-center justify-between">
                            <span class="text-xs font-medium text-muted-foreground">Колонка {{ index + 1 }}</span>
                            <div class="flex items-center gap-1">
                                <Button
                                    variant="ghost"
                                    size="icon"
                                    class="size-7 text-muted-foreground hover:text-foreground"
                                    :disabled="index === 0"
                                    @click="moveColumn(index, 'up')"
                                >
                                    <ChevronsUpDown :size="14" />
                                </Button>
                                <Button
                                    variant="ghost"
                                    size="icon"
                                    class="size-7 text-destructive hover:bg-destructive/10"
                                    :disabled="form.columns.length <= 1"
                                    @click="removeColumn(index)"
                                >
                                    <Trash2 :size="14" />
                                </Button>
                            </div>
                        </div>

                        <!-- Fields -->
                        <div class="space-y-3">
                            <div>
                                <label :for="`col-key-${index}`" class="mb-2 block text-xs font-medium text-muted-foreground">
                                    Ключ <span class="text-muted-foreground">(уникальный идентификатор)</span>
                                </label>
                                <input
                                    :id="`col-key-${index}`"
                                    v-model="column.key"
                                    placeholder="manufacturer_code"
                                    class="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm shadow-sm outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                                />
                            </div>

                            <div>
                                <label :for="`col-name-${index}`" class="mb-2 block text-xs font-medium text-muted-foreground">
                                    Название <span class="text-muted-foreground">(для отображения)</span>
                                </label>
                                <input
                                    :id="`col-name-${index}`"
                                    v-model="column.name"
                                    placeholder="Код производителя"
                                    class="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm shadow-sm outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                                />
                            </div>

                            <div>
                                <label :for="`col-type-${index}`" class="mb-2 block text-xs font-medium text-muted-foreground">
                                    Тип данных
                                </label>
                                <select
                                    :id="`col-type-${index}`"
                                    v-model="column.type"
                                    class="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm shadow-sm outline-none transition focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                                >
                                    <option v-for="t in types" :key="t.value" :value="t.value">{{ t.label }}</option>
                                </select>
                                <p class="mt-1 text-xs text-muted-foreground">
                                    <CircleHelp :size="12" class="inline mr-1" />
                                    {{ getTypeInfo(column.type).label }}
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Empty state -->
                    <div v-if="form.columns.length === 0" class="rounded-xl border-2 border-dashed border-muted p-8 text-center">
                        <p class="text-sm text-muted-foreground">Нет колонок. Добавьте первую колонку.</p>
                    </div>
                </div>
            </div>

            <!-- Submit -->
            <div class="flex justify-end gap-3">
                <Link :href="route('admin.custom-tables.show', { custom_table: table.id })">
                    <Button variant="outline">Отмена</Button>
                </Link>
                <Button class="gap-2" :disabled="form.processing" @click="submit">
                    <Loader2 v-if="form.processing" :size="18" class="animate-spin" />
                    <Check v-else :size="18" />
                    Сохранить изменения
                </Button>
            </div>
        </div>
    </div>
</template>
