
<script setup lang="ts">
import { computed } from 'vue'
import { Head, Link, useForm } from '@inertiajs/vue3'
import {
    ArrowLeft,
    SlidersHorizontal,
    ListChecks,
    CheckCircle2,
    Circle,
    Save,
    Info,
    Hash,
    Settings2,
    X,
} from '@lucide/vue'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { index as categoriesIndex } from '@/routes/admin/categories'

defineOptions({
    layout: AdminLayout,
})

interface Category {
    id: number
    name: string
    slug: string
}

interface Characteristic {
    id: number
    name: string
    slug: string
    type: string
    unit: string | null
    assigned: boolean
    is_required: boolean
    sort_order: number
}

interface Props {
    category: Category
    characteristics: Characteristic[]
}

const props = defineProps<Props>()

const form = useForm({
    characteristics: props.characteristics.map((characteristic) => ({
        id: characteristic.id,
        enabled: characteristic.assigned,
        is_required: characteristic.is_required,
        sort_order: characteristic.sort_order,
    })),
})

const typeLabels: Record<string, string> = {
    text: 'Текст',
    string: 'Текст',
    number: 'Число',
    integer: 'Целое число',
    decimal: 'Дробное число',
    select: 'Список',
    boolean: 'Да / Нет',
}

const selectedCount = computed(() => {
    return form.characteristics.filter(
        (characteristic) => characteristic.enabled,
    ).length
})

const requiredCount = computed(() => {
    return form.characteristics.filter(
        (characteristic) =>
            characteristic.enabled && characteristic.is_required,
    ).length
})

const hasChanges = computed(() => form.isDirty)

const save = (): void => {
    const selectedCharacteristics = form.characteristics
        .filter((characteristic) => characteristic.enabled)
        .map((characteristic) => ({
            id: characteristic.id,
            is_required: characteristic.is_required,
            sort_order: characteristic.sort_order,
        }))

    form.transform(() => ({
        characteristics: selectedCharacteristics,
    })).put(`/admin/categories/${props.category.id}/characteristics`, {
        preserveScroll: true,
    })
}
</script>

