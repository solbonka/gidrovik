<script setup lang="ts">
import { Form } from '@inertiajs/vue3';
import { useTemplateRef } from 'vue';
import ProfileController from '@/actions/App/Http/Controllers/Settings/ProfileController';
import Heading from '@/components/Heading.vue';
import InputError from '@/components/InputError.vue';
import PasswordInput from '@/components/PasswordInput.vue';
import { Button } from '@/components/ui/button';
import {
    Dialog,
    DialogClose,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';

const passwordInput = useTemplateRef('passwordInput');
</script>

<template>
    <div class="space-y-6">
        <Heading
            variant="small"
            title="Удаление аккаунта"
            description="Удалите аккаунт и все связанные с ним данные"
        />

        <div
            class="space-y-4 rounded-xl border border-destructive/30 bg-destructive/5 p-4 sm:p-5"
        >
            <div class="space-y-1 text-destructive">
                <p class="font-semibold">Внимание</p>
                <p class="text-sm text-muted-foreground">
                    Будьте осторожны: это действие необратимо.
                </p>
            </div>

            <Dialog>
                <DialogTrigger as-child>
                    <Button
                        variant="destructive"
                        data-test="delete-user-button"
                    >
                        Удалить аккаунт
                    </Button>
                </DialogTrigger>

                <DialogContent>
                    <Form
                        v-bind="ProfileController.destroy.form()"
                        reset-on-success
                        @error="() => passwordInput?.focus()"
                        :options="{ preserveScroll: true }"
                        class="space-y-6"
                        v-slot="{ errors, processing, reset, clearErrors }"
                    >
                        <DialogHeader class="space-y-3">
                            <DialogTitle>
                                Вы действительно хотите удалить аккаунт?
                            </DialogTitle>

                            <DialogDescription>
                                После удаления аккаунта все связанные с ним
                                данные и ресурсы будут удалены без возможности
                                восстановления. Введите пароль, чтобы подтвердить
                                удаление.
                            </DialogDescription>
                        </DialogHeader>

                        <div class="grid gap-2">
                            <Label for="password" class="sr-only">
                                Пароль
                            </Label>

                            <PasswordInput
                                id="password"
                                name="password"
                                ref="passwordInput"
                                placeholder="Введите пароль"
                            />

                            <InputError :message="errors.password" />
                        </div>

                        <DialogFooter class="gap-2">
                            <DialogClose as-child>
                                <Button
                                    variant="secondary"
                                    @click="
                                        () => {
                                            clearErrors();
                                            reset();
                                        }
                                    "
                                >
                                    Отмена
                                </Button>
                            </DialogClose>

                            <Button
                                type="submit"
                                variant="destructive"
                                :disabled="processing"
                                data-test="confirm-delete-user-button"
                            >
                                Удалить аккаунт
                            </Button>
                        </DialogFooter>
                    </Form>
                </DialogContent>
            </Dialog>
        </div>
    </div>
</template>
