import { router } from '@inertiajs/vue3';
import { usePage } from '@inertiajs/vue3';
import { toast } from 'vue-sonner';
import { nextTick } from 'vue';
import type { FlashToast } from '@/types/ui';

let initialized = false;
let lastToastShown = '';

export function initializeFlashToast(): void {
    console.log('[FlashToast] Инициализация');

    if (initialized) {
        return;
    }

    initialized = true;

    // Сбрасываем дедупликацию при навигации
    router.on('start', () => {
        lastToastShown = '';
    });

    // Проверяем flash-данные на начальной загрузке страницы (deferred)
    nextTick(() => {
        checkInitialFlash();
    });

    // Слушаем событие success для Inertia запросов (клиентская навигация)
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

function checkInitialFlash(): void {
    try {
        const page = usePage();
        if (!page || !page.props) {
            console.log('[FlashToast] initial flash: page not ready');
            return;
        }
        const flash = page.props.flash as
            | {
                  success?: string | null;
                  error?: string | null;
                  toast?: FlashToast;
              }
            | undefined;

        console.log('[FlashToast] initial flash:', flash);
        showFlash(flash);
    } catch (e) {
        console.warn('[FlashToast] initial flash check failed:', e);
    }
}

function showFlash(flash: { success?: string | null; error?: string | null; toast?: FlashToast } | undefined) {
    if (!flash) return;

    const message = flash.toast?.message || flash.success || flash.error;
    if (!message || message === lastToastShown) return;

    lastToastShown = message;

    // Приоритет: toast > success > error
    if (flash.toast) {
        toast[flash.toast.type](flash.toast.message);
    } else if (flash.success) {
        toast.success(flash.success);
    } else if (flash.error) {
        toast.error(flash.error);
    }
}

export function showErrorToast(message: string): void {
    if (!message || message === lastToastShown) return;
    lastToastShown = message;
    toast.error(message);
}

export function showSuccessToast(message: string): void {
    if (!message || message === lastToastShown) return;
    lastToastShown = message;
    toast.success(message);
}
