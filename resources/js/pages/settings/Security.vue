<script setup lang="ts">
import { Form, Head } from '@inertiajs/vue3';
import SecurityController from '@/actions/App/Http/Controllers/Settings/SecurityController';
import AdminLayout from '@/layouts/AdminLayout.vue';
import Heading from '@/components/Heading.vue';
import InputError from '@/components/InputError.vue';
import PasswordInput from '@/components/PasswordInput.vue';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Spinner } from '@/components/ui/spinner';
import type { Props as ManagePasskeysProps } from '@/components/ManagePasskeys.vue';
import ManagePasskeys from '@/components/ManagePasskeys.vue';
import type { Props as ManageTwoFactorProps } from '@/components/ManageTwoFactor.vue';
import ManageTwoFactor from '@/components/ManageTwoFactor.vue';

type Props = {
    passwordRules: string;
} & ManagePasskeysProps &
    ManageTwoFactorProps;

const props = defineProps<Props>();

defineOptions({
    layout: AdminLayout,
});
</script>

<template>
    <Head title="Настройки безопасности" />

    <div class="space-y-6">
        <Heading
            variant="small"
            title="Смена пароля"
            description="Используйте длинный случайный пароль, чтобы защитить аккаунт"
        />

        <Form
            v-bind="SecurityController.update.form()"
            :options="{
                preserveScroll: true,
            }"
            reset-on-success
            :reset-on-error="[
                'password',
                'password_confirmation',
                'current_password',
            ]"
            class="space-y-6"
            v-slot="{ errors, processing, recentlySuccessful }"
        >
            <div class="grid gap-2">
                <Label for="current_password">Текущий пароль</Label>

                <PasswordInput
                    id="current_password"
                    name="current_password"
                    class="block w-full"
                    required
                    autocomplete="current-password"
                    placeholder="Текущий пароль"
                />

                <InputError :message="errors.current_password" />
            </div>

            <div class="grid gap-2">
                <Label for="password">Новый пароль</Label>

                <PasswordInput
                    id="password"
                    name="password"
                    class="block w-full"
                    required
                    autocomplete="new-password"
                    placeholder="Новый пароль"
                    :passwordrules="props.passwordRules"
                />

                <InputError :message="errors.password" />
            </div>

            <div class="grid gap-2">
                <Label for="password_confirmation">
                    Подтвердите пароль
                </Label>

                <PasswordInput
                    id="password_confirmation"
                    name="password_confirmation"
                    class="block w-full"
                    required
                    autocomplete="new-password"
                    placeholder="Повторите новый пароль"
                    :passwordrules="props.passwordRules"
                />

                <InputError :message="errors.password_confirmation" />
            </div>

            <div class="flex items-center gap-4">
                <Button
                    type="submit"
                    :disabled="processing"
                    data-test="update-password-button"
                >
                    <Spinner v-if="processing" />
                    Сохранить пароль
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
                        Пароль изменён.
                    </p>
                </Transition>
            </div>
        </Form>
    </div>

    <ManageTwoFactor
        :canManageTwoFactor="canManageTwoFactor"
        :requiresConfirmation="requiresConfirmation"
        :twoFactorEnabled="twoFactorEnabled"
    />

    <ManagePasskeys
        :canManagePasskeys="canManagePasskeys"
        :passkeys="passkeys"
    />
</template>
