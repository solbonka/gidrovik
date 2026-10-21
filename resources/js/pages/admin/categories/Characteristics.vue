<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { computed } from 'vue';
import { toast } from 'vue-sonner';
import {
    CheckCircle2,
    Hash,
    Info,
    ListChecks,
    LoaderCircle,
    Save,
    SlidersHorizontal,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import { Button } from '@/components/ui/button';
import { index as categoriesIndex } from '@/routes/admin/categories';

defineOptions({
    layout: AdminLayout,
});

interface Category {
    id: number;
    name: string;
    slug: string;
}

interface Characteristic {
    id: number;
    name: string;
    slug: string;
    type: string;
    unit: string | null;
    assigned: boolean;
    is_required: boolean;
    sort_order: number;
}

interface Props {
    category: Category;
    characteristics: Characteristic[];
}

const props = defineProps<Props>();

const form = useForm({
    characteristics: props.characteristics.map((characteristic) => ({
        id: characteristic.id,
        enabled: characteristic.assigned,
        is_required: characteristic.is_required,
        sort_order: characteristic.sort_order,
    })),
});

const typeLabels: Record<string, string> = {
    text: 'Текст',
    string: 'Текст',
    number: 'Число',
    integer: 'Целое число',
    decimal: 'Дробное число',
    select: 'Список',
    boolean: 'Да / Нет',
};

// Строки для таблицы и мобильных карточек: описание + состояние формы
const rows = computed(() =>
    props.characteristics.map((meta, index) => ({
        meta,
        state: form.characteristics[index],
    })),
);

const selectedCount = computed(
    () => form.characteristics.filter((item) => item.enabled).length,
);

const requiredCount = computed(
    () =>
        form.characteristics.filter((item) => item.enabled && item.is_required)
            .length,
);

const setAll = (enabled: boolean): void => {
    for (const item of form.characteristics) {
        item.enabled = enabled;

        if (!enabled) {
            item.is_required = false;
        }
    }
};

const fieldClass =
    'w-24 rounded-lg border border-input bg-background px-3 py-2 text-sm shadow-xs outline-none transition focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30 disabled:cursor-not-allowed disabled:bg-muted disabled:text-muted-foreground';

const checkboxClass = 'size-4 rounded border-input accent-primary';

const hasErrors = computed(() => Object.keys(form.errors).length > 0);

const save = (): void => {
    form.transform((data) => ({
        characteristics: data.characteristics
            .filter((item) => item.enabled)
            .map((item) => ({
                id: item.id,
                is_required: item.is_required,
                sort_order: item.sort_order,
            })),
    })).put(`/admin/categories/${props.category.id}/characteristics`, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Характеристики категории сохранены.');
            // Текущие значения становятся исходными, кнопка снова неактивна
            form.defaults();
        },
        onError: () => {
            toast.error('Не удалось сохранить характеристики.');
        },
    });
};
</script>

