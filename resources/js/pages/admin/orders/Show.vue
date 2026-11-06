<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import {
    ArrowLeft,
    ArrowRight,
    Calendar,
    Check,
    ChevronDown,
    Copy,
    FileText,
    Mail,
    MessageSquare,
    Package,
    Phone,
    Store,
    Truck,
    User,
    X,
} from '@lucide/vue'

import AdminLayout from '@/layouts/AdminLayout.vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { statusStyle } from '@/lib/orderStatusStyles'
import type { Order, OrderStatus } from '@/types/order'

defineOptions({ layout: AdminLayout })

const props = defineProps<{
    order: Order & {
        customer_name: string
        customer_email: string
        customer_phone: string
        customer_organization?: string | null
        delivery_method: string
        delivery_method_label: string
        delivery_address?: string | null
        comment?: string | null
        total_amount: string
        status: string
        status_label: string
        status_color: string
        created_at: string
        items: Array<{
            id: number
            product_id: number
            name: string
            code: string | null
            article: string | null
            quantity: number
            price: string
            subtotal: string
        }>
        status_history: Array<{
            id: number
            from_status: string | null
            to_status: string
            note: string | null
            changed_by: string | null
            created_at: string
        }>
    }
    statuses: OrderStatus[]
}>()

const showCompleteDialog = ref(false)
const showCancelDialog = ref(false)
const cancelReason = ref('')
const statusNote = ref('')
const showStatusMenu = ref(false)
const menuRef = ref<HTMLElement | null>(null)
const processing = ref(false)

function onDocumentClick(e: MouseEvent) {
    if (showStatusMenu.value && menuRef.value && !menuRef.value.contains(e.target as Node)) {
        showStatusMenu.value = false
    }
}
onMounted(() => document.addEventListener('click', onDocumentClick))
onBeforeUnmount(() => document.removeEventListener('click', onDocumentClick))

const isFinal = computed(() => ['completed', 'cancelled'].includes(props.order.status))
const isCancelled = computed(() => props.order.status === 'cancelled')
const currentStyle = computed(() => statusStyle(props.order.status))

// Основной путь заказа (без «отменён»), в порядке, как пришло с сервера
const flow = computed(() => props.statuses.filter((s) => s.value !== 'cancelled'))
const currentIndex = computed(() => flow.value.findIndex((s) => s.value === props.order.status))
const nextStatus = computed(() => {
    if (isFinal.value || currentIndex.value < 0) return null
    return flow.value[currentIndex.value + 1] ?? null
})
// Финальные статусы (завершён/отменён) сервер через смену статуса не принимает —
// для них есть отдельные кнопки «Завершить» и «Отменить»
const otherStatuses = computed(() =>
    props.statuses.filter(
        (s) => s.value !== props.order.status && !['completed', 'cancelled'].includes(s.value),
    ),
)

function goNext() {
    if (!nextStatus.value) return
    if (nextStatus.value.value === 'completed') {
        showCompleteDialog.value = true
    } else {
        updateStatus(nextStatus.value.value)
    }
}

// Новые записи сверху
const history = computed(() => [...props.order.status_history].reverse())

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}

function statusLabel(value: string | null): string {
    if (!value) return ''
    return props.statuses.find((s) => s.value === value)?.label ?? value
}

async function copy(text: string, what: string) {
    await navigator.clipboard.writeText(text)
}

function updateStatus(newStatus: string) {
    if (!newStatus || processing.value) return
    showStatusMenu.value = false
    router.put(
        route('admin.orders.status.update', { order: props.order.order_number }),
        { status: newStatus, note: statusNote.value },
        {
            preserveState: true,
            preserveScroll: true,
            onStart: () => (processing.value = true),
            onFinish: () => (processing.value = false),
            onSuccess: () => {
                statusNote.value = ''
            },
        },
    )
}

function completeOrder() {
    router.post(
        route('admin.orders.complete', { order: props.order.order_number }),
        {},
        {
            preserveState: true,
            preserveScroll: true,
            onStart: () => (processing.value = true),
            onFinish: () => (processing.value = false),
            onSuccess: () => {
                showCompleteDialog.value = false
            },
        },
    )
}

