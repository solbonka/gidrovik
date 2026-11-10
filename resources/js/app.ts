import { createInertiaApp } from '@inertiajs/vue3';
import { initializeTheme } from '@/composables/useAppearance';
import AppLayout from '@/layouts/AppLayout.vue';
import AuthLayout from '@/layouts/AuthLayout.vue';
import SettingsLayout from '@/layouts/settings/Layout.vue';
import StoreLayout from '@/layouts/StoreLayout.vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { initializeFlashToast } from '@/lib/flashToast';
import { initMetrika } from '@/lib/metrika';
import * as routes from '@/routes';
import storeRoutes from '@/routes/store';
import adminRoutes from '@/routes/admin';

// Все namespace для поиска маршрутов
const allNamespaces: Record<string, unknown>[] = [routes, storeRoutes, adminRoutes];

function toCamelCase(str: string): string {
    return str.replace(/-([a-z])/g, (_, c) => c.toUpperCase());
}

function resolveRoute(name: string, params: Record<string, unknown> = {}): string {
    const parts = name.split('.');
    let ns: unknown = routes;
    let rest = parts;
    if (parts[0] === 'store') { ns = storeRoutes; rest = parts.slice(1); }
    else if (parts[0] === 'admin') { ns = adminRoutes; rest = parts.slice(1); }

    const candidates = [{ ns, rest }, ...allNamespaces.map(n => ({ ns: n, rest: parts }))];
    for (const { ns: namespace, rest: r } of candidates) {
        let obj: unknown = namespace;
        let found = true;
        for (const part of r) {
            if (obj && typeof obj === 'object') {
                const objRecord = obj as Record<string, unknown>;
                // Сначала ищем прямой ключ, потом camelCase версию (custom-tables → customTables)
                const key = part in objRecord ? part : toCamelCase(part);
                if (key in objRecord) {
                    obj = objRecord[key];
                } else {
                    found = false;
                    break;
                }
            } else {
                found = false;
                break;
            }
        }
        if (found && typeof (obj as { url?: unknown }).url === 'function') {
            const urlFn = (obj as { url: (...a: unknown[]) => string }).url;
            return urlFn(params);
        }
    }
    return '/' + name.replace(/\./g, '/');
}

// Make route() available globally for Vue templates
if (typeof window !== 'undefined') {
    window.route = resolveRoute;
}

const appName = import.meta.env.VITE_APP_NAME || 'Laravel';

void createInertiaApp({
    title: (title) => (title ? `${title} - ${appName}` : appName),
    layout: (name) => {
        switch (true) {
            case name === 'Welcome':
                return null;
            case name.startsWith('errors/'):
                return null;
            case name.startsWith('store/'):
                return StoreLayout;
            case name.startsWith('auth/'):
                return AuthLayout;
            case name.startsWith('settings/'):
                return [AppLayout, SettingsLayout];
            case name.startsWith('admin/'):
                return AdminLayout;
            default:
                return AppLayout;
        }
    },
    withApp: (app) => {
        app.config.globalProperties.route = resolveRoute;
        app.directive('focus', {
            mounted: (el: HTMLElement, shouldFocus) => {
                if (shouldFocus.value !== false) {
                    el.focus();
                }
            },
        });
    },
    progress: {
        color: '#4B5563',
    },
});

// This will set light / dark mode on page load...
initializeTheme();

// This will listen for flash toast data from the server...
initializeFlashToast();

// Yandex.Metrika (SPA): ручные hit при навигации Inertia
initMetrika();
