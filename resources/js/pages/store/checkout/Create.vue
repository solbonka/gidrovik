<script setup lang="ts">
import { ArrowLeft, Package } from '@lucide/vue'
import { router } from '@inertiajs/vue3'
import { ref } from 'vue'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

const props = defineProps<{
    items: Array<{
        id: number
        product_id: number
        name: string
        sku: string | null
        quantity: number
        price: string
        subtotal: string
    }>
    total: string
    empty: boolean
}>()

const loading = ref(false)
const deliveryMethod = ref('delivery')
const form = ref({
    customer_name: '',
    customer_email: '',
    customer_phone: '',
    customer_organization: '',
    delivery_address: '',
    comment: '',
    agree_terms: false,
})

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}

function submitForm() {
    loading.value = true
    router.post(
        route('store.checkout.store'),
        {
            ...form.value,
            delivery_method: deliveryMethod.value,
        },
        {
            onFinish: () => { loading.value = false },
        }
    )
}
</script>

<template>
    <div class="mx-auto max-w-4xl px-5 py-8 lg:px-10">
            <a
                :href="route('store.cart.index')"
                class="mb-6 inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-emerald-700"
            >
                <ArrowLeft :size="14" />
                Вернуться в корзину
            </a>

            <h1 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">Оформление заказа</h1>

            <div v-if="empty" class="mt-8 rounded-xl border border-amber-200 bg-amber-50 p-6 text-center">
                <Package :size="32" class="mx-auto text-amber-400" />
                <h3 class="mt-3 text-lg font-bold text-amber-900">Корзина пуста</h3>
                <p class="mt-1 text-sm text-amber-700">Добавьте товары перед оформлением заказа</p>
                <a
                    :href="route('store.catalog.index')"
                    class="mt-4 inline-block rounded-lg bg-amber-600 px-4 py-2 text-sm font-semibold text-white hover:bg-amber-700"
                >
                    Перейти в каталог
                </a>
            </div>

            <div v-else class="mt-8 grid gap-8 lg:grid-cols-5">
                <!-- Form -->
                <div class="lg:col-span-3">
                    <form @submit.prevent="submitForm" class="space-y-6">
                        <!-- Contact info -->
                        <div class="rounded-xl border border-slate-200 bg-white p-6">
                            <h2 class="text-lg font-bold text-slate-900">Контактные данные</h2>
                            <div class="mt-4 space-y-4">
                                <div>
                                    <label class="mb-1 block text-sm font-medium text-slate-700">
                                        * Имя или название организации
                                    </label>
                                    <Input
                                        v-model="form.customer_name"
                                        required
                                        placeholder="Иван Иванов"
                                        class="w-full"
                                    />
                                </div>

                                <div class="grid gap-4 sm:grid-cols-2">
                                    <div>
                                        <label class="mb-1 block text-sm font-medium text-slate-700">
                                            * Электронная почта
                                        </label>
                                        <Input
                                            v-model="form.customer_email"
                                            type="email"
                                            required
                                            placeholder="ivan@example.com"
                                            class="w-full"
                                        />
                                    </div>
                                    <div>
                                        <label class="mb-1 block text-sm font-medium text-slate-700">
                                            * Телефон
                                        </label>
                                        <Input
                                            v-model="form.customer_phone"
                                            type="tel"
                                            required
                                            placeholder="+7 (XXX) XXX-XX-XX"
                                            class="w-full"
                                        />
                                    </div>
                                </div>

                                <div>
                                    <label class="mb-1 block text-sm font-medium text-slate-700">
                                        Организация (необязательно)
                                    </label>
                                    <Input
                                        v-model="form.customer_organization"
                                        placeholder="ООО «Ромашка»"
                                        class="w-full"
                                    />
                                </div>
                            </div>
                        </div>

                        <!-- Delivery method -->
                        <div class="rounded-xl border border-slate-200 bg-white p-6">
                            <h2 class="text-lg font-bold text-slate-900">Способ получения</h2>
                            <div class="mt-4 grid gap-3 sm:grid-cols-2">
                                <label
                                    class="cursor-pointer rounded-lg border-2 p-4 transition"
                                    :class="deliveryMethod === 'delivery' ? 'border-emerald-600 bg-emerald-50' : 'border-slate-200 hover:border-slate-300'"
                                >
                                    <input
                                        type="radio"
                                        name="delivery_method"
                                        value="delivery"
                                        v-model="deliveryMethod"
                                        class="sr-only"
                                    />
                                    <div class="font-semibold text-slate-900">Доставка</div>
                                    <div class="mt-1 text-xs text-slate-500">Доставим по указанному адресу</div>
                                </label>

                                <label
                                    class="cursor-pointer rounded-lg border-2 p-4 transition"
                                    :class="deliveryMethod === 'pickup' ? 'border-emerald-600 bg-emerald-50' : 'border-slate-200 hover:border-slate-300'"
                                >
                                    <input
                                        type="radio"
                                        name="delivery_method"
                                        value="pickup"
                                        v-model="deliveryMethod"
                                        class="sr-only"
                                    />
                                    <div class="font-semibold text-slate-900">Самовывоз</div>
                                    <div class="mt-1 text-xs text-slate-500">Заберём самостоятельно</div>
                                </label>
                            </div>

                            <div v-if="deliveryMethod === 'delivery'" class="mt-4">
                                <label class="mb-1 block text-sm font-medium text-slate-700">
                                    * Адрес доставки
                                </label>
                                <textarea
                                    v-model="form.delivery_address"
                                    required
                                    rows="3"
                                    class="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-emerald-400 focus:ring-emerald-400"
                                    placeholder="Город, улица, дом, квартира"
                                />
                            </div>
                        </div>

                        <!-- Comment -->
                        <div class="rounded-xl border border-slate-200 bg-white p-6">
                            <h2 class="text-lg font-bold text-slate-900">Комментарий</h2>
                            <textarea
                                v-model="form.comment"
                                rows="3"
                                class="mt-4 w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-emerald-400 focus:ring-emerald-400"
                                placeholder="Дополнительные пожелания к заказу"
                            />
                        </div>

                        <!-- Terms -->
                        <label class="flex cursor-pointer items-start gap-3">
                            <input
                                type="checkbox"
                                v-model="form.agree_terms"
                                class="mt-1 size-4 rounded border-slate-300 accent-emerald-600"
                            />
                            <span class="text-sm text-slate-600">
                                Я даю согласие на
                                <a :href="route('store.pages.privacy')" class="text-emerald-700 hover:underline">
                                    обработку персональных данных
                                </a>
                            </span>
                        </label>

                        <!-- Submit -->
                        <Button
                            type="submit"
                            :disabled="loading || !form.agree_terms"
                            class="w-full rounded-xl bg-emerald-600 py-3 text-base font-semibold text-white shadow-lg shadow-emerald-600/20 hover:bg-emerald-700 disabled:opacity-50"
                        >
                            {{ loading ? 'Оформление...' : 'Оформить заказ' }}
                        </Button>
                    </form>
                </div>

                <!-- Order summary -->
                <div class="lg:col-span-2">
                    <div class="sticky top-24 rounded-xl border border-slate-200 bg-white p-6">
                        <h2 class="text-lg font-bold text-slate-900">Ваш заказ</h2>

                        <div class="mt-4 space-y-3">
                            <div
                                v-for="item in items"
                                :key="item.id"
                                class="flex justify-between text-sm"
                            >
                                <div class="min-w-0 flex-1">
                                    <span class="font-medium text-slate-900">{{ item.name }}</span>
                                    <span class="ml-1 text-slate-400">×{{ item.quantity }}</span>
                                </div>
                                <span class="shrink-0 font-semibold text-slate-900">
                                    {{ formatPrice(item.subtotal) }} ₽
                                </span>
                            </div>
                        </div>

                        <div class="mt-4 border-t border-slate-200 pt-4">
                            <div class="flex items-center justify-between">
                                <span class="text-base font-bold text-slate-900">Итого:</span>
                                <span class="text-2xl font-extrabold text-slate-950">
                                    {{ formatPrice(total) }} ₽
                                </span>
                            </div>
                        </div>

                        <div class="mt-4 rounded-lg bg-slate-50 p-3 text-xs text-slate-500">
                            <p>Оплата согласовывается с менеджером после оформления заказа.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</template>
