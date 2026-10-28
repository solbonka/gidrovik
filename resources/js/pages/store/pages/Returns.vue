<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    PhCaretLeft,
    PhArrowCounterClockwise,
    PhCheckCircle,
    PhClockCounterClockwise,
    PhPackage,
} from '@phosphor-icons/vue'
</script>

<template>
    <Head title="Возврат" />

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
                <h1 class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-3xl">Возврат</h1>
            </div>
        </div>

        <div class="space-y-6">
            <!-- Card -->
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-start gap-4">
                    <div class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-orange-500/10 text-orange-600 dark:text-orange-400">
                        <PhArrowCounterClockwise :size="24" weight="duotone" />
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Условия возврата</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            Вы можете вернуть товар в течение 14 дней с момента получения, если он не был в использовании и сохранены его товарный вид, упаковка и документы.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Card -->
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-start gap-4">
                    <div class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-orange-500/10 text-orange-600 dark:text-orange-400">
                        <PhPackageSearch :size="24" weight="duotone" />
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Порядок возврата</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            Для оформления возврата свяжитесь с нами по телефону или электронной почте. Мы предоставим адрес для отправки товара и инструкцию по оформлению.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Card -->
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-start gap-4">
                    <div class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-orange-500/10 text-orange-600 dark:text-orange-400">
                        <PhClockCounterClockwise :size="24" weight="duotone" />
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Сроки возврата средств</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            Возврат средств осуществляется в течение 7 рабочих дней после получения и проверки возвращённого товара. Деньги возвращаются тем же способом, которым была произведена оплата.
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
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Гарантия качества</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            Мы гарантируем качество всей продукции. Если вы обнаружили брак, свяжитесь с нами — мы заменим товар или вернём деньги.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
