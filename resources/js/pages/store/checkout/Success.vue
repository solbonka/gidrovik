<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    PhArrowRight,
    PhCheck,
    PhCheckCircle,
    PhCopy,
    PhEnvelope,
    PhKey,
    PhMapPin,
    PhPhone,
    PhReceipt,
    PhShoppingCart,
} from '@phosphor-icons/vue'
import { onBeforeUnmount, ref } from 'vue'

const props = defineProps<{
    order: {
        id: number
        order_number: string
        access_token: string
        customer_name: string
        customer_email: string
        customer_phone: string
        delivery_method: string
        delivery_method_label: string
        delivery_address?: string | null
        total_amount: string
        status: string
        status_label: string
        status_color: string
        created_at: string
        items: Array<{
            name: string
            quantity: number
            price: string
            subtotal: string
        }>
    }
}>()

const cardClass = 'rounded-3xl border border-zinc-200 bg-white p-6 shadow-sm dark:border-zinc-800 dark:bg-zinc-900'

const copied = ref(false)
let copiedTimeout: ReturnType<typeof setTimeout> | null = null

onBeforeUnmount(() => {
    if (copiedTimeout) clearTimeout(copiedTimeout)
})

async function copyToken() {
    try {
        await navigator.clipboard.writeText(props.order.access_token)
        copied.value = true

        if (copiedTimeout) clearTimeout(copiedTimeout)

        copiedTimeout = setTimeout(() => {
            copied.value = false
        }, 2000)
    } catch {
        // Буфер обмена недоступен — пользователь может выделить токен вручную
    }
}

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}
</script>

