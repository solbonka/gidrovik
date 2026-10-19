
<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import { toast } from 'vue-sonner'
import {
    ArrowLeft,
    FolderPen,
    Tag,
    Hash,
    CheckCircle2,
    Save,
    X,
    Info,
    RotateCcw,
} from '@lucide/vue'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { index, update } from '@/routes/admin/categories'

defineOptions({
    layout: AdminLayout,
})

interface Category {
    id: number
    name: string
    slug: string
    is_active: boolean
}

const props = defineProps<{
    category: Category
}>()

const form = useForm({
    name: props.category.name,
    slug: props.category.slug,
    is_active: props.category.is_active,
})

const submit = (): void => {
    form.put(update.url(props.category.id), {
        onSuccess: () => {
            toast.success('Категория успешно обновлена.')
        },
        onError: () => {
            toast.error('Не удалось обновить категорию. Проверьте поля формы.')
        },
    })
}

const resetForm = (): void => {
    form.name = props.category.name
    form.slug = props.category.slug
    form.is_active = props.category.is_active
    form.clearErrors()
}
</script>

<template>
    <Head :title="`Редактирование: ${category.name}`" />

    <div class="mx-auto max-w-3xl space-y-6 pb-8">
        <!-- Шапка -->
        <div
            class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-slate-800 to-indigo-950 px-5 py-6 shadow-lg sm:px-8 sm:py-8"
        >
            <div
                class="pointer-events-none absolute -right-12 -top-16 h-56 w-56 rounded-full bg-indigo-500/20 blur-3xl"
            />

            <div
                class="relative flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between"
            >
                <div class="flex items-start gap-4">
                    <div
                        class="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl border border-white/10 bg-white/10 text-white sm:h-14 sm:w-14"
                    >
                        <FolderPen :size="27" />
                    </div>

                    <div class="min-w-0">
                        <div
                            class="mb-1 flex flex-wrap items-center gap-2 text-xs font-medium text-slate-300"
                        >
                            <span>Склад</span>
                            <span class="text-slate-500">/</span>

                            <Link
                                :href="index.url()"
                                class="transition hover:text-white"
                            >
                                Категории
                            </Link>

                            <span class="text-slate-500">/</span>
                            <span class="text-white/90">Редактирование</span>
                        </div>

                        <h1
                            class="break-words text-2xl font-bold tracking-tight text-white sm:text-3xl"
                        >
                            Редактирование категории
                        </h1>

                        <p class="mt-2 text-sm leading-6 text-slate-300">
                            Изменение настроек категории
                            <span class="font-semibold text-white">
                                {{ category.name }}
                            </span>
                        </p>
                    </div>
                </div>

                <Link
                    :href="index.url()"
                    class="inline-flex min-h-10 items-center justify-center gap-2 self-start rounded-xl border border-white/15 bg-white/10 px-4 py-2 text-sm font-medium text-white transition hover:bg-white/15 focus:outline-none focus:ring-2 focus:ring-white/50 sm:self-center"
                >
                    <ArrowLeft :size="16" />
                    К категориям
                </Link>
            </div>
        </div>

        <!-- Информация о категории -->
        <div
            class="grid grid-cols-1 gap-4 sm:grid-cols-2"
        >
            <div
                class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-700 dark:bg-slate-900"
            >
                <div
                    class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400"
                >
                    <Tag :size="20" />
                </div>

                <div class="min-w-0">
                    <p class="text-xs font-medium text-slate-500 dark:text-slate-400">
                        ID категории
                    </p>
                    <p class="mt-1 text-lg font-bold text-slate-900 dark:text-white">
                        #{{ category.id }}
                    </p>
                </div>
            </div>

            <div
                class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white p-4 shadow-sm dark:border-slate-700 dark:bg-slate-900"
            >
                <div
                    class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl"
                    :class="
                        form.is_active
                            ? 'bg-emerald-50 text-emerald-600 dark:bg-emerald-500/10 dark:text-emerald-400'
                            : 'bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400'
                    "
                >
                    <CheckCircle2 :size="20" />
                </div>

                <div class="min-w-0">
                    <p class="text-xs font-medium text-slate-500 dark:text-slate-400">
                        Текущий статус
                    </p>

                    <p
                        class="mt-1 text-sm font-semibold"
                        :class="
                            form.is_active
                                ? 'text-emerald-700 dark:text-emerald-400'
                                : 'text-slate-600 dark:text-slate-300'
                        "
                    >
                        {{ form.is_active ? 'Активна' : 'Неактивна' }}
                    </p>
                </div>
            </div>
        </div>

        <!-- Форма редактирования -->
        <form
            class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-700 dark:bg-slate-900"
            @submit.prevent="submit"
        >
            <div
                class="flex items-center gap-3 border-b border-slate-200 px-5 py-5 dark:border-slate-700 sm:px-7"
            >
                <div
                    class="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400"
                >
                    <FolderPen :size="20" />
                </div>

                <div>
                    <h2 class="text-base font-semibold text-slate-900 dark:text-white">
                        Основная информация
                    </h2>
                    <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
                        Обновите название, идентификатор и статус категории.
                    </p>
                </div>
            </div>

            <div class="space-y-6 p-5 sm:p-7">
                <!-- Название -->
                <div>
                    <label
                        for="name"
                        class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                    >
                        Название категории
                        <span class="text-red-500">*</span>
                    </label>

                    <div class="relative">
                        <Tag
                            :size="18"
                            class="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400"
                        />

                        <input
                            id="name"
                            v-model="form.name"
                            type="text"
                            autocomplete="off"
                            placeholder="Например, Рукава"
                            :aria-invalid="!!form.errors.name"
                            class="w-full rounded-xl border bg-slate-50 py-3 pl-11 pr-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-800 dark:text-white dark:focus:bg-slate-800"
                            :class="
                                form.errors.name
                                    ? 'border-red-400 focus:border-red-400 focus:ring-red-500/10 dark:border-red-500'
                                    : 'border-slate-200 focus:border-indigo-400 focus:ring-indigo-500/10 dark:border-slate-700 dark:focus:border-indigo-500'
                            "
                        />
                    </div>

                    <p
                        v-if="form.errors.name"
                        class="mt-2 flex items-start gap-1.5 text-sm text-red-600 dark:text-red-400"
                    >
                        <Info :size="15" class="mt-0.5 shrink-0" />
                        {{ form.errors.name }}
                    </p>

                    <p
                        v-else
                        class="mt-2 text-xs text-slate-500 dark:text-slate-400"
                    >
                        Название, которое отображается в интерфейсе склада.
                    </p>
                </div>

                <!-- Slug -->
                <div>
                    <label
                        for="slug"
                        class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                    >
                        Slug
                        <span class="text-red-500">*</span>
                    </label>

                    <div class="relative">
                        <Hash
                            :size="18"
                            class="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400"
                        />

                        <input
                            id="slug"
                            v-model="form.slug"
                            type="text"
                            autocomplete="off"
                            placeholder="rukava"
                            :aria-invalid="!!form.errors.slug"
                            class="w-full rounded-xl border bg-slate-50 py-3 pl-11 pr-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-800 dark:text-white dark:focus:bg-slate-800"
                            :class="
                                form.errors.slug
                                    ? 'border-red-400 focus:border-red-400 focus:ring-red-500/10 dark:border-red-500'
                                    : 'border-slate-200 focus:border-indigo-400 focus:ring-indigo-500/10 dark:border-slate-700 dark:focus:border-indigo-500'
                            "
                        />
                    </div>

                    <p
                        v-if="form.errors.slug"
                        class="mt-2 flex items-start gap-1.5 text-sm text-red-600 dark:text-red-400"
                    >
                        <Info :size="15" class="mt-0.5 shrink-0" />
                        {{ form.errors.slug }}
                    </p>

                    <p
                        v-else
                        class="mt-2 text-xs leading-5 text-slate-500 dark:text-slate-400"
                    >
                        Системный идентификатор категории. Если он используется в коде или URL, меняйте его внимательно.
                    </p>
                </div>

                <!-- Статус -->
                <div
                    class="rounded-xl border p-4 transition-colors"
                    :class="
                        form.is_active
                            ? 'border-emerald-200 bg-emerald-50/60 dark:border-emerald-500/20 dark:bg-emerald-500/5'
                            : 'border-slate-200 bg-slate-50 dark:border-slate-700 dark:bg-slate-800/50'
                    "
                >
                    <label
                        for="is_active"
                        class="flex cursor-pointer items-start gap-3"
                    >
                        <input
                            id="is_active"
                            v-model="form.is_active"
                            type="checkbox"
                            class="mt-0.5 size-4 shrink-0 rounded border-slate-300 text-emerald-600 focus:ring-2 focus:ring-emerald-500/20 dark:border-slate-600 dark:bg-slate-800"
                        />

                        <span class="min-w-0 flex-1">
                            <span
                                class="flex flex-wrap items-center gap-2 text-sm font-semibold text-slate-900 dark:text-white"
                            >
                                Категория активна

                                <span
                                    v-if="form.is_active"
                                    class="inline-flex items-center gap-1 rounded-full bg-emerald-100 px-2 py-0.5 text-xs font-medium text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-300"
                                >
                                    <CheckCircle2 :size="12" />
                                    Активна
                                </span>

                                <span
                                    v-else
                                    class="rounded-full bg-slate-200 px-2 py-0.5 text-xs font-medium text-slate-600 dark:bg-slate-700 dark:text-slate-300"
                                >
                                    Неактивна
                                </span>
                            </span>

                            <span
                                class="mt-1 block text-sm leading-5 text-slate-500 dark:text-slate-400"
                            >
                                Статус определяет, доступна ли категория для использования в интерфейсе.
                            </span>
                        </span>
                    </label>
                </div>
            </div>

            <!-- Действия -->
            <div
                class="flex flex-col-reverse gap-3 border-t border-slate-200 bg-slate-50/70 px-5 py-4 dark:border-slate-700 dark:bg-slate-800/30 sm:flex-row sm:items-center sm:justify-between sm:px-7"
            >
                <button
                    type="button"
                    :disabled="form.processing"
                    class="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-semibold text-slate-600 transition hover:bg-slate-100 focus:outline-none focus:ring-2 focus:ring-slate-500/20 disabled:cursor-not-allowed disabled:opacity-50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                    @click="resetForm"
                >
                    <RotateCcw :size="16" />
                    Сбросить изменения
                </button>

                <div class="flex flex-col-reverse gap-3 sm:flex-row">
                    <Link
                        :href="index.url()"
                        class="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-semibold text-slate-700 transition hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500/20 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                    >
                        <X :size="16" />
                        Отмена
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing || !form.isDirty"
                        class="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus:outline-none focus:ring-4 focus:ring-indigo-500/20 disabled:cursor-not-allowed disabled:opacity-60"
                    >
                        <span
                            v-if="form.processing"
                            class="size-4 animate-spin rounded-full border-2 border-white/30 border-t-white"
                        />
                        <Save v-else :size="17" />

                        {{ form.processing ? 'Сохранение...' : 'Сохранить изменения' }}
                    </button>
                </div>
            </div>
        </form>

        <!-- Подсказка -->
        <div
            class="flex items-start gap-3 rounded-xl border border-blue-200 bg-blue-50/70 p-4 dark:border-blue-500/20 dark:bg-blue-500/5"
        >
            <Info
                :size="18"
                class="mt-0.5 shrink-0 text-blue-600 dark:text-blue-400"
            />

            <div>
                <p class="text-sm font-semibold text-blue-900 dark:text-blue-200">
                    Обратите внимание
                </p>
                <p class="mt-1 text-sm leading-5 text-blue-800/80 dark:text-blue-300/80">
                    Изменение названия не меняет автоматически характеристики и типы товаров, связанные с этой категорией.
                </p>
            </div>
        </div>
    </div>
</template>
