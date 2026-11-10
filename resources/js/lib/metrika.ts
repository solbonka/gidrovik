import { router } from '@inertiajs/vue3';

declare global {
    interface Window {
        ym?: (id: number, method: string, ...args: unknown[]) => void;
        __YANDEX_METRIKA_ID__?: number;
    }
}

const COUNTER_ID = typeof window !== 'undefined' ? window.__YANDEX_METRIKA_ID__ : undefined;

function hit(url?: string) {
    if (!COUNTER_ID || typeof window.ym !== 'function') {
        return;
    }

    window.ym(COUNTER_ID, 'hit', url);
}

export function initMetrika() {
    if (!COUNTER_ID) {
        return;
    }

    // defer: true отключает автоматическую отправку просмотров —
    // первый hit отправляем вручную для начальной страницы.
    hit(window.location.href);

    router.on('navigate', (event) => {
        const detail = (event as CustomEvent).detail as
            | { page?: { url?: string }; type?: string }
            | undefined;

        // type 'initial' покрыт ручным hit выше — пропускаем, чтобы не дублировать
        if (!detail || detail.type === 'initial') {
            return;
        }

        const pageUrl = detail.page?.url;
        hit(pageUrl ? new URL(pageUrl, window.location.origin).href : window.location.href);
    });
}

export function reachGoal(goal: string, params?: Record<string, unknown>) {
    if (!COUNTER_ID || typeof window.ym !== 'function') {
        return;
    }

    window.ym(COUNTER_ID, 'reachGoal', goal, params);
}