<template>
    <Head title="Заказ оформлен" />

    <div class="mx-auto max-w-3xl px-4 py-8 sm:px-6 sm:py-12 lg:px-10">
        <!-- Успех -->
        <header class="relative overflow-hidden rounded-3xl border border-emerald-200/70 bg-gradient-to-br from-emerald-50 via-white to-orange-50 p-8 text-center dark:border-emerald-500/20 dark:from-emerald-500/10 dark:via-zinc-900 dark:to-orange-500/10 sm:p-12">
            <div class="pointer-events-none absolute -left-16 -top-16 size-64 rounded-full bg-emerald-400/20 blur-3xl dark:bg-emerald-500/15" />
            <div class="pointer-events-none absolute -bottom-20 -right-10 size-56 rounded-full bg-orange-400/20 blur-3xl dark:bg-orange-500/10" />

            <div class="relative">
                <div class="mx-auto mb-6 flex size-24 items-center justify-center rounded-full bg-emerald-500/10 ring-8 ring-emerald-500/5">
                    <PhCheckCircle :size="56" weight="fill" class="text-emerald-600 dark:text-emerald-400" />
                </div>

                <h1 class="text-3xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-4xl">
                    Заказ оформлен!
                </h1>

                <p class="mx-auto mt-3 max-w-md text-base text-zinc-600 dark:text-zinc-400 sm:text-lg">
                    Спасибо за ваш заказ. Мы свяжемся с вами в ближайшее время.
                </p>
            </div>
        </header>

        <div class="mx-auto mt-6 max-w-lg space-y-5">
            <!-- Номер заказа -->
            <section :class="cardClass">
                <div class="flex items-center justify-between gap-4">
                    <div class="min-w-0">
                        <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-zinc-400">
                            Номер заказа
                        </p>

                        <p class="mt-1 truncate text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                            {{ order.order_number }}
                        </p>
                    </div>

                    <span
                        class="inline-flex shrink-0 rounded-full px-3 py-1.5 text-xs font-bold"
                        :class="order.status_color"
                    >
                        {{ order.status_label }}
                    </span>
                </div>

                <div class="mt-4 border-t border-dashed border-zinc-200 pt-4 dark:border-zinc-700">
                    <p class="text-sm text-zinc-500 dark:text-zinc-400">
                        Дата оформления:
                        <span class="font-semibold text-zinc-900 dark:text-white">{{ order.created_at }}</span>
                    </p>
                </div>

                <!-- Токен -->
                <div class="mt-4 rounded-2xl border border-orange-200 bg-orange-50 p-4 dark:border-orange-500/30 dark:bg-orange-500/10">
                    <p class="flex items-center gap-2 text-sm font-bold text-orange-800 dark:text-orange-300">
                        <PhKey :size="18" weight="duotone" />
                        Сохраните токен для просмотра заказа
                    </p>

                    <div class="mt-3 flex items-center gap-2">
                        <code class="min-w-0 flex-1 select-all break-all rounded-xl bg-white px-3 py-2.5 font-mono text-sm text-zinc-900 shadow-sm dark:bg-zinc-900 dark:text-zinc-100">
                            {{ order.access_token }}
                        </code>

                        <button
                            type="button"
                            class="flex size-11 shrink-0 items-center justify-center rounded-xl text-sm font-semibold transition focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/30"
                            :class="copied
                                ? 'bg-emerald-500 text-white'
                                : 'bg-orange-500 text-zinc-950 hover:bg-orange-400'"
                            :aria-label="copied ? 'Скопировано' : 'Скопировать токен'"
                            :title="copied ? 'Скопировано' : 'Скопировать токен'"
                            @click="copyToken"
                        >
                            <PhCheck v-if="copied" :size="18" weight="bold" />
                            <PhCopy v-else :size="18" weight="bold" />
                        </button>
                    </div>

                    <p class="mt-3 text-xs text-orange-700 dark:text-orange-400">
                        Этот токен нужен для повторного просмотра заказа. Без него заказ будет недоступен.
                    </p>
                </div>
            </section>

            <!-- Состав заказа -->
            <section :class="cardClass">
                <h2 class="flex items-center gap-2 text-lg font-extrabold text-zinc-950 dark:text-white">
                    <PhReceipt :size="20" weight="duotone" class="text-orange-500" />
                    Ваш заказ
                </h2>

                <ul class="mt-4 space-y-3">
                    <li
                        v-for="(item, index) in order.items"
                        :key="index"
                        class="flex justify-between gap-3 text-sm"
                    >
                        <div class="min-w-0 flex-1">
                            <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ item.name }}</span>
                            <span class="ml-1 rounded-md bg-zinc-100 px-1.5 py-0.5 text-xs font-semibold text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400">×{{ item.quantity }}</span>
                        </div>

                        <span class="shrink-0 font-semibold text-zinc-900 dark:text-zinc-100">
                            {{ formatPrice(item.subtotal) }} ₽
                        </span>
                    </li>
                </ul>

                <div class="mt-5 border-t border-dashed border-zinc-200 pt-5 dark:border-zinc-700">
                    <div class="flex items-baseline justify-between gap-3">
                        <span class="text-base font-bold text-zinc-950 dark:text-white">Итого</span>
                        <span class="text-3xl font-black tracking-tight text-zinc-950 dark:text-white">
                            {{ formatPrice(order.total_amount) }} ₽
                        </span>
                    </div>
                </div>
            </section>

            <!-- Контакты -->
            <section class="rounded-3xl border border-zinc-200 bg-zinc-50 p-6 dark:border-zinc-800 dark:bg-zinc-900/50">
                <h3 class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-zinc-500 before:h-3 before:w-0.5 before:rounded-full before:bg-orange-500 dark:text-zinc-400">
                    Контактные данные
                </h3>

                <ul class="mt-4 space-y-3 text-sm text-zinc-700 dark:text-zinc-300">
                    <li class="flex items-center gap-3">
                        <span class="flex size-8 shrink-0 items-center justify-center rounded-full bg-white text-orange-500 shadow-sm dark:bg-zinc-800">
                            <PhPhone :size="16" weight="duotone" />
                        </span>
                        {{ order.customer_phone }}
                    </li>

                    <li class="flex items-center gap-3">
                        <span class="flex size-8 shrink-0 items-center justify-center rounded-full bg-white text-orange-500 shadow-sm dark:bg-zinc-800">
                            <PhEnvelope :size="16" weight="duotone" />
                        </span>
                        {{ order.customer_email }}
                    </li>

                    <li v-if="order.delivery_method === 'delivery'" class="flex items-center gap-3">
                        <span class="flex size-8 shrink-0 items-center justify-center rounded-full bg-white text-orange-500 shadow-sm dark:bg-zinc-800">
                            <PhMapPin :size="16" weight="duotone" />
                        </span>
                        {{ order.delivery_address }}
                    </li>
                </ul>
            </section>

            <!-- Что дальше -->
            <section class="rounded-3xl border border-orange-200 bg-gradient-to-br from-orange-50 to-white p-6 dark:border-orange-500/30 dark:from-orange-500/10 dark:to-zinc-900">
                <h3 class="text-[11px] font-bold uppercase tracking-[0.14em] text-orange-700 dark:text-orange-400">
                    Что дальше?
                </h3>

                <ol class="mt-4 space-y-3 text-sm text-orange-900 dark:text-orange-200">
                    <li class="flex items-start gap-3">
                        <PhCheckCircle :size="18" weight="fill" class="mt-0.5 shrink-0 text-orange-500" />
                        Менеджер свяжется с вами для подтверждения заказа
                    </li>

                    <li class="flex items-start gap-3">
                        <PhCheckCircle :size="18" weight="fill" class="mt-0.5 shrink-0 text-orange-500" />
                        После оплаты мы приступим к подготовке заказа
                    </li>

                    <li v-if="order.delivery_method === 'delivery'" class="flex items-start gap-3">
                        <PhCheckCircle :size="18" weight="fill" class="mt-0.5 shrink-0 text-orange-500" />
                        Доставка по указанному адресу
                    </li>

                    <li v-else class="flex items-start gap-3">
                        <PhCheckCircle :size="18" weight="fill" class="mt-0.5 shrink-0 text-orange-500" />
                        Самовывоз после подтверждения
                    </li>
                </ol>
            </section>

            <!-- Кнопки -->
            <div class="flex flex-col gap-3 pt-2">
                <a
                    :href="route('store.catalog.index')"
                    class="inline-flex h-13 items-center justify-center gap-2 rounded-full bg-orange-500 px-8 py-3.5 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/30 transition hover:-translate-y-0.5 hover:bg-orange-400 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/30"
                >
                    <PhShoppingCart :size="18" weight="duotone" />
                    Продолжить покупки
                </a>

                <div class="grid gap-3 sm:grid-cols-2">
                    <a
                        :href="`/orders/${order.order_number}?token=${order.access_token}`"
                        class="inline-flex items-center justify-center gap-2 rounded-full border border-zinc-200 bg-white px-6 py-3 text-sm font-bold text-zinc-700 shadow-sm transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
                    >
                        <PhReceipt :size="18" weight="duotone" />
                        Мой заказ
                    </a>

                    <a
                        :href="route('store.home')"
                        class="inline-flex items-center justify-center gap-2 rounded-full border border-zinc-200 bg-white px-6 py-3 text-sm font-bold text-zinc-700 shadow-sm transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
                    >
                        На главную
                        <PhArrowRight :size="18" weight="bold" />
                    </a>
                </div>
            </div>
        </div>
    </div>
</template>
