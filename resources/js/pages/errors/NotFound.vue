<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    PhArrowRight,
    PhHouse,
    PhMagnifyingGlass,
    PhQuestion,
    PhWarningOctagon,
} from '@phosphor-icons/vue'
</script>

<template>
    <Head title="Страница не найдена" />

    <div class="mx-auto max-w-3xl px-4 py-12 sm:px-6 sm:py-16 lg:px-10 lg:py-20">
        <!-- Ошибка 404 -->
        <header class="relative overflow-hidden rounded-3xl border border-orange-200/70 bg-gradient-to-br from-orange-50 via-white to-zinc-50 p-8 text-center dark:border-orange-500/20 dark:from-orange-500/10 dark:via-zinc-900 dark:to-zinc-800 sm:p-12">
            <div class="pointer-events-none absolute -left-16 -top-16 size-64 rounded-full bg-orange-400/20 blur-3xl dark:bg-orange-500/15" />
            <div class="pointer-events-none absolute -bottom-20 -right-10 size-56 rounded-full bg-zinc-400/20 blur-3xl dark:bg-zinc-500/10" />

            <div class="relative">
                <div class="mx-auto mb-6 flex size-24 items-center justify-center rounded-full bg-orange-500/10 ring-8 ring-orange-500/5">
                    <PhWarningOctagon :size="56" weight="fill" class="text-orange-600 dark:text-orange-400" />
                </div>

                <h1 class="text-3xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-4xl">
                    Страница не найдена
                </h1>

                <p class="mx-auto mt-3 max-w-md text-base text-zinc-600 dark:text-zinc-400 sm:text-lg">
                    Извините, запрашиваемая страница не существует или была перемещена.
                </p>
            </div>
        </header>

        <div class="mx-auto mt-8 max-w-lg space-y-6">
            <!-- Что можно сделать -->
            <section class="rounded-3xl border border-zinc-200 bg-white p-6 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                <h2 class="flex items-center gap-2 text-lg font-extrabold text-zinc-950 dark:text-white">
                    <PhQuestion :size="20" weight="duotone" class="text-orange-500" />
                    Что можно сделать?
                </h2>

                <ul class="mt-4 space-y-3 text-sm text-zinc-700 dark:text-zinc-300">
                    <li class="flex items-start gap-3">
                        <PhHouse :size="18" weight="duotone" class="mt-0.5 shrink-0 text-orange-500" />
                        <span>Вернитесь на <a :href="route('store.home')" class="font-semibold text-orange-600 hover:underline dark:text-orange-400">главную страницу</a></span>
                    </li>

                    <li class="flex items-start gap-3">
                        <PhMagnifyingGlass :size="18" weight="duotone" class="mt-0.5 shrink-0 text-orange-500" />
                        <span>Воспользуйтесь <a :href="route('store.catalog.index')" class="font-semibold text-orange-600 hover:underline dark:text-orange-400">каталогом товаров</a></span>
                    </li>

                    <li class="flex items-start gap-3">
                        <PhArrowRight :size="18" weight="duotone" class="mt-0.5 shrink-0 text-orange-500" />
                        <span>Проверьте правильность введённого адреса</span>
                    </li>
                </ul>
            </section>

            <!-- Кнопки действий -->
            <div class="flex flex-col gap-3">
                <a
                    :href="route('store.home')"
                    class="inline-flex h-13 items-center justify-center gap-2 rounded-full bg-orange-500 px-8 py-3.5 text-sm font-bold text-zinc-950 shadow-lg shadow-orange-500/30 transition hover:-translate-y-0.5 hover:bg-orange-400 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-orange-500/30"
                >
                    <PhHouse :size="18" weight="duotone" />
                    На главную
                </a>

                <a
                    :href="route('store.catalog.index')"
                    class="inline-flex items-center justify-center gap-2 rounded-full border border-zinc-200 bg-white px-6 py-3 text-sm font-bold text-zinc-700 shadow-sm transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
                >
                    <PhMagnifyingGlass :size="18" weight="duotone" />
                    Перейти в каталог
                </a>
            </div>
        </div>
    </div>
</template>
