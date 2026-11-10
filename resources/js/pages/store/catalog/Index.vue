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
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'

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
    standards: Array<{ id: number, name: string, code: string }>
    diameters: Array<{ id: number, value: string }>
    product_types: Array<{ id: number, name: string }>
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
        standard?: string | null
        diameter?: string | null
        product_type?: string | null
        stock_status?: string | null
        min_price?: string | null
        max_price?: string | null
        characteristics?: Record<string, string>
        sort: string
        direction: string
        search?: string
    }
}>()

// ---------- Общие классы ----------
const labelClass = 'mb-2 flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-zinc-500 before:h-3 before:w-0.5 before:rounded-full before:bg-orange-500 dark:text-zinc-400'
const fieldClass = 'w-full rounded-xl border border-zinc-200 bg-white text-sm font-medium text-zinc-800 outline-none transition hover:border-zinc-300 focus:border-orange-500 focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-100 dark:hover:border-zinc-600 dark:focus:border-orange-400'
const chipClass = 'group inline-flex items-center gap-1.5 rounded-full border border-orange-200 bg-orange-50 py-1.5 pl-3 pr-2 text-xs font-semibold text-orange-800 transition hover:border-orange-400 hover:bg-orange-100 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/30 dark:border-orange-500/30 dark:bg-orange-500/10 dark:text-orange-200 dark:hover:bg-orange-500/20 sm:text-sm'
const roundBtnClass = 'flex shrink-0 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-700 transition hover:border-orange-400 hover:text-orange-600 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/20 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-200 dark:hover:text-orange-400'

function switchTrackClass(on: boolean): string {
    return on ? 'bg-orange-500' : 'bg-zinc-300 dark:bg-zinc-700'
}

function switchKnobClass(on: boolean): string {
    return on ? 'translate-x-5' : 'translate-x-0'
}

function optionClass(active: boolean): string {
    return active
        ? 'bg-orange-50 text-orange-700 ring-1 ring-inset ring-orange-200 dark:bg-orange-500/10 dark:text-orange-300 dark:ring-orange-500/30'
        : 'text-zinc-600 hover:bg-zinc-100 hover:text-zinc-900 dark:text-zinc-400 dark:hover:bg-zinc-800 dark:hover:text-zinc-100'
}

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

// ---------- Состояние ----------
const showFilters = ref(false)
const loading = ref(false)
const activeCategory = computed(() =>
    props.categories.find(c => c.slug === props.filters.category || String(c.id) === String(props.filters.category)),
)

const sort = ref(props.filters.sort || 'created_at')
const direction = ref(props.filters.direction || 'desc')
const minPrice = ref(props.filters.min_price ?? '')
const maxPrice = ref(props.filters.max_price ?? '')

watch(() => props.filters, (f) => {
    sort.value = f.sort || 'created_at'
    direction.value = f.direction || 'desc'
    minPrice.value = f.min_price ?? ''
    maxPrice.value = f.max_price ?? ''
}, { deep: true })

watch(showFilters, (open) => {
    document.body.style.overflow = open ? 'hidden' : ''
})

function onKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape' && showFilters.value) showFilters.value = false
}

onMounted(() => window.addEventListener('keydown', onKeydown))

onBeforeUnmount(() => {
    window.removeEventListener('keydown', onKeydown)
    document.body.style.overflow = ''

    if (searchTimeout) clearTimeout(searchTimeout)
})

const sortOptions = [
    { value: 'created_at', label: 'Новизна' },
    { value: 'name', label: 'Название' },
    { value: 'price', label: 'Цена' },
]

// ---------- Поиск ----------
const searchQuery = ref(props.filters.search ?? '')
let searchTimeout: ReturnType<typeof setTimeout> | null = null
let suppressSearchWatch = false

watch(() => props.filters.search, (newSearch) => {
    searchQuery.value = newSearch ?? ''
})

watch(searchQuery, (newQuery) => {
    if (suppressSearchWatch) {
        suppressSearchWatch = false

        return
    }

    if (searchTimeout) clearTimeout(searchTimeout)

    if (!newQuery.trim()) {
        go({ page: 1 })

        return
    }

    searchTimeout = setTimeout(() => {
        go({ page: 1 })
    }, 600)
})

