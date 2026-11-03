<script setup lang="ts">
import { Head, router } from '@inertiajs/vue3'
import {
    PhArrowLeft,
    PhArrowRight,
    PhCaretDown,
    PhCheck,
    PhFunnel,
    PhMagnifyingGlass,
    PhPackage,
    PhSortAscending,
    PhSortDescending,
    PhX,
} from '@phosphor-icons/vue'
import { computed, onBeforeUnmount, ref, watch } from 'vue'

import ProductCard from '@/components/store/ProductCard.vue'

const props = defineProps<{
    products: {
        data: Array<{
            id: number
            name: string
            slug: string
            code: string | null
            article: string | null
            price: string
            image_path?: string | null
            stock_status: string
            category?: string
        }>
        current_page: number
        last_page: number
        per_page: number
        total: number
        links: Array<{ url: string | null, label: string, active: boolean }>
    }
    categories: Array<{ id: number, name: string, slug: string }>
    manufacturers: Array<{ id: number, name: string }>
    standards: Array<{ id: number, name: string }>
    diameters: Array<{ id: number, value: string }>
    characteristics: Array<{
        id: number
        name: string
        slug: string
        type: string
        unit: string | null
    }>
    characteristic_values: Record<string, string[]>
    favorite_product_ids: number[]
    filters: {
        category?: string | null
        manufacturer?: string | null
        standard?: string | null
        diameter?: string | null
        min_price?: string | null
        max_price?: string | null
        characteristics: Array<{ id: number }>
        sort: string
        direction: string
        search?: string
    }
}>()

// ---------- Избранное ----------
const favorites = ref<Set<number>>(new Set(props.favorite_product_ids))

watch(() => props.favorite_product_ids, (newIds) => {
    favorites.value = new Set(newIds)
}, { deep: true })

function toggleFavorite(productId: number) {
    if (favorites.value.has(productId)) {
        router.delete(route('store.favorites.destroy'), {
            data: { product_id: productId },
            preserveScroll: true,
            onSuccess: () => {
                favorites.value.delete(productId)
            },
        })
    } else {
        router.post(route('store.favorites.store'), {
            product_id: productId,
        }, {
            preserveScroll: true,
            onSuccess: () => {
                favorites.value.add(productId)
            },
        })
    }
}

// ---------- Фильтры и сортировка ----------
const showFilters = ref(false)
const sort = ref(props.filters.sort || 'created_at')
const direction = ref(props.filters.direction || 'desc')
const minPrice = ref(props.filters.min_price ?? '')
const maxPrice = ref(props.filters.max_price ?? '')
const activeStandard = ref(props.filters.standard ?? '')
const activeDiameter = ref(props.filters.diameter ?? '')

watch(() => props.filters, (f) => {
    sort.value = f.sort || 'created_at'
    direction.value = f.direction || 'desc'
    minPrice.value = f.min_price ?? ''
    maxPrice.value = f.max_price ?? ''
    activeStandard.value = f.standard ?? ''
    activeDiameter.value = f.diameter ?? ''
}, { deep: true })

watch(showFilters, (open) => {
    document.body.style.overflow = open ? 'hidden' : ''
})
onBeforeUnmount(() => {
    document.body.style.overflow = ''
})

const sortOptions = [
    { value: 'created_at', label: 'Новизна' },
    { value: 'name', label: 'Название' },
    { value: 'price', label: 'Цена' },
]

// ---------- Поиск ----------
const searchQuery = ref(props.filters.search ?? '')
let searchTimeout: ReturnType<typeof setTimeout> | null = null

watch(() => props.filters.search, (newSearch) => {
    searchQuery.value = newSearch ?? ''
})

watch(searchQuery, (newQuery) => {
    if (searchTimeout) clearTimeout(searchTimeout)
    if (!newQuery.trim()) {
        go({ page: 1 })
        return
    }
    searchTimeout = setTimeout(() => {
        go({ page: 1 })
    }, 800)
})

type Params = Record<string, string | number | null | undefined>

