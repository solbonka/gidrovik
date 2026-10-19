<script setup lang="ts">
import { computed } from 'vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import {
    ArrowLeft,
    Check,
    CheckCircle2,
    FileText,
    FolderTree,
    Hash,
    Info,
    LoaderCircle,
    Package,
    RotateCcw,
    Save,
    ToggleRight,
} from '@lucide/vue';
import { toast } from 'vue-sonner';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { index, update } from '@/routes/admin/product-types';

defineOptions({
    layout: AdminLayout,
});

interface Category {
    id: number;
    name: string;
}

interface ProductType {
    id: number;
    category_id: number;
    name: string;
    slug: string;
    is_active: boolean;
}

interface Props {
    productType: ProductType;
    categories: Category[];
}

const props = defineProps<Props>();

const initialValues = {
    category_id: String(props.productType.category_id),
    name: props.productType.name,
    slug: props.productType.slug,
    is_active: props.productType.is_active,
};

const form = useForm({
    ...initialValues,
});

const selectedCategory = computed(() =>
    props.categories.find(
        (category) => String(category.id) === form.category_id,
    ),
);

const resetForm = (): void => {
    form.category_id = initialValues.category_id;
    form.name = initialValues.name;
    form.slug = initialValues.slug;
    form.is_active = initialValues.is_active;
    form.clearErrors();
};

const submit = (): void => {
    form.put(update(props.productType.id).url, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Тип товара успешно обновлён.');
        },
        onError: () => {
            toast.error('Проверьте правильность заполнения формы.');
        },
    });
};
</script>

