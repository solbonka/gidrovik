<script setup lang="ts">
import { Head, Link, router, usePage } from '@inertiajs/vue3'
import {
    PhArrowCounterClockwise,
    PhCaretRight,
    PhDrop,
    PhGearSix,
    PhHeart,
    PhHouse,
    PhList,
    PhMagnifyingGlass,
    PhMapPin,
    PhMoon,
    PhPhone,
    PhShieldCheck,
    PhShoppingCart,
    PhSignIn,
    PhSignOut,
    PhSquaresFour,
    PhSun,
    PhTruck,
    PhUser,
    PhWallet,
    PhX,
} from '@phosphor-icons/vue'
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { toast } from 'vue-sonner'
import { Toaster } from '@/components/ui/sonner'

import { login, logout } from '@/routes'
import { dashboard } from '@/routes/admin'

const props = defineProps<{
    title?: string
    cartCount?: number
}>()

const page = usePage()
const cartCount = computed(() => props.cartCount ?? 0)
const user = computed(() => page.props.auth.user)

// Сотрудник (есть флаг is_employee)
const isEmployee = computed(() => page.props.auth.user?.is_employee === true)

// ---------- Toast notifications ----------
watch(
    () => page.props.flash as {
        success?: string | null
        error?: string | null
        toast?: { type?: string; message?: string } | null
    } | undefined,
    (flash) => {
        if (!flash) return

        if (flash.toast) {
            const type = flash.toast.type || 'success'
            const message = flash.toast.message || ''
            if (type === 'error') {
                toast.error(message)
            } else {
                toast.success(message)
            }
            return
        }

        if (flash.error) {
            toast.error(flash.error)
            return
        }

        if (flash.success) {
            toast.success(flash.success)
        }
    },
    { immediate: true },
)

// ---------- Тема ----------
type Appearance = 'light' | 'dark' | 'system'

const STORAGE_KEY = 'appearance'
const appearance = ref<Appearance>('system')
const systemDark = ref(false)
let mediaQuery: MediaQueryList | null = null

const isDark = computed(() =>
    appearance.value === 'dark' || (appearance.value === 'system' && systemDark.value),
)

function applyTheme() {
    document.documentElement.classList.toggle('dark', isDark.value)
    document.documentElement.style.colorScheme = isDark.value ? 'dark' : 'light'
}

function toggleTheme() {
    appearance.value = isDark.value ? 'light' : 'dark'
}

function onSystemChange(e: MediaQueryListEvent) {
    systemDark.value = e.matches
}

watch(appearance, (value) => {
    try {
        localStorage.setItem(STORAGE_KEY, value)
        document.cookie = `${STORAGE_KEY}=${value};path=/;max-age=31536000;SameSite=Lax`
    } catch {
        /* хранилище недоступно — не страшно */
    }
    applyTheme()
})

watch(systemDark, applyTheme)

// ---------- Мобильное меню ----------
const mobileMenuOpen = ref(false)

// ---------- Поиск ----------
const searchQuery = ref('')
const searchExamples = ref([
    'DKOL 16 10 90',
    '2SN d-25',
    'Муфта, Italy, 4SP, d-20mm',
    'Фитинг, d-12mm, BSP, Ш, 1/2, 0°',
    'Хомут червячный 70-90/9 W1',
    'Трубка возд.10*1 (полиамид) чёрная',
])
const currentExampleIndex = ref(0)
const currentText = ref('')
const isDeleting = ref(false)
let typewriterTimer: ReturnType<typeof setTimeout> | null = null

function typeExample() {
    const fullText = searchExamples.value[currentExampleIndex.value]

    if (!isDeleting.value) {
        // Typing
        currentText.value = fullText.substring(0, currentText.value.length + 1)
        if (currentText.value === fullText) {
            // Pause before deleting
            typewriterTimer = setTimeout(() => {
                isDeleting.value = true
                typeExample()
            }, 2000)
            return
        }
        typewriterTimer = setTimeout(typeExample, 80)
    } else {
        // Deleting
        currentText.value = fullText.substring(0, currentText.value.length - 1)
        if (currentText.value === '') {
            isDeleting.value = false
            currentExampleIndex.value = (currentExampleIndex.value + 1) % searchExamples.value.length
            typewriterTimer = setTimeout(typeExample, 400)
            return
        }
        typewriterTimer = setTimeout(typeExample, 40)
    }
}

