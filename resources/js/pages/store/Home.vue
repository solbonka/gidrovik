<script setup lang="ts">
import { Link, router } from '@inertiajs/vue3'
import {
    PhArrowRight,
    PhArrowUpRight,
    PhMagnifyingGlass,
    PhPackage,
    PhPhone,
    PhShieldCheck,
    PhSquaresFour,
    PhTruck,
    PhWrench,
} from '@phosphor-icons/vue'
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import type { Component, DirectiveBinding } from 'vue'

import ProductCard from '@/components/store/ProductCard.vue'
import RvdDiagram from '@/components/store/RvdDiagram.vue'

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
    totalProducts?: number | null
}>()

const phone = { href: 'tel:+7XXXXXXXXXX', label: '+7 (XXX) XXX-XX-XX' }

const standards: string[] = []

/* ---------- Поиск ---------- */
const query = ref('')
const searchInput = ref<HTMLInputElement | null>(null)

function submitSearch() {
    const search = query.value.trim()
    router.get(route('store.catalog.index'), search ? { search } : {})
}

function onKeydown(e: KeyboardEvent) {
    const target = e.target as HTMLElement | null
    if (
        e.key === '/' &&
        !e.ctrlKey &&
        !e.metaKey &&
        !e.altKey &&
        !target?.isContentEditable &&
        !['INPUT', 'TEXTAREA', 'SELECT'].includes(target?.tagName ?? '')
    ) {
        e.preventDefault()
        searchInput.value?.focus()
    }
}

const quickCategories = computed(() => props.categories.slice(0, 5))

/* ---------- Показатели ---------- */
const maxCount = computed(() => Math.max(1, ...props.categories.map((c) => c.product_count)))
const hasTotal = computed(() => typeof props.totalProducts === 'number' && props.totalProducts > 0)

const shownProducts = ref(props.totalProducts ?? 0)
const shownCategories = ref(props.categories.length)
const animationFrames = new Set<number>()

function animateNumber(target: number, set: (v: number) => void, duration = 1100) {
    const start = performance.now()
    const tick = (now: number) => {
        const progress = Math.min((now - start) / duration, 1)
        set(Math.round(target * (1 - Math.pow(1 - progress, 3))))
        if (progress < 1) animationFrames.add(requestAnimationFrame(tick))
    }
    set(0)
    animationFrames.add(requestAnimationFrame(tick))
}

const fmt = (n: number) => new Intl.NumberFormat('ru-RU').format(n)

onMounted(() => {
    document.addEventListener('keydown', onKeydown)
    if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        if (hasTotal.value) animateNumber(props.totalProducts as number, (v) => (shownProducts.value = v))
        animateNumber(props.categories.length, (v) => (shownCategories.value = v), 900)
    }
})
onBeforeUnmount(() => {
    document.removeEventListener('keydown', onKeydown)
    animationFrames.forEach((frame) => cancelAnimationFrame(frame))
    animationFrames.clear()
})

/* ---------- Преимущества ---------- */
const iconMap: Record<string, Component> = {
    truck: PhTruck,
    shield: PhShieldCheck,
    'shield-check': PhShieldCheck,
    package: PhPackage,
    wrench: PhWrench,
    phone: PhPhone,
}
const fallbackIcons: Component[] = [PhShieldCheck, PhTruck, PhWrench]

function advantageIcon(icon: string | undefined, index: number): Component {
    const key = (icon ?? '').toLowerCase().replace(/_/g, '-')
    return iconMap[key] ?? fallbackIcons[index % fallbackIcons.length]
}

function productsLabel(count: number): string {
    const mod10 = count % 10
    const mod100 = count % 100
    if (mod10 === 1 && mod100 !== 11) return `${count} товар`
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) return `${count} товара`
    return `${count} товаров`
}

const pad = (n: number) => String(n).padStart(2, '0')

const steps = [
    { title: 'Найдите комплектующие', text: 'Ищите по названию, артикулу или коду товара.' },
    { title: 'Добавьте в корзину', text: 'Соберите заказ из нужных позиций каталога.' },
    { title: 'Оставьте контакты', text: 'Укажите удобный способ получения заказа.' },
    { title: 'Согласуйте детали', text: 'Менеджер подтвердит наличие и условия получения.' },
]

