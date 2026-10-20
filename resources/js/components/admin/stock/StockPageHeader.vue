<script setup lang="ts">
import { Link } from '@inertiajs/vue3';
import type { Component } from 'vue';
import { ArrowLeft } from '@lucide/vue';

withDefaults(
    defineProps<{
        title: string;
        description: string;
        backHref: string;
        backLabel: string;
        icon: Component;
        tone?: 'default' | 'danger';
    }>(),
    { tone: 'default' },
);
</script>

<template>
    <header>
        <Link
            :href="backHref"
            class="mb-4 inline-flex items-center gap-2 text-sm font-medium text-muted-foreground transition-colors hover:text-primary"
        >
            <ArrowLeft :size="16" />
            {{ backLabel }}
        </Link>

        <div class="flex items-center gap-4">
            <div
                class="flex size-12 shrink-0 items-center justify-center rounded-2xl text-white shadow-sm"
                :class="
                    tone === 'danger'
                        ? 'bg-rose-600'
                        : 'bg-primary text-primary-foreground'
                "
            >
                <component :is="icon" :size="24" />
            </div>

            <div>
                <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                    {{ title }}
                </h1>
                <p class="mt-1 text-sm text-muted-foreground">
                    {{ description }}
                </p>
            </div>
        </div>
    </header>
</template>
