<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { toast } from 'vue-sonner';
import {
    ArrowLeft,
    Check,
    ChevronDown,
    FileText,
    Hash,
    List,
    Pencil,
    Ruler,
    Save,
    Settings2,
    ShieldCheck,
    Type,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { index, update } from '@/routes/admin/characteristics';

defineOptions({
    layout: AdminLayout,
});

interface Characteristic {
    id: number;
    name: string;
    slug: string;
    type: string;
    unit: string | null;
    is_active: boolean;
}

interface Props {
    characteristic: Characteristic;
}

const props = defineProps<Props>();

const form = useForm({
    name: props.characteristic.name,
    slug: props.characteristic.slug,
    type: props.characteristic.type,
    unit: props.characteristic.unit ?? '',
    is_active: props.characteristic.is_active,
});

const typeOptions = [
    {
        value: 'text',
        label: 'Текст',
        description: 'Текстовое значение',
        icon: Type,
    },
    {
        value: 'number',
        label: 'Число',
        description: 'Числовое значение',
        icon: Hash,
    },
    {
        value: 'select',
        label: 'Список',
        description: 'Выбор из вариантов',
        icon: List,
    },
    {
        value: 'boolean',
        label: 'Да / Нет',
        description: 'Логическое значение',
        icon: Check,
    },
];

const submit = (): void => {
    form.put(update(props.characteristic.id).url, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Характеристика успешно обновлена.');
        },
        onError: () => {
            toast.error('Проверьте правильность заполнения формы.');
        },
    });
};
</script>

