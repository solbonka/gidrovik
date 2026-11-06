<script setup lang="ts">
import { Link } from '@inertiajs/vue3';
import { computed, ref, watch } from 'vue';
import { Check, Hash, List, LoaderCircle, Save, Type } from '@lucide/vue';
import StockField from '@/components/admin/stock/StockField.vue';
import OptionsEditor from '@/components/admin/characteristics/OptionsEditor.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

/* eslint-disable vue/no-mutating-props -- form — это useForm-объект Inertia, он мутируется намеренно */
const props = defineProps<{
    form: any;
    submitLabel: string;
    cancelHref: string;
    autoSlug?: boolean;
}>();
const emit = defineEmits<{ submit: [] }>();

const typeOptions = [
    { value: 'text', label: 'Текст', description: 'Текстовое значение', icon: Type },
    { value: 'number', label: 'Число', description: 'Числовое значение', icon: Hash },
    { value: 'select', label: 'Список', description: 'Выбор из вариантов', icon: List },
    { value: 'boolean', label: 'Да / Нет', description: 'Логическое значение', icon: Check },
];

/* ---------- Slug автоматически из названия ---------- */

const translitMap: Record<string, string> = {
    а: 'a', б: 'b', в: 'v', г: 'g', д: 'd', е: 'e', ё: 'e', ж: 'zh', з: 'z', и: 'i', й: 'y',
    к: 'k', л: 'l', м: 'm', н: 'n', о: 'o', п: 'p', р: 'r', с: 's', т: 't', у: 'u', ф: 'f',
    х: 'h', ц: 'ts', ч: 'ch', ш: 'sh', щ: 'sch', ъ: '', ы: 'y', ь: '', э: 'e', ю: 'yu', я: 'ya',
};

const slugify = (text: string) =>
    text
        .toLowerCase()
        .split('')
        .map((c) => translitMap[c] ?? c)
        .join('')
        .replace(/[^a-z0-9]+/g, '_')
        .replace(/^_+|_+$/g, '');

const slugTouched = ref(!props.autoSlug);

watch(
    () => props.form.name,
    (name: string) => {
        if (!slugTouched.value) props.form.slug = slugify(name);
    },
);

/* ---------- Зависимость полей от типа ---------- */

const isSelect = computed(() => props.form.type === 'select');
const isNumber = computed(() => props.form.type === 'number');

function setType(type: string) {
    props.form.type = type;
    if (type !== 'select') props.form.values = [];
    if (type !== 'number') props.form.unit = '';
}
</script>

<template>
    <form class="overflow-hidden rounded-2xl border bg-card shadow-sm" novalidate @submit.prevent="emit('submit')">
        <div class="border-b px-6 py-5">
            <h2 class="font-semibold">Основная информация</h2>
            <p class="mt-1 text-sm text-muted-foreground">Название, тип и системный идентификатор</p>
        </div>

        <div class="space-y-6 p-6">
            <StockField label="Название" for-id="name" required :error="form.errors.name" hint="Понятное название параметра, например «Диаметр» или «Давление»">
                <Input id="name" v-model="form.name" type="text" autofocus autocomplete="off" placeholder="Например: Рабочее давление" class="h-11 rounded-xl" :aria-invalid="!!form.errors.name" />
            </StockField>

            <StockField label="Slug" for-id="slug" required :error="form.errors.slug" :hint="autoSlug && !slugTouched ? 'Заполняется автоматически из названия, можно изменить' : 'Уникальный идентификатор латиницей'">
                <Input id="slug" v-model="form.slug" type="text" autocomplete="off" placeholder="working_pressure" class="h-11 rounded-xl font-mono" :aria-invalid="!!form.errors.slug" @input="slugTouched = true" />
            </StockField>

            <StockField label="Тип значения" required :error="form.errors.type" hint="Тип значения характеристики">
                <div class="grid grid-cols-2 gap-2">
                    <button
                        v-for="option in typeOptions"
                        :key="option.value"
                        type="button"
                        class="flex items-center gap-3 rounded-xl border p-3 text-left transition hover:border-primary"
                        :class="form.type === option.value ? 'border-primary bg-primary/5 dark:bg-primary/10' : 'border-border bg-card'"
                        @click="setType(option.value)"
                    >
                        <div class="flex size-9 shrink-0 items-center justify-center rounded-lg" :class="form.type === option.value ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground'">
                            <component :is="option.icon" :size="16" />
                        </div>
                        <div>
                            <span class="text-sm font-medium">{{ option.label }}</span>
                            <span class="block text-xs text-muted-foreground">{{ option.description }}</span>
                        </div>
                    </button>
                </div>
            </StockField>

            <!-- Единица измерения нужна только для чисел -->
            <StockField v-if="isNumber" label="Единица измерения" for-id="unit" :error="form.errors.unit" hint="Необязательно: бар, мм, кг">
                <Input id="unit" v-model="form.unit" type="text" autocomplete="off" placeholder="бар, мм, кг" class="h-11 rounded-xl" :aria-invalid="!!form.errors.unit" />
            </StockField>

            <OptionsEditor v-if="isSelect" v-model="form.values" :error="form.errors.values" />

            <label class="flex cursor-pointer items-start gap-3 rounded-xl border bg-muted/40 p-4">
                <input v-model="form.is_active" type="checkbox" class="mt-0.5 size-4 rounded border-input accent-primary" />
                <span>
                    <span class="block text-sm font-semibold">Характеристика активна</span>
                    <span class="mt-1 block text-sm leading-5 text-muted-foreground">Активная характеристика будет доступна для назначения категориям.</span>
                </span>
            </label>
        </div>

        <div class="sticky bottom-0 flex flex-col-reverse gap-3 border-t bg-muted/80 px-6 py-4 backdrop-blur sm:flex-row sm:justify-end">
            <Button as-child variant="outline" :disabled="form.processing">
                <Link :href="cancelHref">Отмена</Link>
            </Button>
            <Button type="submit" :disabled="form.processing">
                <LoaderCircle v-if="form.processing" :size="17" class="mr-2 animate-spin" />
                <Save v-else :size="17" class="mr-2" />
                {{ form.processing ? 'Сохранение...' : submitLabel }}
            </Button>
        </div>
    </form>
</template>
