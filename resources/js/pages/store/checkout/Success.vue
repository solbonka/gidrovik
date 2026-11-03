<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    PhCheckCircle,
    PhShoppingCart,
    PhArrowRight,
    PhMapPin,
    PhPhone,
    PhEnvelope,
} from '@phosphor-icons/vue'

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

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}
</script>

<template>
    <Head title="Заказ оформлен" />

    <div class="mx-auto max-w-3xl px-4 py-12 sm:px-6 lg:px-10">
        <!-- Успех -->
        <div class="text-center">
            <div class="mx-auto mb-6 flex size-20 items-center justify-center rounded-full bg-emerald-500/10">
                <PhCheckCircle :size="48" weight="fill" class="text-emerald-600 dark:text-emerald-400" />
            </div>

            <h1 class="text-3xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-4xl">
                Заказ оформлен!
            </h1>
            <p class="mt-3 text-lg text-zinc-600 dark:text-zinc-400">
                Спасибо за ваш заказ. Мы свяжемся с вами в ближайшее время.
            </p>
        </div>

        <!-- Номер заказа -->
        <div class="mx-auto mt-8 max-w-lg">
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm font-medium text-zinc-500 dark:text-zinc-400">Номер заказа</p>
                        <p class="mt-1 text-2xl font-bold tracking-tight text-zinc-950 dark:text-white">
                            {{ order.order_number }}
                        </p>
                    </div>
                    <div class="rounded-full bg-emerald-500/10 px-4 py-2">
                        <span
                            class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-bold"
                            :class="order.status_color"
                        >
                            {{ order.status_label }}
                        </span>
                    </div>
                </div>

                <div class="mt-4 border-t border-zinc-200 pt-4 dark:border-zinc-800">
                    <p class="text-sm text-zinc-600 dark:text-zinc-400">
                        Дата оформления: <span class="font-semibold text-zinc-900 dark:text-white">{{ order.created_at }}</span>
                    </p>
                </div>

                <div class="mt-4 rounded-xl border border-orange-200 bg-orange-50 p-4 dark:border-orange-900/50 dark:bg-orange-950/30">
                    <p class="text-sm font-medium text-orange-800 dark:text-orange-300">
                        🔐 Сохраните токен для просмотра заказа
                    </p>
                    <div class="mt-2 flex items-center gap-2">
                        <code class="flex-1 rounded bg-white px-3 py-2 text-sm font-mono text-zinc-900 dark:bg-zinc-900 dark:text-zinc-100">
                            {{ order.access_token }}
                        </code>
                    </div>
                    <p class="mt-2 text-xs text-orange-700 dark:text-orange-400">
                        Этот токен нужен для повторного просмотра заказа. Без него заказ будет недоступен.
                    </p>
                </div>
            </div>
        </div>

        <!-- Детали заказа -->
        <div class="mx-auto mt-8 max-w-lg">
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Ваш заказ</h2>

                <div class="mt-4 space-y-3">
                    <div
                        v-for="(item, index) in order.items"
                        :key="index"
                        class="flex justify-between text-sm"
                    >
                        <div class="min-w-0 flex-1">
                            <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ item.name }}</span>
                            <span class="ml-1 text-zinc-400">×{{ item.quantity }}</span>
                        </div>
                        <span class="shrink-0 font-semibold text-zinc-900 dark:text-zinc-100">
                            {{ formatPrice(item.subtotal) }} ₽
                        </span>
                    </div>
                </div>

                <div class="mt-4 border-t border-zinc-200 pt-4 dark:border-zinc-800">
                    <div class="flex items-baseline justify-between">
                        <span class="text-base font-bold text-zinc-950 dark:text-white">Итого:</span>
                        <span class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                            {{ formatPrice(order.total_amount) }} ₽
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Контакты -->
        <div class="mx-auto mt-6 max-w-lg">
            <div class="rounded-2xl border border-zinc-200 bg-zinc-50 p-6 dark:border-zinc-800 dark:bg-zinc-900/50">
                <h3 class="text-sm font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
                    Контактные данные
                </h3>
                <div class="mt-3 space-y-2 text-sm text-zinc-700 dark:text-zinc-300">
                    <div class="flex items-center gap-2">
                        <PhPhone :size="16" class="shrink-0 text-zinc-400" />
                        {{ order.customer_phone }}
                    </div>
                    <div class="flex items-center gap-2">
                        <PhEnvelope :size="16" class="shrink-0 text-zinc-400" />
                        {{ order.customer_email }}
                    </div>
                    <div v-if="order.delivery_method === 'delivery'" class="flex items-center gap-2">
                        <PhMapPin :size="16" class="shrink-0 text-zinc-400" />
                        {{ order.delivery_address }}
                    </div>
                </div>
            </div>
        </div>

        <!-- Что дальше -->
        <div class="mx-auto mt-6 max-w-lg">
            <div class="rounded-2xl border border-orange-200 bg-orange-50 p-6 dark:border-orange-900/50 dark:bg-orange-950/30">
                <h3 class="text-sm font-bold uppercase tracking-wider text-orange-700 dark:text-orange-400">
                    Что дальше?
                </h3>
                <ul class="mt-3 space-y-2 text-sm text-orange-800 dark:text-orange-300">
                    <li class="flex items-start gap-2">
                        <PhCheckCircle :size="16" class="mt-0.5 shrink-0 text-orange-600 dark:text-orange-400" weight="fill" />
                        Менеджер свяжется с вами для подтверждения заказа
                    </li>
                    <li class="flex items-start gap-2">
                        <PhCheckCircle :size="16" class="mt-0.5 shrink-0 text-orange-600 dark:text-orange-400" weight="fill" />
                        После оплаты мы приступим к подготовке заказа
                    </li>
                    <li v-if="order.delivery_method === 'delivery'" class="flex items-start gap-2">
                        <PhCheckCircle :size="16" class="mt-0.5 shrink-0 text-orange-600 dark:text-orange-400" weight="fill" />
                        Доставка по указанному адресу
                    </li>
                    <li v-else class="flex items-start gap-2">
                        <PhCheckCircle :size="16" class="mt-0.5 shrink-0 text-orange-600 dark:text-orange-400" weight="fill" />
                        Самовывоз после подтверждения
                    </li>
                </ul>
            </div>
        </div>

        <!-- Кнопки -->
        <div class="mx-auto mt-8 flex max-w-lg flex-col gap-3 sm:flex-row">
            <a
                :href="`/orders/${order.order_number}?token=${order.access_token}`"
                class="inline-flex flex-1 items-center justify-center gap-2 rounded-full border border-zinc-200 bg-white px-8 py-3 text-sm font-bold text-zinc-700 transition hover:border-zinc-300 hover:bg-zinc-50 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-zinc-700 dark:hover:bg-zinc-800"
            >
                <PhEnvelope :size="18" weight="duotone" />
                Мой заказ
            </a>
            <a
                :href="route('store.catalog.index')"
                class="inline-flex flex-1 items-center justify-center gap-2 rounded-full bg-orange-500 px-8 py-3 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/25 transition hover:bg-orange-400"
            >
                <PhShoppingCart :size="18" weight="duotone" />
                Продолжить покупки
            </a>
            <a
                :href="route('store.home')"
                class="inline-flex flex-1 items-center justify-center gap-2 rounded-full border border-zinc-200 bg-white px-8 py-3 text-sm font-bold text-zinc-700 transition hover:border-zinc-300 hover:bg-zinc-50 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-zinc-700 dark:hover:bg-zinc-800"
            >
                На главную
                <PhArrowRight :size="18" weight="bold" />
            </a>
        </div>
    </div>
</template>
