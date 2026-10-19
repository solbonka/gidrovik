<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import {
    ArrowLeft,
    Check,
    CheckCircle2,
    FileText,
    Hash,
    Info,
    LoaderCircle,
    RotateCcw,
    Save,
    ShieldCheck,
    ToggleRight,
} from '@lucide/vue'
import { toast } from 'vue-sonner'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { index, update } from '@/routes/admin/threads'

defineOptions({
    layout: AdminLayout,
})

interface Thread {
    id: number
    system: string
    designation: string
    name: string
    is_active: boolean
}

interface Props {
    thread: Thread
}

const props = defineProps<Props>()

const initialValues = {
    system: props.thread.system,
    designation: props.thread.designation,
    name: props.thread.name,
    is_active: props.thread.is_active,
}

const form = useForm({
    ...initialValues,
})

const resetForm = (): void => {
    form.system = initialValues.system
    form.designation = initialValues.designation
    form.name = initialValues.name
    form.is_active = initialValues.is_active
    form.clearErrors()
}

const submit = (): void => {
    form.put(update(props.thread.id).url, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Резьба успешно обновлена.')
        },
        onError: () => {
            toast.error('Проверьте правильность заполнения формы.')
        },
    })
}
</script>

<template>
    <Head :title="`Редактирование: ${thread.designation}`" />

    <div class="space-y-6 p-4 sm:p-6">
        <!-- Заголовок -->
        <div
            class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-indigo-950 to-violet-900 p-6 text-white shadow-lg sm:p-8"
        >
            <div
                class="pointer-events-none absolute -right-10 -top-16 h-52 w-52 rounded-full bg-violet-400/20 blur-3xl"
            />

            <div class="relative">
                <Link
                    :href="index().url"
                    class="mb-5 inline-flex items-center gap-2 rounded-lg border border-white/20 bg-white/10 px-3 py-2 text-sm text-indigo-100 transition hover:bg-white/20 hover:text-white"
                >
                    <ArrowLeft class="h-4 w-4" />
                    К списку резьб
                </Link>

                <div class="flex items-center gap-4">
                    <div class="hidden rounded-2xl border border-white/15 bg-white/10 p-3 sm:block">
                        <Hash class="h-8 w-8 text-indigo-200" />
                    </div>

                    <div class="min-w-0">
                        <div class="mb-2 flex items-center gap-2 text-sm text-indigo-200">
                            <Hash class="h-4 w-4" />
                            Справочники
                        </div>

                        <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                            Редактирование резьбы
                        </h1>

                        <p class="mt-2 break-words text-sm text-slate-300 sm:text-base">
                            {{ thread.designation }}
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 items-start gap-6 xl:grid-cols-[minmax(0,1fr)_300px]">
            <!-- Форма -->
            <form
                class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900"
                @submit.prevent="submit"
            >
                <div class="border-b border-slate-200 px-5 py-5 dark:border-slate-800 sm:px-7">
                    <div class="flex items-center gap-3">
                        <div class="rounded-xl bg-indigo-50 p-2.5 dark:bg-indigo-500/10">
                            <FileText class="h-5 w-5 text-indigo-600 dark:text-indigo-400" />
                        </div>

                        <div>
                            <h2 class="font-semibold text-slate-900 dark:text-white">
                                Основная информация
                            </h2>
                            <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
                                Измените нужные поля и сохраните результат.
                            </p>
                        </div>
                    </div>
                </div>

                <div class="space-y-6 p-5 sm:p-7">
                    <div>
                        <label
                            for="system"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Система
                            <span class="text-rose-500">*</span>
                        </label>

                        <select
                            id="system"
                            v-model="form.system"
                            required
                            :aria-invalid="!!form.errors.system"
                            class="w-full rounded-xl border bg-slate-50 py-3 px-4 text-sm text-slate-900 outline-none transition focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                            :class="form.errors.system
                                ? 'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500'
                                : 'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700'"
                        >
                            <option value="metric">
                                Метрическая
                            </option>

                            <option value="inch">
                                Дюймовая
                            </option>

                            <option value="other">
                                Другая
                            </option>
                        </select>

                        <p
                            v-if="form.errors.system"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.system }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="designation"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Обозначение
                            <span class="text-rose-500">*</span>
                        </label>

                        <div class="relative">
                            <Hash class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />

                            <input
                                id="designation"
                                v-model="form.designation"
                                type="text"
                                maxlength="100"
                                required
                                autocomplete="off"
                                :aria-invalid="!!form.errors.designation"
                                class="w-full rounded-xl border bg-slate-50 py-3 pl-10 pr-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                                :class="form.errors.designation
                                    ? 'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500'
                                    : 'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700'"
                            />
                        </div>

                        <p
                            v-if="form.errors.designation"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.designation }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="name"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Название
                            <span class="text-rose-500">*</span>
                        </label>

                        <input
                            id="name"
                            v-model="form.name"
                            type="text"
                            maxlength="255"
                            required
                            autocomplete="off"
                            :aria-invalid="!!form.errors.name"
                            class="w-full rounded-xl border bg-slate-50 py-3 px-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                            :class="form.errors.name
                                ? 'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500'
                                : 'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700'"
                        />

                        <p
                            v-if="form.errors.name"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.name }}
                        </p>
                    </div>

                    <div class="rounded-xl border border-slate-200 bg-slate-50/70 p-4 dark:border-slate-700 dark:bg-slate-950/50">
                        <label
                            for="is_active"
                            class="flex cursor-pointer items-center justify-between gap-4"
                        >
                            <div class="flex items-start gap-3">
                                <div class="rounded-lg bg-emerald-50 p-2 dark:bg-emerald-500/10">
                                    <ToggleRight class="h-5 w-5 text-emerald-600 dark:text-emerald-400" />
                                </div>

                                <div>
                                    <p class="text-sm font-semibold text-slate-900 dark:text-white">
                                        Активная резьба
                                    </p>
                                    <p class="mt-1 text-xs leading-5 text-slate-500 dark:text-slate-400">
                                        Определяет, доступна ли резьба для выбора.
                                    </p>
                                </div>
                            </div>

                            <input
                                id="is_active"
                                v-model="form.is_active"
                                type="checkbox"
                                class="h-5 w-5 shrink-0 cursor-pointer rounded border-slate-300 text-indigo-600 focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 dark:border-slate-600 dark:bg-slate-900 dark:focus:ring-offset-slate-900"
                            />
                        </label>
                    </div>
                </div>

                <div class="flex flex-col-reverse gap-3 border-t border-slate-200 bg-slate-50/70 px-5 py-4 dark:border-slate-800 dark:bg-slate-950/40 sm:flex-row sm:items-center sm:justify-between sm:px-7">
                    <button
                        type="button"
                        :disabled="form.processing || !form.isDirty"
                        class="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-medium text-slate-600 transition hover:bg-slate-100 disabled:cursor-not-allowed disabled:opacity-40 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                        @click="resetForm"
                    >
                        <RotateCcw class="h-4 w-4" />
                        Сбросить изменения
                    </button>

                    <div class="flex flex-col-reverse gap-3 sm:flex-row">
                        <Link
                            :href="index().url"
                            class="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-5 py-2.5 text-sm font-semibold text-slate-700 transition hover:bg-slate-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-400 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                        >
                            Отмена
                        </Link>

                        <button
                            type="submit"
                            :disabled="form.processing || !form.isDirty"
                            class="inline-flex items-center justify-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60 dark:focus-visible:ring-offset-slate-900"
                        >
                            <LoaderCircle
                                v-if="form.processing"
                                class="h-4 w-4 animate-spin"
                            />
                            <Save v-else class="h-4 w-4" />

                            {{ form.processing ? 'Сохранение...' : 'Сохранить изменения' }}
                        </button>
                    </div>
                </div>
            </form>

            <aside class="space-y-4">
                <div class="rounded-2xl border border-indigo-100 bg-indigo-50/70 p-5 dark:border-indigo-500/20 dark:bg-indigo-500/5">
                    <div class="flex items-center gap-2">
                        <div class="rounded-lg bg-indigo-100 p-2 dark:bg-indigo-500/15">
                            <Info class="h-5 w-5 text-indigo-600 dark:text-indigo-400" />
                        </div>

                        <h3 class="font-semibold text-slate-900 dark:text-white">
                            Информация
                        </h3>
                    </div>

                    <div class="mt-4 space-y-4">
                        <div>
                            <p class="text-xs text-slate-500 dark:text-slate-400">
                                ID резьбы
                            </p>
                            <p class="mt-1 font-semibold text-slate-900 dark:text-white">
                                #{{ thread.id }}
                            </p>
                        </div>

                        <div>
                            <p class="text-xs text-slate-500 dark:text-slate-400">
                                Статус
                            </p>
                            <span
                                :class="[
                                    'mt-2 inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium',
                                    form.is_active
                                        ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400'
                                        : 'bg-slate-200 text-slate-600 dark:bg-slate-800 dark:text-slate-400',
                                ]"
                            >
                                <CheckCircle2 v-if="form.is_active" class="h-3.5 w-3.5" />
                                <ShieldCheck v-else class="h-3.5 w-3.5" />
                                {{ form.is_active ? 'Активна' : 'Неактивна' }}
                            </span>
                        </div>
                    </div>
                </div>
            </aside>
        </div>
    </div>
</template>
