<script setup lang="ts">
import { computed } from 'vue';
import { AlertTriangle, LoaderCircle, Trash2, X } from '@lucide/vue';

interface Props {
    open: boolean;
    title?: string;
    description?: string;
    itemName?: string;
    processing?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
    title: 'Подтвердите удаление',
    description: 'Это действие нельзя отменить.',
    itemName: '',
    processing: false,
});

const emit = defineEmits<{
    confirm: [];
    cancel: [];
}>();

const message = computed(() => {
    return props.itemName
        ? `Вы действительно хотите удалить «${props.itemName}»?`
        : props.description;
});

const cancel = (): void => {
    if (!props.processing) {
        emit('cancel');
    }
};

const confirm = (): void => {
    if (!props.processing) {
        emit('confirm');
    }
};
</script>

<template>
    <Teleport to="body">
        <Transition
            enter-active-class="duration-200 ease-out"
            enter-from-class="opacity-0"
            enter-to-class="opacity-100"
            leave-active-class="duration-150 ease-in"
            leave-from-class="opacity-100"
            leave-to-class="opacity-0"
        >
            <div
                v-if="open"
                class="fixed inset-0 z-[100] flex items-center justify-center overflow-y-auto bg-gray-950/60 p-4 backdrop-blur-sm"
                @click.self="cancel"
                @keydown.esc="cancel"
            >
                <Transition
                    appear
                    enter-active-class="duration-200 ease-out"
                    enter-from-class="translate-y-3 scale-95 opacity-0"
                    enter-to-class="translate-y-0 scale-100 opacity-100"
                    leave-active-class="duration-150 ease-in"
                    leave-from-class="translate-y-0 scale-100 opacity-100"
                    leave-to-class="translate-y-3 scale-95 opacity-0"
                >
                    <div
                        v-if="open"
                        role="alertdialog"
                        aria-modal="true"
                        aria-labelledby="delete-dialog-title"
                        aria-describedby="delete-dialog-description"
                        class="w-full max-w-md overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-2xl dark:border-gray-700 dark:bg-gray-950"
                    >
                        <div class="p-6">
                            <div class="flex items-start gap-4">
                                <div
                                    class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-red-100 text-red-600 dark:bg-red-950/60 dark:text-red-400"
                                >
                                    <AlertTriangle class="size-6" />
                                </div>

                                <div class="min-w-0 flex-1 pt-0.5">
                                    <h2
                                        id="delete-dialog-title"
                                        class="text-lg font-semibold text-gray-900 dark:text-white"
                                    >
                                        {{ title }}
                                    </h2>

                                    <p
                                        id="delete-dialog-description"
                                        class="mt-2 text-sm leading-6 break-words text-gray-600 dark:text-gray-400"
                                    >
                                        {{ message }}
                                    </p>

                                    <p
                                        v-if="itemName"
                                        class="mt-2 text-sm text-gray-500 dark:text-gray-400"
                                    >
                                        {{ description }}
                                    </p>
                                </div>

                                <button
                                    type="button"
                                    aria-label="Закрыть окно"
                                    :disabled="processing"
                                    class="rounded-lg p-1.5 text-gray-400 transition hover:bg-gray-100 hover:text-gray-700 disabled:opacity-50 dark:hover:bg-gray-800 dark:hover:text-gray-200"
                                    @click="cancel"
                                >
                                    <X class="size-5" />
                                </button>
                            </div>
                        </div>

                        <div
                            class="flex flex-col-reverse gap-3 border-t border-gray-100 bg-gray-50/80 px-6 py-4 sm:flex-row sm:justify-end dark:border-gray-800 dark:bg-gray-900/60"
                        >
                            <button
                                type="button"
                                :disabled="processing"
                                class="inline-flex items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm font-medium text-gray-700 transition hover:bg-gray-100 focus-visible:ring-2 focus-visible:ring-gray-400 focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50 dark:border-gray-700 dark:bg-gray-900 dark:text-gray-200 dark:hover:bg-gray-800"
                                @click="cancel"
                            >
                                Отмена
                            </button>

                            <button
                                type="button"
                                :disabled="processing"
                                class="inline-flex items-center justify-center gap-2 rounded-xl bg-red-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-red-700 focus-visible:ring-4 focus-visible:ring-red-500/25 focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-60"
                                @click="confirm"
                            >
                                <LoaderCircle
                                    v-if="processing"
                                    class="size-4 animate-spin"
                                />
                                <Trash2 v-else class="size-4" />
                                {{ processing ? 'Удаление...' : 'Удалить' }}
                            </button>
                        </div>
                    </div>
                </Transition>
            </div>
        </Transition>
    </Teleport>
</template>
