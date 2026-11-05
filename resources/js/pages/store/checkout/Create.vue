<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    PhCaretLeft,
    PhCircleNotch,
    PhLock,
    PhMapPin,
    PhPackage,
    PhTruck,
} from '@phosphor-icons/vue'
import { ref } from 'vue'

defineProps<{
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
    total: string
    empty: boolean
}>()

const loading = ref(false)
const submitted = ref(false)
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

const labelClass = 'mb-1.5 block text-sm font-semibold text-zinc-700 dark:text-zinc-300'
const fieldClass = 'w-full rounded-xl border border-zinc-200 bg-zinc-50 px-4 py-3 text-sm text-zinc-900 shadow-sm outline-none transition placeholder:text-zinc-400 hover:border-zinc-300 focus:border-orange-500 focus:bg-white focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-100 dark:placeholder:text-zinc-500 dark:hover:border-zinc-600 dark:focus:border-orange-400 dark:focus:bg-zinc-800'
const cardClass = 'rounded-3xl border border-zinc-200 bg-white p-5 shadow-sm dark:border-zinc-800 dark:bg-zinc-900 sm:p-6'
const stepBadgeClass = 'flex size-7 shrink-0 items-center justify-center rounded-full bg-orange-500 text-xs font-black text-zinc-950'

function deliveryOptionClass(active: boolean): string {
    return active
        ? 'border-orange-500 bg-orange-50 shadow-md shadow-orange-500/10 dark:border-orange-400 dark:bg-orange-500/10'
        : 'border-zinc-200 hover:border-orange-300 dark:border-zinc-700 dark:hover:border-zinc-600'
}

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}

function submitForm() {
    if (loading.value || submitted.value) return
    submitted.value = true
    loading.value = true

    const formData = new FormData()
    formData.append('customer_name', form.value.customer_name)
    formData.append('customer_email', form.value.customer_email)
    formData.append('customer_phone', form.value.customer_phone)
    formData.append('customer_organization', form.value.customer_organization)
    formData.append('delivery_method', deliveryMethod.value)
    formData.append('delivery_address', form.value.delivery_address)
    formData.append('comment', form.value.comment)
    formData.append('agree_terms', form.value.agree_terms ? '1' : '0')

    fetch(route('store.checkout.store'), {
        method: 'POST',
        headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
        },
        body: formData,
    })
        .then(async (response) => {
            if (response.redirected) {
                window.location.href = response.url

                return
            }

            const data = await response.json()

            if (data.errors) {
                loading.value = false
                submitted.value = false
                alert('Проверьте правильность заполнения формы')
            }
        })
        .catch(() => {
            loading.value = false
            submitted.value = false
        })
}
</script>

