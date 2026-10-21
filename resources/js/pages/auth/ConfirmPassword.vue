<script setup lang="ts">
import { Form, Head } from '@inertiajs/vue3';
import InputError from '@/components/InputError.vue';
import PasskeyVerify from '@/components/PasskeyVerify.vue';
import PasswordInput from '@/components/PasswordInput.vue';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Spinner } from '@/components/ui/spinner';
import {
    index as confirmOptions,
    store as confirmStore,
} from '@/actions/Laravel/Passkeys/Http/Controllers/PasskeyConfirmationController';
import { store } from '@/routes/password/confirm';

defineOptions({
    layout: {
        title: 'Подтвердите пароль',
        description:
            'Это защищённая область приложения. Подтвердите пароль, чтобы продолжить.',
    },
});
</script>

<template>
    <Head title="Подтверждение пароля" />

    <PasskeyVerify
        :routes="{
            options: confirmOptions(),
            submit: confirmStore(),
        }"
        label="Подтвердить с помощью passkey"
        loading-label="Подтверждение..."
        separator="Или подтвердите паролем"
    />

    <Form
        v-bind="store.form()"
        reset-on-success
        v-slot="{ errors, processing }"
    >
        <div class="space-y-6">
            <div class="grid gap-2">
                <Label for="password">Пароль</Label>
                <PasswordInput
                    id="password"
                    name="password"
                    required
                    autocomplete="current-password"
                    autofocus
                    placeholder="Пароль"
                />

                <InputError :message="errors.password" />
            </div>

            <Button
                type="submit"
                class="w-full"
                :disabled="processing"
                data-test="confirm-password-button"
            >
                <Spinner v-if="processing" />
                Подтвердить пароль
            </Button>
        </div>
    </Form>
</template>
