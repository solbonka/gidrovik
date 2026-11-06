<script setup lang="ts">
import { computed, ref } from 'vue';
import { ArrowDown, ArrowUp, Plus, Trash2 } from '@lucide/vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

const props = defineProps<{ modelValue: string[]; error?: string }>();
const emit = defineEmits<{ 'update:modelValue': [value: string[]] }>();

const draft = ref('');

const duplicates = computed(() => {
    const seen = new Set<string>();
    const dup = new Set<string>();
    for (const v of props.modelValue) {
        const k = v.trim().toLowerCase();
        if (!k) continue;
        seen.has(k) ? dup.add(k) : seen.add(k);
    }
    return dup;
});

const isDup = (v: string) => duplicates.value.has(v.trim().toLowerCase());

const set = (list: string[]) => emit('update:modelValue', list);

/** Добавляет один или несколько вариантов (разделители: перенос строки, ; или запятая). */
function addFromDraft() {
    const parts = draft.value
        .split(/[\n;,]+/)
        .map((s) => s.trim())
        .filter(Boolean);
    if (!parts.length) return;

    const existing = new Set(props.modelValue.map((v) => v.trim().toLowerCase()));
    const fresh: string[] = [];
    for (const p of parts) {
        const k = p.toLowerCase();
        if (!existing.has(k)) {
            existing.add(k);
            fresh.push(p);
        }
    }
    set([...props.modelValue, ...fresh]);
    draft.value = '';
}

function onPaste(e: ClipboardEvent) {
    const text = e.clipboardData?.getData('text') ?? '';
    if (/[\n;]/.test(text)) {
        e.preventDefault();
        draft.value = text;
        addFromDraft();
    }
}

function update(i: number, value: string) {
    const list = [...props.modelValue];
    list[i] = value;
    set(list);
}

function remove(i: number) {
    set(props.modelValue.filter((_, idx) => idx !== i));
}

function move(i: number, dir: -1 | 1) {
    const j = i + dir;
    if (j < 0 || j >= props.modelValue.length) return;
    const list = [...props.modelValue];
    [list[i], list[j]] = [list[j], list[i]];
    set(list);
}

function sortAlpha() {
    set([...props.modelValue].sort((a, b) => a.localeCompare(b, 'ru', { numeric: true })));
}
</script>

<template>
    <div class="space-y-3">
        <div class="flex items-center justify-between">
            <label class="text-sm font-medium">Варианты</label>
            <div class="flex items-center gap-3">
                <button
                    v-if="modelValue.length > 1"
                    type="button"
                    class="text-xs text-muted-foreground transition hover:text-foreground"
                    @click="sortAlpha"
                >
                    Сортировать А–Я
                </button>
                <button
                    v-if="modelValue.length"
                    type="button"
                    class="text-xs text-muted-foreground transition hover:text-destructive"
                    @click="set([])"
                >
                    Очистить
                </button>
                <span class="text-xs text-muted-foreground tabular-nums">{{ modelValue.length }} шт.</span>
            </div>
        </div>

        <!-- Добавление: Enter добавляет вариант, форма не отправляется -->
        <div class="flex gap-2">
            <Input
                v-model="draft"
                type="text"
                autocomplete="off"
                placeholder="Введите вариант и нажмите Enter"
                class="h-11 flex-1 rounded-xl"
                @keydown.enter.prevent="addFromDraft"
                @paste="onPaste"
            />
            <Button type="button" class="h-11" :disabled="!draft.trim()" @click="addFromDraft">
                <Plus :size="16" class="mr-1.5" />
                Добавить
            </Button>
        </div>
        <p class="text-xs text-muted-foreground">
            Можно вставить сразу несколько — через запятую, «;» или с новой строки (например, из Excel).
        </p>

        <!-- Список: каждый вариант редактируется на месте -->
        <ul v-if="modelValue.length" class="space-y-2">
            <li v-for="(option, i) in modelValue" :key="i" class="flex items-center gap-2">
                <span class="w-6 shrink-0 text-center text-xs text-muted-foreground tabular-nums">{{ i + 1 }}</span>
                <Input
                    :model-value="option"
                    type="text"
                    autocomplete="off"
                    class="h-9 flex-1 rounded-lg"
                    :class="isDup(option) ? 'border-destructive' : ''"
                    @update:model-value="update(i, String($event))"
                    @keydown.enter.prevent
                />
                <Button type="button" variant="ghost" size="icon" class="size-8 shrink-0" :disabled="i === 0" @click="move(i, -1)">
                    <ArrowUp :size="14" />
                    <span class="sr-only">Выше</span>
                </Button>
                <Button type="button" variant="ghost" size="icon" class="size-8 shrink-0" :disabled="i === modelValue.length - 1" @click="move(i, 1)">
                    <ArrowDown :size="14" />
                    <span class="sr-only">Ниже</span>
                </Button>
                <Button type="button" variant="ghost" size="icon" class="size-8 shrink-0 text-muted-foreground hover:text-destructive" @click="remove(i)">
                    <Trash2 :size="14" />
                    <span class="sr-only">Удалить</span>
                </Button>
            </li>
        </ul>
        <div v-else class="rounded-lg border border-dashed p-4 text-center text-sm text-muted-foreground">
            Вариантов пока нет
        </div>

        <p v-if="duplicates.size" class="text-xs text-destructive">Есть повторяющиеся варианты — оставьте один из них.</p>
        <p v-if="error" class="text-xs text-destructive">{{ error }}</p>
    </div>
</template>
