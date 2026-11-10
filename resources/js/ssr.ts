import { createInertiaApp } from '@inertiajs/vue3';
import createServer from '@inertiajs/vue3/server';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import { createSSRApp, h } from 'vue';
import { renderToString } from 'vue/server-renderer';

import AppLayout from '@/layouts/AppLayout.vue';
import AuthLayout from '@/layouts/AuthLayout.vue';
import SettingsLayout from '@/layouts/settings/Layout.vue';
import StoreLayout from '@/layouts/StoreLayout.vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
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

const appName = import.meta.env.VITE_APP_NAME || 'Laravel';

createServer((page) =>
    createInertiaApp({
        page,
        render: renderToString,
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
        resolve: (name) =>
            resolvePageComponent(`./pages/${name}.vue`, import.meta.glob('./pages/**/*.vue')),
        setup({ App, props, plugin }) {
            const app = createSSRApp({ render: () => h(App, props) });
            app.use(plugin);
            app.config.globalProperties.route = resolveRoute;
            return app;
        },
    }),
);
