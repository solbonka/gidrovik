<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { computed } from 'vue';
import { toast } from 'vue-sonner';
import {
    ArrowLeft,
    Check,
    Grid2X2,
    Info,
    LoaderCircle,
    RotateCcw,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
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
    warehouse_id: number | null;
    locations: Location[];
}

interface Warehouse {
    id: number;
    name: string;
}

interface Props {
    rack: Rack;
    warehouses: Warehouse[];
}

const props = defineProps<Props>();

const form = useForm({
    code: props.rack.code,
    name: props.rack.name ?? '',
    warehouse_id: props.rack.warehouse_id,
});

const submit = (): void => {
    form.put(update(props.rack.id).url, {
        onSuccess: () => {
            toast.success('Стеллаж успешно обновлён.');
        },
        onError: () => {
            toast.error('Не удалось сохранить изменения. Проверьте поля формы.');
        },
    });
};

function pluralize(count: number, one: string, few: string, many: string) {
    const mod10 = count % 10;
    const mod100 = count % 100;

    if (mod10 === 1 && mod100 !== 11) return one;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;

    return many;
}

const locationsCount = computed(() => props.rack.locations.length);

const sortedLocations = computed(() =>
    [...props.rack.locations].sort((a, b) => a.number - b.number),
);

const locationsLabel = computed(
    () =>
        `${locationsCount.value} ${pluralize(locationsCount.value, 'ячейка', 'ячейки', 'ячеек')}`,
);
</script>