<template>
    <Head :title="`Редактирование: ${characteristic.name}`" />

    <div class="mx-auto w-full max-w-5xl space-y-6 p-4 sm:p-6 lg:p-8">
        <!-- Заголовок -->
        <div
            class="relative overflow-hidden rounded-2xl border border-indigo-200/60 bg-gradient-to-br from-indigo-50 via-white to-violet-50 p-6 shadow-sm sm:p-8 dark:border-indigo-900/50 dark:from-indigo-950/50 dark:via-gray-950 dark:to-violet-950/30"
        >
            <div
                class="pointer-events-none absolute -top-16 -right-12 h-48 w-48 rounded-full bg-indigo-400/10 blur-3xl"
            />

            <div
                class="relative flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between"
            >
                <div class="flex items-start gap-4">
                    <div
                        class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-indigo-500 to-violet-600 text-white shadow-lg shadow-indigo-500/20"
                    >
                        <Pencil class="size-6" />
                    </div>

                    <div class="min-w-0">
                        <div class="mb-2 flex flex-wrap items-center gap-2">
                            <span
                                class="rounded-full border border-indigo-200 bg-indigo-100/70 px-2.5 py-1 text-xs font-medium text-indigo-700 dark:border-indigo-800 dark:bg-indigo-900/40 dark:text-indigo-300"
                            >
                                Справочники
                            </span>
                            <span class="text-xs text-muted-foreground">
                                / Характеристики / Редактирование
                            </span>
                        </div>

                        <h1
                            class="text-2xl font-bold tracking-tight text-gray-900 sm:text-3xl dark:text-white"
                        >
                            Редактирование характеристики
                        </h1>

                        <p
                            class="mt-2 max-w-xl text-sm leading-6 break-words text-gray-600 dark:text-gray-400"
                        >
                            Измените параметры характеристики
                            <span
                                class="font-semibold text-gray-800 dark:text-gray-200"
                            >
                                «{{ characteristic.name }}» </span
                            >.
                        </p>

                        <p class="mt-2 text-xs text-muted-foreground">
                            ID характеристики: {{ characteristic.id }}
                        </p>
                    </div>
                </div>

                <Link
                    :href="index.url()"
                    class="inline-flex shrink-0 items-center justify-center gap-2 self-start rounded-xl border border-gray-200 bg-white/80 px-4 py-2.5 text-sm font-medium text-gray-700 shadow-sm transition hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-700 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:outline-none sm:self-center dark:border-gray-700 dark:bg-gray-900/70 dark:text-gray-200 dark:hover:border-indigo-700 dark:hover:bg-indigo-950/50 dark:hover:text-indigo-300"
                >
                    <ArrowLeft class="size-4" />
                    К списку
                </Link>
            </div>
        </div>

        <!-- Форма -->
        <form
            class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-800 dark:bg-gray-950"
            @submit.prevent="submit"
        >
            <div
                class="border-b border-gray-100 px-5 py-5 sm:px-7 dark:border-gray-800"
            >
                <div class="flex items-center gap-3">
                    <div
                        class="flex size-10 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-950/60 dark:text-indigo-400"
                    >
                        <Settings2 class="size-5" />
                    </div>

                    <div>
                        <h2 class="font-semibold text-gray-900 dark:text-white">
                            Основные сведения
                        </h2>
                        <p class="mt-0.5 text-sm text-muted-foreground">
                            Измените необходимые поля и сохраните результат
                        </p>
                    </div>
                </div>
            </div>

            <div class="space-y-6 p-5 sm:p-7">
                <!-- Название -->
                <div class="space-y-2">
                    <label
                        for="characteristic-name"
                        class="block text-sm font-medium text-gray-800 dark:text-gray-200"
                    >
                        Название
                        <span class="text-red-500">*</span>
                    </label>

                    <input
                        id="characteristic-name"
                        v-model="form.name"
                        type="text"
                        autocomplete="off"
                        :aria-invalid="Boolean(form.errors.name)"
                        placeholder="Например: Рабочее давление"
                        class="w-full rounded-xl border bg-white px-4 py-3 text-sm text-gray-900 shadow-sm transition outline-none placeholder:text-gray-400 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 dark:bg-gray-900 dark:text-white dark:placeholder:text-gray-500"
                        :class="
                            form.errors.name
                                ? 'border-red-400 dark:border-red-500'
                                : 'border-gray-200 dark:border-gray-700'
                        "
                    />

                    <p
                        v-if="form.errors.name"
                        class="flex items-start gap-1.5 text-sm text-red-600 dark:text-red-400"
                    >
                        <X class="mt-0.5 size-4 shrink-0" />
                        {{ form.errors.name }}
                    </p>
                </div>

                <!-- Slug -->
                <div class="space-y-2">
                    <label
                        for="characteristic-slug"
                        class="block text-sm font-medium text-gray-800 dark:text-gray-200"
                    >
                        Slug
                        <span class="text-red-500">*</span>
                    </label>

                    <div
                        class="flex items-center overflow-hidden rounded-xl border bg-gray-50 shadow-sm transition focus-within:border-indigo-500 focus-within:ring-4 focus-within:ring-indigo-500/10 dark:bg-gray-900"
                        :class="
                            form.errors.slug
                                ? 'border-red-400 dark:border-red-500'
                                : 'border-gray-200 dark:border-gray-700'
                        "
                    >
                        <span
                            class="border-r border-gray-200 px-3 py-3 text-gray-400 dark:border-gray-700"
                        >
                            <Hash class="size-4" />
                        </span>

                        <input
                            id="characteristic-slug"
                            v-model="form.slug"
                            type="text"
                            autocomplete="off"
                            placeholder="working_pressure"
                            :aria-invalid="Boolean(form.errors.slug)"
                            class="min-w-0 flex-1 border-0 bg-transparent px-3 py-3 text-sm text-gray-900 outline-none focus:ring-0 dark:text-white"
                        />
                    </div>

                    <p
                        v-if="form.errors.slug"
                        class="flex items-start gap-1.5 text-sm text-red-600 dark:text-red-400"
                    >
                        <X class="mt-0.5 size-4 shrink-0" />
                        {{ form.errors.slug }}
                    </p>

                    <p v-else class="text-xs text-muted-foreground">
                        Системный идентификатор характеристики. Изменяйте его,
                        если уверены, что это не нарушит существующие
                        интеграции.
                    </p>
                </div>

                <!-- Тип значения -->
                <div class="space-y-2">
                    <label
                        for="characteristic-type"
                        class="block text-sm font-medium text-gray-800 dark:text-gray-200"
                    >
                        Тип значения
                        <span class="text-red-500">*</span>
                    </label>

                    <div class="relative">
                        <select
                            id="characteristic-type"
                            v-model="form.type"
                            :aria-invalid="Boolean(form.errors.type)"
                            class="w-full appearance-none rounded-xl border bg-white px-4 py-3 pr-11 text-sm text-gray-900 shadow-sm transition outline-none focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 dark:bg-gray-900 dark:text-white"
                            :class="
                                form.errors.type
                                    ? 'border-red-400 dark:border-red-500'
                                    : 'border-gray-200 dark:border-gray-700'
                            "
                        >
                            <option
                                v-for="option in typeOptions"
                                :key="option.value"
                                :value="option.value"
                            >
                                {{ option.label }} — {{ option.description }}
                            </option>
                        </select>

                        <ChevronDown
                            class="pointer-events-none absolute top-1/2 right-4 size-4 -translate-y-1/2 text-gray-400"
                        />
                    </div>

                    <p
                        v-if="form.errors.type"
                        class="flex items-start gap-1.5 text-sm text-red-600 dark:text-red-400"
                    >
                        <X class="mt-0.5 size-4 shrink-0" />
                        {{ form.errors.type }}
                    </p>

                    <div class="grid gap-3 pt-2 sm:grid-cols-2">
                        <div
                            v-for="option in typeOptions"
                            :key="option.value"
                            class="flex items-start gap-3 rounded-xl border p-3 transition"
                            :class="
                                form.type === option.value
                                    ? 'border-indigo-300 bg-indigo-50/70 dark:border-indigo-800 dark:bg-indigo-950/30'
                                    : 'border-gray-200 bg-gray-50/60 dark:border-gray-800 dark:bg-gray-900/50'
                            "
                        >
                            <div
                                class="flex size-9 shrink-0 items-center justify-center rounded-lg"
                                :class="
                                    form.type === option.value
                                        ? 'bg-indigo-100 text-indigo-700 dark:bg-indigo-900/70 dark:text-indigo-300'
                                        : 'bg-white text-gray-500 dark:bg-gray-800 dark:text-gray-400'
                                "
                            >
                                <component :is="option.icon" class="size-4" />
                            </div>

                            <div class="min-w-0">
                                <p
                                    class="text-sm font-medium text-gray-800 dark:text-gray-200"
                                >
                                    {{ option.label }}
                                </p>
                                <p class="mt-0.5 text-xs text-muted-foreground">
                                    {{ option.description }}
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Единица измерения -->
                <div class="space-y-2">
                    <label
                        for="characteristic-unit"
                        class="flex flex-wrap items-center gap-2 text-sm font-medium text-gray-800 dark:text-gray-200"
                    >
                        <Ruler class="size-4 text-gray-400" />
                        Единица измерения
                        <span class="font-normal text-muted-foreground">
                            (необязательно)
                        </span>
                    </label>

                    <input
                        id="characteristic-unit"
                        v-model="form.unit"
                        type="text"
                        placeholder="бар, мм, кг"
                        :aria-invalid="Boolean(form.errors.unit)"
                        class="w-full rounded-xl border bg-white px-4 py-3 text-sm text-gray-900 shadow-sm transition outline-none placeholder:text-gray-400 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 dark:bg-gray-900 dark:text-white dark:placeholder:text-gray-500"
                        :class="
                            form.errors.unit
                                ? 'border-red-400 dark:border-red-500'
                                : 'border-gray-200 dark:border-gray-700'
                        "
                    />

                    <p
                        v-if="form.errors.unit"
                        class="flex items-start gap-1.5 text-sm text-red-600 dark:text-red-400"
                    >
                        <X class="mt-0.5 size-4 shrink-0" />
                        {{ form.errors.unit }}
                    </p>

                    <p v-else class="text-xs text-muted-foreground">
                        Например, «бар» для давления или «мм» для диаметра.
                    </p>
                </div>

                <!-- Статус -->
                <div
                    class="flex flex-col gap-4 rounded-xl border border-gray-200 bg-gray-50/70 p-4 sm:flex-row sm:items-center sm:justify-between dark:border-gray-800 dark:bg-gray-900/50"
                >
                    <div class="flex items-start gap-3">
                        <div
                            class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-emerald-50 text-emerald-600 dark:bg-emerald-950/50 dark:text-emerald-400"
                        >
                            <ShieldCheck class="size-5" />
                        </div>

                        <div>
                            <p
                                class="text-sm font-medium text-gray-900 dark:text-white"
                            >
                                Активная характеристика
                            </p>
                            <p class="mt-1 text-sm text-muted-foreground">
                                Активные характеристики доступны для
                                использования в категориях.
                            </p>
                        </div>
                    </div>

                    <label
                        class="inline-flex shrink-0 cursor-pointer items-center gap-3 self-start sm:self-center"
                    >
                        <span
                            class="text-sm font-medium text-gray-700 dark:text-gray-300"
                        >
                            {{ form.is_active ? 'Активна' : 'Неактивна' }}
                        </span>

                        <input
                            v-model="form.is_active"
                            type="checkbox"
                            class="peer sr-only"
                        />

                        <span
                            class="relative h-6 w-11 rounded-full bg-gray-300 transition peer-checked:bg-indigo-600 peer-focus-visible:ring-4 peer-focus-visible:ring-indigo-500/20 peer-focus-visible:outline-none dark:bg-gray-700"
                        >
                            <span
                                class="absolute top-0.5 left-0.5 size-5 rounded-full bg-white shadow-sm transition peer-checked:translate-x-5"
                            />
                        </span>
                    </label>
                </div>
            </div>

            <!-- Действия -->
            <div
                class="flex flex-col-reverse gap-3 border-t border-gray-100 bg-gray-50/70 px-5 py-5 sm:flex-row sm:items-center sm:justify-between sm:px-7 dark:border-gray-800 dark:bg-gray-900/40"
            >
                <p class="text-xs text-muted-foreground">
                    <span class="text-red-500">*</span>
                    Обязательные поля
                </p>

                <div class="flex flex-col-reverse gap-3 sm:flex-row">
                    <Link
                        :href="index.url()"
                        class="inline-flex items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white px-5 py-2.5 text-sm font-medium text-gray-700 transition hover:bg-gray-100 focus-visible:ring-2 focus-visible:ring-gray-400 focus-visible:outline-none dark:border-gray-700 dark:bg-gray-900 dark:text-gray-300 dark:hover:bg-gray-800"
                    >
                        <X class="size-4" />
                        Отмена
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing"
                        class="inline-flex items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-indigo-600 to-violet-600 px-5 py-2.5 text-sm font-semibold text-white shadow-md shadow-indigo-500/20 transition hover:from-indigo-700 hover:to-violet-700 focus-visible:ring-4 focus-visible:ring-indigo-500/30 focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-60"
                    >
                        <span
                            v-if="form.processing"
                            class="size-4 animate-spin rounded-full border-2 border-white/30 border-t-white"
                        />
                        <Save v-else class="size-4" />
                        {{
                            form.processing
                                ? 'Сохранение...'
                                : 'Сохранить изменения'
                        }}
                    </button>
                </div>
            </div>
        </form>
    </div>
</template>