function cancelOrder() {
    router.post(
        route('admin.orders.cancel', { order: props.order.order_number }),
        { reason: cancelReason.value },
        {
            preserveState: true,
            preserveScroll: true,
            onStart: () => (processing.value = true),
            onFinish: () => (processing.value = false),
            onSuccess: () => {
                showCancelDialog.value = false
                cancelReason.value = ''
            },
        },
    )
}

function closeDialogs() {
    showStatusMenu.value = false
    showCompleteDialog.value = false
    showCancelDialog.value = false
}

const itemsCount = computed(() => props.order.items.reduce((sum, i) => sum + i.quantity, 0))
</script>

<template>
    <Head :title="`Заказ ${order.order_number}`" />

    <div class="space-y-6 pb-4" @keydown.esc="closeDialogs">
        <!-- Заголовок -->
        <header class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div class="flex items-center gap-4">
                <Button as-child variant="ghost" size="icon" class="size-9" aria-label="К списку заказов">
                    <Link :href="route('admin.orders.index')">
                        <ArrowLeft :size="20" />
                    </Link>
                </Button>
                <div
                    class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                >
                    <FileText :size="24" />
                </div>
                <div>
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Заказ {{ order.order_number }}
                    </h1>
                    <p class="mt-1 flex items-center gap-1.5 text-sm text-muted-foreground">
                        <Calendar :size="14" />
                        Оформлен {{ order.created_at }}
                    </p>
                </div>
            </div>

            <span
                class="inline-flex w-fit items-center rounded-full px-3 py-1.5 text-sm font-semibold ring-1 ring-inset"
                :class="order.status_color"
            >
                {{ order.status_label }}
            </span>
        </header>

        <!-- Прогресс заказа -->
        <section class="rounded-2xl border bg-card p-5 shadow-sm" aria-label="Ход выполнения заказа">
            <div
                v-if="isCancelled"
                class="flex items-center gap-3 rounded-xl bg-rose-500/10 px-4 py-3 text-sm font-medium text-rose-700 dark:text-rose-400"
            >
                <X :size="18" />
                Заказ отменён
            </div>

            <ol v-else class="flex items-start overflow-x-auto">
                <li
                    v-for="(step, i) in flow"
                    :key="step.value"
                    class="flex min-w-[88px] flex-1 flex-col items-center text-center"
                >
                    <div class="flex w-full items-center">
                        <div
                            class="h-0.5 flex-1"
                            :class="i === 0 ? 'bg-transparent' : i <= currentIndex ? currentStyle.line : 'bg-border'"
                        />
                        <div
                            class="flex size-8 shrink-0 items-center justify-center rounded-full text-xs font-bold transition"
                            :class="i < currentIndex
                                ? currentStyle.step
                                : i === currentIndex
                                    ? [currentStyle.step, 'ring-4', currentStyle.ring]
                                    : 'bg-muted text-muted-foreground'"
                        >
                            <Check v-if="i < currentIndex" :size="15" />
                            <span v-else>{{ i + 1 }}</span>
                        </div>
                        <div
                            class="h-0.5 flex-1"
                            :class="i === flow.length - 1 ? 'bg-transparent' : i < currentIndex ? currentStyle.line : 'bg-border'"
                        />
                    </div>
                    <span
                        class="mt-2 px-1 text-xs"
                        :class="i === currentIndex ? 'font-semibold text-foreground' : 'text-muted-foreground'"
                    >
                        {{ step.label }}
                    </span>
                </li>
            </ol>
        </section>

        <div class="grid items-start gap-6 lg:grid-cols-3">
            <!-- Боковая панель идёт первой на мобильных: действия и контакты важнее -->
            <aside class="space-y-6 lg:order-2 lg:sticky lg:top-4">
                <!-- Действия -->
                <section class="rounded-2xl border bg-card shadow-sm" aria-labelledby="actions-title">
                    <div class="border-b px-5 py-4">
                        <h2 id="actions-title" class="font-semibold">Что дальше</h2>
                    </div>

                    <div class="space-y-4 p-5">
                        <p v-if="isFinal" class="text-sm text-muted-foreground">
                            {{ isCancelled ? 'Заказ отменён' : 'Заказ выполнен' }} — изменения недоступны.
                        </p>

                        <template v-else>
                            <Input
                                v-model="statusNote"
                                type="text"
                                placeholder="Комментарий к смене статуса (необязательно)"
                            />

                            <Button
                                v-if="nextStatus"
                                class="w-full justify-between"
                                :disabled="processing"
                                @click="goNext"
                            >
                                {{ nextStatus.label }}
                                <ArrowRight :size="16" />
                            </Button>

                            <!-- Выбор другого статуса: клик по пункту применяет его сразу -->
                            <div ref="menuRef" class="relative">
                                <button
                                    type="button"
                                    aria-haspopup="listbox"
                                    :aria-expanded="showStatusMenu"
                                    :disabled="processing"
                                    class="flex w-full items-center justify-between rounded-xl border border-input bg-background px-4 py-2.5 text-sm shadow-xs outline-none transition hover:bg-accent focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30 disabled:opacity-50"
                                    @click="showStatusMenu = !showStatusMenu"
                                >
                                    <span class="flex items-center gap-2.5">
                                        <span class="size-2.5 rounded-full" :class="currentStyle.dot" />
                                        Сменить статус
                                    </span>
                                    <ChevronDown
                                        :size="16"
                                        class="text-muted-foreground transition-transform duration-200"
                                        :class="showStatusMenu ? 'rotate-180' : ''"
                                    />
                                </button>

                                <Transition
                                    enter-active-class="transition duration-150 ease-out"
                                    enter-from-class="-translate-y-1 opacity-0"
                                    enter-to-class="translate-y-0 opacity-100"
                                    leave-active-class="transition duration-100 ease-in"
                                    leave-from-class="opacity-100"
                                    leave-to-class="opacity-0"
                                >
                                    <ul
                                        v-if="showStatusMenu"
                                        role="listbox"
                                        class="absolute inset-x-0 top-full z-20 mt-1.5 max-h-72 space-y-0.5 overflow-auto rounded-xl border bg-card p-1.5 shadow-lg"
                                    >
                                        <li v-for="s in otherStatuses" :key="s.value">
                                            <button
                                                type="button"
                                                role="option"
                                                class="group flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-left text-sm transition hover:bg-muted focus-visible:bg-muted focus-visible:outline-none"
                                                @click="updateStatus(s.value)"
                                            >
                                                <span
                                                    class="size-2.5 shrink-0 rounded-full"
                                                    :class="statusStyle(s.value).dot"
                                                />
                                                <span class="flex-1 font-medium">{{ s.label }}</span>
                                                <ArrowRight
                                                    :size="14"
                                                    class="text-muted-foreground opacity-0 transition group-hover:translate-x-0.5 group-hover:opacity-100"
                                                />
                                            </button>
                                        </li>
                                        <li
                                            v-if="otherStatuses.length === 0"
                                            class="px-3 py-2.5 text-sm text-muted-foreground"
                                        >
                                            Других статусов нет
                                        </li>
                                    </ul>
                                </Transition>
                            </div>

                            <div class="grid grid-cols-2 gap-2 border-t pt-4">
                                <Button variant="outline" class="gap-2" @click="showCompleteDialog = true">
                                    <Check :size="16" />
                                    Завершить
                                </Button>
                                <Button
                                    variant="outline"
                                    class="gap-2 text-destructive hover:bg-destructive/10 hover:text-destructive"
                                    @click="showCancelDialog = true"
                                >
                                    <X :size="16" />
                                    Отменить
                                </Button>
                            </div>
                        </template>
                    </div>
                </section>

                <!-- Покупатель -->
                <section class="rounded-2xl border bg-card shadow-sm" aria-labelledby="contact-title">
                    <div class="border-b px-5 py-4">
                        <h2 id="contact-title" class="font-semibold">Покупатель</h2>
                    </div>

                    <ul class="space-y-1 p-3 text-sm">
                        <li class="flex items-center gap-3 rounded-xl px-2 py-2">
                            <div class="flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                <User :size="14" />
                            </div>
                            <div class="min-w-0">
                                <p class="font-medium break-words">{{ order.customer_name }}</p>
                                <p v-if="order.customer_organization" class="text-xs text-muted-foreground">
                                    {{ order.customer_organization }}
                                </p>
                            </div>
                        </li>

                        <li class="group flex items-center gap-3 rounded-xl px-2 py-2 hover:bg-muted/50">
                            <div class="flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                <Phone :size="14" />
                            </div>
                            <a :href="`tel:${order.customer_phone}`" class="min-w-0 flex-1 font-medium hover:underline">
                                {{ order.customer_phone }}
                            </a>
                            <button
                                type="button"
                                class="rounded-md p-1.5 text-muted-foreground transition hover:bg-muted hover:text-foreground"
                                aria-label="Скопировать телефон"
                                @click="copy(order.customer_phone, 'Телефон')"
                            >
                                <Copy :size="14" />
                            </button>
                        </li>

                        <li class="group flex items-center gap-3 rounded-xl px-2 py-2 hover:bg-muted/50">
                            <div class="flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                <Mail :size="14" />
                            </div>
                            <a
                                :href="`mailto:${order.customer_email}`"
                                class="min-w-0 flex-1 font-medium break-all hover:underline"
                            >
                                {{ order.customer_email }}
                            </a>
                            <button
                                type="button"
                                class="rounded-md p-1.5 text-muted-foreground transition hover:bg-muted hover:text-foreground"
                                aria-label="Скопировать email"
                                @click="copy(order.customer_email, 'Email')"
                            >
                                <Copy :size="14" />
                            </button>
                        </li>
                    </ul>
                </section>

                <!-- Получение -->
                <section class="rounded-2xl border bg-card shadow-sm" aria-labelledby="delivery-title">
                    <div class="border-b px-5 py-4">
                        <h2 id="delivery-title" class="font-semibold">Получение</h2>
                    </div>

                    <div class="space-y-3 p-5 text-sm">
                        <div class="flex items-center gap-3">
                            <div class="flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                <Truck v-if="order.delivery_method === 'delivery'" :size="14" />
                                <Store v-else :size="14" />
                            </div>
                            <span class="font-medium">{{ order.delivery_method_label }}</span>
                        </div>

                        <div v-if="order.delivery_address" class="flex items-start justify-between gap-2 border-t pt-3">
                            <div>
                                <span class="text-xs text-muted-foreground">Адрес</span>
                                <p class="mt-0.5">{{ order.delivery_address }}</p>
                            </div>
                            <button
                                type="button"
                                class="rounded-md p-1.5 text-muted-foreground transition hover:bg-muted hover:text-foreground"
                                aria-label="Скопировать адрес"
                                @click="copy(order.delivery_address!, 'Адрес')"
                            >
                                <Copy :size="14" />
                            </button>
                        </div>

                        <div
                            v-if="order.comment"
                            class="rounded-xl bg-amber-500/10 p-3 text-amber-900 dark:text-amber-200"
                        >
                            <div class="flex items-center gap-1.5 text-xs font-medium">
                                <MessageSquare :size="13" />
                                Комментарий покупателя
                            </div>
                            <p class="mt-1">{{ order.comment }}</p>
                        </div>
                    </div>
                </section>
            </aside>

            <!-- Основная часть -->
            <div class="space-y-6 lg:order-1 lg:col-span-2">
                <!-- Товары -->
                <section class="overflow-hidden rounded-2xl border bg-card shadow-sm" aria-labelledby="items-title">
                    <div class="flex items-center justify-between border-b px-6 py-4">
                        <h2 id="items-title" class="font-semibold">Товары в заказе</h2>
                        <span class="text-sm text-muted-foreground">
                            {{ order.items.length }} поз. · {{ itemsCount }} шт.
                        </span>
                    </div>

                    <ul class="divide-y">
                        <li
                            v-for="item in order.items"
                            :key="item.id"
                            class="flex items-start justify-between gap-4 px-6 py-4"
                        >
                            <div class="flex min-w-0 items-start gap-3">
                                <div
                                    class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary"
                                >
                                    <Package :size="19" />
                                </div>
                                <div class="min-w-0">
                                    <p class="font-medium">{{ item.name }}</p>
                                    <p
                                        v-if="item.code || item.article"
                                        class="mt-0.5 text-xs text-muted-foreground"
                                    >
                                        <span v-if="item.code">Код: {{ item.code }}</span>
                                        <span v-if="item.code && item.article"> · </span>
                                        <span v-if="item.article">Арт.: {{ item.article }}</span>
                                    </p>
                                </div>
                            </div>

                            <div class="shrink-0 text-right">
                                <p class="font-bold tabular-nums">{{ formatPrice(item.subtotal) }} ₽</p>
                                <p class="mt-0.5 text-xs text-muted-foreground tabular-nums">
                                    {{ formatPrice(item.price) }} ₽ × {{ item.quantity }}
                                </p>
                            </div>
                        </li>
                    </ul>

                    <div class="flex items-center justify-between border-t bg-muted/40 px-6 py-4">
                        <span class="text-base font-semibold">Итого</span>
                        <span class="text-2xl font-bold tabular-nums">
                            {{ formatPrice(order.total_amount) }} ₽
                        </span>
                    </div>
                </section>

                <!-- История -->
                <section class="overflow-hidden rounded-2xl border bg-card shadow-sm" aria-labelledby="history-title">
                    <div class="border-b px-6 py-4">
                        <h2 id="history-title" class="font-semibold">История изменений</h2>
                    </div>

                    <ol class="p-6">
                        <li
                            v-for="(h, i) in history"
                            :key="h.id"
                            class="relative flex gap-4 pb-6 last:pb-0"
                        >
                            <div class="flex flex-col items-center">
                                <span
                                    class="mt-1.5 size-3 rounded-full"
                                    :class="i === 0 ? 'bg-primary ring-4 ring-primary/20' : 'bg-border'"
                                />
                                <span v-if="i < history.length - 1" class="mt-1 w-px flex-1 bg-border" />
                            </div>
                            <div class="min-w-0 flex-1">
                                <p class="text-sm font-medium">
                                    {{ statusLabel(h.to_status) }}
                                    <span v-if="h.from_status" class="font-normal text-muted-foreground">
                                        · было: {{ statusLabel(h.from_status) }}
                                    </span>
                                </p>
                                <p v-if="h.note" class="mt-1 rounded-lg bg-muted/60 px-3 py-2 text-sm">
                                    {{ h.note }}
                                </p>
                                <p class="mt-1 text-xs text-muted-foreground">
                                    {{ h.created_at }}<span v-if="h.changed_by"> · {{ h.changed_by }}</span>
                                </p>
                            </div>
                        </li>
                    </ol>
                </section>
            </div>
        </div>

        <!-- Завершить -->
        <div
            v-if="showCompleteDialog"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
            role="dialog"
            aria-modal="true"
            @click.self="showCompleteDialog = false"
        >
            <div class="w-full max-w-md rounded-2xl bg-card p-6 shadow-lg">
                <h3 class="text-lg font-bold">Завершить заказ?</h3>
                <p class="mt-2 text-sm text-muted-foreground">
                    Заказ {{ order.order_number }} будет помечен как выполненный.
                </p>
                <div class="mt-6 flex justify-end gap-3">
                    <Button variant="outline" @click="showCompleteDialog = false">Назад</Button>
                    <Button :disabled="processing" @click="completeOrder">Завершить</Button>
                </div>
            </div>
        </div>

        <!-- Отменить -->
        <div
            v-if="showCancelDialog"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
            role="dialog"
            aria-modal="true"
            @click.self="showCancelDialog = false"
        >
            <div class="w-full max-w-md rounded-2xl bg-card p-6 shadow-lg">
                <h3 class="text-lg font-bold text-destructive">Отменить заказ?</h3>
                <p class="mt-2 text-sm text-muted-foreground">
                    Заказ {{ order.order_number }} будет отменён. Это действие нельзя отменить.
                </p>
                <div class="mt-4">
                    <label class="mb-1 block text-xs font-medium text-muted-foreground">
                        Причина (необязательно)
                    </label>
                    <Input v-model="cancelReason" placeholder="Укажите причину отмены" class="w-full" />
                </div>
                <div class="mt-6 flex justify-end gap-3">
                    <Button variant="outline" @click="showCancelDialog = false">Назад</Button>
                    <Button variant="destructive" :disabled="processing" @click="cancelOrder">
                        Отменить заказ
                    </Button>
                </div>
            </div>
        </div>
    </div>
</template>
