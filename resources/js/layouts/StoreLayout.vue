<script setup lang="ts">
import { Head, Link, router, usePage } from '@inertiajs/vue3'
import {
    ArrowRight,
    Boxes,
    ChevronDown,
    LogIn,
    LogOut,
    Menu,
    Package,
    Phone,
    Search,
    ShoppingCart,
    User,
    X,
} from '@lucide/vue'
import { computed, onMounted, ref, watch } from 'vue'

import { login, logout } from '@/routes'
import { dashboard } from '@/routes/admin'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

const props = defineProps<{
    title?: string
    cartCount?: number
}>()

const page = usePage()
const cartCount = computed(() => props.cartCount ?? 0)

// Check if user is an employee (has is_employee flag)
const isEmployee = computed(() => page.props.auth.user?.is_employee === true)

// Mobile menu
const mobileMenuOpen = ref(false)

// Header search
const searchQuery = ref('')

function performSearch() {
    const q = searchQuery.value.trim()
    if (q) {
        router.get(route('store.search.index'), { q })
        mobileMenuOpen.value = false
    }
}

// Close mobile menu on route change
watch(() => page.url, () => {
    mobileMenuOpen.value = false
})

onMounted(() => {
    // Close mobile menu on escape
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') mobileMenuOpen.value = false
    })
})
</script>