<template>
    <Head :title="`Стеллаж ${rack.code}`" />

    <div class="mx-auto max-w-5xl space-y-6">
        <!-- Заголовок -->
        <header>
            <Link
                :href="index().url"
                class="mb-4 inline-flex items-center gap-2 text-sm font-medium text-muted-foreground transition-colors hover:text-primary"
            >
                <ArrowLeft :size="16" />
                Назад к стеллажам
            </Link>

            <div class="flex items-center gap-4">
                <div
                    class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                >
                    <Grid2X2 :size="24" />
                </div>

                <div>
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Редактирование стеллажа
                    </h1>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Изменение параметров стеллажа
                        <span class="font-medium text-foreground">{{ rack.code }}</span>
                    </p>
                </div>
            </div>
        </header>

        <div class="grid gap-6 lg:grid-cols-[minmax(0,1fr)_280px]">
            <!-- Форма -->
            <form
                class="overflow-hidden rounded-2xl border bg-card shadow-sm"
                novalidate
                @submit.prevent="submit"
            >
                <div class="border-b px-6 py-5">
                    <h2 class="font-semibold">Основные сведения</h2>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Измените код или название стеллажа
                    </p>
                </div>

                <div class="space-y-6 p-6">
                    <!-- Склад -->
                    <div class="space-y-2">
                        <Label for="warehouse_id">
                            Склад
                            <span class="text-destructive" aria-hidden="true">*</span>
                        </Label>

                        <Select v-model="form.warehouse_id" required>
                            <SelectTrigger id="warehouse_id" class="h-11 rounded-xl">
                                <SelectValue placeholder="Выберите склад" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem
                                    v-for="warehouse in warehouses"
                                    :key="warehouse.id"
                                    :value="warehouse.id.toString()"
                                >
                                    {{ warehouse.name }}
                                </SelectItem>
                            </SelectContent>
                        </Select>

                        <p
                            v-if="form.errors.warehouse_id"
                            class="text-sm text-destructive"
                        >
                            {{ form.errors.warehouse_id }}
                        </p>
                    </div>

                    <!-- Код -->
                    <div class="space-y-2">
                        <Label for="code">
                            Код стеллажа
                            <span class="text-destructive" aria-hidden="true">*</span>
                        </Label>

                        <Input
                            id="code"
                            v-model="form.code"
                            type="text"
                            maxlength="10"
                            placeholder="Например, A"
                            autocomplete="off"
                            required
                            class="h-11 rounded-xl"
                            :aria-invalid="!!form.errors.code"
                            :aria-describedby="form.errors.code ? 'code-error' : 'code-hint'"
                        />

                        <div class="flex items-start justify-between gap-3">
                            <p
                                v-if="form.errors.code"
                                id="code-error"
                                class="text-sm text-destructive"
                            >
                                {{ form.errors.code }}
                            </p>
                            <p
                                v-else
                                id="code-hint"
                                class="text-xs text-muted-foreground"
                            >
                                Короткое обозначение для идентификации
                                стеллажа.
                            </p>

                            <span class="shrink-0 text-xs text-muted-foreground tabular-nums">
                                {{ form.code.length }}/10
                            </span>
                        </div>
                    </div>

                    <!-- Название -->
                    <div class="space-y-2">
                        <Label for="name">
                            Название
                            <span class="text-destructive" aria-hidden="true">*</span>
                        </Label>

                        <Input
                            id="name"
                            v-model="form.name"
                            type="text"
                            maxlength="255"
                            placeholder="Например, Стеллаж A"
                            autocomplete="off"
                            required
                            class="h-11 rounded-xl"
                            :aria-invalid="!!form.errors.name"
                            :aria-describedby="form.errors.name ? 'name-error' : 'name-hint'"
                        />

                        <p
                            v-if="form.errors.name"
                            id="name-error"
                            class="text-sm text-destructive"
                        >
                            {{ form.errors.name }}
                        </p>
                        <p
                            v-else
                            id="name-hint"
                            class="text-xs text-muted-foreground"
                        >
                            Понятное название для отображения в складской
                            системе.
                        </p>
                    </div>
                </div>

                <!-- Действия -->
                <div
                    class="flex flex-col-reverse gap-3 border-t bg-muted/30 px-6 py-4 sm:flex-row sm:items-center sm:justify-between"
                >
                    <Button
                        v-if="form.isDirty"
                        type="button"
                        variant="ghost"
                        class="text-muted-foreground sm:mr-auto"
                        :disabled="form.processing"
                        @click="form.reset()"
                    >
                        <RotateCcw :size="15" class="mr-2" />
                        Вернуть как было
                    </Button>

                    <div class="flex flex-col-reverse gap-3 sm:ml-auto sm:flex-row">
                        <Button as-child variant="outline" :disabled="form.processing">
                            <Link :href="index().url">Отмена</Link>
                        </Button>

                        <Button
                            type="submit"
                            :disabled="form.processing || !form.isDirty"
                        >
                            <LoaderCircle
                                v-if="form.processing"
                                :size="17"
                                class="mr-2 animate-spin"
                            />
                            <Check v-else :size="17" class="mr-2" />
                            {{
                                form.processing
                                    ? 'Сохранение...'
                                    : 'Сохранить изменения'
                            }}
                        </Button>
                    </div>
                </div>
            </form>

            <!-- Боковая колонка -->
            <aside class="space-y-4 lg:sticky lg:top-6 lg:self-start">
                <div class="rounded-2xl border bg-card p-5 shadow-sm">
                    <div class="flex items-center justify-between gap-3">
                        <h2 class="font-semibold">Ячейки стеллажа</h2>
                        <span
                            class="rounded-full bg-muted px-2.5 py-1 text-xs font-semibold tabular-nums"
                        >
                            {{ locationsCount }}
                        </span>
                    </div>

                    <p class="mt-1 text-sm text-muted-foreground">
                        Сейчас создано: {{ locationsLabel }}
                    </p>

                    <div
                        v-if="sortedLocations.length"
                        class="mt-4 flex flex-wrap gap-1.5"
                    >
                        <span
                            v-for="location in sortedLocations"
                            :key="location.id"
                            class="inline-flex min-w-9 justify-center rounded-lg border bg-muted/40 px-2 py-1 text-xs font-semibold tabular-nums"
                        >
                            {{ location.number }}
                        </span>
                    </div>

                    <p
                        v-else
                        class="mt-4 rounded-xl border border-dashed py-4 text-center text-sm text-muted-foreground"
                    >
                        Ячеек пока нет
                    </p>
                </div>

                <div class="flex items-start gap-3 rounded-2xl border bg-muted/40 p-4">
                    <Info :size="18" class="mt-0.5 shrink-0 text-primary" />
                    <div>
                        <p class="text-sm font-semibold">Управление ячейками</p>
                        <p class="mt-1 text-sm leading-relaxed text-muted-foreground">
                            Добавлять и удалять ячейки можно на странице
                            стеллажей.
                        </p>
                        <Link
                            :href="index().url"
                            class="mt-2 inline-block text-sm font-medium text-primary hover:underline"
                        >
                            Перейти к стеллажам
                        </Link>
                    </div>
                </div>
            </aside>
        </div>
    </div>
</template>