/* ---------- Плавное появление ---------- */
const revealObservers = new WeakMap<HTMLElement, IntersectionObserver>()

const vReveal = {
    mounted(el: HTMLElement, binding: DirectiveBinding<number | undefined>) {
        if (
            !('IntersectionObserver' in window) ||
            window.matchMedia('(prefers-reduced-motion: reduce)').matches
        ) {
            return
        }
        const delay = binding.value ?? 0
        el.style.opacity = '0'
        el.style.transform = 'translateY(20px)'
        el.style.transition = `opacity .7s ease ${delay}ms, transform .7s cubic-bezier(.2,.7,.2,1) ${delay}ms`

        const observer = new IntersectionObserver(
            ([entry]) => {
                if (!entry.isIntersecting) return
                el.style.opacity = ''
                el.style.transform = ''
                observer.disconnect()
                revealObservers.delete(el)
            },
            { threshold: 0.1 },
        )
        revealObservers.set(el, observer)
        observer.observe(el)
    },
    unmounted(el: HTMLElement) {
        revealObservers.get(el)?.disconnect()
        revealObservers.delete(el)
    },
}
</script>

<template>
    <main class="overflow-x-clip bg-white text-zinc-950 dark:bg-zinc-950 dark:text-white">
        <!-- HERO -->
        <section class="px-3 pb-6 pt-2 sm:px-6 sm:pb-10 sm:pt-6 lg:px-8">
            <div class="relative mx-auto max-w-7xl overflow-hidden rounded-[1.25rem] bg-[#15181b] text-white ring-1 ring-black/5 dark:ring-white/10 sm:rounded-[2rem]">
                <div
                    class="pointer-events-none absolute inset-0 opacity-[0.1]
                           [background-image:linear-gradient(rgba(255,255,255,.2)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,.2)_1px,transparent_1px)]
                           [background-size:44px_44px]
                           [mask-image:radial-gradient(ellipse_at_70%_30%,black,transparent_75%)]"
                />
                <div class="pointer-events-none absolute -right-32 -top-40 size-[34rem] rounded-full bg-orange-500/20 blur-[120px]" />
                <div class="pointer-events-none absolute -bottom-52 left-1/4 size-[28rem] rounded-full bg-orange-700/10 blur-[120px]" />

                <div class="relative grid items-center gap-5 px-3 py-6 sm:gap-10 sm:px-10 sm:py-14 lg:grid-cols-[1.05fr_.95fr] lg:gap-6 lg:px-14 lg:py-16">
                    <!-- Текст -->
                    <div class="relative z-10 order-1 min-w-0">
                        <div class="inline-flex items-center gap-2 rounded-md border border-orange-400/30 bg-orange-400/10 px-2.5 py-1 text-[10px] font-bold uppercase tracking-[.16em] text-orange-300 sm:px-3 sm:py-1.5 sm:text-[11px] sm:tracking-[.18em]">
                            <span class="relative flex size-1.5 sm:size-2">
                                <span class="absolute inline-flex size-full animate-ping rounded-full bg-orange-400 opacity-70" />
                                <span class="relative inline-flex size-1.5 rounded-full bg-orange-500 sm:size-2" />
                            </span>
                            Гидравлические комплектующие
                        </div>

                        <h1 class="mt-4 max-w-2xl text-[1.75rem] font-extrabold leading-[1.05] tracking-[-.04em] sm:mt-7 sm:text-5xl sm:leading-[.98] sm:tracking-[-.055em] lg:text-[4.4rem]">
                            Комплектующие для
                            <span class="mt-0.5 block bg-gradient-to-r from-orange-400 to-amber-300 bg-clip-text pb-0.5 text-transparent sm:mt-2 sm:pb-2">
                                гидравлических систем
                            </span>
                        </h1>

                        <p class="mt-3 max-w-xl text-[13px] leading-5 text-zinc-300 sm:mt-6 sm:text-base sm:leading-8">
                            Фитинги, рукава высокого давления, соединения и сопутствующие товары
                            для промышленного и мобильного оборудования.
                        </p>

                        <div v-if="standards.length" class="mt-3 flex flex-wrap gap-2 sm:mt-5" aria-label="Стандарты соединений">
                            <span
                                v-for="standard in standards"
                                :key="standard"
                                class="rounded-md border border-white/10 bg-white/[.04] px-2.5 py-1 font-mono text-[11px] font-bold tracking-wider text-zinc-300"
                            >
                                {{ standard }}
                            </span>
                        </div>

                        <!-- Поиск: компактнее на мобиле -->
                        <form
                            class="group mt-5 flex max-w-xl items-center rounded-xl border border-white/15 bg-white/[.07] p-1 shadow-2xl shadow-black/30 backdrop-blur transition focus-within:border-orange-400/70 focus-within:bg-white/10 focus-within:shadow-orange-500/10 sm:mt-8 sm:rounded-2xl sm:p-1.5"
                            role="search"
                            @submit.prevent="submitSearch"
                        >
                            <PhMagnifyingGlass :size="18" class="ml-2 shrink-0 text-zinc-400 transition group-focus-within:text-orange-400 sm:ml-3 sm:size-5" />
                            <input
                                ref="searchInput"
                                v-model="query"
                                type="search"
                                placeholder="Название, код или артикул"
                                aria-label="Поиск по каталогу"
                                class="min-w-0 flex-1 bg-transparent px-2 py-2 text-sm text-white outline-none placeholder:text-zinc-500 sm:px-3 sm:py-3 sm:text-base"
                            />
                            <kbd class="mr-2 hidden rounded-md border border-white/15 px-2 py-0.5 font-mono text-xs text-zinc-500 group-focus-within:hidden lg:block">/</kbd>
                            <button
                                type="submit"
                                class="inline-flex h-9 shrink-0 items-center justify-center gap-1.5 rounded-lg bg-orange-500 px-3 text-sm font-bold text-zinc-950 transition hover:bg-orange-400 sm:h-11 sm:gap-2 sm:rounded-xl sm:px-6"
                            >
                                Найти
                                <PhArrowRight :size="15" weight="bold" class="sm:size-4" />
                            </button>
                        </form>

                        <div v-if="quickCategories.length" class="mt-3 flex flex-wrap items-center gap-1.5 sm:mt-5 sm:gap-2">
                            <span class="mr-0.5 text-[10px] text-zinc-500 sm:mr-1 sm:text-xs">Популярные</span>
                            <Link
                                v-for="category in quickCategories"
                                :key="category.id"
                                :href="route('store.catalog.index', { category: category.slug })"
                                class="rounded-md border border-white/10 bg-white/[.04] px-2 py-0.5 text-[10px] text-zinc-300 transition hover:border-orange-400/60 hover:bg-orange-400/10 hover:text-orange-200 sm:rounded-lg sm:px-3 sm:py-1.5 sm:text-xs"
                            >
                                {{ category.name }}
                            </Link>
                        </div>

                        <div class="mt-5 flex flex-wrap items-center gap-x-4 gap-y-2.5 sm:mt-8 sm:gap-x-6">
                            <Link
                                :href="route('store.catalog.index')"
                                class="group/btn inline-flex h-10 items-center gap-2 rounded-xl border border-white/15 bg-white/5 px-4 text-sm font-bold text-white transition hover:bg-white/10 sm:h-12 sm:gap-3 sm:px-6"
                            >
                                Весь каталог
                                <PhArrowUpRight :size="15" weight="bold" class="transition group-hover/btn:translate-x-0.5 group-hover/btn:-translate-y-0.5" />
                            </Link>
                            <a :href="phone.href" class="inline-flex items-center gap-1.5 text-sm font-semibold text-zinc-300 transition hover:text-white">
                                <PhPhone :size="16" weight="fill" class="text-orange-400" />
                                {{ phone.label }}
                            </a>
                        </div>
                    </div>

                    <!-- Диаграмма: на мобиле уже, без обрезки подписей -->
                    <div class="relative order-2 mx-auto w-full max-w-[300px] sm:max-w-[420px] lg:max-w-[560px]">
                        <RvdDiagram />
                    </div>
                </div>

                <!-- Показатели: компактнее на мобиле -->
                <div class="relative grid grid-cols-1 divide-y divide-white/10 border-t border-white/10 bg-black/20 sm:grid-cols-3 sm:divide-x sm:divide-y-0">
                    <div class="flex items-center gap-2.5 px-3 py-3 sm:gap-4 sm:px-8 sm:py-5 lg:px-10">
                        <PhPackage :size="20" weight="duotone" class="shrink-0 text-orange-400 sm:size-6" />
                        <div class="min-w-0">
                            <template v-if="hasTotal">
                                <div class="text-lg font-extrabold tabular-nums tracking-tight sm:text-2xl">{{ fmt(shownProducts) }}</div>
                                <div class="text-[10px] text-zinc-500 sm:text-xs">позиций в каталоге</div>
                            </template>
                            <template v-else>
                                <div class="text-sm font-extrabold tracking-tight sm:text-base">Поиск по коду и артикулу</div>
                                <div class="text-[10px] text-zinc-500 sm:text-xs">Быстрый подбор нужной позиции</div>
                            </template>
                        </div>
                    </div>
                    <div class="flex items-center gap-2.5 px-3 py-3 sm:gap-4 sm:px-8 sm:py-5 lg:px-10">
                        <PhSquaresFour :size="20" weight="duotone" class="shrink-0 text-orange-400 sm:size-6" />
                        <div class="min-w-0">
                            <div class="text-lg font-extrabold tabular-nums tracking-tight sm:text-2xl">{{ shownCategories }}</div>
                            <div class="text-[10px] text-zinc-500 sm:text-xs">категорий товаров</div>
                        </div>
                    </div>
                    <div class="flex items-center gap-2.5 px-3 py-3 sm:gap-4 sm:px-8 sm:py-5 lg:px-10">
                        <PhTruck :size="20" weight="duotone" class="shrink-0 text-orange-400 sm:size-6" />
                        <div class="min-w-0">
                            <div class="text-sm font-extrabold tracking-tight sm:text-base">Доставка или самовывоз</div>
                            <div class="text-[10px] text-zinc-500 sm:text-xs">Выберите при оформлении</div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- КАТЕГОРИИ -->
        <section class="px-3 py-8 sm:px-6 sm:py-16 lg:px-8">
            <div class="mx-auto max-w-7xl">
                <div v-reveal class="flex flex-col justify-between gap-2 sm:flex-row sm:items-end sm:gap-4">
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-[.2em] text-orange-600 dark:text-orange-400 sm:text-xs sm:tracking-[.22em]">Ассортимент</p>
                        <h2 class="mt-1 text-xl font-extrabold tracking-tight sm:mt-2 sm:text-4xl">Каталог продукции</h2>
                        <p class="mt-1.5 max-w-xl text-[13px] leading-5 text-zinc-500 dark:text-zinc-400 sm:mt-3 sm:text-sm sm:leading-6">
                            Основные группы товаров для комплектации, ремонта и обслуживания гидравлических систем.
                        </p>
                    </div>
                    <Link
                        :href="route('store.catalog.index')"
                        class="inline-flex items-center gap-1.5 text-sm font-bold transition hover:text-orange-600 dark:hover:text-orange-400"
                    >
                        Весь каталог <PhArrowUpRight :size="15" weight="bold" />
                    </Link>
                </div>

                <div v-if="categories.length" v-reveal="100" class="mt-4 grid grid-cols-1 gap-2 sm:mt-6 sm:grid-cols-2 sm:gap-3 lg:grid-cols-3">
                    <Link
                        v-for="(category, index) in categories"
                        :key="category.id"
                        :href="route('store.catalog.index', { category: category.slug })"
                        class="group relative flex min-h-[96px] flex-col justify-between overflow-hidden rounded-xl border border-zinc-200 bg-zinc-50 p-3 transition duration-300 hover:-translate-y-0.5 hover:border-orange-400 hover:bg-white hover:shadow-lg hover:shadow-orange-500/10 dark:border-zinc-800 dark:bg-zinc-900 dark:hover:border-orange-500 sm:min-h-[140px] sm:p-4"
                    >
                        <span
                            class="pointer-events-none absolute -right-1 -top-1 select-none text-[2.75rem] font-black leading-none tracking-tighter text-zinc-900/[.04] transition duration-500 group-hover:text-orange-500/10 dark:text-white/[.04] sm:-top-2 sm:text-[4.5rem]"
                        >
                            {{ pad(index + 1) }}
                        </span>

                        <div class="relative flex items-start justify-between">
                            <span class="font-mono text-[10px] font-bold tracking-widest text-zinc-400">{{ pad(index + 1) }}</span>
                            <span class="flex size-6 items-center justify-center rounded-full bg-white text-zinc-500 shadow-sm transition duration-300 group-hover:rotate-45 group-hover:bg-orange-500 group-hover:text-zinc-950 dark:bg-zinc-800 dark:text-zinc-300 sm:size-7">
                                <PhArrowUpRight :size="13" weight="bold" />
                            </span>
                        </div>

                        <div class="relative mt-2 sm:mt-4">
                            <h3 class="max-w-[90%] text-sm font-extrabold leading-snug tracking-tight sm:text-base">{{ category.name }}</h3>
                            <div class="mt-1.5 flex items-center gap-2 sm:mt-2.5">
                                <span class="shrink-0 text-[11px] text-zinc-500 dark:text-zinc-400 sm:text-xs">{{ productsLabel(category.product_count) }}</span>
                                <span class="h-1 flex-1 overflow-hidden rounded-full bg-zinc-200 dark:bg-zinc-700">
                                    <span
                                        class="block h-full rounded-full bg-zinc-400 transition-all duration-500 group-hover:bg-orange-500"
                                        :style="{ width: `${Math.max(6, (category.product_count / maxCount) * 100)}%` }"
                                    />
                                </span>
                            </div>
                        </div>
                    </Link>
                </div>
                <div v-else class="mt-6 rounded-2xl border border-dashed border-zinc-300 px-5 py-10 text-center text-sm text-zinc-500 dark:border-zinc-700 sm:mt-8 sm:px-6 sm:py-12">
                    Категории товаров скоро появятся.
                </div>
            </div>
        </section>

        <!-- ПОПУЛЯРНЫЕ ТОВАРЫ -->
        <section v-if="featuredProducts.length" class="border-y border-zinc-200 bg-zinc-50/80 px-3 py-8 dark:border-zinc-800 dark:bg-zinc-900/40 sm:px-6 sm:py-16 lg:px-8">
            <div class="mx-auto max-w-7xl">
                <div v-reveal class="flex items-end justify-between gap-3 sm:gap-4">
                    <div>
                        <p class="text-[11px] font-bold uppercase tracking-[.2em] text-orange-600 dark:text-orange-400 sm:text-xs sm:tracking-[.22em]">Выбор каталога</p>
                        <h2 class="mt-1 text-xl font-extrabold tracking-tight sm:mt-2 sm:text-4xl">Популярные товары</h2>
                        <p class="mt-1 text-[13px] text-zinc-500 dark:text-zinc-400 sm:mt-2 sm:text-sm">Подборка товаров из нашего каталога</p>
                    </div>
                    <Link
                        :href="route('store.catalog.index')"
                        class="hidden items-center gap-2 rounded-xl border border-zinc-300 px-4 py-2.5 text-sm font-bold transition hover:border-orange-500 hover:text-orange-600 dark:border-zinc-700 dark:hover:text-orange-400 sm:inline-flex"
                    >
                        Все товары <PhArrowRight :size="16" weight="bold" />
                    </Link>
                </div>

                <!-- На мобиле: уже карточки + peek следующей -->
                <div
                    v-reveal="100"
                    class="no-scrollbar -mx-3 mt-5 flex snap-x snap-mandatory gap-2.5 overflow-x-auto px-3 pb-2 sm:-mx-0 sm:mt-8 sm:grid sm:grid-cols-2 sm:gap-4 sm:overflow-visible sm:px-0 lg:grid-cols-4"
                >
                    <div
                        v-for="product in featuredProducts"
                        :key="product.id"
                        class="w-[68%] max-w-[260px] shrink-0 snap-start sm:w-auto sm:max-w-none"
                    >
                        <ProductCard :product="product" />
                    </div>
                </div>
                <div class="mt-3 sm:hidden">
                    <Link :href="route('store.catalog.index')" class="inline-flex items-center gap-2 text-sm font-bold text-orange-600 dark:text-orange-400">
                        Смотреть весь каталог <PhArrowRight :size="16" weight="bold" />
                    </Link>
                </div>
            </div>
        </section>

        <!-- ПРЕИМУЩЕСТВА -->
        <section v-if="advantages.length" class="px-3 py-8 sm:px-6 sm:py-16 lg:px-8">
            <div class="mx-auto max-w-7xl">
                <div class="grid gap-6 lg:grid-cols-[.8fr_1.2fr] lg:gap-16">
                    <div v-reveal class="lg:sticky lg:top-24 lg:self-start">
                        <p class="text-[11px] font-bold uppercase tracking-[.2em] text-orange-600 dark:text-orange-400 sm:text-xs sm:tracking-[.22em]">Почему Гидровик</p>
                        <h2 class="mt-1 max-w-md text-xl font-extrabold leading-tight tracking-tight sm:mt-2 sm:text-4xl">
                            Практичный подход к выбору оборудования
                        </h2>
                        <p class="mt-2.5 max-w-md text-[13px] leading-5 text-zinc-500 dark:text-zinc-400 sm:mt-4 sm:text-sm sm:leading-7">
                            Помогаем сориентироваться в ассортименте гидравлических комплектующих и подобрать позиции под задачу.
                        </p>
                    </div>

                    <div v-reveal="100" class="grid gap-2.5 sm:grid-cols-2 sm:gap-3">
                        <article
                            v-for="(advantage, index) in advantages"
                            :key="index"
                            class="group rounded-2xl border p-3.5 transition duration-300 hover:-translate-y-1 sm:p-6"
                            :class="index === 0
                                ? 'border-transparent bg-orange-500 text-zinc-950 sm:col-span-2'
                                : 'border-zinc-200 hover:border-orange-400 dark:border-zinc-800 dark:bg-zinc-900/50'"
                        >
                            <div class="flex items-start justify-between">
                                <div
                                    class="flex size-9 items-center justify-center rounded-xl sm:size-11"
                                    :class="index === 0
                                        ? 'bg-zinc-950 text-orange-400'
                                        : 'bg-orange-500/10 text-orange-600 dark:text-orange-400'"
                                >
                                    <component :is="advantageIcon(advantage.icon, index)" :size="20" weight="duotone" class="sm:size-[22px]" />
                                </div>
                                <span
                                    class="font-mono text-[10px] font-bold tracking-widest sm:text-xs"
                                    :class="index === 0 ? 'text-zinc-950/50' : 'text-zinc-300 dark:text-zinc-700'"
                                >
                                    {{ pad(index + 1) }}
                                </span>
                            </div>
                            <h3 class="mt-3 text-[14px] font-extrabold tracking-tight sm:mt-5 sm:text-lg">{{ advantage.title }}</h3>
                            <p
                                class="mt-1 text-[13px] leading-5 sm:mt-2 sm:text-sm sm:leading-6"
                                :class="index === 0 ? 'max-w-xl text-zinc-950/75' : 'text-zinc-500 dark:text-zinc-400'"
                            >
                                {{ advantage.description }}
                            </p>
                        </article>
                    </div>
                </div>
            </div>
        </section>

        <!-- КАК ЗАКАЗАТЬ -->
        <section class="border-y border-zinc-200 bg-zinc-50 px-3 py-8 dark:border-zinc-800 dark:bg-zinc-900/40 sm:px-6 sm:py-16 lg:px-8">
            <div class="mx-auto max-w-7xl">
                <div v-reveal class="max-w-xl">
                    <p class="text-[11px] font-bold uppercase tracking-[.2em] text-orange-600 dark:text-orange-400 sm:text-xs sm:tracking-[.22em]">Понятный процесс</p>
                    <h2 class="mt-1 text-xl font-extrabold tracking-tight sm:mt-2 sm:text-4xl">Как оформить заказ</h2>
                </div>

                <ol v-reveal="100" class="mt-6 grid gap-5 sm:mt-10 sm:grid-cols-2 sm:gap-8 lg:grid-cols-4 lg:gap-6">
                    <li v-for="(step, i) in steps" :key="step.title" class="relative">
                        <div class="flex items-center gap-2.5 sm:gap-4">
                            <span
                                class="text-4xl font-black leading-none tracking-tighter text-transparent sm:text-6xl"
                                style="-webkit-text-stroke: 1.5px rgb(249 115 22)"
                            >
                                {{ pad(i + 1) }}
                            </span>
                            <span
                                v-if="i < steps.length - 1"
                                class="hidden h-px flex-1 bg-gradient-to-r from-orange-500/60 to-transparent lg:block"
                            />
                        </div>
                        <h3 class="mt-2.5 text-[15px] font-extrabold tracking-tight sm:mt-4 sm:text-lg">{{ step.title }}</h3>
                        <p class="mt-1 text-[13px] leading-5 text-zinc-500 dark:text-zinc-400 sm:mt-2 sm:text-sm sm:leading-6">{{ step.text }}</p>
                    </li>
                </ol>
            </div>
        </section>

        <!-- CTA -->
        <section class="px-3 py-8 sm:px-6 sm:py-16 lg:px-8">
            <div
                v-reveal
                class="relative mx-auto max-w-7xl overflow-hidden rounded-[1.25rem] bg-orange-500 px-4 py-7 text-zinc-950 sm:rounded-[2rem] sm:px-10 sm:py-14 lg:px-14"
            >
                <div class="pointer-events-none absolute -right-20 -top-32 size-96 rounded-full border-[50px] border-black/[.06]" />
                <div class="pointer-events-none absolute -right-4 -top-16 size-64 rounded-full border border-black/10" />
                <div class="pointer-events-none absolute -bottom-24 left-1/3 size-64 rounded-full border border-black/10" />

                <div class="relative flex flex-col justify-between gap-5 sm:gap-8 lg:flex-row lg:items-center">
                    <div class="max-w-2xl">
                        <p class="text-[11px] font-extrabold uppercase tracking-[.18em] text-zinc-900/60 sm:text-xs sm:tracking-[.2em]">Нужна помощь с подбором?</p>
                        <h2 class="mt-1.5 text-xl font-extrabold leading-tight tracking-tight sm:mt-3 sm:text-4xl">Не нашли нужную позицию?</h2>
                        <p class="mt-2 max-w-xl text-[13px] leading-5 text-zinc-900/75 sm:mt-3 sm:text-base sm:leading-7">
                            Свяжитесь с нами — поможем разобраться с ассортиментом и подобрать необходимые комплектующие.
                        </p>
                    </div>
                    <div class="flex w-full shrink-0 flex-col gap-2 sm:w-auto sm:flex-row sm:gap-3">
                        <a
                            :href="phone.href"
                            class="inline-flex h-11 items-center justify-center gap-2 rounded-xl bg-zinc-950 px-5 text-sm font-bold text-white transition hover:bg-zinc-800 sm:h-12 sm:px-6"
                        >
                            <PhPhone :size="17" weight="fill" />
                            {{ phone.label }}
                        </a>
                        <Link
                            :href="route('store.catalog.index')"
                            class="inline-flex h-11 items-center justify-center gap-2 rounded-xl border border-zinc-950/20 px-5 text-sm font-bold transition hover:bg-black/5 sm:h-12 sm:px-6"
                        >
                            Открыть каталог <PhArrowRight :size="16" weight="bold" />
                        </Link>
                    </div>
                </div>
            </div>
        </section>
    </main>
</template>

<style scoped>
.no-scrollbar {
    scrollbar-width: none;
}
.no-scrollbar::-webkit-scrollbar {
    display: none;
}

@media (prefers-reduced-motion: reduce) {
    .hv-flow {
        animation: none;
    }
}
</style>
