<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    PhCaretLeft,
    PhTruck,
    PhClock,
    PhPackage,
    PhCheckCircle,
} from '@phosphor-icons/vue'
</script>

<template>
    <Head title="Доставка" />

    <div class="mx-auto max-w-4xl px-4 py-8 sm:px-6 lg:px-10 lg:py-12">
        <!-- Header -->
        <div class="mb-8 flex items-center gap-4">
            <a
                href="javascript:history.back()"
                class="flex size-10 items-center justify-center rounded-full border border-zinc-200 bg-white text-zinc-600 transition hover:border-orange-400 hover:text-orange-600 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-300 dark:hover:border-orange-500 dark:hover:text-orange-400"
            >
                <PhCaretLeft :size="20" weight="bold" />
            </a>
            <div>
                <p class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400">Информация</p>
                <h1 class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-3xl">Доставка</h1>
            </div>
        </div>

        <div class="space-y-6">
            <!-- Card -->
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-start gap-4">
                    <div class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-orange-500/10 text-orange-600 dark:text-orange-400">
                        <PhTruck :size="24" weight="duotone" />
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Доставка по России</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            Отправляем заказы транспортными компаниями по всей России. Доставка занимает от 1 до 7 рабочих дней в зависимости от региона.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Card -->
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-start gap-4">
                    <div class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-orange-500/10 text-orange-600 dark:text-orange-400">
                        <PhClock :size="24" weight="duotone" />
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Сроки обработки</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            Заказ обрабатывается в течение 1-2 рабочих дней после подтверждения. Отправка осуществляется в ближайший день доставки транспортной компании.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Card -->
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-start gap-4">
                    <div class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-orange-500/10 text-orange-600 dark:text-orange-400">
                        <PhPackage :size="24" weight="duotone" />
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Тарифы доставки</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            Стоимость доставки рассчитывается индивидуально в зависимости от веса, габаритов груза и адреса доставки. Точную стоимость вы можете узнать у менеджера.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Card -->
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-start gap-4">
                    <div class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
                        <PhCheckCircle :size="24" weight="duotone" />
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Бесплатная доставка</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            При заказе на сумму от 50 000 ₽ доставка осуществляется бесплатно по всей территории России.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