function clearSearch() {
    searchQuery.value = ''

    if (searchTimeout) {
        clearTimeout(searchTimeout)
        searchTimeout = null
    }
}

// ---------- Запросы ----------
type Params = Record<string, string | number | null | undefined | Record<string, string>>

function go(overrides: Params = {}, scrollTop = false) {
    const params: Params = {
        category: props.filters.category,
        standard: props.filters.standard ?? null,
        diameter: props.filters.diameter ?? null,
        product_type: props.filters.product_type ?? null,
        stock_status: props.filters.stock_status ?? null,
        min_price: minPrice.value || null,
        max_price: maxPrice.value || null,
        sort: sort.value,
        direction: direction.value,
        search: searchQuery.value || null,
        characteristics: props.filters.characteristics ?? undefined,
        ...overrides,
    }

    for (const key of Object.keys(params)) {
        if (params[key] === null || params[key] === undefined || params[key] === '') {
            delete params[key]
        }
    }

    const categorySlug = typeof params.category === 'string' ? params.category : null
    delete params.category

    const url = categorySlug
        ? `/catalog/${encodeURIComponent(categorySlug)}`
        : route('store.catalog.index')

    router.get(url, params, {
        preserveState: true,
        preserveScroll: true,
        onStart: () => {
            loading.value = true
        },
        onFinish: () => {
            loading.value = false
        },
        onSuccess: () => {
            if (scrollTop) window.scrollTo({ top: 0, behavior: 'smooth' })
        },
    })
}

function clearFilters() {
    suppressSearchWatch = true
    searchQuery.value = ''

    void nextTick(() => {
        suppressSearchWatch = false
    })

    minPrice.value = ''
    maxPrice.value = ''
    sort.value = 'created_at'
    direction.value = 'desc'

    if (searchTimeout) {
        clearTimeout(searchTimeout)
        searchTimeout = null
    }

    router.get(route('store.catalog.index'), {}, {
        preserveState: true,
        preserveScroll: true,
        onStart: () => {
            loading.value = true
        },
        onFinish: () => {
            loading.value = false
        },
        onSuccess: () => {
            showFilters.value = false
        },
    })
}

function toggleDirection() {
    direction.value = direction.value === 'asc' ? 'desc' : 'asc'
    go({ page: 1 })
}

function selectCategory(slug: string) {
    go({
        category: props.filters.category === slug ? null : slug,
        standard: null,
        diameter: null,
        product_type: null,
        characteristics: {},
        page: 1,
    })
}

// ---------- Выпадающие фильтры (стандарт / диаметр / тип) ----------
type SelectKey = 'standard' | 'diameter' | 'product_type'

const selectFilters = computed(() => [
    {
        key: 'standard' as SelectKey,
        label: 'Стандарт',
        all: 'Все стандарты',
        value: props.filters.standard ?? '',
        options: props.standards.map(s => ({ value: String(s.id), label: s.code })),
    },
    {
        key: 'diameter' as SelectKey,
        label: 'Диаметр',
        all: 'Все диаметры',
        value: props.filters.diameter ?? '',
        options: props.diameters.map(d => ({ value: String(d.id), label: d.value })),
    },
    {
        key: 'product_type' as SelectKey,
        label: 'Тип продукта',
        all: 'Все типы',
        value: props.filters.product_type ?? '',
        options: props.product_types.map(pt => ({ value: String(pt.id), label: pt.name })),
    },
].filter(f => f.options.length > 0))

function onSelectChange(key: SelectKey, event: Event) {
    const value = (event.target as HTMLSelectElement).value

    go({ [key]: value || null, page: 1 })
}

// ---------- Характеристики ----------
function isBooleanCharacteristicActive(characteristicId: number): boolean {
    const value = props.filters.characteristics?.[String(characteristicId)]

    return value === '1' || value === 'true' || value === 'yes' || value === 'да'
}

function setCharacteristicFilter(characteristicId: number, value: string | null) {
    const characteristics = { ...(props.filters.characteristics ?? {}) }

    if (value) {
        characteristics[String(characteristicId)] = value
    } else {
        delete characteristics[String(characteristicId)]
    }

    go({ characteristics, page: 1 })
}

function onCharacteristicChange(characteristicId: number, event: Event) {
    setCharacteristicFilter(characteristicId, (event.target as HTMLSelectElement).value || null)
}