onMounted(() => {
    typewriterTimer = setTimeout(typeExample, 1000)
})

onBeforeUnmount(() => {
    if (typewriterTimer) clearTimeout(typewriterTimer)
})

function performSearch() {
    const q = searchQuery.value.trim()
    if (q) {
        router.get(route('store.search.index'), { q })
        mobileMenuOpen.value = false
    }
}

function doLogout() {
    mobileMenuOpen.value = false
    router.post(logout().url)
}

// Закрываем меню при переходе на другую страницу
watch(() => page.url, () => {
    mobileMenuOpen.value = false
})

// Блокируем прокрутку страницы, когда открыто меню
watch(mobileMenuOpen, (open) => {
    document.body.style.overflow = open ? 'hidden' : ''
})

function onKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape') mobileMenuOpen.value = false
}

onMounted(() => {
    document.addEventListener('keydown', onKeydown)

    mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    systemDark.value = mediaQuery.matches
    mediaQuery.addEventListener('change', onSystemChange)

    try {
        const saved = localStorage.getItem(STORAGE_KEY) as Appearance | null
        if (saved === 'light' || saved === 'dark' || saved === 'system') {
            appearance.value = saved
        }
    } catch {
        /* ignore */
    }
    applyTheme()
})

onBeforeUnmount(() => {
    document.removeEventListener('keydown', onKeydown)
    mediaQuery?.removeEventListener('change', onSystemChange)
    document.body.style.overflow = ''
})

// Подсветка активного пункта нижней навигации (без route().current — он падает в Ziggy)
const currentPath = computed(() => (page.url ?? '').split('?')[0].split('#')[0])

function isActive(name: string): boolean {
    try {
        const routeName = name.replace(/\.\*$/, '.index')
        const path = new URL(route(routeName), 'http://localhost').pathname
        if (path === '/') return currentPath.value === '/'
        return currentPath.value === path || currentPath.value.startsWith(path + '/')
    } catch {
        return false
    }
}
</script>

