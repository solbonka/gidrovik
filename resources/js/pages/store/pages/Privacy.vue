<script setup lang="ts">
import { Head } from '@inertiajs/vue3'
import {
    PhCaretLeft,
    PhShieldCheck,
    PhLock,
    PhUser,
    PhDatabase,
} from '@phosphor-icons/vue'
</script>

<template>
    <Head title="Политика конфиденциальности" />

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
                <p class="text-xs font-bold uppercase tracking-[0.2em] text-orange-600 dark:text-orange-400">Документы</p>
                <h1 class="text-2xl font-black tracking-tight text-zinc-950 dark:text-white sm:text-3xl">Политика конфиденциальности</h1>
            </div>
        </div>

        <div class="space-y-6">
            <!-- Card -->
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-start gap-4">
                    <div class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-orange-500/10 text-orange-600 dark:text-orange-400">
                        <PhShieldCheck :size="24" weight="duotone" />
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Общие положения</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            Мы серьёзно относимся к защите ваших персональных данных. Настоящая политика описывает, как мы собираем, используем и защищаем информацию, которую вы предоставляете при использовании нашего сайта.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Card -->
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-start gap-4">
                    <div class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-orange-500/10 text-orange-600 dark:text-orange-400">
                        <PhUser :size="24" weight="duotone" />
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Собираемые данные</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            Мы можем собирать следующие персональные данные: имя, адрес электронной почты, номер телефона, адрес доставки. Эти данные необходимы для обработки вашего заказа и связи с вами.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Card -->
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-start gap-4">
                    <div class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-orange-500/10 text-orange-600 dark:text-orange-400">
                        <PhDatabase :size="24" weight="duotone" />
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Использование данных</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            Ваши данные используются для: обработки и доставки заказов, связи с вами по вопросам заказа, улучшения качества обслуживания, отправки уведомлений о статусе заказа.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Card -->
            <div class="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div class="flex items-start gap-4">
                    <div class="flex size-12 shrink-0 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
                        <PhLock :size="24" weight="duotone" />
                    </div>
                    <div>
                        <h2 class="text-lg font-bold text-zinc-950 dark:text-white">Защита данных</h2>
                        <p class="mt-2 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                            Мы принимаем все необходимые технические и организационные меры для защиты ваших персональных данных от несанкционированного доступа, изменения, раскрытия или уничтожения.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
