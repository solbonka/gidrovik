<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3'
import {
    ArrowRight,
    Check,
    ChevronRight,
    Package,
    Phone,
    ShieldCheck,
    Truck,
    Zap,
} from '@lucide/vue'
import { ref } from 'vue'

const props = defineProps<{
    categories: Array<{
        id: number
        name: string
        slug: string
        product_count: number
    }>
    featuredProducts: Array<{
        id: number
        name: string
        slug: string
        sku: string
        price: string
        image_path?: string | null
        stock_status: string
    }>
    advantages: Array<{
        icon: string
        title: string
        description: string
    }>
}>()

const currentYear = new Date().getFullYear()

// Simple reactive state for future use (e.g., category hover)
const activeCategoryId = ref<number | null>(null)
</script>

<template>
    <!-- Hero -->
    <section class="relative overflow-hidden bg-gradient-to-br from-slate-900 via-slate-800 to-emerald-900">
            <div class="pointer-events-none absolute inset-0">
                <div class="absolute -right-40 -top-40 h-96 w-96 rounded-full bg-emerald-500/10 blur-3xl" />
                <div class="absolute -bottom-40 -left-40 h-96 w-96 rounded-full bg-teal-500/10 blur-3xl" />
            </div>

            <div class="relative mx-auto max-w-7xl px-5 py-16 sm:px-8 sm:py-20 lg:px-10 lg:py-24">
                <div class="grid items-center gap-12 lg:grid-cols-2">
                    <div>
                        <div class="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-500/10 px-3.5 py-2 text-xs font-semibold text-emerald-300">
                            <span class="size-2 rounded-full bg-emerald-400 animate-pulse" />
                            Работаем с 2020 года
                        </div>

                        <h1 class="mt-6 text-3xl font-extrabold leading-tight tracking-tight text-white sm:text-4xl lg:text-5xl">
                            Промышленное
                            <br />
                            гидравлическое
                            <br />
                            <span class="bg-gradient-to-r from-emerald-400 to-teal-300 bg-clip-text text-transparent">
                                оборудование
                            </span>
                        </h1>

                        <p class="mt-5 max-w-xl text-base leading-7 text-slate-300 sm:text-lg">
                            Комплектующие, фитинги, трубы и сопутствующие товары
                            от ведущих производителей. Всё в наличии — без ожидания поставок.
                        </p>

                        <div class="mt-8 flex flex-col gap-3 sm:flex-row">
                            <Link
                                :href="route('store.catalog.index')"
                                class="inline-flex items-center justify-center gap-2 rounded-xl bg-emerald-600 px-6 py-3 text-sm font-semibold text-white shadow-lg shadow-emerald-600/25 transition hover:bg-emerald-700"
                            >
                                Перейти в каталог
                                <ArrowRight :size="16" />
                            </Link>
                        </div>

                        <ul class="mt-8 flex flex-wrap gap-x-5 gap-y-3 text-sm text-slate-400">
                            <li class="flex items-center gap-2">
                                <Check :size="14" class="text-emerald-400" />
                                Розничные цены
                            </li>
                            <li class="flex items-center gap-2">
                                <Check :size="14" class="text-emerald-400" />
                                Отправка по всей России
                            </li>
                            <li class="flex items-center gap-2">
                                <Check :size="14" class="text-emerald-400" />
                                Технические консультации
                            </li>
                        </ul>
                    </div>

                    <!-- Stats cards -->
                    <div class="grid grid-cols-2 gap-4 sm:grid-cols-2">
                        <div class="rounded-2xl border border-white/10 bg-white/5 p-6 backdrop-blur">
                            <div class="flex size-11 items-center justify-center rounded-xl bg-emerald-500/20 text-emerald-400">
                                <Package :size="22" />
                            </div>
                            <div class="mt-4 text-3xl font-extrabold text-white">1000+</div>
                            <div class="mt-1 text-sm text-slate-400">Товаров в наличии</div>
                        </div>

                        <div class="rounded-2xl border border-white/10 bg-white/5 p-6 backdrop-blur">
                            <div class="flex size-11 items-center justify-center rounded-xl bg-teal-500/20 text-teal-400">
                                <Truck :size="22" />
                            </div>
                            <div class="mt-4 text-3xl font-extrabold text-white">1-3</div>
                            <div class="mt-1 text-sm text-slate-400">Дня доставки</div>
                        </div>

                        <div class="rounded-2xl border border-white/10 bg-white/5 p-6 backdrop-blur">
                            <div class="flex size-11 items-center justify-center rounded-xl bg-cyan-500/20 text-cyan-400">
                                <ShieldCheck :size="22" />
                            </div>
                            <div class="mt-4 text-3xl font-extrabold text-white">100%</div>
                            <div class="mt-1 text-sm text-slate-400">Гарантия качества</div>
                        </div>

                        <div class="rounded-2xl border border-white/10 bg-white/5 p-6 backdrop-blur">
                            <div class="flex size-11 items-center justify-center rounded-xl bg-sky-500/20 text-sky-400">
                                <Zap :size="22" />
                            </div>
                            <div class="mt-4 text-3xl font-extrabold text-white">24/7</div>
                            <div class="mt-1 text-sm text-slate-400">Онлайн-заказы</div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Categories -->
        <section class="px-5 py-16 sm:px-8 sm:py-20 lg:px-10">
            <div class="mx-auto max-w-7xl">
                <div class="flex items-end justify-between">
                    <div>
                        <h2 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">Категории товаров</h2>
                        <p class="mt-2 text-sm text-slate-500">Выберите интересующую категорию</p>
                    </div>
                    <Link
                        :href="route('store.catalog.index')"
                        class="hidden items-center gap-1 text-sm font-semibold text-emerald-700 hover:text-emerald-800 md:inline-flex"
                    >
                        Все категории
                        <ChevronRight :size="16" />
                    </Link>
                </div>

                <div class="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    <Link
                        v-for="category in categories"
                        :key="category.id"
                        :href="route('store.catalog.index', { category: category.slug })"
                        class="group rounded-2xl border border-slate-200 bg-white p-6 transition hover:border-emerald-200 hover:shadow-lg hover:shadow-slate-900/[0.04]"
                    >
                        <div class="flex items-center justify-between">
                            <div>
                                <h3 class="font-bold text-slate-900 group-hover:text-emerald-700">{{ category.name }}</h3>
                                <p class="mt-1 text-xs text-slate-500">{{ category.product_count }} товаров</p>
                            </div>
                            <ChevronRight :size="18" class="text-slate-300 transition group-hover:text-emerald-600 group-hover:translate-x-0.5" />
                        </div>
                    </Link>
                </div>

                <div class="mt-6 text-center sm:hidden">
                    <Link
                        :href="route('store.catalog.index')"
                        class="inline-flex items-center gap-1 text-sm font-semibold text-emerald-700"
                    >
                        Все категории
                        <ChevronRight :size="16" />
                    </Link>
                </div>
            </div>
        </section>

        <!-- Featured products -->
        <section v-if="featuredProducts.length > 0" class="border-y border-slate-100 bg-slate-50/50 px-5 py-16 sm:px-8 sm:py-20 lg:px-10">
            <div class="mx-auto max-w-7xl">
                <div class="flex items-end justify-between">
                    <div>
                        <h2 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">Популярные товары</h2>
                        <p class="mt-2 text-sm text-slate-500">Товары, которые выбирают чаще всего</p>
                    </div>
                    <Link
                        :href="route('store.catalog.index')"
                        class="hidden items-center gap-1 text-sm font-semibold text-emerald-700 hover:text-emerald-800 md:inline-flex"
                    >
                        В каталог
                        <ChevronRight :size="16" />
                    </Link>
                </div>

                <div class="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    <Link
                        v-for="product in featuredProducts"
                        :key="product.id"
                        :href="route('store.products.show', { product: product.slug })"
                        class="group rounded-2xl border border-slate-200 bg-white overflow-hidden transition hover:border-emerald-200 hover:shadow-lg hover:shadow-slate-900/[0.04]"
                    >
                        <!-- Image placeholder -->
                        <div class="aspect-square bg-slate-100 flex items-center justify-center">
                            <Package :size="32" class="text-slate-300" />
                        </div>

                        <div class="p-4">
                            <h3 class="text-sm font-semibold text-slate-900 line-clamp-2 group-hover:text-emerald-700">
                                {{ product.name }}
                            </h3>
                            <p v-if="product.sku" class="mt-0.5 text-xs text-slate-400">Артикул: {{ product.sku }}</p>

                            <div class="mt-3 flex items-center justify-between">
                                <div class="text-lg font-extrabold text-slate-900">{{ product.price }} ₽</div>
                                <span
                                    class="rounded-full px-2 py-0.5 text-[10px] font-bold"
                                    :class="{
                                        'bg-emerald-100 text-emerald-700': product.stock_status === 'in_stock',
                                        'bg-amber-100 text-amber-700': product.stock_status === 'backorder',
                                        'bg-rose-100 text-rose-700': product.stock_status === 'out_of_stock',
                                    }"
                                >
                                    {{ product.stock_status }}
                                </span>
                            </div>
                        </div>
                    </Link>
                </div>
            </div>
        </section>

        <!-- Advantages -->
        <section class="px-5 py-16 sm:px-8 sm:py-20 lg:px-10">
            <div class="mx-auto max-w-7xl">
                <div class="text-center max-w-2xl mx-auto">
                    <h2 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">Почему выбирают нас</h2>
                    <p class="mt-3 text-sm text-slate-500">Работаем напрямую с производителями и гарантируем качество каждого товара</p>
                </div>

                <div class="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
                    <div v-for="(advantage, index) in advantages" :key="index" class="rounded-2xl border border-slate-200 bg-white p-8">
                        <div class="flex size-12 items-center justify-center rounded-xl bg-emerald-50 text-emerald-700">
                            <ShieldCheck :size="24" />
                        </div>
                        <h3 class="mt-5 text-lg font-bold text-slate-900">{{ advantage.title }}</h3>
                        <p class="mt-2 text-sm leading-6 text-slate-500">{{ advantage.description }}</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- CTA -->
        <section class="px-5 py-16 sm:px-8 sm:py-20 lg:px-10">
            <div class="mx-auto max-w-7xl">
                <div class="relative overflow-hidden rounded-3xl bg-gradient-to-br from-emerald-600 to-teal-600 px-8 py-14 sm:px-12 sm:py-16">
                    <div class="pointer-events-none absolute -right-20 -top-20 h-80 w-80 rounded-full bg-white/10 blur-3xl" />
                    <div class="pointer-events-none absolute -bottom-20 -left-20 h-80 w-80 rounded-full bg-white/5 blur-3xl" />

                    <div class="relative max-w-2xl">
                        <h2 class="text-2xl font-extrabold text-white sm:text-3xl">
                            Не нашли нужный товар?
                        </h2>
                        <p class="mt-3 text-base text-emerald-100">
                            Позвоните нам или оставьте заявку — подберём необходимое оборудование
                            и комплектующие под ваши задачи.
                        </p>
                        <div class="mt-7 flex flex-col gap-3 sm:flex-row">
                            <a
                                href="tel:+7XXXXXXXXXX"
                                class="inline-flex items-center justify-center gap-2 rounded-xl bg-white px-6 py-3 text-sm font-semibold text-emerald-700 shadow-lg transition hover:bg-emerald-50"
                            >
                                <Phone :size="16" />
                                +7 (XXX) XXX-XX-XX
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </section>
</template>
