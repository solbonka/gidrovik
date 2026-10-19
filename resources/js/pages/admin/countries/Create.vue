<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import {
    ArrowLeft,
    Check,
    ChevronDown,
    CirclePlus,
    FileText,
    Globe,
    Hash,
    Info,
    LoaderCircle,
    MapPin,
    ShieldCheck,
    ToggleRight,
} from '@lucide/vue';
import { toast } from 'vue-sonner';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { index, store } from '@/routes/admin/countries';

defineOptions({
    layout: AdminLayout,
});

const form = useForm({
    name: '',
    code: '',
    is_active: true,
});

const submit = (): void => {
    form.post(store.url(), {
        onSuccess: () => {
            toast.success('Страна успешно создана.');
        },
        onError: () => {
            toast.error('Проверьте правильность заполнения формы.');
        },
    });
};
</script>

<template>
    <Head title="Создание страны" />

    <div class="space-y-6 p-4 sm:p-6">
        <!-- Заголовок -->
        <div
            class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-indigo-950 to-violet-900 p-6 text-white shadow-lg sm:p-8"
        >
            <div
                class="pointer-events-none absolute -top-16 -right-10 h-52 w-52 rounded-full bg-violet-400/20 blur-3xl"
            />

            <div class="relative">
                <Link
                    :href="index.url()"
                    class="mb-5 inline-flex items-center gap-2 rounded-lg border border-white/20 bg-white/10 px-3 py-2 text-sm text-indigo-100 transition hover:bg-white/20 hover:text-white"
                >
                    <ArrowLeft class="h-4 w-4" />
                    К списку стран
                </Link>

                <div class="flex items-center gap-4">
                    <div
                        class="hidden rounded-2xl border border-white/15 bg-white/10 p-3 sm:block"
                    >
                        <CirclePlus class="h-8 w-8 text-indigo-200" />
                    </div>

                    <div>
                        <div
                            class="mb-2 flex items-center gap-2 text-sm text-indigo-200"
                        >
                            <Globe class="h-4 w-4" />
                            Справочники
                        </div>

                        <h1
                            class="text-2xl font-bold tracking-tight sm:text-3xl"
                        >
                            Новая страна
                        </h1>

                        <p
                            class="mt-2 max-w-xl text-sm text-slate-300 sm:text-base"
                        >
                            Добавьте страну производителя в справочник.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <div
            class="grid grid-cols-1 items-start gap-6 xl:grid-cols-[minmax(0,1fr)_300px]"
        >
            <!-- Форма -->
            <form
                class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900"
                @submit.prevent="submit"
            >
                <div
                    class="border-b border-slate-200 px-5 py-5 sm:px-7 dark:border-slate-800"
                >
                    <div class="flex items-center gap-3">
                        <div
                            class="rounded-xl bg-indigo-50 p-2.5 dark:bg-indigo-500/10"
                        >
                            <FileText
                                class="h-5 w-5 text-indigo-600 dark:text-indigo-400"
                            />
                        </div>

                        <div>
                            <h2
                                class="font-semibold text-slate-900 dark:text-white"
                            >
                                Основная информация
                            </h2>
                            <p
                                class="mt-1 text-sm text-slate-500 dark:text-slate-400"
                            >
                                Заполните обязательные поля формы.
                            </p>
                        </div>
                    </div>
                </div>

                <div class="space-y-6 p-5 sm:p-7">
                    <!-- Название -->
                    <div>
                        <label
                            for="name"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Название страны
                            <span class="text-rose-500">*</span>
                        </label>

                        <div class="relative">
                            <Globe
                                class="pointer-events-none absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-slate-400"
                            />

                            <input
                                id="name"
                                v-model="form.name"
                                type="text"
                                required
                                maxlength="255"
                                autocomplete="off"
                                :aria-invalid="!!form.errors.name"
                                class="w-full rounded-xl border bg-slate-50 py-3 pr-4 pl-10 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                                :class="
                                    form.errors.name
                                        ? 'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500'
                                        : 'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700'
                                "
                                placeholder="Например: Россия"
                            />
                        </div>

                        <p
                            v-if="form.errors.name"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.name }}
                        </p>

                        <p
                            v-else
                            class="mt-2 text-xs text-slate-500 dark:text-slate-400"
                        >
                            Полное название страны на русском языке.
                        </p>
                    </div>

                    <!-- Код -->
                    <div>
                        <label
                            for="code"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Код (ISO)
                        </label>

                        <div class="relative">
                            <Hash
                                class="pointer-events-none absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-slate-400"
                            />

                            <input
                                id="code"
                                v-model="form.code"
                                type="text"
                                maxlength="3"
                                autocomplete="off"
                                spellcheck="false"
                                :aria-invalid="!!form.errors.code"
                                class="w-full rounded-xl border bg-slate-50 py-3 pr-4 pl-10 text-sm text-slate-900 uppercase transition outline-none placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                                :class="
                                    form.errors.code
                                        ? 'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500'
                                        : 'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700'
                                "
                                placeholder="RUS"
                            />
                        </div>

                        <p
                            v-if="form.errors.code"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.code }}
                        </p>

                        <p
                            v-else
                            class="mt-2 text-xs text-slate-500 dark:text-slate-400"
                        >
                            Трёхбуквенный код страны по стандарту ISO 3166-1
                            alpha-3, например
                            <code
                                class="rounded bg-slate-100 px-1.5 py-0.5 dark:bg-slate-800"
                            >
                                RUS </code
                            >.
                        </p>
                    </div>

                    <!-- Статус -->
                    <div
                        class="rounded-xl border border-slate-200 bg-slate-50/70 p-4 dark:border-slate-700 dark:bg-slate-950/50"
                    >
                        <label
                            for="is_active"
                            class="flex cursor-pointer items-center justify-between gap-4"
                        >
                            <div class="flex items-start gap-3">
                                <div
                                    class="rounded-lg bg-emerald-50 p-2 dark:bg-emerald-500/10"
                                >
                                    <ToggleRight
                                        class="h-5 w-5 text-emerald-600 dark:text-emerald-400"
                                    />
                                </div>

                                <div>
                                    <p
                                        class="text-sm font-semibold text-slate-900 dark:text-white"
                                    >
                                        Активная страна
                                    </p>
                                    <p
                                        class="mt-1 text-xs leading-5 text-slate-500 dark:text-slate-400"
                                    >
                                        Страна будет доступна для выбора при
                                        работе с товарами.
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

                <!-- Кнопки -->
                <div
                    class="flex flex-col-reverse gap-3 border-t border-slate-200 bg-slate-50/70 px-5 py-4 sm:flex-row sm:justify-end sm:px-7 dark:border-slate-800 dark:bg-slate-950/40"
                >
                    <Link
                        :href="index.url()"
                        class="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-5 py-2.5 text-sm font-semibold text-slate-700 transition hover:bg-slate-100 focus-visible:ring-2 focus-visible:ring-slate-400 focus-visible:outline-none dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                    >
                        <ArrowLeft class="h-4 w-4" />
                        Отмена
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing"
                        class="inline-flex items-center justify-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-60 dark:focus-visible:ring-offset-slate-900"
                    >
                        <LoaderCircle
                            v-if="form.processing"
                            class="h-4 w-4 animate-spin"
                        />
                        <Check v-else class="h-4 w-4" />

                        {{ form.processing ? 'Создание...' : 'Создать страну' }}
                    </button>
                </div>
            </form>

            <!-- Боковая подсказка -->
            <aside class="space-y-4">
                <div
                    class="rounded-2xl border border-indigo-100 bg-indigo-50/70 p-5 dark:border-indigo-500/20 dark:bg-indigo-500/5"
                >
                    <div class="flex items-center gap-2">
                        <div
                            class="rounded-lg bg-indigo-100 p-2 dark:bg-indigo-500/15"
                        >
                            <Info
                                class="h-5 w-5 text-indigo-600 dark:text-indigo-400"
                            />
                        </div>

                        <h3
                            class="font-semibold text-slate-900 dark:text-white"
                        >
                            Полезно знать
                        </h3>
                    </div>

                    <ul
                        class="mt-4 space-y-4 text-sm text-slate-600 dark:text-slate-300"
                    >
                        <li class="flex items-start gap-2.5">
                            <Check
                                class="mt-0.5 h-4 w-4 shrink-0 text-indigo-600 dark:text-indigo-400"
                            />
                            <span>
                                Название страны должно быть уникальным в
                                справочнике.
                            </span>
                        </li>

                        <li class="flex items-start gap-2.5">
                            <Check
                                class="mt-0.5 h-4 w-4 shrink-0 text-indigo-600 dark:text-indigo-400"
                            />
                            <span>
                                Код ISO не обязателен, но помогает в
                                идентификации страны.
                            </span>
                        </li>

                        <li class="flex items-start gap-2.5">
                            <Check
                                class="mt-0.5 h-4 w-4 shrink-0 text-indigo-600 dark:text-indigo-400"
                            />
                            <span>
                                Неактивные страны не будут доступны при выборе
                                товаров.
                            </span>
                        </li>
                    </ul>
                </div>

                <div
                    class="rounded-2xl border border-slate-200 bg-white p-5 dark:border-slate-800 dark:bg-slate-900"
                >
                    <div class="flex items-center gap-3">
                        <div
                            class="rounded-xl bg-slate-100 p-2.5 dark:bg-slate-800"
                        >
                            <MapPin
                                class="h-5 w-5 text-slate-600 dark:text-slate-300"
                            />
                        </div>

                        <div>
                            <p
                                class="text-sm font-semibold text-slate-900 dark:text-white"
                            >
                                О кодах ISO
                            </p>
                            <p
                                class="mt-1 text-xs text-slate-500 dark:text-slate-400"
                            >
                                Международный стандарт
                            </p>
                        </div>
                    </div>

                    <p class="mt-4 text-sm text-slate-600 dark:text-slate-300">
                        ISO 3166-1 alpha-3 — трёхбуквенные коды стран. Например:
                        RUS (Россия), CHN (Китай), DEU (Германия).
                    </p>
                </div>
            </aside>
        </div>
    </div>
</template>