function go(overrides: Params = {}, scrollTop = false) {
    const params: Params = {
        category: props.filters.category,
        manufacturer: props.filters.manufacturer,
        standard: activeStandard.value || null,
        diameter: activeDiameter.value || null,
        min_price: minPrice.value || null,
        max_price: maxPrice.value || null,
        sort: sort.value,
        direction: direction.value,
        search: searchQuery.value || null,
        ...overrides,
    }

    for (const key of Object.keys(params)) {
        if (params[key] === null || params[key] === undefined || params[key] === '') {
            delete params[key]
        }
    }

    router.get(route('store.catalog.index'), params, {
        preserveState: true,
        preserveScroll: true,
        only: ['products', 'filters'],
        onSuccess: () => {
            if (scrollTop) window.scrollTo({ top: 0, behavior: 'smooth' })
        },
    })
}

function clearFilters() {
    searchQuery.value = ''
    if (searchTimeout) clearTimeout(searchTimeout)
    router.get(route('store.catalog.index'), {}, {
        preserveState: true,
        preserveScroll: true,
    })
}

function toggleDirection() {
    direction.value = direction.value === 'asc' ? 'desc' : 'asc'
    go()
}

const activeCategory = computed(() => props.categories.find(c => c.slug === props.filters.category))
const activeManufacturer = computed(() =>
    props.manufacturers.find(m => String(m.id) === String(props.filters.manufacturer)),
)
const standardName = computed(() =>
    props.standards.find(s => String(s.id) === String(props.filters.standard)),
)
const diameterName = computed(() =>
    props.diameters.find(d => String(d.id) === String(props.filters.diameter)),
)
const activeCount = computed(() => {
    let count = 0
    if (props.filters.category) count++
    if (props.filters.manufacturer) count++
    if (props.filters.standard) count++
    if (props.filters.diameter) count++
    if (minPrice.value) count++
    if (maxPrice.value) count++
    return count
})

function isManufacturerActive(id: number): boolean {
    return String(props.filters.manufacturer ?? '') === String(id)
}

function optionClass(active: boolean): string {
    return active
        ? 'bg-zinc-950 text-white dark:bg-white dark:text-zinc-950'
        : 'text-zinc-600 hover:bg-zinc-100 dark:text-zinc-400 dark:hover:bg-zinc-800'
}

// ---------- Пагинация ----------
const prevLink = computed(() => props.products.links[0])
const nextLink = computed(() => props.products.links[props.products.links.length - 1])
const numberLinks = computed(() => props.products.links.slice(1, -1))

function goPage(url: string | null) {
    if (!url) return
    const page = new URL(url, window.location.origin).searchParams.get('page')
    if (page) go({ page }, true)
}
</script>