<template>
    <Head :title="`Характеристики — ${category.name}`" />

    <div class="space-y-6 pb-4">
        <StockPageHeader
            title="Характеристики категории"
            :description="`Параметры, доступные у товаров категории «${category.name}»`"
            :back-href="categoriesIndex().url"
            back-label="К категориям"
            :icon="SlidersHorizontal"
        />

        <!-- Сводка -->
        <div
            class="flex flex-col gap-3 rounded-2xl border bg-card p-5 shadow-sm sm:flex-row sm:items-center sm:justify-between"
        >
            <div class="min-w-0">
                <p class="text-xs font-medium text-muted-foreground">
                    Настраиваемая категория
                </p>
                <p class="mt-1 truncate font-semibold">{{ category.name }}</p>
                <p class="mt-0.5 font-mono text-xs text-muted-foreground">
                    {{ category.slug }}
                </p>
            </div>

            <div class="flex flex-wrap gap-2">
                <span
                    class="inline-flex items-center gap-2 rounded-xl bg-primary/10 px-3 py-2 text-sm font-semibold text-primary"
                >
                    <ListChecks :size="16" />
                    Выбрано: {{ selectedCount }}
                </span>

                <span
                    class="inline-flex items-center gap-2 rounded-xl bg-amber-500/10 px-3 py-2 text-sm font-semibold text-amber-700 dark:text-amber-400"
                >
                    <CheckCircle2 :size="16" />
                    Обязательных: {{ requiredCount }}
                </span>
            </div>
        </div>

        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm">
            <div
                class="flex flex-col gap-3 border-b px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6"
            >
                <div>
                    <h2 class="font-semibold">Доступные характеристики</h2>
                    <p class="mt-0.5 text-sm text-muted-foreground">
                        Отметьте параметры, которые будут использоваться у
                        товаров этой категории
                    </p>
                </div>

                <div v-if="characteristics.length" class="flex gap-2">
                    <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        @click="setAll(true)"
                    >
                        Включить все
                    </Button>
                    <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        @click="setAll(false)"
                    >
                        Выключить все
                    </Button>
                </div>
            </div>

            <!-- Пустое состояние -->
            <div
                v-if="characteristics.length === 0"
                class="flex flex-col items-center px-6 py-16 text-center"
            >
                <div
                    class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted"
                >
                    <SlidersHorizontal :size="28" class="text-muted-foreground" />
                </div>
                <p class="font-medium">Характеристик пока нет</p>
                <p class="mt-1 max-w-md text-sm text-muted-foreground">
                    Сначала добавьте характеристики в справочнике, затем
                    назначьте их этой категории.
                </p>
                <Button as-child variant="outline" class="mt-5">
                    <Link href="/admin/characteristics">
                        Перейти к справочнику
                    </Link>
                </Button>
            </div>

            <template v-else>
                <!-- Мобильные карточки -->
                <ul class="divide-y md:hidden">
                    <li
                        v-for="row in rows"
                        :key="row.meta.id"
                        class="space-y-3 p-4"
                    >
                        <div class="flex items-start justify-between gap-3">
                            <div class="min-w-0">
                                <h3
                                    class="text-sm font-semibold break-words"
                                    :class="row.state.enabled ? '' : 'text-muted-foreground'"
                                >
                                    {{ row.meta.name }}
                                </h3>
                                <p class="mt-0.5 font-mono text-xs text-muted-foreground">
                                    {{ row.meta.slug }}
                                </p>
                            </div>

                            <span
                                class="shrink-0 rounded-lg bg-muted px-2 py-1 text-xs font-medium"
                            >
                                {{ typeLabels[row.meta.type] ?? row.meta.type }}
                                <template v-if="row.meta.unit">
                                    · {{ row.meta.unit }}
                                </template>
                            </span>
                        </div>

                        <div class="grid grid-cols-2 gap-3">
                            <label
                                class="flex cursor-pointer items-center gap-2.5 rounded-lg border bg-background px-3 py-2.5 text-sm"
                            >
                                <input
                                    v-model="row.state.enabled"
                                    type="checkbox"
                                    :class="checkboxClass"
                                />
                                Включена
                            </label>

                            <label
                                class="flex items-center gap-2.5 rounded-lg border bg-background px-3 py-2.5 text-sm"
                                :class="row.state.enabled ? 'cursor-pointer' : 'cursor-not-allowed opacity-50'"
                            >
                                <input
                                    v-model="row.state.is_required"
                                    type="checkbox"
                                    :disabled="!row.state.enabled"
                                    :class="checkboxClass"
                                />
                                Обязательная
                            </label>
                        </div>

                        <div class="flex items-center justify-between gap-3">
                            <label
                                :for="`sort-m-${row.meta.id}`"
                                class="text-sm text-muted-foreground"
                            >
                                Порядок
                            </label>
                            <input
                                :id="`sort-m-${row.meta.id}`"
                                v-model.number="row.state.sort_order"
                                type="number"
                                min="0"
                                :disabled="!row.state.enabled"
                                :class="fieldClass"
                            />
                        </div>
                    </li>
                </ul>

                <!-- Таблица -->
                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full min-w-[820px] text-left text-sm">
                        <thead>
                        <tr class="border-b bg-muted/40">
                            <th scope="col" class="w-36 px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Использовать</th>
                            <th scope="col" class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Характеристика</th>
                            <th scope="col" class="px-4 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Тип</th>
                            <th scope="col" class="px-4 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Единица</th>
                            <th scope="col" class="w-40 px-4 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Обязательная</th>
                            <th scope="col" class="w-32 px-4 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Порядок</th>
                        </tr>
                        </thead>

                        <tbody class="divide-y">
                        <tr
                            v-for="row in rows"
                            :key="row.meta.id"
                            class="transition-colors hover:bg-muted/40"
                        >
                            <td class="px-6 py-4">
                                <label class="inline-flex cursor-pointer items-center gap-2.5">
                                    <input
                                        v-model="row.state.enabled"
                                        type="checkbox"
                                        :class="checkboxClass"
                                    />
                                    <span
                                        class="text-xs font-semibold"
                                        :class="row.state.enabled ? 'text-primary' : 'text-muted-foreground'"
                                    >
                                            {{ row.state.enabled ? 'Включена' : 'Выключена' }}
                                        </span>
                                </label>
                            </td>

                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex size-9 shrink-0 items-center justify-center rounded-lg"
                                        :class="
                                                row.state.enabled
                                                    ? 'bg-primary/10 text-primary'
                                                    : 'bg-muted text-muted-foreground'
                                            "
                                    >
                                        <Hash :size="17" />
                                    </div>
                                    <div class="min-w-0">
                                        <p
                                            class="font-semibold"
                                            :class="row.state.enabled ? '' : 'text-muted-foreground'"
                                        >
                                            {{ row.meta.name }}
                                        </p>
                                        <p class="mt-0.5 font-mono text-xs text-muted-foreground">
                                            {{ row.meta.slug }}
                                        </p>
                                    </div>
                                </div>
                            </td>

                            <td class="px-4 py-4">
                                    <span class="inline-flex rounded-lg bg-muted px-2.5 py-1.5 text-xs font-medium">
                                        {{ typeLabels[row.meta.type] ?? row.meta.type }}
                                    </span>
                            </td>

                            <td
                                class="px-4 py-4"
                                :class="row.meta.unit ? 'font-medium' : 'text-muted-foreground/60'"
                            >
                                {{ row.meta.unit || '—' }}
                            </td>

                            <td class="px-4 py-4">
                                <label
                                    class="inline-flex items-center gap-2.5"
                                    :class="row.state.enabled ? 'cursor-pointer' : 'cursor-not-allowed opacity-50'"
                                >
                                    <input
                                        v-model="row.state.is_required"
                                        type="checkbox"
                                        :disabled="!row.state.enabled"
                                        :class="checkboxClass"
                                    />
                                    <span
                                        class="text-sm"
                                        :class="
                                                row.state.enabled && row.state.is_required
                                                    ? 'font-medium text-amber-700 dark:text-amber-400'
                                                    : 'text-muted-foreground'
                                            "
                                    >
                                            {{ row.state.enabled && row.state.is_required ? 'Да' : 'Нет' }}
                                        </span>
                                </label>
                            </td>

                            <td class="px-4 py-4">
                                <input
                                    v-model.number="row.state.sort_order"
                                    type="number"
                                    min="0"
                                    :disabled="!row.state.enabled"
                                    :aria-label="`Порядок характеристики ${row.meta.name}`"
                                    :class="fieldClass"
                                />
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </template>
        </section>

        <div
            v-if="hasErrors"
            role="alert"
            class="rounded-xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive"
        >
            Не удалось сохранить: проверьте значения порядка и повторите
            попытку.
        </div>

        <!-- Подсказка -->
        <div class="flex items-start gap-3 rounded-2xl border bg-muted/40 p-4">
            <Info :size="18" class="mt-0.5 shrink-0 text-primary" />
            <div>
                <p class="text-sm font-semibold">Как работает настройка</p>
                <p class="mt-1 text-sm leading-5 text-muted-foreground">
                    Включённые характеристики будут доступны у товаров
                    категории. Обязательные поля нужно заполнять при создании и
                    редактировании товара. Чем меньше значение порядка, тем
                    раньше характеристика отображается.
                </p>
            </div>
        </div>

        <!-- Панель действий -->
        <div
            v-if="characteristics.length"
            class="sticky bottom-4 z-10 flex flex-col gap-3 rounded-2xl border bg-card/95 p-4 shadow-lg backdrop-blur sm:flex-row sm:items-center sm:justify-between sm:px-6"
        >
            <p class="text-sm text-muted-foreground">
                <template v-if="form.isDirty">
                    Есть несохранённые изменения ·
                </template>
                Выбрано
                <span class="font-semibold text-foreground">{{ selectedCount }}</span>
                из {{ characteristics.length }}
            </p>

            <Button
                type="button"
                :disabled="form.processing || !form.isDirty"
                @click="save"
            >
                <LoaderCircle
                    v-if="form.processing"
                    :size="17"
                    class="mr-2 animate-spin"
                />
                <Save v-else :size="17" class="mr-2" />
                {{ form.processing ? 'Сохранение...' : 'Сохранить изменения' }}
            </Button>
        </div>
    </div>
</template>