// ---------- Активные фильтры ----------
type Chip = { key: string, label: string, remove: () => void }

const activeChips = computed<Chip[]>(() => {
    const chips: Chip[] = []
    const f = props.filters

    const category = props.categories.find(c => c.slug === f.category)

    if (category) {
        chips.push({ key: 'category', label: category.name, remove: () => go({ category: null, page: 1 }) })
    }

    const standard = props.standards.find(s => String(s.id) === String(f.standard))

    if (standard) {
        chips.push({ key: 'standard', label: `Стандарт: ${standard.code}`, remove: () => go({ standard: null, page: 1 }) })
    }

    const diameter = props.diameters.find(d => String(d.id) === String(f.diameter))

    if (diameter) {
        chips.push({ key: 'diameter', label: `Диаметр: ${diameter.value}`, remove: () => go({ diameter: null, page: 1 }) })
    }

    const productType = props.product_types.find(pt => String(pt.id) === String(f.product_type))

    if (productType) {
        chips.push({ key: 'product_type', label: `Тип: ${productType.name}`, remove: () => go({ product_type: null, page: 1 }) })
    }

    for (const characteristic of props.characteristics) {
        const value = f.characteristics?.[String(characteristic.id)]

        if (!value) continue

        const label = characteristic.type === 'boolean'
            ? characteristic.name
            : `${characteristic.name}: ${value}${characteristic.unit ? ` ${characteristic.unit}` : ''}`

        chips.push({
            key: `characteristic-${characteristic.id}`,
            label,
            remove: () => setCharacteristicFilter(characteristic.id, null),
        })
    }

    if (f.stock_status === 'in_stock') {
        chips.push({ key: 'stock', label: 'В наличии', remove: () => go({ stock_status: null, page: 1 }) })
    } else if (f.stock_status === 'out_of_stock') {
        chips.push({ key: 'stock', label: 'Нет в наличии', remove: () => go({ stock_status: null, page: 1 }) })
    }

    if (minPrice.value) {
        chips.push({
            key: 'min_price',
            label: `от ${Number(minPrice.value).toLocaleString('ru-RU')} ₽`,
            remove: () => {
                minPrice.value = ''
                go({ page: 1 })
            },
        })
    }

    if (maxPrice.value) {
        chips.push({
            key: 'max_price',
            label: `до ${Number(maxPrice.value).toLocaleString('ru-RU')} ₽`,
            remove: () => {
                maxPrice.value = ''
                go({ page: 1 })
            },
        })
    }

    return chips
})

