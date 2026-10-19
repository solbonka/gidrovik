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

    // Обработка уведомлений Inertia::flash('toast', ...)
    router.on('flash', (event) => {
        const detail = (event as CustomEvent).detail;

        const flash = detail?.flash as Record<string, unknown> | undefined;

        const data = flash?.toast as FlashToast | undefined;

        if (data) {
            toast[data.type](data.message);
        }
    });

    // Обработка Laravel redirect()->with('success', ...) / with('error', ...)
    router.on('navigate', (event) => {
        const detail = (event as CustomEvent).detail;
        const page = detail?.page;

        const flash = page?.props?.flash as
            | {
                  success?: string | null;
                  error?: string | null;
              }
            | undefined;

        console.log('[FlashToast] navigate:', flash);

        if (flash?.success) {
            toast.success(flash.success);
        }

        if (flash?.error) {
            toast.error(flash.error);
        }
    });
}
