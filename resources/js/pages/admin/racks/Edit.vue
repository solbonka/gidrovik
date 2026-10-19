<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { toast } from 'vue-sonner';
import {
    ArrowLeft,
    Check,
    Grid2X2,
    Info,
    LoaderCircle,
    Package,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { index, update } from '@/routes/admin/racks';

defineOptions({
    layout: AdminLayout,
});

interface Location {
    id: number;
    number: number;
}

interface Rack {
    id: number;
    code: string;
    name: string | null;
    locations: Location[];
}

interface Props {
    rack: Rack;
}

const props = defineProps<Props>();

const form = useForm({
    code: props.rack.code,
    name: props.rack.name ?? '',
});

const submit = (): void => {
    form.put(update(props.rack.id).url, {
        onSuccess: () => {
            toast.success('Стеллаж успешно обновлён.');
        },
    });
};
</script>

<template>
    <Head :title="`Стеллаж ${rack.code}`" />

    <div class="mx-auto max-w-3xl space-y-8">
        <!-- Заголовок -->
        <header>
            <Link
                :href="index().url"
                class="mb-5 inline-flex items-center gap-2 text-sm font-medium text-muted-foreground transition-colors hover:text-primary"
            >
                <ArrowLeft :size="16" />
                Назад к стеллажам
            </Link>

            <div class="flex items-center gap-4">
                <div
                    class="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-primary to-indigo-600 text-white shadow-lg"
                >
                    <Grid2X2 :size="26" />
                </div>

                <div>
                    <h1
                        class="bg-gradient-to-r from-foreground to-muted-foreground bg-clip-text text-3xl font-bold text-transparent"
                    >
                        Редактирование стеллажа
                    </h1>

                    <p class="mt-1 text-sm text-muted-foreground">
                        Изменение параметров стеллажа {{ rack.code }}.
                    </p>
                </div>
            </div>
        </header>

        <!-- Информация о ячейках -->
        <div
            class="flex items-start gap-3 rounded-2xl border border-primary/15 bg-gradient-to-r from-primary/5 to-indigo-500/5 p-4"
        >
            <div
                class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-primary/10 to-indigo-500/10 text-primary"
            >
                <Info :size="20" />
            </div>

            <div>
                <p class="text-sm font-semibold text-foreground">
                    Ячейки стеллажа
                </p>

                <p class="mt-1 text-sm leading-relaxed text-muted-foreground">
                    Сейчас создано:
                    <span class="font-semibold text-foreground">
                        {{ rack.locations.length }}
                    </span>
                    {{
                        rack.locations.length === 1
                            ? 'ячейка'
                            : rack.locations.length >= 2 &&
                                rack.locations.length <= 4
                              ? 'ячейки'
                              : 'ячеек'
                    }}.
                </p>

                <p class="mt-1 text-xs text-muted-foreground">
                    Управление ячейками доступно отдельно на странице стеллажей.
                </p>
            </div>
        </div>

        <!-- Форма -->
        <form
            class="overflow-hidden rounded-2xl border border-border/50 bg-gradient-to-br from-white to-muted/20 shadow-sm"
            @submit.prevent="submit"
        >
            <div class="border-b border-border/50 px-6 py-5">
                <div class="flex items-center gap-3">
                    <div
                        class="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary/10 to-indigo-500/10 text-primary"
                    >
                        <Package :size="20" />
                    </div>

                    <div>
                        <h2 class="font-semibold text-foreground">
                            Основные сведения
                        </h2>

                        <p class="mt-1 text-sm text-muted-foreground">
                            Измените код или название стеллажа.
                        </p>
                    </div>
                </div>
            </div>

            <div class="space-y-6 p-6">
                <!-- Код -->
                <div>
                    <label
                        for="code"
                        class="mb-2 block text-sm font-semibold text-foreground"
                    >
                        Код стеллажа
                        <span class="text-red-500">*</span>
                    </label>

                    <input
                        id="code"
                        v-model="form.code"
                        type="text"
                        maxlength="10"
                        autocomplete="off"
                        placeholder="Например, A"
                        class="w-full rounded-xl border border-border bg-background px-4 py-3 text-sm text-foreground transition-all outline-none placeholder:text-muted-foreground/60 focus:border-primary/50 focus:ring-2 focus:ring-primary/15"
                        :class="{
                            'border-red-500 focus:border-red-500 focus:ring-red-500/10':
                                form.errors.code,
                        }"
                    />

                    <p
                        v-if="form.errors.code"
                        class="mt-2 text-sm text-red-600"
                    >
                        {{ form.errors.code }}
                    </p>

                    <p v-else class="mt-2 text-xs text-muted-foreground">
                        Короткое обозначение для идентификации стеллажа.
                    </p>
                </div>

                <!-- Название -->
                <div>
                    <label
                        for="name"
                        class="mb-2 block text-sm font-semibold text-foreground"
                    >
                        Название
                        <span class="text-red-500">*</span>
                    </label>

                    <input
                        id="name"
                        v-model="form.name"
                        type="text"
                        maxlength="255"
                        autocomplete="off"
                        placeholder="Например, Стеллаж A"
                        class="w-full rounded-xl border border-border bg-background px-4 py-3 text-sm text-foreground transition-all outline-none placeholder:text-muted-foreground/60 focus:border-primary/50 focus:ring-2 focus:ring-primary/15"
                        :class="{
                            'border-red-500 focus:border-red-500 focus:ring-red-500/10':
                                form.errors.name,
                        }"
                    />

                    <p
                        v-if="form.errors.name"
                        class="mt-2 text-sm text-red-600"
                    >
                        {{ form.errors.name }}
                    </p>

                    <p v-else class="mt-2 text-xs text-muted-foreground">
                        Понятное название для отображения в складской системе.
                    </p>
                </div>
            </div>

            <!-- Кнопки -->
            <div
                class="flex flex-col-reverse gap-3 border-t border-border/50 bg-muted/20 px-6 py-5 sm:flex-row sm:justify-end"
            >
                <Link
                    :href="index().url"
                    class="inline-flex items-center justify-center gap-2 rounded-xl border border-primary/20 bg-gradient-to-r from-primary/5 to-indigo-500/5 px-5 py-3 text-sm font-semibold text-foreground shadow-sm transition-all duration-200 hover:border-primary/40 hover:from-primary/10 hover:to-indigo-500/10 focus-visible:ring-2 focus-visible:ring-primary/50 focus-visible:outline-none"
                >
                    <ArrowLeft :size="16" />
                    Отмена
                </Link>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="inline-flex items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-primary to-indigo-600 px-5 py-3 text-sm font-semibold text-white shadow-md transition-all duration-200 hover:-translate-y-0.5 hover:from-primary/90 hover:to-indigo-600/90 hover:shadow-lg focus-visible:ring-2 focus-visible:ring-primary/50 focus-visible:outline-none disabled:pointer-events-none disabled:opacity-50"
                >
                    <LoaderCircle
                        v-if="form.processing"
                        :size="18"
                        class="animate-spin"
                    />

                    <Check v-else :size="18" />

                    {{
                        form.processing
                            ? 'Сохранение...'
                            : 'Сохранить изменения'
                    }}
                </button>
            </div>
        </form>
    </div>
</template>
