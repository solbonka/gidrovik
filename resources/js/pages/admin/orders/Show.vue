<script setup lang="ts">
import { Head, router } from '@inertiajs/vue3'
import {
    ArrowLeft,
    Calendar,
    Check,
    ChevronDown,
    Mail,
    Package,
    Phone,
    Plus,
    Store,
    Truck,
    X,
} from '@lucide/vue'
import { ref } from 'vue'

import AdminLayout from '@/layouts/AdminLayout.vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
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
            sku: string | null
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

const showStatusDropdown = ref(false)
const showCompleteDialog = ref(false)
const showCancelDialog = ref(false)
const statusNote = ref('')
const cancelReason = ref('')

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}

function updateStatus(newStatus: string) {
    router.put(
        route('admin.orders.status.update', { order: props.order.order_number }),
        { status: newStatus, note: statusNote.value },
        {
            preserveState: true,
            onSuccess: () => {
                showStatusDropdown.value = false
                statusNote.value = ''
            },
        }
    )
}

function completeOrder() {
    router.post(
        route('admin.orders.complete', { order: props.order.order_number }),
        {},
        { preserveState: true }
    )
}

function cancelOrder() {
    router.post(
        route('admin.orders.cancel', { order: props.order.order_number }),
        { reason: cancelReason.value },
        { preserveState: true }
    )
}
</script>

