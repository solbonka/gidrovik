<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';

import {
    ArrowLeft,
    Check,
    Loader2,
    Type,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { Button } from '@/components/ui/button';
import { store as createEntryStore } from '@/routes/admin/custom-tables/entries';
import { update as updateEntry } from '@/routes/admin/custom-tables/entries';

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
        columns: Column[];
    };
    entry?: {
        id: number;
        data: Record<string, unknown>;
    };
    mode: 'create' | 'edit';
}

const props = defineProps<Props>();

const isEdit = props.mode === 'edit';

const initialData: Record<string, string | number | boolean> = {};
for (const col of props.table.columns) {
    if (col.type === 'boolean') {
        initialData[col.key] = false;
    } else {
        initialData[col.key] = '';
    }
}

if (isEdit && props.entry?.data) {
    for (const col of props.table.columns) {
        const val = props.entry.data[col.key];
        if (col.type === 'boolean') {
            initialData[col.key] = !!val;
        } else {
            // Handle null, undefined, and empty values
            if (val === null || val === undefined || val === '') {
                initialData[col.key] = '';
            } else {
                initialData[col.key] = String(val);
            }
        }
    }
}

const formData = ref(initialData);
const formErrors = ref<Record<string, string>>({});

function setErrors(errors: Record<string, string>) {
    formErrors.value = errors;
}

const formatFieldLabel = (col: Column): string => {
    return col.name || col.key;
};

function prepareDataForSubmit(data: Record<string, string | number | boolean>): Record<string, string | number | boolean | null> {
    const prepared: Record<string, string | number | boolean | null> = {};
    for (const [key, value] of Object.entries(data)) {
        prepared[key] = value === '' ? null : value;
    }
    return prepared;
}

function submit() {
    const payload = prepareDataForSubmit(formData.value);

    if (isEdit) {
        router.post(
            updateEntry.url({ custom_table: props.table.id, entry: props.entry!.id }),
            { data: payload, _method: 'PUT' },
            {
                preserveScroll: true,
                onError: (errors) => {
                    // Strip 'data.' prefix for matching
                    const stripped: Record<string, string> = {};
                    for (const [key, msg] of Object.entries(errors)) {
                        stripped[key.replace(/^data\./, '')] = msg;
                    }
                    formErrors.value = stripped;
                },
            },
        );
    } else {
        router.post(
            createEntryStore.url({ custom_table: props.table.id }),
            { data: payload },
            {
                preserveScroll: true,
                onError: (errors) => {
                    const stripped: Record<string, string> = {};
                    for (const [key, msg] of Object.entries(errors)) {
                        stripped[key.replace(/^data\./, '')] = msg;
                    }
                    formErrors.value = stripped;
                },
            },
        );
    }
}

function getError(col: Column): string {
    return formErrors.value[col.key] ?? '';
}
</script>

<template>
    <Head :title="isEdit ? 'Редактировать запись' : 'Добавить запись'" />

    <div class="space-y-6 pb-4">
        <!-- Header -->
        <header class="flex items-center gap-4">
            <Link :href="route('admin.custom-tables.show', { custom_table: table.id })">
                <Button variant="ghost" size="icon" class="size-9">
                    <ArrowLeft :size="20" />
                </Button>
            </Link>
            <div>
                <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                    {{ isEdit ? 'Редактировать запись' : 'Добавить запись' }}
                </h1>
                <p class="mt-1 text-sm text-muted-foreground">{{ table.name }}</p>
            </div>
        </header>

        <div class="mx-auto max-w-2xl space-y-6">
            <div class="overflow-hidden rounded-2xl border bg-card shadow-sm">
                <div class="border-b px-6 py-4">
                    <h2 class="font-semibold">Данные записи</h2>
                </div>

                <form @submit.prevent="submit" class="space-y-5 p-6">
                    <div
                        v-for="col in table.columns"
                        :key="col.key"
                        class="space-y-2"
                    >
                        <label class="flex items-center gap-2 text-sm font-medium">
                            <Type v-if="col.type === 'string' || col.type === 'text'" :size="14" />
                            {{ formatFieldLabel(col) }}
                            <span class="text-xs text-muted-foreground">({{ col.type }})</span>
                        </label>

                        <div class="relative">
                            <!-- Boolean -->
                            <input
                                v-if="col.type === 'boolean'"
                                type="checkbox"
                                :checked="!!formData[col.key]"
                                @change="formData[col.key] = ($event.target as HTMLInputElement).checked"
                                class="rounded-lg border border-input bg-background text-primary shadow-sm outline-none transition focus-visible:ring-[3px] focus-visible:ring-ring/30"
                            />

                            <!-- Text area -->
                            <textarea
                                v-else-if="col.type === 'text'"
                                rows="3"
                                :value="formData[col.key] as string"
                                class="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm shadow-sm outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                                :placeholder="formatFieldLabel(col)"
                                @input="formData[col.key] = ($event.target as HTMLTextAreaElement).value"
                            />

                            <!-- Integer -->
                            <input
                                v-else-if="col.type === 'integer'"
                                type="number"
                                step="1"
                                :value="formData[col.key]"
                                class="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm shadow-sm outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                                :placeholder="formatFieldLabel(col)"
                                @input="formData[col.key] = ($event.target as HTMLInputElement).value"
                            />

                            <!-- Decimal -->
                            <input
                                v-else-if="col.type === 'decimal'"
                                type="number"
                                step="0.01"
                                :value="formData[col.key]"
                                class="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm shadow-sm outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                                :placeholder="formatFieldLabel(col)"
                                @input="formData[col.key] = ($event.target as HTMLInputElement).value"
                            />

                            <!-- Date -->
                            <input
                                v-else-if="col.type === 'date'"
                                type="date"
                                :value="formData[col.key] as string"
                                class="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm shadow-sm outline-none transition focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                                @input="formData[col.key] = ($event.target as HTMLInputElement).value"
                            />

                            <!-- String / JSON / default -->
                            <input
                                v-else
                                type="text"
                                :value="formData[col.key] as string"
                                class="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm shadow-sm outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                                :placeholder="formatFieldLabel(col)"
                                @input="formData[col.key] = ($event.target as HTMLInputElement).value"
                            />

                            <!-- Error -->
                            <p v-if="getError(col)" class="mt-1 text-xs text-destructive">
                                {{ getError(col) }}
                            </p>
                        </div>
                    </div>

                    <div class="flex justify-end gap-3 pt-4">
                        <Link :href="route('admin.custom-tables.show', { custom_table: table.id })">
                            <Button variant="outline" type="button">Отмена</Button>
                        </Link>
                        <Button class="gap-2" type="submit">
                            <Check :size="18" />
                            {{ isEdit ? 'Сохранить изменения' : 'Добавить запись' }}
                        </Button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>
