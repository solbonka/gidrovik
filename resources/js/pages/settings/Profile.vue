<script setup lang="ts">
import { Form, Head, Link, usePage } from '@inertiajs/vue3';
import { computed } from 'vue';
import ProfileController from '@/actions/App/Http/Controllers/Settings/ProfileController';
import AdminLayout from '@/layouts/AdminLayout.vue';
import AuthStatus from '@/components/AuthStatus.vue';
import DeleteUser from '@/components/DeleteUser.vue';
import Heading from '@/components/Heading.vue';
import InputError from '@/components/InputError.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Spinner } from '@/components/ui/spinner';
import { send } from '@/routes/verification';

defineOptions({
    layout: AdminLayout,
});

const page = usePage();
const user = computed(() => page.props.auth.user);

const needsVerification = computed(
    () => page.props.mustVerifyEmail && !user.value.email_verified_at,
);
</script>

<template>
    <Head title="Настройки профиля" />

    <div class="flex flex-col space-y-6">
        <Heading
            variant="small"
            title="Профиль"
            description="Обновите имя и адрес электронной почты"
        />

        <Form
            v-bind="ProfileController.update.form()"
            class="space-y-6"
            v-slot="{ errors, processing, recentlySuccessful }"
        >
            <div class="grid gap-2">
                <Label for="name">Имя</Label>

                <Input
                    id="name"
                    class="block w-full"
                    name="name"
                    :default-value="user.name"
                    required
                    autocomplete="name"
                    placeholder="Ваше имя"
                />

                <InputError :message="errors.name" />
            </div>

            <div class="grid gap-2">
                <Label for="email">Адрес email</Label>

                <Input
                    id="email"
                    type="email"
                    class="block w-full"
                    name="email"
                    :default-value="user.email"
                    required
                    autocomplete="username"
                    placeholder="email@example.com"
                />

                <InputError :message="errors.email" />
            </div>

            <div
                v-if="needsVerification"
                class="rounded-xl border border-amber-500/30 bg-amber-500/10 p-4 text-sm"
            >
                <p class="font-medium text-amber-900 dark:text-amber-200">
                    Ваш адрес email не подтверждён.
                </p>

                <Link
                    :href="send()"
                    as="button"
                    type="button"
                    class="mt-1 text-foreground underline decoration-neutral-300 underline-offset-4 transition-colors duration-300 ease-out hover:decoration-current dark:decoration-neutral-500"
                >
                    Отправить письмо для подтверждения ещё раз
                </Link>
            </div>

            <AuthStatus
                v-if="page.props.status === 'verification-link-sent'"
                message="Новая ссылка для подтверждения отправлена на ваш email."
            />

            <div class="flex items-center gap-4">
                <Button
                    type="submit"
                    :disabled="processing"
                    data-test="update-profile-button"
                >
                    <Spinner v-if="processing" />
                    Сохранить
                </Button>

                <Transition
                    enter-active-class="transition ease-in-out"
                    enter-from-class="opacity-0"
                    leave-active-class="transition ease-in-out"
                    leave-to-class="opacity-0"
                >
                    <p
                        v-show="recentlySuccessful"
                        class="text-sm font-medium text-emerald-700 dark:text-emerald-400"
                    >
                        Сохранено.
                    </p>
                </Transition>
            </div>
        </Form>

        <DeleteUser />
    </div>
</template>