<template>
    <Head title="Каталог товаров" />

    <div class="mx-auto max-w-7xl px-3 py-5 sm:px-6 sm:py-6 lg:px-10 lg:py-10">
        <!-- Заголовок -->
        <div>
            <p class="text-[11px] font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400 sm:text-xs">Магазин</p>
            <h1 class="mt-1 text-2xl font-black tracking-tight sm:text-3xl lg:text-5xl">Каталог товаров</h1>
            <p class="mt-1.5 text-sm text-zinc-500 dark:text-zinc-400">
                Найдено товаров:
                <span class="font-bold text-zinc-900 dark:text-zinc-100">{{ products.total.toLocaleString('ru-RU') }}</span>
            </p>
        </div>

        <!-- Управление: на мобиле 2 ряда, на sm+ в одну линию -->
        <div class="mt-4 flex flex-col gap-2 sm:mt-5 sm:flex-row sm:items-center sm:gap-2">
            <!-- Поиск — на всю ширину на мобиле -->
            <div class="relative w-full sm:w-72 sm:flex-none lg:w-80">
                <PhMagnifyingGlass :size="18" class="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" />
                <input
                    v-model="searchQuery"
                    type="search"
                    placeholder="Название, код или артикул"
                    class="h-10 w-full rounded-full border border-zinc-200 bg-white py-2 pl-10 pr-9 text-sm font-medium text-zinc-800 outline-none transition placeholder:text-zinc-400 focus:border-orange-500 focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-100 dark:placeholder:text-zinc-500 dark:focus:border-orange-400 sm:h-11 sm:pr-10"
                />
                <button
                    v-if="searchQuery"
                    type="button"
                    class="absolute right-2.5 top-1/2 -translate-y-1/2 text-zinc-400 transition hover:text-zinc-600 dark:hover:text-zinc-200 sm:right-3"
                    @click="searchQuery = ''; if (searchTimeout) clearTimeout(searchTimeout)"
                >
                    <PhX :size="18" />
                </button>
            </div>

            <!-- Фильтры + сортировка + направление -->
            <div class="flex items-center gap-1.5 sm:gap-2">
                <button
                    type="button"
                    class="relative inline-flex h-10 shrink-0 items-center gap-1.5 rounded-full border border-zinc-200 bg-white px-3 text-sm font-semibold text-zinc-800 transition hover:border-orange-400 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-100 sm:h-11 sm:gap-2 sm:px-4 lg:hidden"
                    @click="showFilters = true"
                >
                    <PhFunnel :size="17" />
                    <span>Фильтры</span>
                    <span
                        v-if="activeCount > 0"
                        class="flex size-5 items-center justify-center rounded-full bg-orange-500 text-[11px] font-bold text-zinc-950"
                    >
                        {{ activeCount }}
                    </span>
                </button>

                <div class="relative min-w-0 flex-1 sm:flex-none">
                    <select
                        v-model="sort"
                        class="h-10 w-full appearance-none rounded-full border border-zinc-200 bg-white py-2 pl-3.5 pr-9 text-sm font-semibold text-zinc-800 outline-none transition hover:border-orange-400 focus:border-orange-500 focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-100 sm:h-11 sm:w-auto sm:pl-4 sm:pr-10"
                        aria-label="Сортировка"
                        @change="go()"
                    >
                        <option v-for="opt in sortOptions" :key="opt.value" :value="opt.value">
                            {{ opt.label }}
                        </option>
                    </select>
                    <PhCaretDown :size="15" weight="bold" class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-zinc-400 sm:right-4" />
                </div>

                <button
                    type="button"
                    class="flex size-10 shrink-0 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-700 transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-200 dark:hover:text-orange-400 sm:size-11"
                    :aria-label="direction === 'asc' ? 'По возрастанию' : 'По убыванию'"
                    :title="direction === 'asc' ? 'По возрастанию' : 'По убыванию'"
                    @click="toggleDirection"
                >
                    <PhSortAscending v-if="direction === 'asc'" :size="18" class="sm:size-5" />
                    <PhSortDescending v-else :size="18" class="sm:size-5" />
                </button>
            </div>
        </div>

        <!-- Выбранные фильтры -->
        <div v-if="activeCount > 0" class="mt-3 flex flex-wrap items-center gap-1.5 sm:mt-5 sm:gap-2">
            <button
                v-if="activeCategory"
                type="button"
                class="inline-flex items-center gap-1 rounded-full bg-zinc-950 py-1 pl-2.5 pr-2 text-xs font-semibold text-white transition hover:bg-zinc-800 dark:bg-white dark:text-zinc-950 dark:hover:bg-zinc-200 sm:gap-1.5 sm:py-1.5 sm:pl-3.5 sm:pr-2.5 sm:text-sm"
                @click="go({ category: null })"
            >
                {{ activeCategory.name }}
                <PhX :size="13" weight="bold" />
            </button>
            <button
                v-if="activeManufacturer"
                type="button"
                class="inline-flex items-center gap-1 rounded-full bg-zinc-950 py-1 pl-2.5 pr-2 text-xs font-semibold text-white transition hover:bg-zinc-800 dark:bg-white dark:text-zinc-950 dark:hover:bg-zinc-200 sm:gap-1.5 sm:py-1.5 sm:pl-3.5 sm:pr-2.5 sm:text-sm"
                @click="go({ manufacturer: null })"
            >
                {{ activeManufacturer.name }}
                <PhX :size="13" weight="bold" />
            </button>
            <button
                v-if="standardName"
                type="button"
                class="inline-flex items-center gap-1 rounded-full bg-zinc-950 py-1 pl-2.5 pr-2 text-xs font-semibold text-white transition hover:bg-zinc-800 dark:bg-white dark:text-zinc-950 dark:hover:bg-zinc-200 sm:gap-1.5 sm:py-1.5 sm:pl-3.5 sm:pr-2.5 sm:text-sm"
                @click="go({ standard: null })"
            >
                Стандарт: {{ standardName.name }}
                <PhX :size="13" weight="bold" />
            </button>
            <button
                v-if="diameterName"
                type="button"
                class="inline-flex items-center gap-1 rounded-full bg-zinc-950 py-1 pl-2.5 pr-2 text-xs font-semibold text-white transition hover:bg-zinc-800 dark:bg-white dark:text-zinc-950 dark:hover:bg-zinc-200 sm:gap-1.5 sm:py-1.5 sm:pl-3.5 sm:pr-2.5 sm:text-sm"
                @click="go({ diameter: null })"
            >
                Диаметр: {{ diameterName.value }}
                <PhX :size="13" weight="bold" />
            </button>
            <button
                v-if="minPrice"
                type="button"
                class="inline-flex items-center gap-1 rounded-full bg-zinc-950 py-1 pl-2.5 pr-2 text-xs font-semibold text-white transition hover:bg-zinc-800 dark:bg-white dark:text-zinc-950 dark:hover:bg-zinc-200 sm:gap-1.5 sm:py-1.5 sm:pl-3.5 sm:pr-2.5 sm:text-sm"
                @click="minPrice = ''; go()"
            >
                от {{ Number(minPrice).toLocaleString('ru-RU') }} ₽
                <PhX :size="13" weight="bold" />
            </button>
            <button
                v-if="maxPrice"
                type="button"
                class="inline-flex items-center gap-1 rounded-full bg-zinc-950 py-1 pl-2.5 pr-2 text-xs font-semibold text-white transition hover:bg-zinc-800 dark:bg-white dark:text-zinc-950 dark:hover:bg-zinc-200 sm:gap-1.5 sm:py-1.5 sm:pl-3.5 sm:pr-2.5 sm:text-sm"
                @click="maxPrice = ''; go()"
            >
                до {{ Number(maxPrice).toLocaleString('ru-RU') }} ₽
                <PhX :size="13" weight="bold" />
            </button>
            <button
                type="button"
                class="px-1.5 text-xs font-semibold text-orange-600 underline-offset-4 hover:underline dark:text-orange-400 sm:px-2 sm:text-sm"
                @click="clearFilters"
            >
                Сбросить всё
            </button>
        </div>

        <div class="mt-5 lg:mt-8 lg:flex lg:gap-8">
            <!-- Затемнение под шторкой -->
            <Transition
                enter-active-class="transition-opacity duration-200"
                leave-active-class="transition-opacity duration-200"
                enter-from-class="opacity-0"
                leave-to-class="opacity-0"
            >
                <div
                    v-if="showFilters"
                    class="fixed inset-0 z-50 bg-zinc-950/60 backdrop-blur-sm lg:hidden"
                    @click="showFilters = false"
                />
            </Transition>

            <!-- Фильтры: сайдбар / нижняя шторка -->
            <aside
                class="lg:w-64 lg:shrink-0"
                :class="showFilters
                    ? 'fixed inset-x-0 bottom-0 z-50 flex max-h-[85vh] flex-col rounded-t-[28px] bg-white shadow-2xl dark:bg-zinc-900 lg:static lg:z-auto lg:block lg:max-h-none lg:rounded-none lg:bg-transparent lg:shadow-none dark:lg:bg-transparent'
                    : 'hidden lg:block'"
            >
                <div class="flex items-center justify-between border-b border-zinc-100 px-5 py-4 dark:border-zinc-800 lg:hidden">
                    <h2 class="text-lg font-extrabold">Фильтры</h2>
                    <button
                        type="button"
                        class="flex size-9 items-center justify-center rounded-full text-zinc-500 hover:bg-zinc-100 dark:hover:bg-zinc-800"
                        aria-label="Закрыть"
                        @click="showFilters = false"
                    >
                        <PhX :size="20" />
                    </button>
                </div>

                <div class="flex-1 space-y-6 overflow-y-auto p-4 sm:space-y-7 sm:p-5 lg:sticky lg:top-28 lg:overflow-visible lg:p-0">
                    <!-- Категории -->
                    <div>
                        <h3 class="mb-2.5 text-xs font-bold uppercase tracking-[0.18em] text-zinc-400 sm:mb-3">Категории</h3>
                        <div class="space-y-0.5 sm:space-y-1">
                            <button
                                v-for="cat in categories"
                                :key="cat.id"
                                type="button"
                                class="flex w-full items-center justify-between gap-2 rounded-xl px-3 py-2 text-left text-sm font-medium transition sm:py-2.5"
                                :class="optionClass(filters.category === cat.slug)"
                                @click="go({ category: filters.category === cat.slug ? null : cat.slug })"
                            >
                                {{ cat.name }}
                                <PhCheck v-if="filters.category === cat.slug" :size="16" weight="bold" class="shrink-0" />
                            </button>
                        </div>
                    </div>

                    <!-- Производители -->
                    <div v-if="manufacturers.length > 0">
                        <h3 class="mb-2.5 text-xs font-bold uppercase tracking-[0.18em] text-zinc-400 sm:mb-3">Производители</h3>
                        <div class="space-y-0.5 sm:space-y-1">
                            <button
                                v-for="mfr in manufacturers"
                                :key="mfr.id"
                                type="button"
                                class="flex w-full items-center justify-between gap-2 rounded-xl px-3 py-2 text-left text-sm font-medium transition sm:py-2.5"
                                :class="optionClass(isManufacturerActive(mfr.id))"
                                @click="go({ manufacturer: isManufacturerActive(mfr.id) ? null : mfr.id })"
                            >
                                {{ mfr.name }}
                                <PhCheck v-if="isManufacturerActive(mfr.id)" :size="16" weight="bold" class="shrink-0" />
                            </button>
                        </div>
                    </div>

                    <!-- Цена -->
                    <div>
                        <h3 class="mb-2.5 text-xs font-bold uppercase tracking-[0.18em] text-zinc-400 sm:mb-3">Цена, ₽</h3>
                        <div class="grid grid-cols-2 gap-2">
                            <div>
                                <label class="mb-1 block text-[11px] font-medium text-zinc-500">От</label>
                                <input
                                    v-model="minPrice"
                                    type="number"
                                    placeholder="0"
                                    class="w-full rounded-lg border border-zinc-200 bg-white px-3 py-2 text-sm text-zinc-900 outline-none transition focus:border-orange-500 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-100 dark:focus:border-orange-400"
                                    @input="go()"
                                />
                            </div>
                            <div>
                                <label class="mb-1 block text-[11px] font-medium text-zinc-500">До</label>
                                <input
                                    v-model="maxPrice"
                                    type="number"
                                    placeholder="∞"
                                    class="w-full rounded-lg border border-zinc-200 bg-white px-3 py-2 text-sm text-zinc-900 outline-none transition focus:border-orange-500 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-100 dark:focus:border-orange-400"
                                    @input="go()"
                                />
                            </div>
                        </div>
                    </div>

                    <!-- Стандарт -->
                    <div v-if="standards.length > 0">
                        <h3 class="mb-2.5 text-xs font-bold uppercase tracking-[0.18em] text-zinc-400 sm:mb-3">Стандарт</h3>
                        <div class="space-y-0.5 sm:space-y-1">
                            <button
                                v-for="std in standards"
                                :key="std.id"
                                type="button"
                                class="flex w-full items-center justify-between gap-2 rounded-xl px-3 py-2 text-left text-sm font-medium transition sm:py-2.5"
                                :class="optionClass(String(filters.standard) === String(std.id))"
                                @click="go({ standard: String(filters.standard) === String(std.id) ? '' : std.id })"
                            >
                                {{ std.name }}
                                <PhCheck v-if="String(filters.standard) === String(std.id)" :size="16" weight="bold" class="shrink-0" />
                            </button>
                        </div>
                    </div>

                    <!-- Диаметр -->
                    <div v-if="diameters.length > 0">
                        <h3 class="mb-2.5 text-xs font-bold uppercase tracking-[0.18em] text-zinc-400 sm:mb-3">Диаметр</h3>
                        <div class="space-y-0.5 sm:space-y-1">
                            <button
                                v-for="d in diameters"
                                :key="d.id"
                                type="button"
                                class="flex w-full items-center justify-between gap-2 rounded-xl px-3 py-2 text-left text-sm font-medium transition sm:py-2.5"
                                :class="optionClass(String(filters.diameter) === String(d.id))"
                                @click="go({ diameter: String(filters.diameter) === String(d.id) ? '' : d.id })"
                            >
                                {{ d.value }}
                                <PhCheck v-if="String(filters.diameter) === String(d.id)" :size="16" weight="bold" class="shrink-0" />
                            </button>
                        </div>
                    </div>

                    <button
                        v-if="activeCount > 0"
                        type="button"
                        class="hidden text-sm font-semibold text-orange-600 underline-offset-4 hover:underline dark:text-orange-400 lg:block"
                        @click="clearFilters"
                    >
                        Сбросить фильтры
                    </button>
                </div>

                <div class="border-t border-zinc-100 p-4 pb-[max(1rem,env(safe-area-inset-bottom))] dark:border-zinc-800 lg:hidden">
                    <button
                        type="button"
                        class="h-12 w-full rounded-full bg-orange-500 text-sm font-bold text-zinc-950 transition hover:bg-orange-400"
                        @click="showFilters = false"
                    >
                        Показать {{ products.total.toLocaleString('ru-RU') }} товаров
                    </button>
                </div>
            </aside>

            <!-- Товары -->
            <div class="min-w-0 flex-1">
                <!-- 2 колонки на мобиле (не 3 — карточки слишком мелкие) -->
                <div v-if="products.data.length > 0" class="grid grid-cols-2 gap-2 sm:grid-cols-3 sm:gap-3 md:grid-cols-4 lg:grid-cols-5">
                    <ProductCard
                        v-for="product in products.data"
                        :key="product.id"
                        :product="product"
                        show-favorite
                        :favorite="favorites.has(product.id)"
                        @toggle-favorite="toggleFavorite"
                    />
                </div>

                <!-- Пусто -->
                <div
                    v-else
                    class="rounded-2xl border border-dashed border-zinc-300 bg-white p-8 text-center dark:border-zinc-700 dark:bg-zinc-900 sm:rounded-3xl sm:p-16"
                >
                    <div class="mx-auto flex size-14 items-center justify-center rounded-2xl bg-zinc-100 text-zinc-400 dark:bg-zinc-800 sm:size-16">
                        <PhPackage :size="28" weight="light" class="sm:size-8" />
                    </div>
                    <h3 class="mt-4 text-lg font-extrabold sm:mt-5 sm:text-xl">Товары не найдены</h3>
                    <p class="mt-1.5 text-sm text-zinc-500 dark:text-zinc-400 sm:mt-2">Попробуйте изменить параметры поиска</p>
                    <button
                        type="button"
                        class="mt-5 inline-flex h-10 items-center rounded-full bg-orange-500 px-5 text-sm font-bold text-zinc-950 transition hover:bg-orange-400 sm:mt-6 sm:h-11 sm:px-6"
                        @click="clearFilters"
                    >
                        Показать все товары
                    </button>
                </div>

                <!-- Пагинация -->
                <nav
                    v-if="products.last_page > 1"
                    class="mt-8 flex items-center justify-center gap-1.5 sm:mt-10"
                    aria-label="Страницы"
                >
                    <button
                        type="button"
                        :disabled="!prevLink?.url"
                        class="flex size-9 items-center justify-center rounded-full border border-zinc-200 text-zinc-700 transition hover:border-orange-400 hover:text-orange-600 disabled:cursor-not-allowed disabled:opacity-30 disabled:hover:border-zinc-200 disabled:hover:text-zinc-700 dark:border-zinc-800 dark:text-zinc-200 sm:size-10"
                        aria-label="Назад"
                        @click="goPage(prevLink?.url ?? null)"
                    >
                        <PhArrowLeft :size="16" weight="bold" class="sm:size-[18px]" />
                    </button>

                    <span class="px-2.5 text-sm font-semibold text-zinc-600 dark:text-zinc-300 sm:hidden">
                        {{ products.current_page }} / {{ products.last_page }}
                    </span>

                    <template v-for="(link, i) in numberLinks" :key="i">
                        <button
                            v-if="link.url"
                            type="button"
                            class="hidden size-10 items-center justify-center rounded-full text-sm font-semibold transition sm:flex"
                            :class="link.active
                                ? 'bg-zinc-950 text-white dark:bg-white dark:text-zinc-950'
                                : 'text-zinc-600 hover:bg-zinc-100 dark:text-zinc-300 dark:hover:bg-zinc-800'"
                            @click="goPage(link.url)"
                        >
                            {{ link.label }}
                        </button>
                        <span v-else class="hidden px-1 text-zinc-400 sm:inline">…</span>
                    </template>

                    <button
                        type="button"
                        :disabled="!nextLink?.url"
                        class="flex size-9 items-center justify-center rounded-full border border-zinc-200 text-zinc-700 transition hover:border-orange-400 hover:text-orange-600 disabled:cursor-not-allowed disabled:opacity-30 disabled:hover:border-zinc-200 disabled:hover:text-zinc-700 dark:border-zinc-800 dark:text-zinc-200 sm:size-10"
                        aria-label="Вперёд"
                        @click="goPage(nextLink?.url ?? null)"
                    >
                        <PhArrowRight :size="16" weight="bold" class="sm:size-[18px]" />
                    </button>
                </nav>
            </div>
        </div>
    </div>
</template>