<template>
    <Head :title="`Характеристики — ${category.name}`" />

    <div class="space-y-6 pb-8">
        <!-- Шапка страницы -->
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
                        <SlidersHorizontal :size="27" />
                    </div>

                    <div class="min-w-0">
                        <div
                            class="mb-1 flex flex-wrap items-center gap-2 text-xs font-medium text-slate-300"
                        >
                            <span>Склад</span>
                            <span class="text-slate-500">/</span>

                            <Link
                                :href="categoriesIndex().url"
                                class="transition hover:text-white"
                            >
                                Категории
                            </Link>

                            <span class="text-slate-500">/</span>
                            <span class="text-white/90">Характеристики</span>
                        </div>

                        <h1
                            class="break-words text-2xl font-bold tracking-tight text-white sm:text-3xl"
                        >
                            Характеристики категории
                        </h1>

                        <p class="mt-2 text-sm leading-6 text-slate-300">
                            Настройте параметры, доступные для категории
                            <span class="font-semibold text-white">
                                {{ category.name }}
                            </span>.
                        </p>
                    </div>
                </div>

                <Link
                    :href="categoriesIndex().url"
                    class="inline-flex min-h-10 items-center justify-center gap-2 self-start rounded-xl border border-white/15 bg-white/10 px-4 py-2 text-sm font-medium text-white transition hover:bg-white/15 focus:outline-none focus:ring-2 focus:ring-white/50 sm:self-center"
                >
                    <ArrowLeft :size="16" />
                    К категориям
                </Link>
            </div>
        </div>

        <!-- Информация о категории -->
        <div
            class="flex flex-col gap-3 rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-700 dark:bg-slate-900 sm:flex-row sm:items-center sm:justify-between sm:px-6"
        >
            <div class="flex min-w-0 items-center gap-3">
                <div
                    class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400"
                >
                    <Settings2 :size="21" />
                </div>

                <div class="min-w-0">
                    <p class="text-xs font-medium text-slate-500 dark:text-slate-400">
                        Настраиваемая категория
                    </p>
                    <p class="mt-1 truncate text-base font-semibold text-slate-900 dark:text-white">
                        {{ category.name }}
                    </p>
                    <p class="mt-1 text-xs text-slate-500 dark:text-slate-400">
                        {{ category.slug }}
                    </p>
                </div>
            </div>

            <div class="flex flex-wrap gap-2">
                <span
                    class="inline-flex items-center gap-2 rounded-xl bg-indigo-50 px-3 py-2 text-sm font-semibold text-indigo-700 dark:bg-indigo-500/10 dark:text-indigo-300"
                >
                    <ListChecks :size="16" />
                    {{ selectedCount }} выбрано
                </span>

                <span
                    class="inline-flex items-center gap-2 rounded-xl bg-amber-50 px-3 py-2 text-sm font-semibold text-amber-700 dark:bg-amber-500/10 dark:text-amber-300"
                >
                    <CheckCircle2 :size="16" />
                    {{ requiredCount }} обязательных
                </span>
            </div>
        </div>

        <!-- Основная карточка -->
        <div
            class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-700 dark:bg-slate-900"
        >
            <div
                class="flex flex-col gap-4 border-b border-slate-200 px-5 py-5 dark:border-slate-700 sm:flex-row sm:items-center sm:justify-between sm:px-6"
            >
                <div>
                    <h2 class="text-lg font-semibold text-slate-900 dark:text-white">
                        Доступные характеристики
                    </h2>
                    <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
                        Отметьте параметры, которые должны использоваться у товаров этой категории.
                    </p>
                </div>

                <button
                    type="button"
                    :disabled="form.processing || !hasChanges"
                    class="inline-flex min-h-10 shrink-0 items-center justify-center gap-2 rounded-xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus:outline-none focus:ring-4 focus:ring-indigo-500/20 disabled:cursor-not-allowed disabled:opacity-50"
                    @click="save"
                >
                    <span
                        v-if="form.processing"
                        class="size-4 animate-spin rounded-full border-2 border-white/30 border-t-white"
                    />
                    <Save v-else :size="16" />
                    {{ form.processing ? 'Сохранение...' : 'Сохранить изменения' }}
                </button>
            </div>

            <!-- Таблица -->
            <div class="overflow-x-auto">
                <table class="w-full min-w-[850px] text-left text-sm">
                    <thead>
                    <tr
                        class="border-b border-slate-200 bg-slate-50/80 dark:border-slate-700 dark:bg-slate-800/60"
                    >
                        <th
                            class="w-32 px-5 py-4 text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400 sm:px-6"
                        >
                            Использовать
                        </th>

                        <th
                            class="px-5 py-4 text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400 sm:px-6"
                        >
                            Характеристика
                        </th>

                        <th
                            class="px-4 py-4 text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400"
                        >
                            Тип
                        </th>

                        <th
                            class="px-4 py-4 text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400"
                        >
                            Единица
                        </th>

                        <th
                            class="w-36 px-4 py-4 text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400"
                        >
                            Обязательная
                        </th>

                        <th
                            class="w-32 px-4 py-4 text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400"
                        >
                            Порядок
                        </th>
                    </tr>
                    </thead>

                    <tbody class="divide-y divide-slate-100 dark:divide-slate-800">
                    <tr
                        v-for="(characteristic, index) in characteristics"
                        :key="characteristic.id"
                        class="transition-colors hover:bg-slate-50/80 dark:hover:bg-slate-800/40"
                    >
                        <!-- Использовать -->
                        <td class="px-5 py-4 sm:px-6">
                            <label class="inline-flex cursor-pointer items-center gap-2.5">
                                <input
                                    v-model="form.characteristics[index].enabled"
                                    type="checkbox"
                                    class="size-4 rounded border-slate-300 text-indigo-600 focus:ring-2 focus:ring-indigo-500/20 dark:border-slate-600 dark:bg-slate-800"
                                />

                                <span
                                    class="text-xs font-semibold"
                                    :class="
                                            form.characteristics[index].enabled
                                                ? 'text-indigo-700 dark:text-indigo-300'
                                                : 'text-slate-400 dark:text-slate-500'
                                        "
                                >
                                        {{
                                        form.characteristics[index].enabled
                                            ? 'Включена'
                                            : 'Выключена'
                                    }}
                                    </span>
                            </label>
                        </td>

                        <!-- Название -->
                        <td class="px-5 py-4 sm:px-6">
                            <div class="flex items-center gap-3">
                                <div
                                    class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg"
                                    :class="
                                            form.characteristics[index].enabled
                                                ? 'bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400'
                                                : 'bg-slate-100 text-slate-400 dark:bg-slate-800 dark:text-slate-500'
                                        "
                                >
                                    <Hash :size="17" />
                                </div>

                                <div class="min-w-0">
                                    <p
                                        class="font-semibold"
                                        :class="
                                                form.characteristics[index].enabled
                                                    ? 'text-slate-900 dark:text-white'
                                                    : 'text-slate-500 dark:text-slate-400'
                                            "
                                    >
                                        {{ characteristic.name }}
                                    </p>
                                    <p class="mt-1 text-xs text-slate-500 dark:text-slate-400">
                                        {{ characteristic.slug }}
                                    </p>
                                </div>
                            </div>
                        </td>

                        <!-- Тип -->
                        <td class="px-4 py-4">
                                <span
                                    class="inline-flex items-center rounded-lg bg-slate-100 px-2.5 py-1.5 text-xs font-medium text-slate-700 dark:bg-slate-800 dark:text-slate-300"
                                >
                                    {{
                                        typeLabels[characteristic.type]
                                        ?? characteristic.type
                                    }}
                                </span>
                        </td>

                        <!-- Единица -->
                        <td class="px-4 py-4">
                                <span
                                    class="text-sm"
                                    :class="
                                        characteristic.unit
                                            ? 'font-medium text-slate-700 dark:text-slate-300'
                                            : 'text-slate-400 dark:text-slate-500'
                                    "
                                >
                                    {{ characteristic.unit || '—' }}
                                </span>
                        </td>

                        <!-- Обязательность -->
                        <td class="px-4 py-4">
                            <label
                                class="inline-flex items-center gap-2.5"
                                :class="
                                        form.characteristics[index].enabled
                                            ? 'cursor-pointer'
                                            : 'cursor-not-allowed opacity-50'
                                    "
                            >
                                <input
                                    v-model="form.characteristics[index].is_required"
                                    type="checkbox"
                                    :disabled="!form.characteristics[index].enabled"
                                    class="size-4 rounded border-slate-300 text-amber-600 focus:ring-2 focus:ring-amber-500/20 disabled:cursor-not-allowed dark:border-slate-600 dark:bg-slate-800"
                                />

                                <span
                                    class="text-sm"
                                    :class="
                                            form.characteristics[index].is_required &&
                                            form.characteristics[index].enabled
                                                ? 'font-medium text-amber-700 dark:text-amber-300'
                                                : 'text-slate-500 dark:text-slate-400'
                                        "
                                >
                                        {{
                                        form.characteristics[index].is_required &&
                                        form.characteristics[index].enabled
                                            ? 'Да'
                                            : 'Нет'
                                    }}
                                    </span>
                            </label>
                        </td>

                        <!-- Порядок -->
                        <td class="px-4 py-4">
                            <input
                                v-model.number="form.characteristics[index].sort_order"
                                type="number"
                                min="0"
                                :disabled="!form.characteristics[index].enabled"
                                :aria-label="`Порядок характеристики ${characteristic.name}`"
                                class="w-24 rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 outline-none transition focus:border-indigo-400 focus:ring-4 focus:ring-indigo-500/10 disabled:cursor-not-allowed disabled:bg-slate-100 disabled:text-slate-400 dark:border-slate-700 dark:bg-slate-800 dark:text-white dark:disabled:bg-slate-800/50"
                            />
                        </td>
                    </tr>

                    <tr v-if="characteristics.length === 0">
                        <td colspan="6" class="px-6 py-16 text-center">
                            <div
                                class="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-slate-100 text-slate-400 dark:bg-slate-800 dark:text-slate-500"
                            >
                                <SlidersHorizontal :size="28" />
                            </div>

                            <h3 class="mt-4 text-sm font-semibold text-slate-900 dark:text-white">
                                Характеристик пока нет
                            </h3>

                            <p class="mx-auto mt-1 max-w-md text-sm text-slate-500 dark:text-slate-400">
                                Сначала добавьте характеристики в справочнике, затем назначьте их этой категории.
                            </p>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <!-- Нижняя панель -->
            <div
                class="flex flex-col gap-4 border-t border-slate-200 bg-slate-50/70 px-5 py-4 dark:border-slate-700 dark:bg-slate-800/30 sm:flex-row sm:items-center sm:justify-between sm:px-6"
            >
                <p class="flex items-center gap-2 text-sm text-slate-500 dark:text-slate-400">
                    <CheckCircle2 :size="16" class="shrink-0 text-emerald-500" />
                    Выбрано характеристик:
                    <span class="font-semibold text-slate-900 dark:text-white">
                        {{ selectedCount }}
                    </span>
                    из {{ characteristics.length }}
                </p>

                <button
                    type="button"
                    :disabled="form.processing || !hasChanges"
                    class="inline-flex min-h-11 items-center justify-center gap-2 rounded-xl bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-indigo-700 focus:outline-none focus:ring-4 focus:ring-indigo-500/20 disabled:cursor-not-allowed disabled:opacity-50"
                    @click="save"
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
                    Как работает настройка
                </p>
                <p class="mt-1 text-sm leading-5 text-blue-800/80 dark:text-blue-300/80">
                    Включённые характеристики будут доступны у товаров категории. Обязательные поля должны заполняться при создании или редактировании товара, если это предусмотрено серверной валидацией. Чем меньше значение порядка, тем раньше характеристика отображается.
                </p>
            </div>
        </div>
    </div>
</template>