const activeCount = computed(() => activeChips.value.length)
const hasAnyCriteria = computed(() => activeCount.value > 0 || !!searchQuery.value.trim())

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

    <div class="mx-auto max-w-7xl px-3 py-5 sm:px-6 sm:py-8 lg:px-10 lg:py-10 [&_input[type=search]]:shadow-sm [&_select]:shadow-sm">
        <!-- Заголовок -->
        <header class="relative overflow-hidden rounded-3xl border border-zinc-200 bg-gradient-to-br from-orange-50 via-white to-white p-5 dark:border-zinc-800 dark:from-orange-500/10 dark:via-zinc-900 dark:to-zinc-900 sm:p-8 lg:p-10">
            <div class="pointer-events-none absolute -right-16 -top-16 size-64 rounded-full bg-orange-400/20 blur-3xl dark:bg-orange-500/15" />
            <div class="pointer-events-none absolute -bottom-24 right-1/3 size-56 rounded-full bg-amber-300/20 blur-3xl dark:bg-amber-500/10" />

            <div class="relative flex flex-wrap items-end justify-between gap-x-6 gap-y-4">
                <div>
                    <p class="inline-flex items-center gap-2 rounded-full bg-orange-500/10 px-3 py-1 text-[11px] font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400 sm:text-xs">
                        <span class="size-1.5 rounded-full bg-orange-500" />
                        Магазин
                    </p>

                    <h1 class="mt-3 text-3xl font-black tracking-tight sm:text-4xl lg:text-5xl">
                        {{ activeCategory?.name ?? 'Каталог товаров' }}
                    </h1>
                </div>

                <p
                    class="inline-flex items-baseline gap-1.5 rounded-2xl border border-zinc-200 bg-white/80 px-4 py-2 text-sm text-zinc-500 shadow-sm backdrop-blur dark:border-zinc-700 dark:bg-zinc-800/70 dark:text-zinc-400"
                    aria-live="polite"
                >
                    Найдено
                    <span class="text-xl font-black text-zinc-900 dark:text-zinc-50">
                        {{ products.total.toLocaleString('ru-RU') }}
                    </span>
                    товаров
                </p>
            </div>
        </header>

        <!-- Панель управления -->
        <div class="mt-5 flex flex-col gap-2 sm:mt-6 sm:flex-row sm:items-center">
            <!-- Поиск -->
            <div class="relative w-full sm:max-w-sm sm:flex-1">
                <PhMagnifyingGlass
                    :size="18"
                    class="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-zinc-400"
                />

                <input
                    v-model="searchQuery"
                    type="search"
                    placeholder="Название, код или артикул"
                    aria-label="Поиск по каталогу"
                    class="h-11 w-full appearance-none rounded-full border border-zinc-200 bg-white py-2 pl-11 pr-10 text-sm font-medium text-zinc-800 outline-none transition placeholder:text-zinc-400 hover:border-zinc-300 focus:border-orange-500 focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-100 dark:placeholder:text-zinc-500 dark:focus:border-orange-400 [&::-webkit-search-cancel-button]:hidden"
                    @keydown.enter="go({ page: 1 })"
                />

                <button
                    v-if="searchQuery"
                    type="button"
                    class="absolute right-2 top-1/2 flex size-7 -translate-y-1/2 items-center justify-center rounded-full text-zinc-400 transition hover:bg-zinc-100 hover:text-zinc-600 dark:hover:bg-zinc-800 dark:hover:text-zinc-200"
                    aria-label="Очистить поиск"
                    @click="clearSearch"
                >
                    <PhX :size="16" />
                </button>
            </div>

            <div class="flex items-center gap-2">
                <!-- Кнопка фильтров (мобильные) -->
                <button
                    type="button"
                    class="relative inline-flex h-11 shrink-0 items-center gap-2 rounded-full border border-zinc-200 bg-white px-4 text-sm font-semibold text-zinc-800 transition hover:border-orange-400 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/20 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-100 lg:hidden"
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

                <!-- Сортировка -->
                <div class="relative min-w-0 flex-1 sm:flex-none">
                    <select
                        v-model="sort"
                        class="h-11 w-full appearance-none rounded-full border border-zinc-200 bg-white py-2 pl-4 pr-10 text-sm font-semibold text-zinc-800 outline-none transition hover:border-orange-400 focus:border-orange-500 focus:ring-4 focus:ring-orange-500/15 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-100 sm:w-auto"
                        aria-label="Сортировка"
                        @change="go({ page: 1 })"
                    >
                        <option v-for="opt in sortOptions" :key="opt.value" :value="opt.value">
                            {{ opt.label }}
                        </option>
                    </select>

                    <PhCaretDown
                        :size="15"
                        weight="bold"
                        class="pointer-events-none absolute right-4 top-1/2 -translate-y-1/2 text-zinc-400"
                    />
                </div>

                <button
                    type="button"
                    :class="roundBtnClass"
                    class="size-11"
                    :aria-label="direction === 'asc' ? 'По возрастанию' : 'По убыванию'"
                    :title="direction === 'asc' ? 'По возрастанию' : 'По убыванию'"
                    @click="toggleDirection"
                >
                    <PhSortAscending v-if="direction === 'asc'" :size="20" />
                    <PhSortDescending v-else :size="20" />
                </button>
            </div>
        </div>

        <!-- Выбранные фильтры -->
        <TransitionGroup
            v-if="activeCount > 0"
            tag="div"
            class="mt-4 flex flex-wrap items-center gap-1.5 sm:gap-2"
            enter-active-class="transition duration-150"
            leave-active-class="transition duration-100"
            enter-from-class="scale-90 opacity-0"
            leave-to-class="scale-90 opacity-0"
        >
            <button
                v-for="chip in activeChips"
                :key="chip.key"
                type="button"
                :class="chipClass"
                :aria-label="`Убрать фильтр: ${chip.label}`"
                @click="chip.remove()"
            >
                {{ chip.label }}

                <span class="flex size-4 items-center justify-center rounded-full bg-orange-500/15 transition group-hover:bg-orange-500 group-hover:text-white">
                    <PhX :size="10" weight="bold" />
                </span>
            </button>

            <button
                key="clear-all"
                type="button"
                class="rounded-full px-2.5 py-1.5 text-xs font-semibold text-orange-600 underline-offset-4 hover:underline focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/20 dark:text-orange-400 sm:text-sm"
                @click="clearFilters"
            >
                Сбросить всё
            </button>
        </TransitionGroup>

        <div class="mt-6 lg:mt-8 lg:flex lg:items-start lg:gap-8">
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
                    aria-hidden="true"
                    @click="showFilters = false"
                />
            </Transition>

            <!-- Фильтры -->
            <aside
                class="lg:w-64 lg:shrink-0"
                :class="showFilters
                    ? 'fixed inset-x-0 bottom-0 z-50 flex max-h-[88vh] flex-col rounded-t-[28px] bg-white shadow-2xl dark:bg-zinc-900 lg:static lg:z-auto lg:block lg:max-h-none lg:rounded-none lg:bg-transparent lg:shadow-none dark:lg:bg-transparent'
                    : 'hidden lg:block'"
                aria-label="Фильтры каталога"
            >
                <!-- Шапка шторки -->
                <div class="shrink-0 lg:hidden">
                    <div class="mx-auto mt-2.5 h-1 w-10 rounded-full bg-zinc-200 dark:bg-zinc-700" />

                    <div class="flex items-center justify-between border-b border-zinc-100 px-5 py-3 dark:border-zinc-800">
                        <h2 class="text-lg font-extrabold">
                            Фильтры
                        </h2>

                        <div class="flex items-center gap-1">
                            <button
                                v-if="activeCount > 0"
                                type="button"
                                class="rounded-full px-3 py-1.5 text-sm font-semibold text-orange-600 dark:text-orange-400"
                                @click="clearFilters"
                            >
                                Сбросить
                            </button>

                            <button
                                type="button"
                                class="flex size-9 items-center justify-center rounded-full text-zinc-500 hover:bg-zinc-100 dark:hover:bg-zinc-800"
                                aria-label="Закрыть"
                                @click="showFilters = false"
                            >
                                <PhX :size="20" />
                            </button>
                        </div>
                    </div>
                </div>

                <div
                    class="flex-1 space-y-6 overflow-y-auto p-4 lg:sticky lg:top-28 lg:max-h-[calc(100vh-8rem)] lg:rounded-3xl lg:border lg:border-zinc-200 lg:bg-white lg:p-5 lg:shadow-sm dark:lg:border-zinc-800 dark:lg:bg-zinc-900"
                >
                    <!-- Категории -->
                    <section v-if="categories.length > 0">
                        <h3 :class="labelClass">
                            Категории
                        </h3>

                        <div class="space-y-0.5">
                            <button
                                v-for="cat in categories"
                                :key="cat.id"
                                type="button"
                                class="flex w-full items-center justify-between gap-2 rounded-xl px-3 py-2 text-left text-[13px] font-medium transition"
                                :class="optionClass(props.filters.category === cat.slug)"
                                :aria-pressed="props.filters.category === cat.slug"
                                @click="selectCategory(cat.slug)"
                            >
                                {{ cat.name }}

                                <PhCheck
                                    v-if="props.filters.category === cat.slug"
                                    :size="16"
                                    weight="bold"
                                    class="shrink-0"
                                />
                            </button>
                        </div>
                    </section>

                    <!-- Цена -->
                    <section>
                        <h3 :class="labelClass">
                            Цена, ₽
                        </h3>

                        <div class="flex items-center gap-2">
                            <input
                                v-model="minPrice"
                                type="number"
                                min="0"
                                inputmode="numeric"
                                placeholder="От"
                                aria-label="Цена от"
                                :class="fieldClass"
                                class="h-10 px-3"
                                @change="go({ page: 1 })"
                            />

                            <span class="text-zinc-300 dark:text-zinc-600">—</span>

                            <input
                                v-model="maxPrice"
                                type="number"
                                min="0"
                                inputmode="numeric"
                                placeholder="До"
                                aria-label="Цена до"
                                :class="fieldClass"
                                class="h-10 px-3"
                                @change="go({ page: 1 })"
                            />
                        </div>
                    </section>

                    <!-- Стандарт / Диаметр / Тип -->
                    <section v-for="filter in selectFilters" :key="filter.key">
                        <label :for="`catalog-${filter.key}`" :class="labelClass">
                            {{ filter.label }}
                        </label>

                        <div class="relative">
                            <select
                                :id="`catalog-${filter.key}`"
                                :value="filter.value"
                                :class="fieldClass"
                                class="h-10 appearance-none px-3 pr-9"
                                @change="onSelectChange(filter.key, $event)"
                            >
                                <option value="">
                                    {{ filter.all }}
                                </option>

                                <option v-for="opt in filter.options" :key="opt.value" :value="opt.value">
                                    {{ opt.label }}
                                </option>
                            </select>

                            <PhCaretDown
                                :size="14"
                                class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-zinc-400"
                            />
                        </div>
                    </section>

                    <!-- Характеристики -->
                    <section v-if="characteristics.length > 0" class="space-y-4">
                        <div
                            v-for="characteristic in characteristics"
                            :key="characteristic.id"
                            class="min-w-0"
                        >
                            <!-- Boolean — переключатель -->
                            <div v-if="characteristic.type === 'boolean'" class="flex items-center justify-between gap-3">
                                <span class="text-[13px] font-medium text-zinc-700 dark:text-zinc-200">
                                    {{ characteristic.name }}
                                </span>

                                <button
                                    type="button"
                                    role="switch"
                                    :aria-checked="isBooleanCharacteristicActive(characteristic.id)"
                                    :aria-label="characteristic.name"
                                    class="relative h-6 w-11 shrink-0 rounded-full transition-colors focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/30"
                                    :class="switchTrackClass(isBooleanCharacteristicActive(characteristic.id))"
                                    @click="setCharacteristicFilter(
                                        characteristic.id,
                                        isBooleanCharacteristicActive(characteristic.id) ? null : '1',
                                    )"
                                >
                                    <span
                                        class="absolute left-0.5 top-0.5 size-5 rounded-full bg-white shadow transition-transform"
                                        :class="switchKnobClass(isBooleanCharacteristicActive(characteristic.id))"
                                    />
                                </button>
                            </div>

                            <!-- Остальные типы — список значений -->
                            <div v-else>
                                <label :for="`characteristic-${characteristic.id}`" :class="labelClass">
                                    {{ characteristic.name }}<span v-if="characteristic.unit">, {{ characteristic.unit }}</span>
                                </label>

                                <div class="relative">
                                    <select
                                        :id="`characteristic-${characteristic.id}`"
                                        :value="props.filters.characteristics?.[String(characteristic.id)] ?? ''"
                                        :class="fieldClass"
                                        class="h-10 appearance-none px-3 pr-9"
                                        @change="onCharacteristicChange(characteristic.id, $event)"
                                    >
                                        <option value="">
                                            Любое значение
                                        </option>

                                        <option
                                            v-for="value in (props.characteristic_values[String(characteristic.id)] ?? [])"
                                            :key="value"
                                            :value="value"
                                        >
                                            {{ value }}
                                        </option>
                                    </select>

                                    <PhCaretDown
                                        :size="14"
                                        class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-zinc-400"
                                    />
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- Наличие -->
                    <section class="flex items-center justify-between gap-3 border-t border-zinc-100 pt-5 dark:border-zinc-800">
                        <div>
                            <h3 class="text-[13px] font-semibold text-zinc-800 dark:text-zinc-100">
                                Только в наличии
                            </h3>

                            <p class="mt-0.5 text-[11px] text-zinc-400">
                                Скрыть товары без остатка
                            </p>
                        </div>

                        <button
                            type="button"
                            role="switch"
                            :aria-checked="props.filters.stock_status === 'in_stock'"
                            aria-label="Только товары в наличии"
                            class="relative h-6 w-11 shrink-0 rounded-full transition-colors focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/30"
                            :class="switchTrackClass(props.filters.stock_status === 'in_stock')"
                            @click="go({
                                stock_status: props.filters.stock_status === 'in_stock' ? null : 'in_stock',
                                page: 1,
                            })"
                        >
                            <span
                                class="absolute left-0.5 top-0.5 size-5 rounded-full bg-white shadow transition-transform"
                                :class="switchKnobClass(props.filters.stock_status === 'in_stock')"
                            />
                        </button>
                    </section>

                    <button
                        v-if="activeCount > 0"
                        type="button"
                        class="hidden w-full rounded-xl border border-zinc-200 py-2 text-sm font-semibold text-orange-600 transition hover:border-orange-400 dark:border-zinc-700 dark:text-orange-400 lg:block"
                        @click="clearFilters"
                    >
                        Сбросить фильтры
                    </button>
                </div>

                <!-- Подвал шторки -->
                <div class="shrink-0 border-t border-zinc-100 p-4 pb-[max(1rem,env(safe-area-inset-bottom))] dark:border-zinc-800 lg:hidden">
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
                <div
                    v-if="products.data.length > 0"
                    class="grid grid-cols-2 gap-2 transition-opacity duration-200 sm:gap-3 md:grid-cols-3 xl:grid-cols-4"
                    :class="loading ? 'pointer-events-none opacity-50' : 'opacity-100'"
                    :aria-busy="loading"
                >
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
                    class="rounded-3xl border border-dashed border-orange-300/70 bg-gradient-to-b from-orange-50/60 to-white p-8 text-center transition-opacity dark:border-orange-500/30 dark:from-orange-500/5 dark:to-zinc-900 sm:p-16"
                    :class="loading ? 'opacity-50' : ''"
                >
                    <div class="mx-auto flex size-20 items-center justify-center rounded-3xl bg-orange-100 text-orange-500 shadow-inner dark:bg-orange-500/15">
                        <PhPackage :size="38" weight="duotone" />
                    </div>

                    <h3 class="mt-5 text-lg font-extrabold sm:text-xl">
                        Товары не найдены
                    </h3>

                    <p class="mx-auto mt-2 max-w-sm text-sm text-zinc-500 dark:text-zinc-400">
                        {{ hasAnyCriteria
                        ? 'По выбранным параметрам ничего нет. Попробуйте убрать часть фильтров или изменить запрос.'
                        : 'В каталоге пока нет товаров.' }}
                    </p>

                    <button
                        v-if="hasAnyCriteria"
                        type="button"
                        class="mt-6 inline-flex h-11 items-center rounded-full bg-orange-500 px-6 text-sm font-bold text-zinc-950 transition hover:bg-orange-400"
                        @click="clearFilters"
                    >
                        Сбросить и показать все
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
                        :class="roundBtnClass"
                        class="size-10 disabled:cursor-not-allowed disabled:opacity-30 disabled:hover:border-zinc-200 disabled:hover:text-zinc-700"
                        aria-label="Назад"
                        @click="goPage(prevLink?.url ?? null)"
                    >
                        <PhArrowLeft :size="18" weight="bold" />
                    </button>

                    <span class="px-3 text-sm font-semibold text-zinc-600 dark:text-zinc-300 sm:hidden">
                        {{ products.current_page }} / {{ products.last_page }}
                    </span>

                    <template v-for="(link, i) in numberLinks" :key="i">
                        <button
                            v-if="link.url"
                            type="button"
                            class="hidden size-10 items-center justify-center rounded-full text-sm font-semibold transition sm:flex"
                            :class="link.active
                                ? 'bg-orange-500 text-zinc-950 shadow-md shadow-orange-500/30'
                                : 'text-zinc-600 hover:bg-zinc-100 dark:text-zinc-300 dark:hover:bg-zinc-800'"
                            :aria-current="link.active ? 'page' : undefined"
                            @click="goPage(link.url)"
                        >
                            {{ link.label }}
                        </button>

                        <span v-else class="hidden px-1 text-zinc-400 sm:inline">
                            …
                        </span>
                    </template>

                    <button
                        type="button"
                        :disabled="!nextLink?.url"
                        :class="roundBtnClass"
                        class="size-10 disabled:cursor-not-allowed disabled:opacity-30 disabled:hover:border-zinc-200 disabled:hover:text-zinc-700"
                        aria-label="Вперёд"
                        @click="goPage(nextLink?.url ?? null)"
                    >
                        <PhArrowRight :size="18" weight="bold" />
                    </button>
                </nav>
            </div>
        </div>
    </div>
</template>