<template>
    <Head title="Заказ " />

    <div class="p-6 lg:p-8">
        <!-- Header -->
        <div class="mb-6 flex items-center justify-between">
            <div class="flex items-center gap-4">
                <a
                    :href="route('admin.orders.index')"
                    class="flex items-center gap-1.5 text-sm text-slate-500 hover:text-emerald-700"
                >
                    <ArrowLeft :size="16" />
                    Назад
                </a>
                <h1 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">
                    Заказ {{ order.order_number }}
                </h1>
            </div>

            <div class="flex items-center gap-2">
                <span
                    class="inline-flex rounded-full px-3 py-1.5 text-sm font-bold"
                    :class="order.status_color"
                >
                    {{ order.status_label }}
                </span>
            </div>
        </div>

        <div class="grid gap-6 lg:grid-cols-5">
            <!-- Order items -->
            <div class="lg:col-span-3">
                <div class="rounded-xl border border-slate-200 bg-white">
                    <div class="border-b border-slate-200 px-6 py-4">
                        <h2 class="text-lg font-bold text-slate-900">Товары</h2>
                    </div>

                    <div class="divide-y divide-slate-100">
                        <div
                            v-for="item in order.items"
                            :key="item.id"
                            class="flex justify-between px-6 py-4"
                        >
                            <div class="min-w-0 flex-1">
                                <div class="font-medium text-slate-900">{{ item.name }}</div>
                                <p v-if="item.sku" class="mt-0.5 text-xs text-slate-400">
                                    Арт: {{ item.sku }}
                                </p>
                                <div class="mt-1 text-xs text-slate-500">
                                    {{ formatPrice(item.price) }} ₽ × {{ item.quantity }}
                                </div>
                            </div>
                            <div class="shrink-0 text-right font-bold text-slate-900">
                                {{ formatPrice(item.subtotal) }} ₽
                            </div>
                        </div>
                    </div>

                    <div class="border-t border-slate-200 px-6 py-4">
                        <div class="flex items-center justify-between">
                            <span class="text-base font-bold text-slate-900">Итого:</span>
                            <span class="text-2xl font-extrabold text-slate-950">
                                {{ formatPrice(order.total_amount) }} ₽
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Order details -->
            <div class="lg:col-span-2 space-y-6">
                <!-- Status change -->
                <div class="rounded-xl border border-slate-200 bg-white p-6">
                    <h3 class="text-sm font-bold text-slate-900">Статус</h3>

                    <div class="mt-3 relative">
                        <Button
                            variant="outline"
                            class="w-full justify-between"
                            @click="showStatusDropdown = !showStatusDropdown"
                        >
                            <span class="flex items-center gap-2">
                                <span
                                    class="inline-block size-2 rounded-full"
                                    :class="{
                                        'bg-emerald-500': order.status === 'confirmed' || order.status === 'picking' || order.status === 'ready' || order.status === 'shipped' || order.status === 'completed',
                                        'bg-amber-500': order.status === 'new',
                                        'bg-rose-500': order.status === 'cancelled',
                                    }"
                                />
                                {{ order.status_label }}
                            </span>
                            <ChevronDown :size="16" />
                        </Button>

                        <div
                            v-if="showStatusDropdown"
                            class="absolute right-0 z-10 mt-1 w-full rounded-lg border border-slate-200 bg-white shadow-lg"
                        >
                            <div class="p-2">
                                <input
                                    v-model="statusNote"
                                    type="text"
                                    placeholder="Комментарий (необязательно)"
                                    class="mb-2 w-full rounded-md border border-slate-200 px-3 py-1.5 text-sm focus:border-emerald-400"
                                />
                                <button
                                    v-for="status in statuses"
                                    :key="status.value"
                                    :disabled="status.value === order.status"
                                    @click="updateStatus(status.value)"
                                    class="w-full rounded-md px-3 py-2 text-left text-sm hover:bg-slate-50 disabled:opacity-50"
                                >
                                    {{ status.label }}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick actions -->
                <div class="rounded-xl border border-slate-200 bg-white p-6">
                    <h3 class="text-sm font-bold text-slate-900">Действия</h3>
                    <div class="mt-3 space-y-2">
                        <Button
                            variant="outline"
                            class="w-full justify-start gap-2 border-emerald-200 text-emerald-700 hover:bg-emerald-50"
                            @click="showCompleteDialog = true"
                        >
                            <Check :size="16" />
                            Завершить заказ
                        </Button>
                        <Button
                            variant="outline"
                            class="w-full justify-start gap-2 border-rose-200 text-rose-700 hover:bg-rose-50"
                            @click="showCancelDialog = true"
                        >
                            <X :size="16" />
                            Отменить заказ
                        </Button>
                    </div>
                </div>

                <!-- Contact info -->
                <div class="rounded-xl border border-slate-200 bg-white p-6">
                    <h3 class="text-sm font-bold text-slate-900">Контактные данные</h3>
                    <div class="mt-3 space-y-3 text-sm">
                        <div class="flex items-center gap-2">
                            <Phone :size="14" class="text-slate-400" />
                            <span class="font-medium text-slate-900">{{ order.customer_phone }}</span>
                        </div>
                        <div class="flex items-center gap-2">
                            <Mail :size="14" class="text-slate-400" />
                            <span class="font-medium text-slate-900">{{ order.customer_email }}</span>
                        </div>
                        <div v-if="order.customer_organization">
                            <span class="text-slate-500">Организация:</span>
                            <span class="ml-2 font-medium text-slate-900">{{ order.customer_organization }}</span>
                        </div>
                    </div>
                </div>

                <!-- Delivery info -->
                <div class="rounded-xl border border-slate-200 bg-white p-6">
                    <h3 class="text-sm font-bold text-slate-900">Доставка</h3>
                    <div class="mt-3 space-y-2 text-sm">
                        <div class="flex items-center gap-2">
                            <Truck v-if="order.delivery_method === 'delivery'" :size="14" class="text-slate-400" />
                            <Store v-else :size="14" class="text-slate-400" />
                            <span class="font-medium text-slate-900">{{ order.delivery_method_label }}</span>
                        </div>
                        <div v-if="order.delivery_address">
                            <span class="text-slate-500">Адрес:</span>
                            <p class="mt-0.5 text-slate-900">{{ order.delivery_address }}</p>
                        </div>
                        <div v-if="order.comment">
                            <span class="text-slate-500">Комментарий:</span>
                            <p class="mt-0.5 text-slate-900">{{ order.comment }}</p>
                        </div>
                    </div>
                </div>

                <!-- Date -->
                <div class="rounded-xl border border-slate-200 bg-white p-6">
                    <div class="flex items-center gap-2 text-sm text-slate-500">
                        <Calendar :size="14" />
                        <span>Оформлен: {{ order.created_at }}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Status history -->
        <div class="mt-6">
            <h2 class="mb-4 text-lg font-bold text-slate-900">История статусов</h2>
            <div class="space-y-4">
                <div
                    v-for="(history, i) in order.status_history"
                    :key="history.id"
                    class="flex gap-4"
                >
                    <div class="flex flex-col items-center">
                        <div class="flex size-8 items-center justify-center rounded-full bg-emerald-100 text-sm font-bold text-emerald-700">
                            {{ i + 1 }}
                        </div>
                        <div v-if="i < order.status_history.length - 1" class="mt-1 h-8 w-px bg-slate-200" />
                    </div>
                    <div class="pb-6">
                        <div class="text-sm font-medium text-slate-900">
                            {{ history.to_status }}
                            <span v-if="history.from_status" class="text-slate-400">
                                (было: {{ history.from_status }})
                            </span>
                        </div>
                        <p v-if="history.note" class="mt-0.5 text-xs text-slate-500">{{ history.note }}</p>
                        <p class="mt-1 text-xs text-slate-400">
                            {{ history.created_at }}
                            <span v-if="history.changed_by">· {{ history.changed_by }}</span>
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Complete dialog -->
        <div
            v-if="showCompleteDialog"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
            @click.self="showCompleteDialog = false"
        >
            <div class="w-full max-w-md rounded-xl bg-white p-6">
                <h3 class="text-lg font-bold text-slate-900">Завершить заказ?</h3>
                <p class="mt-2 text-sm text-slate-500">
                    Заказ {{ order.order_number }} будет помечен как выполненный.
                </p>
                <div class="mt-6 flex justify-end gap-3">
                    <Button variant="outline" @click="showCompleteDialog = false">
                        Отмена
                    </Button>
                    <Button @click="completeOrder">
                        Завершить
                    </Button>
                </div>
            </div>
        </div>

        <!-- Cancel dialog -->
        <div
            v-if="showCancelDialog"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
            @click.self="showCancelDialog = false"
        >
            <div class="w-full max-w-md rounded-xl bg-white p-6">
                <h3 class="text-lg font-bold text-rose-700">Отменить заказ?</h3>
                <p class="mt-2 text-sm text-slate-500">
                    Заказ {{ order.order_number }} будет отменён. Это действие нельзя отменить.
                </p>
                <div class="mt-4">
                    <label class="mb-1 block text-xs font-medium text-slate-500">Причина (необязательно)</label>
                    <Input
                        v-model="cancelReason"
                        placeholder="Укажите причину отмены"
                        class="w-full"
                    />
                </div>
                <div class="mt-6 flex justify-end gap-3">
                    <Button variant="outline" @click="showCancelDialog = false">
                        Отмена
                    </Button>
                    <Button variant="destructive" @click="cancelOrder">
                        Отменить заказ
                    </Button>
                </div>
            </div>
        </div>
    </div>
</template>