<template>
    <Head title="Оформление заказа" />

    <div class="mx-auto max-w-7xl px-3 py-5 sm:px-6 sm:py-8 lg:px-10 lg:py-10">
        <!-- Шапка -->
        <header class="relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-orange-50 via-white to-white p-5 dark:border-zinc-800 dark:from-orange-500/10 dark:via-zinc-900 dark:to-zinc-900 sm:p-8">
            <div class="pointer-events-none absolute -right-16 -top-16 size-64 rounded-full bg-orange-400/20 blur-3xl dark:bg-orange-500/15" />
            <div class="pointer-events-none absolute -bottom-24 right-1/3 size-56 rounded-full bg-amber-300/20 blur-3xl dark:bg-amber-500/10" />

            <div class="relative flex items-center gap-4">
                <a
                    :href="route('store.cart.index')"
                    class="flex size-11 shrink-0 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-600 shadow-sm transition hover:border-orange-400 hover:text-orange-600 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/20 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
                    aria-label="Вернуться в корзину"
                >
                    <PhCaretLeft :size="20" weight="bold" />
                </a>

                <div>
                    <p class="inline-flex items-center gap-2 rounded-full bg-orange-500/10 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400 sm:text-xs">
                        <span class="size-1.5 rounded-full bg-orange-500" />
                        Оформление
                    </p>

                    <h1 class="mt-2 text-3xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-4xl">
                        Оформление заказа
                    </h1>
                </div>
            </div>
        </header>

        <!-- Пустая корзина -->
        <div
            v-if="empty"
            class="mt-6 rounded-3xl border border-dashed border-orange-300/70 bg-gradient-to-b from-orange-50/60 to-white p-8 text-center dark:border-orange-500/30 dark:from-orange-500/5 dark:to-zinc-900 sm:mt-8 sm:p-16"
        >
            <div class="mx-auto flex size-20 items-center justify-center rounded-3xl bg-orange-100 text-orange-500 shadow-inner dark:bg-orange-500/15">
                <PhPackage :size="38" weight="duotone" />
            </div>

            <h3 class="mt-5 text-xl font-extrabold text-zinc-900 dark:text-zinc-100">
                Корзина пуста
            </h3>

            <p class="mx-auto mt-2 max-w-sm text-sm text-zinc-500 dark:text-zinc-400">
                Добавьте товары перед оформлением заказа
            </p>

            <a
                :href="route('store.catalog.index')"
                class="mt-6 inline-flex h-12 items-center rounded-full bg-orange-500 px-8 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/30 transition hover:-translate-y-0.5 hover:bg-orange-400"
            >
                Перейти в каталог
            </a>
        </div>

        <div v-else class="mt-6 grid gap-6 lg:mt-8 lg:grid-cols-5 lg:items-start lg:gap-8">
            <!-- Форма -->
            <div class="space-y-5 lg:col-span-3">
                <!-- Контакты -->
                <section :class="cardClass">
                    <h2 class="flex items-center gap-3 text-lg font-extrabold text-zinc-950 dark:text-white">
                        <span :class="stepBadgeClass">1</span>
                        Контактные данные
                    </h2>

                    <div class="mt-5 space-y-4">
                        <div>
                            <label for="customer_name" :class="labelClass">
                                Имя или название организации <span class="text-orange-500">*</span>
                            </label>

                            <input
                                id="customer_name"
                                v-model="form.customer_name"
                                required
                                autocomplete="name"
                                placeholder="Иван Иванов"
                                :class="fieldClass"
                            />
                        </div>

                        <div class="grid gap-4 sm:grid-cols-2">
                            <div>
                                <label for="customer_email" :class="labelClass">
                                    Электронная почта <span class="text-orange-500">*</span>
                                </label>

                                <input
                                    id="customer_email"
                                    v-model="form.customer_email"
                                    type="email"
                                    required
                                    autocomplete="email"
                                    placeholder="ivan@example.com"
                                    :class="fieldClass"
                                />
                            </div>

                            <div>
                                <label for="customer_phone" :class="labelClass">
                                    Телефон <span class="text-orange-500">*</span>
                                </label>

                                <input
                                    id="customer_phone"
                                    v-model="form.customer_phone"
                                    type="tel"
                                    required
                                    autocomplete="tel"
                                    placeholder="+7 (XXX) XXX-XX-XX"
                                    :class="fieldClass"
                                />
                            </div>
                        </div>

                        <div>
                            <label for="customer_organization" :class="labelClass">
                                Организация <span class="font-normal text-zinc-400">(необязательно)</span>
                            </label>

                            <input
                                id="customer_organization"
                                v-model="form.customer_organization"
                                autocomplete="organization"
                                placeholder="ООО «Ромашка»"
                                :class="fieldClass"
                            />
                        </div>
                    </div>
                </section>

                <!-- Способ получения -->
                <section :class="cardClass">
                    <h2 class="flex items-center gap-3 text-lg font-extrabold text-zinc-950 dark:text-white">
                        <span :class="stepBadgeClass">2</span>
                        Способ получения
                    </h2>

                    <div class="mt-5 grid gap-3 sm:grid-cols-2">
                        <label
                            class="cursor-pointer rounded-2xl border-2 p-4 transition focus-within:ring-4 focus-within:ring-orange-500/20"
                            :class="deliveryOptionClass(deliveryMethod === 'delivery')"
                        >
                            <input
                                v-model="deliveryMethod"
                                type="radio"
                                name="delivery_method"
                                value="delivery"
                                class="sr-only"
                            />

                            <span class="mb-3 flex size-11 items-center justify-center rounded-xl bg-orange-500/10 text-orange-500">
                                <PhTruck :size="24" weight="duotone" />
                            </span>

                            <div class="font-bold text-zinc-900 dark:text-zinc-100">Доставка</div>
                            <div class="mt-1 text-xs text-zinc-500 dark:text-zinc-400">Доставим по указанному адресу</div>
                        </label>

                        <label
                            class="cursor-pointer rounded-2xl border-2 p-4 transition focus-within:ring-4 focus-within:ring-orange-500/20"
                            :class="deliveryOptionClass(deliveryMethod === 'pickup')"
                        >
                            <input
                                v-model="deliveryMethod"
                                type="radio"
                                name="delivery_method"
                                value="pickup"
                                class="sr-only"
                            />

                            <span class="mb-3 flex size-11 items-center justify-center rounded-xl bg-orange-500/10 text-orange-500">
                                <PhMapPin :size="24" weight="duotone" />
                            </span>

                            <div class="font-bold text-zinc-900 dark:text-zinc-100">Самовывоз</div>
                            <div class="mt-1 text-xs text-zinc-500 dark:text-zinc-400">Заберём самостоятельно</div>
                        </label>
                    </div>

                    <div v-if="deliveryMethod === 'delivery'" class="mt-4">
                        <label for="delivery_address" :class="labelClass">
                            Адрес доставки <span class="text-orange-500">*</span>
                        </label>

                        <textarea
                            id="delivery_address"
                            v-model="form.delivery_address"
                            required
                            rows="3"
                            placeholder="Город, улица, дом, квартира"
                            :class="fieldClass"
                        />
                    </div>
                </section>

                <!-- Комментарий -->
                <section :class="cardClass">
                    <h2 class="flex items-center gap-3 text-lg font-extrabold text-zinc-950 dark:text-white">
                        <span :class="stepBadgeClass">3</span>
                        Комментарий
                    </h2>

                    <textarea
                        v-model="form.comment"
                        rows="3"
                        aria-label="Комментарий к заказу"
                        placeholder="Дополнительные пожелания к заказу"
                        :class="fieldClass"
                        class="mt-5"
                    />
                </section>

                <!-- Согласие -->
                <label class="flex cursor-pointer items-start gap-3 rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm transition hover:border-orange-300 dark:border-zinc-800 dark:bg-zinc-900">
                    <input
                        v-model="form.agree_terms"
                        type="checkbox"
                        class="mt-0.5 size-5 rounded-md border-zinc-300 accent-orange-500"
                    />

                    <span class="text-sm text-zinc-600 dark:text-zinc-400">
                        Я даю согласие на
                        <a
                            :href="route('store.pages.privacy')"
                            class="font-semibold text-orange-600 underline-offset-4 hover:underline dark:text-orange-400"
                        >
                            обработку персональных данных
                        </a>
                    </span>
                </label>

                <!-- Отправка -->
                <button
                    type="button"
                    :disabled="loading || !form.agree_terms"
                    class="flex h-14 w-full items-center justify-center gap-2 rounded-full bg-orange-500 px-8 text-base font-bold text-zinc-950 shadow-lg shadow-orange-500/30 transition hover:-translate-y-0.5 hover:bg-orange-400 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/30 disabled:translate-y-0 disabled:cursor-not-allowed disabled:opacity-50 disabled:shadow-none"
                    @click="submitForm"
                >
                    <PhCircleNotch v-if="loading || submitted" :size="20" weight="bold" class="animate-spin" />
                    {{ loading || submitted ? 'Оформляем…' : 'Оформить заказ' }}
                </button>
            </div>

            <!-- Состав заказа -->
            <aside class="lg:col-span-2">
                <div class="overflow-hidden rounded-3xl border border-zinc-200 bg-white shadow-sm dark:border-zinc-800 dark:bg-zinc-900 lg:sticky lg:top-28">
                    <div class="relative overflow-hidden bg-gradient-to-br from-orange-50 to-white px-6 py-5 dark:from-orange-500/10 dark:to-zinc-900">
                        <div class="pointer-events-none absolute -right-10 -top-10 size-32 rounded-full bg-orange-400/20 blur-2xl" />

                        <h2 class="relative text-lg font-extrabold text-zinc-950 dark:text-white">
                            Ваш заказ
                        </h2>
                    </div>

                    <div class="p-6">
                        <ul class="space-y-3">
                            <li
                                v-for="item in items"
                                :key="item.id"
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
                                    {{ formatPrice(total) }} ₽
                                </span>
                            </div>
                        </div>

                        <div class="mt-5 flex items-start gap-3 rounded-2xl bg-orange-50 p-4 text-xs text-orange-800 dark:bg-orange-500/10 dark:text-orange-300">
                            <PhLock :size="16" weight="duotone" class="mt-0.5 shrink-0" />
                            <p>Оплата согласовывается с менеджером после оформления заказа.</p>
                        </div>
                    </div>
                </div>
            </aside>
        </div>
    </div>
</template>
