<script setup lang="ts">
import { PhMapPin, PhX } from '@phosphor-icons/vue'
import { Transition, Teleport } from 'vue'
import SiteMap from './SiteMap.vue'

defineProps<{
    open: boolean
    query: string
    address?: string | null
    latitude?: number | string | null
    longitude?: number | string | null
}>()

const emit = defineEmits<{
    close: []
}>()
</script>

<template>
    <Teleport to="body">
        <Transition
            enter-active-class="duration-200 ease-out"
            enter-from-class="opacity-0"
            enter-to-class="opacity-100"
            leave-active-class="duration-150 ease-in"
            leave-from-class="opacity-100"
            leave-to-class="opacity-0"
        >
            <div
                v-if="open"
                class="fixed inset-0 z-[100] flex items-center justify-center bg-zinc-950/70 p-4 backdrop-blur-sm"
                role="dialog"
                aria-modal="true"
                @click.self="emit('close')"
                @keydown.esc="emit('close')"
            >
                <div class="flex max-h-[90vh] w-full max-w-3xl flex-col overflow-hidden rounded-2xl bg-white shadow-2xl dark:bg-zinc-900">
                    <div class="flex items-start justify-between gap-4 border-b border-zinc-200 px-5 py-4 dark:border-zinc-800">
                        <div>
                            <h3 class="text-base font-extrabold tracking-tight text-zinc-900 dark:text-white">Как нас найти</h3>
                            <p v-if="address" class="mt-1 flex items-center gap-1.5 text-sm text-zinc-500 dark:text-zinc-400">
                                <PhMapPin :size="15" weight="fill" class="shrink-0 text-orange-500" />
                                {{ address }}
                            </p>
                        </div>
                        <button
                            type="button"
                            class="flex size-9 shrink-0 items-center justify-center rounded-full text-zinc-500 transition hover:bg-zinc-100 hover:text-zinc-900 dark:hover:bg-zinc-800 dark:hover:text-white"
                            aria-label="Закрыть"
                            @click="emit('close')"
                        >
                            <PhX :size="20" weight="bold" />
                        </button>
                    </div>

                    <div class="h-[55vh] min-h-[300px] w-full">
                        <SiteMap :query="query" :latitude="latitude" :longitude="longitude" />
                    </div>
                </div>
            </div>
        </Transition>
    </Teleport>
</template>
