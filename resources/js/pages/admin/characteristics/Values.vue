<script setup lang="ts">
import { Head, Link, router, useForm } from '@inertiajs/vue3';
import { toast } from 'vue-sonner';
import {
    ArrowLeft,
    Check,
    ChevronDown,
    List,
    ListPlus,
    Pencil,
    Plus,
    Save,
    Settings2,
    Trash2,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { index } from '@/routes/admin/characteristics';

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

interface Value {
    id: number;
    value: string;
    sort_order: number;
}

interface Props {
    characteristic: Characteristic;
    values: Value[];
}

const props = defineProps<Props>();

const form = useForm({
    value: '',
});

const editingId = ref<number | null>(null);
const editingValue = ref('');

const startEdit = (value: Value): void => {
    editingId.value = value.id;
    editingValue.value = value.value;
};

const cancelEdit = (): void => {
    editingId.value = null;
    editingValue.value = '';
};

const submitAdd = (): void => {
    if (!form.value.value.trim()) return;

    form.post(`/admin/characteristics/${props.characteristic.id}/values`, {
        onSuccess: () => {
            form.value = '';
            toast.success('Значение добавлено.');
        },
        onError: () => {
            toast.error('Проверьте правильность заполнения.');
        },
    });
};

const submitEdit = (): void => {
    if (!editingId.value || !editingValue.value.trim()) return;

    router.patch(
        `/admin/characteristics/${props.characteristic.id}/values/${editingId.value}`,
        { value: editingValue.value },
        {
            onSuccess: () => {
                cancelEdit();
                toast.success('Значение обновлено.');
            },
            onError: () => {
                toast.error('Проверьте правильность заполнения.');
            },
        }
    );
};

const destroy = (id: number): void => {
    router.delete(`/admin/characteristics/${props.characteristic.id}/values/${id}`, {
        onSuccess: () => {
            toast.success('Значение удалено.');
        },
    });
};
</script>

<template>
    <Head :title="`Варианты: ${characteristic.name}`" />

    <div class="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6 lg:p-8">
        <!-- Заголовок -->
        <div
            class="relative overflow-hidden rounded-2xl border border-indigo-200/60 bg-gradient-to-br from-indigo-50 via-white to-violet-50 p-6 shadow-sm sm:p-8 dark:border-indigo-900/50 dark:from-indigo-950/50 dark:via-gray-950 dark:to-violet-950/30"
        >
            <div class="relative flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between">
                <div class="flex items-start gap-4">
                    <div
                        class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-indigo-500 to-violet-600 text-white shadow-lg shadow-indigo-500/20"
                    >
                        <List class="size-6" />
                    </div>

                    <div class="min-w-0">
                        <div class="mb-2 flex flex-wrap items-center gap-2">
                            <span
                                class="rounded-full border border-indigo-200 bg-indigo-100/70 px-2.5 py-1 text-xs font-medium text-indigo-700 dark:border-indigo-800 dark:bg-indigo-900/40 dark:text-indigo-300"
                            >
                                Справочники
                            </span>
                            <Link
                                :href="index.url()"
                                class="text-xs text-muted-foreground hover:text-primary transition-colors"
                            >
                                Характеристики
                            </Link>
                            <span class="text-xs text-muted-foreground">/ Варианты</span>
                        </div>

                        <h1
                            class="text-2xl font-bold tracking-tight text-gray-900 sm:text-3xl dark:text-white"
                        >
                            Варианты: {{ characteristic.name }}
                        </h1>

                        <p class="mt-2 max-w-xl text-sm leading-6 text-gray-600 dark:text-gray-400">
                            Управляйте списком доступных значений для характеристики.
                            Эти варианты будут показаны при заполнении товаров.
                        </p>
                    </div>
                </div>

                <Link
                    :href="`/admin/characteristics/${characteristic.id}/edit`"
                    class="inline-flex shrink-0 items-center justify-center gap-2 self-start rounded-xl border border-gray-200 bg-white/80 px-4 py-2.5 text-sm font-medium text-gray-700 shadow-sm transition hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-700 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:outline-none sm:self-center dark:border-gray-700 dark:bg-gray-900/70 dark:text-gray-200 dark:hover:border-indigo-700 dark:hover:bg-indigo-950/50 dark:hover:text-indigo-300"
                >
                    <ArrowLeft class="size-4" />
                    К редактированию
                </Link>
            </div>
        </div>

        <!-- Форма добавления -->
        <div
            class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-800 dark:bg-gray-950"
        >
            <div class="border-b border-gray-100 px-5 py-4 sm:px-6 dark:border-gray-800">
                <div class="flex items-center gap-3">
                    <div
                        class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-950/60 dark:text-indigo-400"
                    >
                        <Plus class="size-5" />
                    </div>
                    <div>
                        <h2 class="font-semibold text-gray-900 dark:text-white">Добавить значение</h2>
                        <p class="mt-0.5 text-sm text-muted-foreground">
                            Введите новый вариант и нажмите Enter
                        </p>
                    </div>
                </div>
            </div>

            <div class="p-5 sm:p-6">
                <form @submit.prevent="submitAdd">
                    <div class="flex gap-3">
                        <input
                            v-model="form.value"
                            type="text"
                            placeholder="Например: 50 мм"
                            class="flex-1 rounded-xl border border-gray-200 bg-white px-4 py-3 text-sm text-gray-900 shadow-sm transition outline-none placeholder:text-gray-400 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 dark:bg-gray-900 dark:text-white dark:border-gray-700"
                        />
                        <button
                            type="submit"
                            :disabled="form.processing || !form.value.trim()"
                            class="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-indigo-600 to-violet-600 px-5 py-3 text-sm font-semibold text-white shadow-md shadow-indigo-500/20 transition hover:from-indigo-700 hover:to-violet-700 disabled:cursor-not-allowed disabled:opacity-60"
                        >
                            <span v-if="form.processing" class="size-4 animate-spin rounded-full border-2 border-white/30 border-t-white" />
                            <Save v-else class="size-4" />
                            Добавить
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Список значений -->
        <div
            class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-gray-800 dark:bg-gray-950"
        >
            <div class="border-b border-gray-100 px-5 py-4 sm:px-6 dark:border-gray-800">
                <div class="flex items-center gap-3">
                    <div
                        class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-950/60 dark:text-indigo-400"
                    >
                        <List class="size-5" />
                    </div>
                    <div>
                        <h2 class="font-semibold text-gray-900 dark:text-white">
                            Значения
                            <span class="ml-2 text-sm font-normal text-muted-foreground">
                                ({{ values.length }})
                            </span>
                        </h2>
                    </div>
                </div>
            </div>

            <div v-if="values.length === 0" class="p-12 text-center">
                <div class="mx-auto mb-4 flex size-16 items-center justify-center rounded-full bg-muted">
                    <ListPlus class="size-7 text-muted-foreground" />
                </div>
                <h3 class="text-lg font-semibold">Пока нет значений</h3>
                <p class="mt-1 text-sm text-muted-foreground">
                    Добавьте варианты, которые будут доступны при заполнении товаров
                </p>
            </div>

            <ul v-else class="divide-y dark:divide-gray-800">
                <li
                    v-for="(item, index) in values"
                    :key="item.id"
                    class="flex items-center gap-3 px-5 py-4 sm:px-6 transition-colors hover:bg-gray-50/50 dark:hover:bg-gray-900/50"
                >
                    <span class="flex size-8 shrink-0 items-center justify-center rounded-lg bg-muted text-xs font-medium text-muted-foreground">
                        {{ index + 1 }}
                    </span>

                    <!-- Режим просмотра -->
                    <template v-if="editingId !== item.id">
                        <span class="flex-1 text-sm font-medium text-gray-900 dark:text-white">
                            {{ item.value }}
                        </span>

                        <div class="flex shrink-0 gap-1">
                            <button
                                @click="startEdit(item)"
                                class="inline-flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs font-medium text-gray-600 hover:bg-indigo-50 hover:text-indigo-700 transition-colors dark:text-gray-400 dark:hover:bg-indigo-950/50 dark:hover:text-indigo-400"
                            >
                                <Pencil class="size-3.5" />
                                Изменить
                            </button>
                            <button
                                @click="destroy(item.id)"
                                class="inline-flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs font-medium text-gray-600 hover:bg-red-50 hover:text-red-700 transition-colors dark:text-gray-400 dark:hover:bg-red-950/50 dark:hover:text-red-400"
                            >
                                <Trash2 class="size-3.5" />
                                Удалить
                            </button>
                        </div>
                    </template>

                    <!-- Режим редактирования -->
                    <template v-else>
                        <form @submit.prevent="submitEdit" class="flex flex-1 gap-3">
                            <input
                                v-model="editingValue"
                                type="text"
                                class="flex-1 rounded-xl border border-indigo-300 bg-white px-4 py-2.5 text-sm text-gray-900 shadow-sm outline-none focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 dark:bg-gray-900 dark:text-white dark:border-gray-700"
                                autofocus
                            />
                            <button
                                type="submit"
                                :disabled="form.processing || !editingValue.trim()"
                                class="inline-flex shrink-0 items-center gap-1.5 rounded-xl bg-indigo-600 px-3 py-2.5 text-xs font-medium text-white shadow-sm transition hover:bg-indigo-700 disabled:opacity-60"
                            >
                                <Check class="size-3.5" />
                            </button>
                            <button
                                type="button"
                                @click="cancelEdit"
                                class="inline-flex shrink-0 items-center gap-1.5 rounded-xl border border-gray-200 bg-white px-3 py-2.5 text-xs font-medium text-gray-700 shadow-sm transition hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-900 dark:text-gray-300 dark:hover:bg-gray-800"
                            >
                                <X class="size-3.5" />
                            </button>
                        </form>
                    </template>
                </li>
            </ul>
        </div>
    </div>
</template>
