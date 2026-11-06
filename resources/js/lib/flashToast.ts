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

    // Слушаем событие success для Inertia запросов
    router.on('success', (event) => {
        const page = (event as CustomEvent).detail?.page;
        const flash = page?.props?.flash as
            | {
                  success?: string | null;
                  error?: string | null;
                  toast?: FlashToast;
              }
            | undefined;

        console.log('[FlashToast] success:', flash);
        showFlash(flash);
    });
}

function showFlash(flash: { success?: string | null; error?: string | null; toast?: FlashToast } | undefined) {
    if (!flash) return;

    // Приоритет: toast > success > error
    if (flash.toast) {
        toast[flash.toast.type](flash.toast.message);
    } else if (flash.success) {
        toast.success(flash.success);
    } else if (flash.error) {
        toast.error(flash.error);
    }
}
