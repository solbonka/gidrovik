<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3'
import {
    ArrowRight,
    Boxes,
    Check,
    MapPin,
    Warehouse,
} from '@lucide/vue'

import { login, register } from '@/routes'
import { Button } from '@/components/ui/button'

const year = new Date().getFullYear()
</script>

<template>
    <Head title="Гидровик — система складского учёта" />

    <div class="min-h-screen bg-white text-slate-900">
        <!-- Header -->
        <header class="border-b border-slate-200 bg-white/90 backdrop-blur">
            <div class="mx-auto flex h-16 max-w-7xl items-center justify-between px-5 lg:px-10">
                <div class="flex items-center gap-2.5">
                    <div class="flex size-9 items-center justify-center rounded-lg bg-emerald-600 text-white">
                        <Warehouse :size="18" />
                    </div>
                    <div>
                        <div class="text-[17px] font-extrabold text-slate-900">Гидровик</div>
                        <div class="text-[8px] font-bold uppercase tracking-[0.18em] text-slate-400">складской учёт</div>
                    </div>
                </div>

                <div class="flex items-center gap-2">
                    <Button variant="ghost" as-child class="text-slate-600 hover:text-emerald-700">
                        <Link :href="login().url">Войти</Link>
                    </Button>
                    <Button as-child class="rounded-xl bg-emerald-600 text-white hover:bg-emerald-700">
                        <Link :href="register().url">
                            Начать
                            <ArrowRight :size="16" class="ml-1.5" />
                        </Link>
                    </Button>
                </div>
            </div>
        </header>

        <main>
            <!-- Hero -->
            <section class="mx-auto max-w-7xl px-5 py-20 sm:py-28 lg:px-10">
                <div class="mx-auto max-w-3xl text-center">
                    <h1 class="text-3xl font-extrabold tracking-tight text-slate-950 sm:text-4xl lg:text-5xl">
                        Система складского учёта
                        <br />
                        <span class="text-emerald-600">Гидровик</span>
                    </h1>

                    <p class="mt-5 text-base leading-7 text-slate-500 sm:text-lg">
                        Управляйте товарами, остатками и складскими операциями в одном месте.
                        Простой и надёжный инструмент для вашего бизнеса.
                    </p>

                    <div class="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
                        <Button
                            as-child
                            size="lg"
                            class="rounded-xl bg-emerald-600 px-8 text-base font-semibold text-white shadow-lg shadow-emerald-600/20 hover:bg-emerald-700"
                        >
                            <Link :href="register().url">
                                Создать аккаунт
                                <ArrowRight :size="18" class="ml-2" />
                            </Link>
                        </Button>

                        <Button
                            as-child
                            variant="outline"
                            size="lg"
                            class="rounded-xl border-slate-300 px-8 text-base font-semibold text-slate-700 hover:border-emerald-300 hover:bg-emerald-50"
                        >
                            <Link :href="login().url">Уже есть аккаунт</Link>
                        </Button>
                    </div>

                    <ul class="mt-8 flex flex-wrap items-center justify-center gap-x-5 gap-y-3 text-sm text-slate-500">
                        <li class="flex items-center gap-2">
                            <Check :size="14" class="text-emerald-600" />
                            Каталог товаров
                        </li>
                        <li class="flex items-center gap-2">
                            <Check :size="14" class="text-emerald-600" />
                            Адресное хранение
                        </li>
                        <li class="flex items-center gap-2">
                            <Check :size="14" class="text-emerald-600" />
                            Складские операции
                        </li>
                    </ul>
                </div>

                <!-- Feature grid -->
                <div class="mt-20 grid gap-5 sm:grid-cols-3">
                    <div class="rounded-2xl border border-slate-200 bg-white p-6 text-center">
                        <div class="mx-auto flex size-12 items-center justify-center rounded-xl bg-emerald-50 text-emerald-700">
                            <Boxes :size="22" />
                        </div>
                        <h3 class="mt-4 font-bold text-slate-900">Каталог</h3>
                        <p class="mt-2 text-sm text-slate-500">Товары, категории, характеристики и производители</p>
                    </div>

                    <div class="rounded-2xl border border-slate-200 bg-white p-6 text-center">
                        <div class="mx-auto flex size-12 items-center justify-center rounded-xl bg-sky-50 text-sky-700">
                            <MapPin :size="22" />
                        </div>
                        <h3 class="mt-4 font-bold text-slate-900">Хранение</h3>
                        <p class="mt-2 text-sm text-slate-500">Стеллажи, места и адресное хранение товаров</p>
                    </div>

                    <div class="rounded-2xl border border-slate-200 bg-white p-6 text-center">
                        <div class="mx-auto flex size-12 items-center justify-center rounded-xl bg-violet-50 text-violet-700">
                            <Warehouse :size="22" />
                        </div>
                        <h3 class="mt-4 font-bold text-slate-900">Операции</h3>
                        <p class="mt-2 text-sm text-slate-500">Приход, перемещение, списание и инвентаризация</p>
                    </div>
                </div>
            </section>
        </main>

        <footer class="border-t border-slate-200">
            <div class="mx-auto max-w-7xl px-5 py-8 lg:px-10">
                <p class="text-center text-xs text-slate-400">
                    &copy; {{ year }} Гидровик · Система управления складскими запасами
                </p>
            </div>
        </footer>
    </div>
</template>
