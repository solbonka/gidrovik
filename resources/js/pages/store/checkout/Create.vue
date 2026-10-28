<script setup lang="ts">
import { Head, router } from '@inertiajs/vue3'
import {
    PhCaretLeft,
    PhPackage,
    PhTruck,
    PhMapPin,
    PhShoppingCart,
} from '@phosphor-icons/vue'
import { ref } from 'vue'

const props = defineProps<{
    items: Array<{
        id: number
        product_id: number
        name: string
        code: string | null;
        article: string | null;
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
            preserveScroll: true,
            onFinish: () => { loading.value = false },
        }
    )
}
</script>

<template>
    <Head title="Оформление заказа" />

    <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-10 lg:py-12">
        <!-- Header -->
        <div class="mb-8 flex items-center gap-4">
            <a
                :href="route('store.cart.index')"
                class="flex size-10 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-600 transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
            >
                <PhCaretLeft :size="20" weight="bold" />
            </a>
            <div>
                <p class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400">Оформление</p>
                <h1 class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-3xl">Оформление заказа</h1>
            </div>
        </div>

        <div v-if="empty" class="rounded-3xl border border-amber-200 bg-amber-50 p-8 text-center dark:border-amber-800 dark:bg-amber-950/30">
            <PhPackage :size="48" weight="light" class="mx-auto text-amber-500" />
            <h3 class="mt-4 text-xl font-extrabold text-amber-900 dark:text-amber-100">Корзина пуста</h3>
            <p class="mt-2 text-sm text-amber-700 dark:text-amber-300">Добавьте товары перед оформлением заказа</p>
            <a
                :href="route('store.catalog.index')"
                class="mt-6 inline-flex h-12 items-center rounded-full bg-amber-600 px-8 text-sm font-bold text-white shadow-lg shadow-amber-600/25 transition hover:bg-amber-500"
            >
                Перейти в каталог
            </a>
        </div>

        <div v-else class="grid gap-8 lg:grid-cols-5">
            <!-- Form -->
            <div class="space-y-6 lg:col-span-3">
                <!-- Contact info -->
                <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                    <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Контактные данные</h2>
                    <div class="mt-4 space-y-4">
                        <div>
                            <label class="mb-1 block text-sm font-medium text-zinc-700 dark:text-zinc-300">
                                * Имя или название организации
                            </label>
                            <input
                                v-model="form.customer_name"
                                required
                                placeholder="Иван Иванов"
                                class="w-full rounded-xl border border-zinc-200 bg-zinc-50 px-4 py-3 text-sm outline-none transition focus:border-orange-400 focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-100 dark:focus:border-orange-500"
                            />
                        </div>

                        <div class="grid gap-4 sm:grid-cols-2">
                            <div>
                                <label class="mb-1 block text-sm font-medium text-zinc-700 dark:text-zinc-300">
                                    * Электронная почта
                                </label>
                                <input
                                    v-model="form.customer_email"
                                    type="email"
                                    required
                                    placeholder="ivan@example.com"
                                    class="w-full rounded-xl border border-zinc-200 bg-zinc-50 px-4 py-3 text-sm outline-none transition focus:border-orange-400 focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-100 dark:focus:border-orange-500"
                                />
                            </div>
                            <div>
                                <label class="mb-1 block text-sm font-medium text-zinc-700 dark:text-zinc-300">
                                    * Телефон
                                </label>
                                <input
                                    v-model="form.customer_phone"
                                    type="tel"
                                    required
                                    placeholder="+7 (XXX) XXX-XX-XX"
                                    class="w-full rounded-xl border border-zinc-200 bg-zinc-50 px-4 py-3 text-sm outline-none transition focus:border-orange-400 focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-100 dark:focus:border-orange-500"
                                />
                            </div>
                        </div>

                        <div>
                            <label class="mb-1 block text-sm font-medium text-zinc-700 dark:text-zinc-300">
                                Организация (необязательно)
                            </label>
                            <input
                                v-model="form.customer_organization"
                                placeholder="ООО «Ромашка»"
                                class="w-full rounded-xl border border-zinc-200 bg-zinc-50 px-4 py-3 text-sm outline-none transition focus:border-orange-400 focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-100 dark:focus:border-orange-500"
                            />
                        </div>
                    </div>
                </div>

                <!-- Delivery method -->
                <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                    <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Способ получения</h2>
                    <div class="mt-4 grid gap-3 sm:grid-cols-2">
                        <label
                            class="cursor-pointer rounded-xl border-2 p-4 transition"
                            :class="deliveryMethod === 'delivery' ? 'border-orange-500 bg-orange-50 dark:border-orange-400 dark:bg-orange-950/30' : 'border-zinc-200 hover:border-zinc-300 dark:border-zinc-700 dark:hover:border-zinc-600'"
                        >
                            <input
                                type="radio"
                                name="delivery_method"
                                value="delivery"
                                v-model="deliveryMethod"
                                class="sr-only"
                            />
                            <PhTruck :size="24" weight="duotone" class="mb-2 text-orange-500" />
                            <div class="font-semibold text-zinc-900 dark:text-zinc-100">Доставка</div>
                            <div class="mt-1 text-xs text-zinc-500 dark:text-zinc-400">Доставим по указанному адресу</div>
                        </label>

                        <label
                            class="cursor-pointer rounded-xl border-2 p-4 transition"
                            :class="deliveryMethod === 'pickup' ? 'border-orange-500 bg-orange-50 dark:border-orange-400 dark:bg-orange-950/30' : 'border-zinc-200 hover:border-zinc-300 dark:border-zinc-700 dark:hover:border-zinc-600'"
                        >
                            <input
                                type="radio"
                                name="delivery_method"
                                value="pickup"
                                v-model="deliveryMethod"
                                class="sr-only"
                            />
                            <PhMapPin :size="24" weight="duotone" class="mb-2 text-orange-500" />
                            <div class="font-semibold text-zinc-900 dark:text-zinc-100">Самовывоз</div>
                            <div class="mt-1 text-xs text-zinc-500 dark:text-zinc-400">Заберём самостоятельно</div>
                        </label>
                    </div>

                    <div v-if="deliveryMethod === 'delivery'" class="mt-4">
                        <label class="mb-1 block text-sm font-medium text-zinc-700 dark:text-zinc-300">
                            * Адрес доставки
                        </label>
                        <textarea
                            v-model="form.delivery_address"
                            required
                            rows="3"
                            class="w-full rounded-xl border border-zinc-200 bg-zinc-50 px-4 py-3 text-sm outline-none transition focus:border-orange-400 focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-100 dark:focus:border-orange-500"
                            placeholder="Город, улица, дом, квартира"
                        />
                    </div>
                </div>

                <!-- Comment -->
                <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                    <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Комментарий</h2>
                    <textarea
                        v-model="form.comment"
                        rows="3"
                        class="mt-4 w-full rounded-xl border border-zinc-200 bg-zinc-50 px-4 py-3 text-sm outline-none transition focus:border-orange-400 focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-100 dark:focus:border-orange-500"
                        placeholder="Дополнительные пожелания к заказу"
                    />
                </div>

                <!-- Terms -->
                <label class="flex cursor-pointer items-start gap-3">
                    <input
                        type="checkbox"
                        v-model="form.agree_terms"
                        class="mt-1 size-4 rounded border-zinc-300 accent-orange-500"
                    />
                    <span class="text-sm text-zinc-600 dark:text-zinc-400">
                        Я даю согласие на
                        <a :href="route('store.pages.privacy')" class="font-semibold text-orange-600 underline-offset-4 hover:underline dark:text-orange-400">
                            обработку персональных данных
                        </a>
                    </span>
                </label>

                <!-- Submit -->
                <button
                    type="button"
                    @click="submitForm"
                    :disabled="loading || !form.agree_terms"
                    class="w-full h-14 rounded-full bg-orange-500 px-8 text-base font-bold text-zinc-950 shadow-lg shadow-orange-500/25 transition hover:bg-orange-400 disabled:opacity-50"
                >
                    {{ loading ? 'Оформление...' : 'Оформить заказ' }}
                </button>
            </div>

            <!-- Order summary -->
            <div class="lg:col-span-2">
                <div class="sticky top-28 rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                    <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Ваш заказ</h2>

                    <div class="mt-4 space-y-3">
                        <div
                            v-for="item in items"
                            :key="item.id"
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
                                {{ formatPrice(total) }} ₽
                            </span>
                        </div>
                    </div>

                    <div class="mt-4 rounded-xl bg-zinc-50 p-4 text-xs text-zinc-500 dark:bg-zinc-800 dark:text-zinc-400">
                        <p>Оплата согласовывается с менеджером после оформления заказа.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
