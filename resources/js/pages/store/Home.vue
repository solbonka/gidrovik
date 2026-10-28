<script setup lang="ts">
import { Link } from '@inertiajs/vue3'
import {
    PhArrowRight,
    PhArrowUpRight,
    PhCheck,
    PhClock,
    PhHeadset,
    PhLightning,
    PhPackage,
    PhPhone,
    PhShieldCheck,
    PhTruck,
    PhWallet,
} from '@phosphor-icons/vue'
import type { Component } from 'vue'

import ProductCard from '@/components/store/ProductCard.vue'

defineProps<{
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
        code: string
        article: string | null
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

const stats = [
    { icon: PhPackage, value: '1000+', label: 'Товаров в наличии' },
    { icon: PhTruck, value: '1–3', label: 'Дня доставки' },
    { icon: PhShieldCheck, value: '100%', label: 'Гарантия качества' },
    { icon: PhLightning, value: '24/7', label: 'Онлайн-заказы' },
]

const perks = ['Розничные цены', 'Отправка по всей России', 'Технические консультации']

// Иконка преимущества приходит строкой с бэкенда — подбираем подходящую
const iconMap: Record<string, Component> = {
    truck: PhTruck,
    shield: PhShieldCheck,
    'shield-check': PhShieldCheck,
    zap: PhLightning,
    package: PhPackage,
    phone: PhPhone,
    headphones: PhHeadset,
    clock: PhClock,
    wallet: PhWallet,
}
const fallbackIcons: Component[] = [PhShieldCheck, PhTruck, PhLightning, PhHeadset, PhPackage, PhClock]

function advantageIcon(icon: string | undefined, index: number): Component {
    const key = (icon ?? '').toLowerCase().replace(/_/g, '-')
    return iconMap[key] ?? fallbackIcons[index % fallbackIcons.length]
}
</script>

<template>
    <!-- Hero -->
    <section class="mx-auto max-w-7xl px-4 pt-4 sm:px-6 sm:pt-6 lg:px-10">
        <div class="relative isolate overflow-hidden rounded-[28px] bg-zinc-950 px-5 py-10 text-white ring-1 ring-zinc-900/5 dark:ring-white/10 sm:rounded-[36px] sm:px-10 sm:py-16 lg:px-14 lg:py-20">
            <!-- Сетка и свечение -->
            <div
                class="pointer-events-none absolute inset-0 -z-10 [background-image:linear-gradient(to_right,rgba(255,255,255,0.06)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.06)_1px,transparent_1px)] [background-size:44px_44px] [mask-image:radial-gradient(ellipse_at_top_right,black,transparent_72%)]"
            />
            <div class="pointer-events-none absolute -right-32 -top-32 -z-10 size-[28rem] rounded-full bg-orange-500/25 blur-[110px]" />
            <div class="pointer-events-none absolute -bottom-40 -left-24 -z-10 size-[22rem] rounded-full bg-amber-400/10 blur-[110px]" />

            <div class="grid items-center gap-10 lg:grid-cols-[1.15fr_1fr] lg:gap-14">
                <div>
                    <div class="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-3.5 py-1.5 text-xs font-semibold text-zinc-300">
                        <span class="relative flex size-2">
                            <span class="absolute inline-flex size-full animate-ping rounded-full bg-orange-400 opacity-75" />
                            <span class="relative inline-flex size-2 rounded-full bg-orange-500" />
                        </span>
                        Работаем с 2020 года
                    </div>

                    <h1 class="mt-6 text-[2rem] font-black leading-[1.05] tracking-tight sm:text-5xl lg:text-6xl">
                        Промышленное
                        <span class="block text-orange-500">гидравлическое</span>
                        оборудование
                    </h1>

                    <p class="mt-5 max-w-xl text-base leading-7 text-zinc-400 sm:text-lg">
                        Комплектующие, фитинги, трубы и сопутствующие товары от ведущих производителей.
                        Всё в наличии — без ожидания поставок.
                    </p>

                    <div class="mt-8 flex flex-col gap-3 sm:flex-row">
                        <Link
                            :href="route('store.catalog.index')"
                            class="group inline-flex h-12 items-center justify-center gap-2 rounded-full bg-orange-500 px-7 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/25 transition hover:bg-orange-400"
                        >
                            Перейти в каталог
                            <PhArrowRight :size="18" weight="bold" class="transition group-hover:translate-x-1" />
                        </Link>
                        <a
                            href="tel:+7XXXXXXXXXX"
                            class="inline-flex h-12 items-center justify-center gap-2 rounded-full border border-white/15 bg-white/5 px-6 text-sm font-semibold text-white backdrop-blur transition hover:bg-white/10"
                        >
                            <PhPhone :size="18" weight="fill" class="text-orange-500" />
                            Позвонить
                        </a>
                    </div>

                    <ul class="mt-8 flex flex-wrap gap-x-5 gap-y-2.5 text-sm text-zinc-400">
                        <li v-for="perk in perks" :key="perk" class="flex items-center gap-2">
                            <PhCheck :size="14" weight="bold" class="text-orange-500" />
                            {{ perk }}
                        </li>
                    </ul>
                </div>

                <!-- Показатели -->
                <div class="grid grid-cols-2 gap-3 sm:gap-4">
                    <div
                        v-for="(stat, i) in stats"
                        :key="stat.label"
                        class="rounded-3xl border border-white/10 bg-white/[0.04] p-5 backdrop-blur transition hover:bg-white/[0.07] sm:p-6"
                        :class="i % 2 === 1 ? 'translate-y-4 sm:translate-y-6' : ''"
                    >
                        <div class="flex size-10 items-center justify-center rounded-xl bg-orange-500/15 text-orange-400 sm:size-11">
                            <component :is="stat.icon" :size="22" weight="duotone" />
                        </div>
                        <div class="mt-5 text-3xl font-black tracking-tight sm:text-4xl">{{ stat.value }}</div>
                        <div class="mt-1 text-xs text-zinc-400 sm:text-sm">{{ stat.label }}</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Категории -->
    <section class="px-4 py-14 sm:px-6 sm:py-20 lg:px-10">
        <div class="mx-auto max-w-7xl">
            <div class="flex items-end justify-between gap-4">
                <div>
                    <p class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400">Каталог</p>
                    <h2 class="mt-2 text-3xl font-black tracking-tight sm:text-4xl">Категории товаров</h2>
                </div>
                <Link
                    :href="route('store.catalog.index')"
                    class="hidden shrink-0 items-center gap-1.5 text-sm font-bold text-zinc-900 transition hover:text-orange-600 dark:text-zinc-100 dark:hover:text-orange-400 md:inline-flex"
                >
                    Все категории
                    <PhArrowUpRight :size="16" weight="bold" />
                </Link>
            </div>

            <div class="mt-8 grid grid-cols-2 gap-3 sm:gap-4 lg:grid-cols-4">
                <Link
                    v-for="(category, i) in categories"
                    :key="category.id"
                    :href="route('store.catalog.index', { category: category.slug })"
                    class="group flex min-h-[150px] flex-col justify-between rounded-3xl border border-zinc-200 bg-white p-4 transition duration-300 hover:-translate-y-1 hover:border-orange-500 hover:bg-orange-500 dark:border-zinc-800 dark:bg-zinc-900 dark:hover:border-orange-500 sm:min-h-[180px] sm:p-6"
                >
                    <div class="flex items-start justify-between">
                        <span class="font-mono text-xs font-semibold text-zinc-400 transition group-hover:text-zinc-950/60">
                            {{ String(i + 1).padStart(2, '0') }}
                        </span>
                        <span class="flex size-9 items-center justify-center rounded-full bg-zinc-100 text-zinc-500 transition group-hover:rotate-45 group-hover:bg-zinc-950 group-hover:text-orange-500 dark:bg-zinc-800">
                            <PhArrowUpRight :size="16" weight="bold" />
                        </span>
                    </div>
                    <div>
                        <h3 class="text-base font-extrabold leading-tight tracking-tight text-zinc-900 transition group-hover:text-zinc-950 dark:text-zinc-100 dark:group-hover:text-zinc-950 sm:text-lg">
                            {{ category.name }}
                        </h3>
                        <p class="mt-1 text-xs text-zinc-500 transition group-hover:text-zinc-950/70 dark:text-zinc-400 dark:group-hover:text-zinc-950/70">
                            {{ category.product_count }} товаров
                        </p>
                    </div>
                </Link>
            </div>

            <div class="mt-6 text-center md:hidden">
                <Link
                    :href="route('store.catalog.index')"
                    class="inline-flex items-center gap-1.5 text-sm font-bold text-orange-600 dark:text-orange-400"
                >
                    Все категории
                    <PhArrowRight :size="16" weight="bold" />
                </Link>
            </div>
        </div>
    </section>

    <!-- Популярные товары -->
    <section
        v-if="featuredProducts.length > 0"
        class="border-y border-zinc-200 bg-white px-4 py-14 dark:border-zinc-800 dark:bg-zinc-900/40 sm:px-6 sm:py-20 lg:px-10"
    >
        <div class="mx-auto max-w-7xl">
            <div class="flex items-end justify-between gap-4">
                <div>
                    <p class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400">Хиты</p>
                    <h2 class="mt-2 text-3xl font-black tracking-tight sm:text-4xl">Популярные товары</h2>
                    <p class="mt-2 text-sm text-zinc-500 dark:text-zinc-400">Товары, которые выбирают чаще всего</p>
                </div>
                <Link
                    :href="route('store.catalog.index')"
                    class="hidden shrink-0 items-center gap-1.5 rounded-full border border-zinc-200 px-5 py-2.5 text-sm font-bold transition hover:border-orange-500 hover:text-orange-600 dark:border-zinc-700 dark:hover:text-orange-400 md:inline-flex"
                >
                    В каталог
                    <PhArrowRight :size="16" weight="bold" />
                </Link>
            </div>

            <div class="mt-8 grid grid-cols-2 gap-3 sm:gap-4 lg:grid-cols-4">
                <ProductCard v-for="product in featuredProducts" :key="product.id" :product="product" />
            </div>
        </div>
    </section>

    <!-- Преимущества -->
    <section class="px-4 py-14 sm:px-6 sm:py-20 lg:px-10">
        <div class="mx-auto max-w-7xl">
            <div class="mx-auto max-w-2xl text-center">
                <p class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400">Преимущества</p>
                <h2 class="mt-2 text-3xl font-black tracking-tight sm:text-4xl">Почему выбирают нас</h2>
                <p class="mt-3 text-sm text-zinc-500 dark:text-zinc-400 sm:text-base">
                    Работаем напрямую с производителями и гарантируем качество каждого товара
                </p>
            </div>

            <div class="mt-10 grid gap-3 sm:gap-4 md:grid-cols-2 lg:grid-cols-3">
                <div
                    v-for="(advantage, index) in advantages"
                    :key="index"
                    class="rounded-3xl border p-6 transition duration-300 hover:-translate-y-1 sm:p-8"
                    :class="index === 0
                        ? 'border-transparent bg-orange-500 text-zinc-950'
                        : 'border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900'"
                >
                    <div
                        class="flex size-12 items-center justify-center rounded-2xl"
                        :class="index === 0
                            ? 'bg-zinc-950 text-orange-500'
                            : 'bg-orange-500/10 text-orange-600 dark:text-orange-400'"
                    >
                        <component :is="advantageIcon(advantage.icon, index)" :size="26" weight="duotone" />
                    </div>
                    <h3 class="mt-6 text-lg font-extrabold tracking-tight sm:text-xl">{{ advantage.title }}</h3>
                    <p
                        class="mt-2 text-sm leading-6"
                        :class="index === 0 ? 'text-zinc-950/75' : 'text-zinc-500 dark:text-zinc-400'"
                    >
                        {{ advantage.description }}
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA -->
    <section class="px-4 pb-14 sm:px-6 sm:pb-20 lg:px-10">
        <div class="mx-auto max-w-7xl">
            <div class="relative isolate overflow-hidden rounded-[28px] bg-zinc-950 px-6 py-12 text-white ring-1 ring-zinc-900/5 dark:ring-white/10 sm:rounded-[36px] sm:px-12 sm:py-16">
                <div class="pointer-events-none absolute -right-24 -top-24 -z-10 size-96 rounded-full bg-orange-500/30 blur-[100px]" />
                <div
                    class="pointer-events-none absolute inset-0 -z-10 [background-image:linear-gradient(to_right,rgba(255,255,255,0.05)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.05)_1px,transparent_1px)] [background-size:44px_44px] [mask-image:radial-gradient(ellipse_at_right,black,transparent_70%)]"
                />

                <div class="max-w-2xl">
                    <h2 class="text-3xl font-black tracking-tight sm:text-4xl">Не нашли нужный товар?</h2>
                    <p class="mt-4 text-base leading-7 text-zinc-400">
                        Позвоните нам или оставьте заявку — подберём необходимое оборудование
                        и комплектующие под ваши задачи.
                    </p>
                    <div class="mt-8 flex flex-col gap-3 sm:flex-row">
                        <a
                            href="tel:+7XXXXXXXXXX"
                            class="inline-flex h-12 items-center justify-center gap-2 rounded-full bg-orange-500 px-7 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/25 transition hover:bg-orange-400"
                        >
                            <PhPhone :size="18" weight="fill" />
                            +7 (XXX) XXX-XX-XX
                        </a>
                        <Link
                            :href="route('store.catalog.index')"
                            class="inline-flex h-12 items-center justify-center gap-2 rounded-full border border-white/15 bg-white/5 px-6 text-sm font-semibold text-white transition hover:bg-white/10"
                        >
                            Открыть каталог
                            <PhArrowRight :size="16" weight="bold" />
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    </section>
</template>
