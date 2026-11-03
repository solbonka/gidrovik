<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import { computed, ref } from 'vue'
import { ArrowLeft, Check, ChevronsUpDown, CircleHelp, Hash, Loader2, Plus, Trash2, Type } from '@lucide/vue'

import AdminLayout from '@/layouts/AdminLayout.vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { create as createPage, store } from '@/routes/admin/custom-tables'

defineOptions({ layout: AdminLayout })

const name = ref('')
const slug = ref('')
const description = ref('')
const columns = ref<{ key: string; name: string; type: string }[]>([{ key: '', name: '', type: 'string' }])

const types = [
    { value: 'string', label: 'Строка', icon: Type },
    { value: 'text', label: 'Текст', icon: Type },
    { value: 'integer', label: 'Целое число', icon: Hash },
    { value: 'decimal', label: 'Число с запятой', icon: Hash },
    { value: 'boolean', label: 'Да/Нет', icon: Type },
    { value: 'date', label: 'Дата', icon: Type },
    { value: 'json', label: 'JSON', icon: Type },
]

const form = useForm({
    name: '',
    slug: '',
    description: '',
    columns: [] as Array<{ key: string; name: string; type: string }>,
})
const isProcessing = computed(() => form.processing)

function generateSlug() {
    slug.value = name.value
        .toLowerCase()
        .replace(/[^a-zа-яё0-9\s]/gi, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
}

function addColumn() {
    columns.value.push({ key: '', name: '', type: 'string' })
}

function removeColumn(index: number) {
    if (columns.value.length <= 1) return
    columns.value.splice(index, 1)
}

function moveColumn(index: number, direction: 'up' | 'down') {
    const newIndex = direction === 'up' ? index - 1 : index + 1
    if (newIndex < 0 || newIndex >= columns.value.length) return
    const temp = columns.value[index]
    columns.value[index] = columns.value[newIndex]
    columns.value[newIndex] = temp
}

function submit() {
    form.columns = columns.value.filter((c) => c.key.trim())
    form.name = name.value
    form.slug = slug.value
    form.description = description.value

    form.post(store().url, {
        preserveScroll: true,
        onError: () => {
            const firstErrorEl = document.querySelector('.form-error')
            if (firstErrorEl) {
                firstErrorEl.scrollIntoView({ behavior: 'smooth', block: 'center' })
            }
        },
    })
}

function getError(field: string): string {
    return (form.errors as Record<string, string>)[field] ?? ''
}

function getColumnError(index: number, key: string): string {
    const field = `columns.${index}.${key}`
    return (form.errors as Record<string, string>)[field] ?? ''
}

function getTypeInfo(type: string) {
    return types.find(t => t.value === type) || types[0]
}
</script>

<template>
    <Head title="Создать таблицу" />

    <div class="space-y-6 pb-4">
        <!-- Header -->
        <header class="flex items-center gap-4">
            <Link :href="route('admin.custom-tables.index')">
                <Button variant="ghost" size="icon" class="size-9">
                    <ArrowLeft :size="20" />
                </Button>
            </Link>
            <div>
                <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">Создать таблицу</h1>
                <p class="mt-1 text-sm text-muted-foreground">Новая пользовательская таблица данных</p>
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
                        <Label for="name">Название</Label>
                        <Input
                            id="name"
                            v-model="name"
                            @input="generateSlug"
                            placeholder="Например: Справочник производителей"
                            :class="getError('name') ? 'border-destructive' : ''"
                        />
                        <p v-if="getError('name')" class="form-error mt-1 text-xs text-destructive">{{ getError('name') }}</p>
                    </div>
                    <div>
                        <Label for="slug">Slug</Label>
                        <Input
                            id="slug"
                            v-model="slug"
                            placeholder="automatically-generated-slug"
                            :class="getError('slug') ? 'border-destructive' : ''"
                        />
                        <p v-if="getError('slug')" class="form-error mt-1 text-xs text-destructive">{{ getError('slug') }}</p>
                    </div>
                    <div>
                        <Label for="description">Описание</Label>
                        <Input
                            id="description"
                            v-model="description"
                            placeholder="Краткое описание назначения таблицы"
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
                        v-for="(column, index) in columns"
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
                                    :disabled="columns.length <= 1"
                                    @click="removeColumn(index)"
                                >
                                    <Trash2 :size="14" />
                                </Button>
                            </div>
                        </div>

                        <!-- Fields -->
                        <div class="space-y-3">
                            <div>
                                <Label :for="`col-key-${index}`">Ключ <span class="text-muted-foreground">(уникальный идентификатор)</span></Label>
                                <Input
                                    :id="`col-key-${index}`"
                                    v-model="column.key"
                                    placeholder="manufacturer_code"
                                    :class="getColumnError(index, 'key') ? 'border-destructive' : ''"
                                />
                                <p v-if="getColumnError(index, 'key')" class="form-error mt-1 text-xs text-destructive">
                                    {{ getColumnError(index, 'key') }}
                                </p>
                            </div>

                            <div>
                                <Label :for="`col-name-${index}`">Название <span class="text-muted-foreground">(для отображения)</span></Label>
                                <Input
                                    :id="`col-name-${index}`"
                                    v-model="column.name"
                                    placeholder="Код производителя"
                                    :class="getColumnError(index, 'name') ? 'border-destructive' : ''"
                                />
                                <p v-if="getColumnError(index, 'name')" class="form-error mt-1 text-xs text-destructive">
                                    {{ getColumnError(index, 'name') }}
                                </p>
                            </div>

                            <div>
                                <Label :for="`col-type-${index}`">Тип данных</Label>
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
                    <div v-if="columns.length === 0" class="rounded-xl border-2 border-dashed border-muted p-8 text-center">
                        <p class="text-sm text-muted-foreground">Нет колонок. Добавьте первую колонку.</p>
                    </div>
                </div>
            </div>

            <!-- Submit -->
            <div class="flex justify-end gap-3">
                <Link :href="route('admin.custom-tables.index')">
                    <Button variant="outline">Отмена</Button>
                </Link>
                <Button class="gap-2" :disabled="isProcessing" @click="submit">
                    <Loader2 v-if="isProcessing" :size="18" class="animate-spin" />
                    <Check v-else :size="18" />
                    Создать таблицу
                </Button>
            </div>
        </div>
    </div>
</template>
