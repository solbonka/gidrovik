<script setup lang="ts">
import { Form, Head } from '@inertiajs/vue3';
import AuthStatus from '@/components/AuthStatus.vue';
import InputError from '@/components/InputError.vue';
import TextLink from '@/components/TextLink.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Spinner } from '@/components/ui/spinner';
import { login } from '@/routes';
import { email } from '@/routes/password';

defineOptions({
    layout: {
        title: 'Восстановление пароля',
        description:
            'Укажите email, и мы отправим ссылку для сброса пароля',
    },
});

defineProps<{
    status?: string;
}>();
</script>

<template>
    <Head title="Восстановление пароля" />

    <AuthStatus v-if="status" :message="status" />

    <div class="space-y-6">
        <Form
            v-bind="email.form()"
            v-slot="{ errors, processing }"
            class="space-y-6"
        >
            <div class="grid gap-2">
                <Label for="email">Адрес email</Label>
                <Input
                    id="email"
                    type="email"
                    name="email"
                    required
                    v-focus
                    autocomplete="email"
                    placeholder="email@example.com"
                />
                <InputError :message="errors.email" />
            </div>

            <Button
                type="submit"
                class="w-full"
                :disabled="processing"
                data-test="email-password-reset-link-button"
            >
                <Spinner v-if="processing" />
                Отправить ссылку для сброса
            </Button>
        </Form>

        <div class="text-center text-sm text-muted-foreground">
            Вспомнили пароль?
            <TextLink :href="login()">Вернуться ко входу</TextLink>
        </div>
    </div>
</template>