<template>
    <Head :title="`Редактирование: ${productType.name}`" />

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
                    К списку типов
                </Link>

                <div class="flex items-center gap-4">
                    <div
                        class="hidden rounded-2xl border border-white/15 bg-white/10 p-3 sm:block"
                    >
                        <Package class="h-8 w-8 text-indigo-200" />
                    </div>

                    <div class="min-w-0">
                        <div
                            class="mb-2 flex items-center gap-2 text-sm text-indigo-200"
                        >
                            <FolderTree class="h-4 w-4" />
                            Каталог товаров
                        </div>

                        <h1
                            class="text-2xl font-bold tracking-tight sm:text-3xl"
                        >
                            Редактирование типа товара
                        </h1>

                        <p
                            class="mt-2 text-sm break-words text-slate-300 sm:text-base"
                        >
                            {{ productType.name }}
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
                                Измените нужные поля и сохраните результат.
                            </p>
                        </div>
                    </div>
                </div>

                <div class="space-y-6 p-5 sm:p-7">
                    <!-- Категория -->
                    <div>
                        <label
                            for="category_id"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Категория
                            <span class="text-rose-500">*</span>
                        </label>

                        <div class="relative">
                            <FolderTree
                                class="pointer-events-none absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-slate-400"
                            />

                            <select
                                id="category_id"
                                v-model="form.category_id"
                                required
                                :aria-invalid="!!form.errors.category_id"
                                class="w-full appearance-none rounded-xl border bg-slate-50 py-3 pr-10 pl-10 text-sm text-slate-900 transition outline-none focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                                :class="
                                    form.errors.category_id
                                        ? 'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500'
                                        : 'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700'
                                "
                            >
                                <option
                                    v-for="category in categories"
                                    :key="category.id"
                                    :value="String(category.id)"
                                >
                                    {{ category.name }}
                                </option>
                            </select>
                        </div>

                        <p
                            v-if="form.errors.category_id"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.category_id }}
                        </p>

                        <p
                            v-else
                            class="mt-2 text-xs text-slate-500 dark:text-slate-400"
                        >
                            Категория, к которой относится этот тип товара.
                        </p>
                    </div>

                    <!-- Название -->
                    <div>
                        <label
                            for="name"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Название типа
                            <span class="text-rose-500">*</span>
                        </label>

                        <div class="relative">
                            <Package
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
                                placeholder="Например: Фитинги"
                            />
                        </div>

                        <p
                            v-if="form.errors.name"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.name }}
                        </p>
                    </div>

                    <!-- Slug -->
                    <div>
                        <label
                            for="slug"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Slug
                            <span class="text-rose-500">*</span>
                        </label>

                        <div class="relative">
                            <Hash
                                class="pointer-events-none absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-slate-400"
                            />

                            <input
                                id="slug"
                                v-model="form.slug"
                                type="text"
                                required
                                maxlength="255"
                                autocomplete="off"
                                spellcheck="false"
                                :aria-invalid="!!form.errors.slug"
                                class="w-full rounded-xl border bg-slate-50 py-3 pr-4 pl-10 text-sm text-slate-900 transition outline-none placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                                :class="
                                    form.errors.slug
                                        ? 'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500'
                                        : 'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700'
                                "
                                placeholder="fittings"
                            />
                        </div>

                        <p
                            v-if="form.errors.slug"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.slug }}
                        </p>

                        <p
                            v-else
                            class="mt-2 text-xs text-slate-500 dark:text-slate-400"
                        >
                            Уникальный идентификатор типа товара. При
                            необходимости его можно изменить.
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
                                        Активный тип товара
                                    </p>
                                    <p
                                        class="mt-1 text-xs leading-5 text-slate-500 dark:text-slate-400"
                                    >
                                        Определяет, отмечен ли тип как активный.
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
                    class="flex flex-col-reverse gap-3 border-t border-slate-200 bg-slate-50/70 px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-7 dark:border-slate-800 dark:bg-slate-950/40"
                >
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
                            :href="index.url()"
                            class="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-5 py-2.5 text-sm font-semibold text-slate-700 transition hover:bg-slate-100 focus-visible:ring-2 focus-visible:ring-slate-400 focus-visible:outline-none dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                        >
                            Отмена
                        </Link>

                        <button
                            type="submit"
                            :disabled="form.processing || !form.isDirty"
                            class="inline-flex items-center justify-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-60 dark:focus-visible:ring-offset-slate-900"
                        >
                            <LoaderCircle
                                v-if="form.processing"
                                class="h-4 w-4 animate-spin"
                            />
                            <Save v-else class="h-4 w-4" />

                            {{
                                form.processing
                                    ? 'Сохранение...'
                                    : 'Сохранить изменения'
                            }}
                        </button>
                    </div>
                </div>
            </form>

            <!-- Информация -->
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
                            Информация
                        </h3>
                    </div>

                    <div class="mt-4 space-y-4">
                        <div>
                            <p
                                class="text-xs text-slate-500 dark:text-slate-400"
                            >
                                ID типа
                            </p>
                            <p
                                class="mt-1 font-semibold text-slate-900 dark:text-white"
                            >
                                #{{ productType.id }}
                            </p>
                        </div>

                        <div>
                            <p
                                class="text-xs text-slate-500 dark:text-slate-400"
                            >
                                Текущая категория
                            </p>
                            <p
                                class="mt-1 flex items-center gap-2 font-medium text-slate-900 dark:text-white"
                            >
                                <FolderTree class="h-4 w-4 text-indigo-500" />
                                {{
                                    selectedCategory?.name ??
                                    'Категория не найдена'
                                }}
                            </p>
                        </div>

                        <div>
                            <p
                                class="text-xs text-slate-500 dark:text-slate-400"
                            >
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
                                <CheckCircle2
                                    v-if="form.is_active"
                                    class="h-3.5 w-3.5"
                                />
                                <Info v-else class="h-3.5 w-3.5" />
                                {{ form.is_active ? 'Активен' : 'Неактивен' }}
                            </span>
                        </div>
                    </div>
                </div>

                <div
                    class="rounded-2xl border border-slate-200 bg-white p-5 dark:border-slate-800 dark:bg-slate-900"
                >
                    <div class="flex items-center gap-3">
                        <div
                            class="rounded-xl bg-slate-100 p-2.5 dark:bg-slate-800"
                        >
                            <Check
                                class="h-5 w-5 text-slate-600 dark:text-slate-300"
                            />
                        </div>

                        <h3
                            class="font-semibold text-slate-900 dark:text-white"
                        >
                            Перед сохранением
                        </h3>
                    </div>

                    <ul
                        class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300"
                    >
                        <li class="flex items-start gap-2">
                            <Check
                                class="mt-0.5 h-4 w-4 shrink-0 text-emerald-500"
                            />
                            Проверьте название и slug.
                        </li>
                        <li class="flex items-start gap-2">
                            <Check
                                class="mt-0.5 h-4 w-4 shrink-0 text-emerald-500"
                            />
                            Убедитесь, что выбрана правильная категория.
                        </li>
                        <li class="flex items-start gap-2">
                            <Check
                                class="mt-0.5 h-4 w-4 shrink-0 text-emerald-500"
                            />
                            Проверьте состояние активности.
                        </li>
                    </ul>
                </div>
            </aside>
        </div>
    </div>
</template>
