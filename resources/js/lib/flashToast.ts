import { router } from '@inertiajs/vue3';
import { toast } from 'vue-sonner';
import type { FlashToast } from '@/types/ui';

let initialized = false;

export function initializeFlashToast(): void {
    console.log('[FlashToast] Инициализация');

    if (initialized) {
        return;
    }

    initialized = true;

    // Единый обработчик для всех типов flash-уведомлений
    router.on('navigate', (event) => {
        const detail = (event as CustomEvent).detail;
        const page = detail?.page;

        const flash = page?.props?.flash as
            | {
                  success?: string | null;
                  error?: string | null;
                  toast?: FlashToast;
              }
            | undefined;

        console.log('[FlashToast] navigate:', flash);

        // Приоритет: toast > success > error
        if (flash?.toast) {
            toast[flash.toast.type](flash.toast.message);
        } else if (flash?.success) {
            toast.success(flash.success);
        } else if (flash?.error) {
            toast.error(flash.error);
        }
    });
}
