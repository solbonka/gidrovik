<script setup lang="ts">
import { usePasskeyRegister } from '@laravel/passkeys/vue';
import { ref } from 'vue';
import InputError from '@/components/InputError.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

const emit = defineEmits<{
    success: [];
}>();

const getDefaultPasskeyName = (): string => {
    const ua = navigator.userAgent;

    const browser = [
        { pattern: /Edg|Edge/, name: 'Edge' },
        { pattern: /OPR|Opera|OPiOS/, name: 'Opera' },
        { pattern: /Firefox|FxiOS/, name: 'Firefox' },
        { pattern: /Chrome|CriOS/, name: 'Chrome' },
        { pattern: /Safari/, name: 'Safari' },
    ].find(({ pattern }) => pattern.test(ua))?.name;

    const os = [
        { pattern: /iPhone/, name: 'iPhone' },
        { pattern: /iPad|Macintosh(?=.*Mobile)/, name: 'iPad' },
        { pattern: /Android/, name: 'Android' },
        { pattern: /Mac/, name: 'Mac' },
        { pattern: /Windows/, name: 'Windows' },
    ].find(({ pattern }) => pattern.test(ua))?.name;

    return [browser, os].filter(Boolean).join(' на ') || '';
};

const name = ref(getDefaultPasskeyName());
const showForm = ref(false);

const { register, isLoading, error, isSupported } = usePasskeyRegister({
    onSuccess: () => {
        name.value = '';
        showForm.value = false;
        emit('success');
    },
});

const handleSubmit = async (event: Event): Promise<void> => {
    event.preventDefault();

    if (!name.value.trim()) {
        return;
    }

    await register(name.value.trim());
};

const handleCancel = (): void => {
    showForm.value = false;
    name.value = '';
};
</script>

<template>
    <div
        v-if="!isSupported"
        class="text-sm text-muted-foreground"
    >
        Ваш браузер не поддерживает ключи доступа (Passkeys).
    </div>

    <Button
        v-else-if="!showForm"
        variant="outline"
        @click="showForm = true"
    >
        Добавить ключ доступа
    </Button>

    <form
        v-else
        class="space-y-4 rounded-xl border border-border bg-card p-4"
        @submit="handleSubmit"
    >
        <div class="grid gap-2">
            <Label for="passkey-name">
                Название ключа доступа
            </Label>

            <Input
                id="passkey-name"
                v-model="name"
                type="text"
                placeholder="Например, MacBook Pro или iPhone"
                class="mt-1 block w-full"
                v-focus
            />

            <p class="text-xs leading-relaxed text-muted-foreground">
                Укажите название, по которому вы сможете определить этот ключ
                доступа в дальнейшем.
            </p>
        </div>

        <InputError
            v-if="error"
            :message="error"
        />

        <div class="flex flex-wrap gap-2">
            <Button
                type="submit"
                :disabled="isLoading || !name.trim()"
            >
                {{ isLoading ? 'Регистрация...' : 'Зарегистрировать ключ' }}
            </Button>

            <Button
                type="button"
                variant="ghost"
                :disabled="isLoading"
                @click="handleCancel"
            >
                Отмена
            </Button>
        </div>
    </form>
</template>
