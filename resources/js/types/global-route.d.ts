/**
 * Глобальный route() helper, предоставляемый Inertia-приложением.
 * Доступен как в script-секциях, так и в шаблонах через globalProperties.
 */
declare function route(name: string, params?: Record<string, unknown>): string;