<template>
    <div class="flex min-h-screen flex-col bg-zinc-50 text-zinc-900 antialiased transition-colors selection:bg-orange-500/30 dark:bg-zinc-950 dark:text-zinc-100">
        <Head :title="title" />

        <!-- Верхняя полоса (только десктоп) -->
        <div class="hidden border-b border-zinc-800 bg-zinc-950 text-zinc-400 md:block">
            <div class="mx-auto flex h-9 max-w-7xl items-center justify-between px-6 text-xs lg:px-10">
                <a href="tel:+7XXXXXXXXXX" class="flex items-center gap-2 transition hover:text-white">
                    <PhPhone :size="14" weight="fill" class="text-orange-500" />
                    +7 (XXX) XXX-XX-XX
                </a>
                <nav class="flex items-center gap-6">
                    <Link :href="route('store.pages.delivery')" class="transition hover:text-white">Доставка</Link>
                    <Link :href="route('store.pages.payment')" class="transition hover:text-white">Оплата</Link>
                    <Link :href="route('store.pages.returns')" class="transition hover:text-white">Возврат</Link>
                </nav>
            </div>
        </div>

        <!-- Шапка -->
        <header class="sticky top-0 z-40 border-b border-zinc-200/80 bg-white/80 backdrop-blur-xl transition-colors dark:border-zinc-800 dark:bg-zinc-950/80">
            <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-10">
                <div class="flex h-14 items-center gap-2 sm:gap-3 md:h-[72px] md:gap-5">
                    <!-- Кнопка меню (мобильные) -->
                    <button
                        type="button"
                        class="-ml-2 flex size-10 items-center justify-center rounded-full text-zinc-800 transition hover:bg-zinc-100 active:scale-95 dark:text-zinc-100 dark:hover:bg-zinc-800 md:hidden"
                        aria-label="Открыть меню"
                        @click="mobileMenuOpen = true"
                    >
                        <PhList :size="24" />
                    </button>

                    <!-- Логотип -->
                    <Link :href="route('store.home')" class="flex shrink-0 items-center gap-2.5">
                        <div class="flex size-9 items-center justify-center rounded-xl bg-zinc-950 text-orange-500 dark:bg-orange-500 dark:text-zinc-950 md:size-10">
                            <PhDrop :size="22" weight="fill" />
                        </div>
                        <div class="leading-none">
                            <div class="text-lg font-black tracking-tight md:text-xl">Гидровик</div>
                            <div class="mt-1 hidden text-[9px] font-semibold uppercase tracking-[0.22em] text-zinc-400 sm:block">интернет-магазин</div>
                        </div>
                    </Link>

                    <!-- Каталог (десктоп) -->
                    <Link
                        :href="route('store.catalog.index')"
                        class="hidden h-11 shrink-0 items-center gap-2 rounded-full bg-zinc-950 px-5 text-sm font-semibold text-white transition hover:bg-orange-500 hover:text-zinc-950 dark:bg-white dark:text-zinc-950 dark:hover:bg-orange-500 md:inline-flex"
                    >
                        <PhSquaresFour :size="18" weight="bold" />
                        Каталог
                    </Link>

                    <!-- Поиск (десктоп) -->
                    <form class="hidden flex-1 md:block" @submit.prevent="performSearch">
                        <div class="group relative">
                            <PhMagnifyingGlass :size="18" class="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400 transition group-focus-within:text-orange-500" />
                            <input
                                v-model="searchQuery"
                                type="search"
                                :placeholder="currentText + (isDeleting ? '' : '▌')"
                                class="h-11 w-full rounded-full border border-transparent bg-zinc-100 pl-11 pr-14 text-sm text-zinc-900 outline-none transition placeholder:text-zinc-400 focus:border-orange-400 focus:bg-white focus:ring-4 focus:ring-orange-500/15 dark:bg-zinc-900 dark:text-zinc-100 dark:focus:border-orange-500 dark:focus:bg-zinc-900"
                            />
                            <button
                                type="submit"
                                class="absolute right-1.5 top-1/2 flex size-8 -translate-y-1/2 items-center justify-center rounded-full bg-orange-500 text-zinc-950 transition hover:bg-orange-400"
                                aria-label="Найти"
                            >
                                <PhMagnifyingGlass :size="16" weight="bold" />
                            </button>
                        </div>
                    </form>

                    <div class="flex-1 md:hidden" />

                    <!-- Действия -->
                    <div class="flex shrink-0 items-center gap-0.5 sm:gap-1">
                        <Link
                            v-if="user && isEmployee"
                            :href="dashboard().url"
                            class="mr-1 hidden h-10 items-center gap-1.5 rounded-full border border-zinc-200 px-4 text-sm font-semibold text-zinc-700 transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-700 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400 lg:inline-flex"
                        >
                            <PhGearSix :size="16" weight="bold" />
                            Админ
                        </Link>

                        <button
                            type="button"
                            class="hidden size-10 items-center justify-center rounded-full text-zinc-600 transition hover:bg-zinc-100 hover:text-orange-500 active:scale-95 dark:text-zinc-300 dark:hover:bg-zinc-800 dark:hover:text-orange-400 sm:flex"
                            :aria-label="isDark ? 'Включить светлую тему' : 'Включить тёмную тему'"
                            :title="isDark ? 'Светлая тема' : 'Тёмная тема'"
                            @click="toggleTheme"
                        >
                            <PhSun v-if="isDark" :size="21" />
                            <PhMoon v-else :size="21" />
                        </button>

                        <Link
                            v-if="user"
                            :href="route('store.favorites.index')"
                            class="hidden size-10 items-center justify-center rounded-full text-zinc-600 transition hover:bg-zinc-100 hover:text-rose-500 dark:text-zinc-300 dark:hover:bg-zinc-800 sm:flex"
                            aria-label="Избранное"
                        >
                            <PhHeart :size="21" />
                        </Link>

                        <Link
                            :href="route('store.cart.index')"
                            class="relative flex size-10 items-center justify-center rounded-full text-zinc-700 transition hover:bg-zinc-100 hover:text-orange-500 dark:text-zinc-200 dark:hover:bg-zinc-800 dark:hover:text-orange-400"
                            aria-label="Корзина"
                        >
                            <PhShoppingCart :size="22" />
                            <span
                                v-if="cartCount > 0"
                                class="absolute right-0 top-0 flex min-w-[18px] items-center justify-center rounded-full bg-orange-500 px-1 text-[10px] font-bold leading-[18px] text-zinc-950 ring-2 ring-white dark:ring-zinc-950"
                            >
                                {{ cartCount }}
                            </span>
                        </Link>

                        <Link
                            v-if="user"
                            :href="route('store.orders.index')"
                            class="hidden h-10 items-center gap-2 rounded-full px-3.5 text-sm font-semibold text-zinc-700 transition hover:bg-zinc-100 dark:text-zinc-200 dark:hover:bg-zinc-800 sm:flex"
                        >
                            <PhUser :size="18" />
                            <span class="hidden lg:inline">Заказы</span>
                        </Link>

                        <Link
                            v-else
                            :href="login().url"
                            class="ml-1 flex h-10 items-center gap-2 rounded-full bg-zinc-950 px-4 text-sm font-semibold text-white transition hover:bg-orange-500 hover:text-zinc-950 dark:bg-white dark:text-zinc-950 dark:hover:bg-orange-500"
                        >
                            <PhSignIn :size="16" weight="bold" />
                            Войти
                        </Link>

                        <button
                            v-if="user"
                            type="button"
                            class="hidden size-10 items-center justify-center rounded-full text-zinc-500 transition hover:bg-zinc-100 hover:text-zinc-900 dark:text-zinc-400 dark:hover:bg-zinc-800 dark:hover:text-white sm:flex"
                            aria-label="Выйти"
                            @click="doLogout"
                        >
                            <PhSignOut :size="20" />
                        </button>
                    </div>
                </div>

                <!-- Поиск на мобильных -->
                <form class="pb-3 md:hidden" @submit.prevent="performSearch">
                    <div class="group relative">
                        <PhMagnifyingGlass :size="18" class="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400 transition group-focus-within:text-orange-500" />
                        <input
                            v-model="searchQuery"
                            type="search"
                            :placeholder="currentText + (isDeleting ? '' : '▌')"
                            class="h-11 w-full rounded-full border border-transparent bg-zinc-100 pl-11 pr-4 text-base text-zinc-900 outline-none placeholder:text-zinc-400 focus:border-orange-400 focus:bg-white focus:ring-4 focus:ring-orange-500/15 dark:bg-zinc-900 dark:text-zinc-100 dark:focus:border-orange-500"
                        />
                    </div>
                </form>
            </div>
        </header>

        <!-- Мобильное меню (выезжающая панель) -->
        <Teleport to="body">
            <Transition
                enter-active-class="transition-opacity duration-200"
                leave-active-class="transition-opacity duration-200"
                enter-from-class="opacity-0"
                leave-to-class="opacity-0"
            >
                <div
                    v-if="mobileMenuOpen"
                    class="fixed inset-0 z-50 bg-zinc-950/60 backdrop-blur-sm md:hidden"
                    @click="mobileMenuOpen = false"
                />
            </Transition>

            <Transition
                enter-active-class="transition-transform duration-300 ease-out"
                leave-active-class="transition-transform duration-200 ease-in"
                enter-from-class="-translate-x-full"
                leave-to-class="-translate-x-full"
            >
                <aside
                    v-if="mobileMenuOpen"
                    class="fixed inset-y-0 left-0 z-50 flex w-[86%] max-w-sm flex-col bg-white text-zinc-900 shadow-2xl dark:bg-zinc-950 dark:text-zinc-100 md:hidden"
                >
                    <div class="flex h-14 items-center justify-between border-b border-zinc-100 px-4 dark:border-zinc-800">
                        <div class="flex items-center gap-2.5">
                            <div class="flex size-9 items-center justify-center rounded-xl bg-zinc-950 text-orange-500 dark:bg-orange-500 dark:text-zinc-950">
                                <PhDrop :size="20" weight="fill" />
                            </div>
                            <span class="text-lg font-black tracking-tight">Гидровик</span>
                        </div>
                        <button
                            type="button"
                            class="flex size-10 items-center justify-center rounded-full text-zinc-500 hover:bg-zinc-100 dark:text-zinc-400 dark:hover:bg-zinc-800"
                            aria-label="Закрыть меню"
                            @click="mobileMenuOpen = false"
                        >
                            <PhX :size="22" />
                        </button>
                    </div>

                    <nav class="flex-1 space-y-6 overflow-y-auto px-4 py-5">
                        <div class="space-y-1">
                            <Link
                                :href="route('store.catalog.index')"
                                class="flex items-center gap-3 rounded-2xl bg-orange-500 px-4 py-3.5 text-base font-bold text-zinc-950"
                            >
                                <PhSquaresFour :size="22" weight="bold" />
                                Каталог
                                <PhCaretRight :size="16" weight="bold" class="ml-auto" />
                            </Link>
                            <Link
                                :href="route('store.cart.index')"
                                class="flex items-center gap-3 rounded-2xl px-4 py-3.5 text-[15px] font-medium text-zinc-700 active:bg-zinc-100 dark:text-zinc-200 dark:active:bg-zinc-900"
                            >
                                <PhShoppingCart :size="22" class="text-zinc-400" />
                                Корзина
                                <span v-if="cartCount > 0" class="ml-auto rounded-full bg-orange-500 px-2 py-0.5 text-[11px] font-bold text-zinc-950">
                                    {{ cartCount }}
                                </span>
                            </Link>
                            <Link
                                v-if="user"
                                :href="route('store.favorites.index')"
                                class="flex items-center gap-3 rounded-2xl px-4 py-3.5 text-[15px] font-medium text-zinc-700 active:bg-zinc-100 dark:text-zinc-200 dark:active:bg-zinc-900"
                            >
                                <PhHeart :size="22" class="text-zinc-400" />
                                Избранное
                            </Link>
                            <Link
                                v-if="user"
                                :href="route('store.orders.index')"
                                class="flex items-center gap-3 rounded-2xl px-4 py-3.5 text-[15px] font-medium text-zinc-700 active:bg-zinc-100 dark:text-zinc-200 dark:active:bg-zinc-900"
                            >
                                <PhUser :size="22" class="text-zinc-400" />
                                Мои заказы
                            </Link>
                            <Link
                                v-if="user && isEmployee"
                                :href="dashboard().url"
                                class="flex items-center gap-3 rounded-2xl px-4 py-3.5 text-[15px] font-medium text-zinc-700 active:bg-zinc-100 dark:text-zinc-200 dark:active:bg-zinc-900"
                            >
                                <PhGearSix :size="22" class="text-zinc-400" />
                                Админ-панель
                            </Link>
                        </div>

                        <div>
                            <div class="mb-2 px-4 text-[11px] font-bold uppercase tracking-[0.18em] text-zinc-400">Информация</div>
                            <div class="space-y-1">
                                <Link :href="route('store.pages.delivery')" class="flex items-center gap-3 rounded-2xl px-4 py-3 text-[15px] font-medium text-zinc-700 active:bg-zinc-100 dark:text-zinc-200 dark:active:bg-zinc-900">
                                    <PhTruck :size="22" class="text-zinc-400" /> Доставка
                                </Link>
                                <Link :href="route('store.pages.payment')" class="flex items-center gap-3 rounded-2xl px-4 py-3 text-[15px] font-medium text-zinc-700 active:bg-zinc-100 dark:text-zinc-200 dark:active:bg-zinc-900">
                                    <PhWallet :size="22" class="text-zinc-400" /> Оплата
                                </Link>
                                <Link :href="route('store.pages.returns')" class="flex items-center gap-3 rounded-2xl px-4 py-3 text-[15px] font-medium text-zinc-700 active:bg-zinc-100 dark:text-zinc-200 dark:active:bg-zinc-900">
                                    <PhArrowCounterClockwise :size="22" class="text-zinc-400" /> Возврат
                                </Link>
                                <Link :href="route('store.pages.privacy')" class="flex items-center gap-3 rounded-2xl px-4 py-3 text-[15px] font-medium text-zinc-700 active:bg-zinc-100 dark:text-zinc-200 dark:active:bg-zinc-900">
                                    <PhShieldCheck :size="22" class="text-zinc-400" /> Персональные данные
                                </Link>
                            </div>
                        </div>
                    </nav>

                    <div class="space-y-2.5 border-t border-zinc-100 p-4 pb-[max(1rem,env(safe-area-inset-bottom))] dark:border-zinc-800">
                        <button
                            type="button"
                            class="flex w-full items-center gap-3 rounded-2xl bg-zinc-100 px-4 py-3 text-sm font-semibold text-zinc-800 dark:bg-zinc-900 dark:text-zinc-100"
                            role="switch"
                            :aria-checked="isDark"
                            @click="toggleTheme"
                        >
                            <PhMoon v-if="!isDark" :size="20" class="text-zinc-500" />
                            <PhSun v-else :size="20" class="text-amber-300" />
                            Тёмная тема
                            <span
                                class="ml-auto flex h-6 w-11 items-center rounded-full p-0.5 transition-colors"
                                :class="isDark ? 'bg-orange-500' : 'bg-zinc-300'"
                            >
                                <span
                                    class="size-5 rounded-full bg-white shadow transition-transform"
                                    :class="isDark ? 'translate-x-5' : 'translate-x-0'"
                                />
                            </span>
                        </button>

                        <a href="tel:+7XXXXXXXXXX" class="flex items-center gap-3 rounded-2xl bg-zinc-100 px-4 py-3 text-sm font-semibold text-zinc-800 dark:bg-zinc-900 dark:text-zinc-100">
                            <PhPhone :size="20" weight="fill" class="text-orange-500" />
                            +7 (XXX) XXX-XX-XX
                        </a>
                        <button
                            v-if="user"
                            type="button"
                            class="flex w-full items-center justify-center gap-2 rounded-2xl border border-zinc-200 py-3 text-sm font-semibold text-zinc-600 active:bg-zinc-50 dark:border-zinc-800 dark:text-zinc-300 dark:active:bg-zinc-900"
                            @click="doLogout"
                        >
                            <PhSignOut :size="18" />
                            Выйти
                        </button>
                        <Link
                            v-else
                            :href="login().url"
                            class="flex w-full items-center justify-center gap-2 rounded-2xl bg-zinc-950 py-3 text-sm font-semibold text-white dark:bg-white dark:text-zinc-950"
                        >
                            <PhSignIn :size="18" weight="bold" />
                            Войти
                        </Link>
                    </div>
                </aside>
            </Transition>
        </Teleport>

        <!-- Контент (отступ снизу под нижнюю навигацию на мобильных) -->
        <main class="flex-1 pb-20 md:pb-0">
            <slot />
        </main>

        <!-- Подвал -->
        <footer class="overflow-hidden border-t border-zinc-800 bg-zinc-950 text-zinc-400">
            <div class="mx-auto max-w-7xl px-4 pt-12 sm:px-6 md:pt-16 lg:px-10">
                <div class="grid grid-cols-2 gap-x-6 gap-y-10 lg:grid-cols-4 lg:gap-10">
                    <div class="col-span-2 lg:col-span-1">
                        <div class="flex items-center gap-2.5">
                            <div class="flex size-10 items-center justify-center rounded-xl bg-orange-500 text-zinc-950">
                                <PhDrop :size="22" weight="fill" />
                            </div>
                            <span class="text-xl font-black tracking-tight text-white">Гидровик</span>
                        </div>
                        <p class="mt-4 max-w-xs text-sm leading-6">
                            Промышленное гидравлическое оборудование и комплектующие.
                        </p>
                    </div>

                    <div>
                        <h3 class="text-xs font-bold uppercase tracking-[0.18em] text-white">Каталог</h3>
                        <ul class="mt-4 space-y-3 text-sm">
                            <li><Link :href="route('store.catalog.index')" class="transition hover:text-orange-400">Все товары</Link></li>
                            <li><Link :href="route('store.catalog.index')" class="transition hover:text-orange-400">Производители</Link></li>
                        </ul>
                    </div>

                    <div>
                        <h3 class="text-xs font-bold uppercase tracking-[0.18em] text-white">Информация</h3>
                        <ul class="mt-4 space-y-3 text-sm">
                            <li><Link :href="route('store.pages.delivery')" class="transition hover:text-orange-400">Доставка</Link></li>
                            <li><Link :href="route('store.pages.payment')" class="transition hover:text-orange-400">Оплата</Link></li>
                            <li><Link :href="route('store.pages.returns')" class="transition hover:text-orange-400">Возврат</Link></li>
                            <li><Link :href="route('store.pages.privacy')" class="transition hover:text-orange-400">Персональные данные</Link></li>
                        </ul>
                    </div>

                    <div class="col-span-2 lg:col-span-1">
                        <h3 class="text-xs font-bold uppercase tracking-[0.18em] text-white">Контакты</h3>
                        <ul class="mt-4 space-y-3 text-sm">
                            <li>
                                <a href="tel:+7XXXXXXXXXX" class="flex items-center gap-2.5 transition hover:text-orange-400">
                                    <PhPhone :size="18" weight="fill" class="shrink-0 text-orange-500" />
                                    +7 (XXX) XXX-XX-XX
                                </a>
                            </li>
                            <li class="flex items-start gap-2.5">
                                <PhMapPin :size="18" weight="fill" class="mt-0.5 shrink-0 text-orange-500" />
                                г. Город, ул. Улица
                            </li>
                        </ul>
                    </div>
                </div>

                <div class="mt-12 flex flex-col gap-2 border-t border-zinc-800 pt-6 text-center text-xs text-zinc-500 sm:flex-row sm:justify-between sm:text-left">
                    <span>&copy; {{ new Date().getFullYear() }} Гидровик. Все права защищены.</span>
                    <Link :href="route('store.pages.privacy')" class="transition hover:text-zinc-300">Политика обработки персональных данных</Link>
                </div>

                <div
                    aria-hidden="true"
                    class="pointer-events-none mt-8 select-none text-center text-[16vw] font-black leading-[0.78] tracking-tighter text-white/[0.04] md:text-[11rem]"
                >
                    ГИДРОВИК
                </div>
            </div>
        </footer>

        <!-- Нижняя навигация (только мобильные) -->
        <nav class="fixed inset-x-0 bottom-0 z-40 border-t border-zinc-200 bg-white/90 pb-[env(safe-area-inset-bottom)] backdrop-blur-xl dark:border-zinc-800 dark:bg-zinc-950/90 md:hidden">
            <div class="mx-auto grid h-16 max-w-md grid-cols-4">
                <Link
                    :href="route('store.home')"
                    class="relative flex flex-col items-center justify-center gap-1 text-[11px] font-semibold transition active:scale-95"
                    :class="isActive('store.home') ? 'text-orange-600 dark:text-orange-400' : 'text-zinc-500 dark:text-zinc-400'"
                >
                    <span v-if="isActive('store.home')" class="absolute top-0 h-0.5 w-8 rounded-full bg-orange-500" />
                    <PhHouse :size="23" :weight="isActive('store.home') ? 'fill' : 'regular'" />
                    Главная
                </Link>
                <Link
                    :href="route('store.catalog.index')"
                    class="relative flex flex-col items-center justify-center gap-1 text-[11px] font-semibold transition active:scale-95"
                    :class="isActive('store.catalog.*') ? 'text-orange-600 dark:text-orange-400' : 'text-zinc-500 dark:text-zinc-400'"
                >
                    <span v-if="isActive('store.catalog.*')" class="absolute top-0 h-0.5 w-8 rounded-full bg-orange-500" />
                    <PhSquaresFour :size="23" :weight="isActive('store.catalog.*') ? 'fill' : 'regular'" />
                    Каталог
                </Link>
                <Link
                    :href="route('store.cart.index')"
                    class="relative flex flex-col items-center justify-center gap-1 text-[11px] font-semibold transition active:scale-95"
                    :class="isActive('store.cart.*') ? 'text-orange-600 dark:text-orange-400' : 'text-zinc-500 dark:text-zinc-400'"
                >
                    <span v-if="isActive('store.cart.*')" class="absolute top-0 h-0.5 w-8 rounded-full bg-orange-500" />
                    <span class="relative">
                        <PhShoppingCart :size="23" :weight="isActive('store.cart.*') ? 'fill' : 'regular'" />
                        <span
                            v-if="cartCount > 0"
                            class="absolute -right-2.5 -top-1.5 flex min-w-[18px] items-center justify-center rounded-full bg-orange-500 px-1 text-[10px] font-bold leading-[18px] text-zinc-950 ring-2 ring-white dark:ring-zinc-950"
                        >
                            {{ cartCount }}
                        </span>
                    </span>
                    Корзина
                </Link>
                <Link
                    :href="user ? route('store.orders.index') : login().url"
                    class="relative flex flex-col items-center justify-center gap-1 text-[11px] font-semibold transition active:scale-95"
                    :class="isActive('store.orders.*') ? 'text-orange-600 dark:text-orange-400' : 'text-zinc-500 dark:text-zinc-400'"
                >
                    <span v-if="isActive('store.orders.*')" class="absolute top-0 h-0.5 w-8 rounded-full bg-orange-500" />
                    <PhUser :size="23" :weight="isActive('store.orders.*') ? 'fill' : 'regular'" />
                    {{ user ? 'Заказы' : 'Войти' }}
                </Link>
            </div>
        </nav>

        <Toaster rich-colors close-button position="top-right" />
    </div>
</template>