<template>
    <div class="min-h-screen flex flex-col bg-white text-slate-900">
        <Head :title="title" />

        <!-- Top bar -->
        <div class="hidden border-b border-slate-100 bg-slate-50 sm:block">
            <div class="mx-auto flex h-9 max-w-7xl items-center justify-between px-5 lg:px-10">
                <div class="flex items-center gap-4 text-xs text-slate-500">
                    <span class="flex items-center gap-1.5">
                        <Phone :size="12" />
                        +7 (XXX) XXX-XX-XX
                    </span>
                </div>
                <div class="flex items-center gap-4 text-xs text-slate-500">
                    <Link :href="route('store.pages.delivery')" class="hover:text-emerald-700">Доставка</Link>
                    <span class="text-slate-300">|</span>
                    <Link :href="route('store.pages.payment')" class="hover:text-emerald-700">Оплата</Link>
                    <span class="text-slate-300">|</span>
                    <Link :href="route('store.pages.returns')" class="hover:text-emerald-700">Возврат</Link>
                </div>
            </div>
        </div>

        <!-- Main header -->
        <header class="sticky top-0 z-40 border-b border-slate-200 bg-white/95 backdrop-blur">
            <div class="mx-auto flex h-16 max-w-7xl items-center gap-4 px-5 lg:px-10">
                <!-- Mobile menu button -->
                <Button
                    variant="ghost"
                    size="icon"
                    class="md:hidden"
                    @click="mobileMenuOpen = !mobileMenuOpen"
                >
                    <Menu v-if="!mobileMenuOpen" :size="20" />
                    <X v-else :size="20" />
                </Button>

                <!-- Logo -->
                <Link :href="route('store.home')" class="flex shrink-0 items-center gap-2.5">
                    <div class="flex size-9 items-center justify-center rounded-lg bg-emerald-600 text-white">
                        <Package :size="18" :stroke-width="2" />
                    </div>
                    <div class="hidden sm:block">
                        <div class="text-[17px] font-extrabold leading-tight text-slate-900">Гидровик</div>
                        <div class="text-[8px] font-bold uppercase tracking-[0.18em] text-slate-400">интернет-магазин</div>
                    </div>
                </Link>

                <!-- Catalog button -->
                <Link :href="route('store.catalog.index')" class="hidden shrink-0 md:block">
                    <Button variant="outline" class="gap-2 border-emerald-200 bg-emerald-50 text-emerald-700 hover:bg-emerald-100">
                        <Boxes :size="16" />
                        Каталог
                        <ChevronDown :size="14" class="ml-1" />
                    </Button>
                </Link>

                <!-- Search -->
                <form @submit.prevent="performSearch" class="flex flex-1 items-center">
                    <div class="relative w-full">
                        <Input
                            v-model="searchQuery"
                            type="text"
                            placeholder="Поиск по названию или артикулу"
                            class="h-10 rounded-xl border-slate-200 bg-slate-50 pr-10 focus:border-emerald-400 focus:bg-white focus:ring-emerald-400"
                        />
                        <button type="submit" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-emerald-600">
                            <Search :size="16" />
                        </button>
                    </div>
                </form>

                <!-- Actions -->
                <div class="flex shrink-0 items-center gap-1">
                    <!-- Admin panel link (visible for employees) -->
                    <Link
                        v-if="$page.props.auth.user && isEmployee"
                        :href="dashboard().url"
                        class="hidden sm:flex"
                    >
                        <Button variant="outline" size="sm" class="gap-1.5 border-slate-200 bg-slate-50 text-slate-600 hover:bg-slate-100 hover:text-slate-900">
                            <Boxes :size="16" />
                            <span class="hidden lg:inline">Админ</span>
                        </Button>
                    </Link>

                    <Link :href="route('store.cart.index')" class="relative hidden sm:flex">
                        <Button variant="ghost" size="icon" class="relative">
                            <ShoppingCart :size="20" />
                            <span
                                v-if="cartCount > 0"
                                class="absolute -right-1 -top-1 flex size-5 items-center justify-center rounded-full bg-emerald-600 text-[10px] font-bold text-white"
                            >
                                {{ cartCount }}
                            </span>
                        </Button>
                    </Link>

                    <Link
                        v-if="!$page.props.auth.user"
                        :href="login().url"
                    >
                        <Button variant="ghost" size="sm" class="gap-1.5">
                            <LogIn :size="16" />
                            <span class="hidden sm:inline">Войти</span>
                        </Button>
                    </Link>

                    <Link
                        v-if="$page.props.auth.user"
                        :href="route('store.orders.index')"
                    >
                        <Button variant="ghost" size="sm" class="gap-1.5">
                            <User :size="16" />
                            <span class="hidden sm:inline">Заказы</span>
                        </Button>
                    </Link>

                    <button
                        v-if="$page.props.auth.user"
                        @click="router.post(logout().url)"
                        class="flex items-center gap-1.5 rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm font-medium text-slate-600 transition hover:bg-slate-50"
                    >
                        <LogOut :size="16" />
                        <span class="hidden sm:inline">Выйти</span>
                    </button>
                </div>
            </div>

            <!-- Mobile menu -->
            <div
                v-if="mobileMenuOpen"
                class="border-t border-slate-100 md:hidden"
            >
                <div class="space-y-1 px-4 py-3">
                    <Link
                        :href="route('store.catalog.index')"
                        class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
                        @click="mobileMenuOpen = false"
                    >
                        <Boxes :size="18" />
                        Каталог
                    </Link>
                    <Link
                        :href="route('store.cart.index')"
                        class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
                        @click="mobileMenuOpen = false"
                    >
                        <ShoppingCart :size="18" />
                        Корзина
                        <span v-if="cartCount > 0" class="ml-auto rounded-full bg-emerald-600 px-2 py-0.5 text-[10px] font-bold text-white">
                            {{ cartCount }}
                        </span>
                    </Link>
                    <Link
                        v-if="!$page.props.auth.user"
                        :href="login().url"
                        class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
                        @click="mobileMenuOpen = false"
                    >
                        <LogIn :size="18" />
                        Войти
                    </Link>
                    <Link
                        v-else
                        :href="route('store.orders.index')"
                        class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
                        @click="mobileMenuOpen = false"
                    >
                        <User :size="18" />
                        Мои заказы
                    </Link>
                    <button
                        v-if="$page.props.auth.user"
                        @click="() => { mobileMenuOpen = false; router.post(logout().url) }"
                        class="flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
                    >
                        <LogOut :size="18" />
                        Выйти
                    </button>
                </div>
            </div>
        </header>

        <!-- Main content -->
        <main class="flex-1">
            <slot />
        </main>

        <!-- Footer -->
        <footer class="border-t border-slate-200 bg-slate-50">
            <div class="mx-auto max-w-7xl px-5 py-12 lg:px-10">
                <div class="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
                    <!-- About -->
                    <div>
                        <div class="flex items-center gap-2.5">
                            <div class="flex size-8 items-center justify-center rounded-lg bg-emerald-600 text-white">
                                <Package :size="16" :stroke-width="2" />
                            </div>
                            <span class="text-sm font-extrabold text-slate-900">Гидровик</span>
                        </div>
                        <p class="mt-3 text-sm leading-6 text-slate-500">
                            Промышленное гидравлическое оборудование и комплектующие.
                        </p>
                    </div>

                    <!-- Catalog -->
                    <div>
                        <h3 class="text-sm font-bold text-slate-900">Каталог</h3>
                        <ul class="mt-3 space-y-2 text-sm text-slate-600">
                            <li><Link :href="route('store.catalog.index')" class="hover:text-emerald-700">Все товары</Link></li>
                            <li><Link :href="route('store.catalog.index')" class="hover:text-emerald-700">Производители</Link></li>
                        </ul>
                    </div>

                    <!-- Information -->
                    <div>
                        <h3 class="text-sm font-bold text-slate-900">Информация</h3>
                        <ul class="mt-3 space-y-2 text-sm text-slate-600">
                            <li><Link :href="route('store.pages.delivery')" class="hover:text-emerald-700">Доставка</Link></li>
                            <li><Link :href="route('store.pages.payment')" class="hover:text-emerald-700">Оплата</Link></li>
                            <li><Link :href="route('store.pages.returns')" class="hover:text-emerald-700">Возврат</Link></li>
                            <li><Link :href="route('store.pages.privacy')" class="hover:text-emerald-700">Персональные данные</Link></li>
                        </ul>
                    </div>

                    <!-- Contacts -->
                    <div>
                        <h3 class="text-sm font-bold text-slate-900">Контакты</h3>
                        <ul class="mt-3 space-y-2 text-sm text-slate-600">
                            <li class="flex items-center gap-2">
                                <Phone :size="14" />
                                +7 (XXX) XXX-XX-XX
                            </li>
                            <li class="flex items-center gap-2">
                                <svg :size="14" class="text-slate-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>
                                г. Город, ул. Улица
                            </li>
                        </ul>
                    </div>
                </div>

                <div class="mt-10 border-t border-slate-200 pt-6 text-center text-xs text-slate-400">
                    &copy; {{ new Date().getFullYear() }} Гидровик. Все права защищены.
                </div>
            </div>
        </footer>
    </div>
</template>
