<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { toast } from 'vue-sonner';
import {
    ArrowLeft,
    FolderPlus,
    Tag,
    CheckCircle2,
    Save,
    X,
    Info,
    Hash,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { index, store } from '@/routes/admin/categories';

defineOptions({
    layout: AdminLayout,
});

const form = useForm({
    name: '',
    slug: '',
    is_active: true,
});

const submit = (): void => {
    form.post(store.url(), {
        onSuccess: () => {
            toast.success('Категория успешно создана.');
        },
        onError: () => {
            toast.error('Проверьте правильность заполнения формы.');
        },
    });
};
</script>

<template>
    <Head title="Добавление категории" />

    <div class="mx-auto max-w-3xl space-y-6 pb-8">
        <!-- Шапка страницы -->
        <div
            class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-slate-800 to-indigo-950 px-5 py-6 shadow-lg sm:px-8 sm:py-8"
        >
            <div
                class="pointer-events-none absolute -top-16 -right-12 h-56 w-56 rounded-full bg-indigo-500/20 blur-3xl"
            />

            <div
                class="relative flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between"
            >
                <div class="flex items-start gap-4">
                    <div
                        class="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl border border-white/10 bg-white/10 text-white sm:h-14 sm:w-14"
                    >
                        <FolderPlus :size="27" />
                    </div>

                    <div>
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
                            <span class="text-white/90">Создание</span>
                        </div>

                        <h1
                            class="text-2xl font-bold tracking-tight text-white sm:text-3xl"
                        >
                            Новая категория
                        </h1>

                        <p
                            class="mt-2 max-w-lg text-sm leading-6 text-slate-300"
                        >
                            Создайте категорию для удобной организации товаров
                            склада.
                        </p>
                    </div>
                </div>

                <Link
                    :href="index.url()"
                    class="inline-flex min-h-10 items-center justify-center gap-2 self-start rounded-xl border border-white/15 bg-white/10 px-4 py-2 text-sm font-medium text-white transition hover:bg-white/15 focus:ring-2 focus:ring-white/50 focus:outline-none sm:self-center"
                >
                    <ArrowLeft :size="16" />
                    К категориям
                </Link>
            </div>
        </div>

        <!-- Форма -->
        <form
            class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-700 dark:bg-slate-900"
            @submit.prevent="submit"
        >
            <!-- Заголовок формы -->
            <div
                class="flex items-center gap-3 border-b border-slate-200 px-5 py-5 sm:px-7 dark:border-slate-700"
            >
                <div
                    class="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400"
                >
                    <Tag :size="20" />
                </div>

                <div>
                    <h2
                        class="text-base font-semibold text-slate-900 dark:text-white"
                    >
                        Основная информация
                    </h2>
                    <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
                        Укажите название и системный идентификатор категории.
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
                        <FolderPlus
                            :size="18"
                            class="pointer-events-none absolute top-1/2 left-3.5 -translate-y-1/2 text-slate-400"
                        />

                        <input
                            id="name"
                            v-model="form.name"
                            type="text"
                            autofocus
                            autocomplete="off"
                            placeholder="Например, Рукава"
                            :aria-invalid="!!form.errors.name"
                            class="w-full rounded-xl border bg-slate-50 py-3 pr-4 pl-11 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-800 dark:text-white dark:focus:bg-slate-800"
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
                        Понятное название, которое будет отображаться в
                        интерфейсе склада.
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
                            class="pointer-events-none absolute top-1/2 left-3.5 -translate-y-1/2 text-slate-400"
                        />

                        <input
                            id="slug"
                            v-model="form.slug"
                            type="text"
                            autocomplete="off"
                            placeholder="rukava"
                            :aria-invalid="!!form.errors.slug"
                            class="w-full rounded-xl border bg-slate-50 py-3 pr-4 pl-11 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-800 dark:text-white dark:focus:bg-slate-800"
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
                        Уникальный системный идентификатор, например
                        <code
                            class="rounded bg-slate-100 px-1.5 py-0.5 text-slate-700 dark:bg-slate-800 dark:text-slate-300"
                            >rukava</code
                        >.
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
                                Активная категория доступна для использования
                                при работе с товарами.
                            </span>
                        </span>
                    </label>
                </div>
            </div>

            <!-- Кнопки -->
            <div
                class="flex flex-col-reverse gap-3 border-t border-slate-200 bg-slate-50/70 px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-7 dark:border-slate-700 dark:bg-slate-800/30"
            >
                <Link
                    :href="index.url()"
                    class="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-semibold text-slate-700 transition hover:bg-slate-50 focus:ring-2 focus:ring-slate-500/20 focus:outline-none dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                >
                    <X :size="16" />
                    Отмена
                </Link>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus:ring-4 focus:ring-indigo-500/20 focus:outline-none disabled:cursor-not-allowed disabled:opacity-60"
                >
                    <span
                        v-if="form.processing"
                        class="size-4 animate-spin rounded-full border-2 border-white/30 border-t-white"
                    />
                    <Save v-else :size="17" />

                    {{
                        form.processing ? 'Сохранение...' : 'Создать категорию'
                    }}
                </button>
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
                <p
                    class="text-sm font-semibold text-blue-900 dark:text-blue-200"
                >
                    Что дальше?
                </p>
                <p
                    class="mt-1 text-sm leading-5 text-blue-800/80 dark:text-blue-300/80"
                >
                    После создания категории вы сможете настроить её
                    характеристики и типы товаров.
                </p>
            </div>
        </div>
    </div>
</template>
