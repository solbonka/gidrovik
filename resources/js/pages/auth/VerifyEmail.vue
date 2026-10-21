<script setup lang="ts">
import { Form, Head } from '@inertiajs/vue3';
import AuthStatus from '@/components/AuthStatus.vue';
import TextLink from '@/components/TextLink.vue';
import { Button } from '@/components/ui/button';
import { Spinner } from '@/components/ui/spinner';
import { logout } from '@/routes';
import { send } from '@/routes/verification';

defineOptions({
    layout: {
        title: 'Подтверждение email',
        description:
            'Подтвердите адрес почты, перейдя по ссылке из письма, которое мы только что отправили.',
    },
});

defineProps<{
    status?: string;
}>();
</script>

<template>
    <Head title="Подтверждение email" />

    <AuthStatus
        v-if="status === 'verification-link-sent'"
        message="Новая ссылка для подтверждения отправлена на адрес, указанный при регистрации."
    />

    <Form
        v-bind="send.form()"
        class="space-y-6 text-center"
        v-slot="{ processing }"
    >
        <Button type="submit" :disabled="processing" variant="secondary">
            <Spinner v-if="processing" />
            Отправить письмо ещё раз
        </Button>

        <TextLink :href="logout()" as="button" class="mx-auto block text-sm">
            Выйти
        </TextLink>
    </Form>
</template>
