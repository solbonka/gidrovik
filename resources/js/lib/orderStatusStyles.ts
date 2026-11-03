// Цвета статусов заказа. Классы записаны целиком, чтобы Tailwind их не вырезал.
// Положите файл в resources/js/lib/ и подключайте как '@/lib/orderStatusStyles'.

export interface StatusStyle {
    /** Цветная точка */
    dot: string
    /** Выбранный чип-фильтр */
    chipActive: string
    /** Пройденный/текущий шаг на шкале */
    step: string
    /** Кольцо вокруг текущего шага */
    ring: string
    /** Линия между пройденными шагами */
    line: string
}

const styles: Record<string, StatusStyle> = {
    new: {
        dot: 'bg-amber-500',
        chipActive: 'border-amber-500/50 bg-amber-500/15 text-amber-700 dark:text-amber-300',
        step: 'bg-amber-500 text-white',
        ring: 'ring-amber-500/25',
        line: 'bg-amber-500',
    },
    confirmed: {
        dot: 'bg-sky-500',
        chipActive: 'border-sky-500/50 bg-sky-500/15 text-sky-700 dark:text-sky-300',
        step: 'bg-sky-500 text-white',
        ring: 'ring-sky-500/25',
        line: 'bg-sky-500',
    },
    picking: {
        dot: 'bg-violet-500',
        chipActive: 'border-violet-500/50 bg-violet-500/15 text-violet-700 dark:text-violet-300',
        step: 'bg-violet-500 text-white',
        ring: 'ring-violet-500/25',
        line: 'bg-violet-500',
    },
    ready: {
        dot: 'bg-teal-500',
        chipActive: 'border-teal-500/50 bg-teal-500/15 text-teal-700 dark:text-teal-300',
        step: 'bg-teal-500 text-white',
        ring: 'ring-teal-500/25',
        line: 'bg-teal-500',
    },
    shipped: {
        dot: 'bg-indigo-500',
        chipActive: 'border-indigo-500/50 bg-indigo-500/15 text-indigo-700 dark:text-indigo-300',
        step: 'bg-indigo-500 text-white',
        ring: 'ring-indigo-500/25',
        line: 'bg-indigo-500',
    },
    completed: {
        dot: 'bg-emerald-500',
        chipActive: 'border-emerald-500/50 bg-emerald-500/15 text-emerald-700 dark:text-emerald-300',
        step: 'bg-emerald-500 text-white',
        ring: 'ring-emerald-500/25',
        line: 'bg-emerald-500',
    },
    cancelled: {
        dot: 'bg-rose-500',
        chipActive: 'border-rose-500/50 bg-rose-500/15 text-rose-700 dark:text-rose-300',
        step: 'bg-rose-500 text-white',
        ring: 'ring-rose-500/25',
        line: 'bg-rose-500',
    },
}

const fallback: StatusStyle = {
    dot: 'bg-muted-foreground',
    chipActive: 'border-primary bg-primary text-primary-foreground',
    step: 'bg-primary text-primary-foreground',
    ring: 'ring-primary/20',
    line: 'bg-primary',
}

export function statusStyle(value: string): StatusStyle {
    return styles[value] ?? fallback
}
