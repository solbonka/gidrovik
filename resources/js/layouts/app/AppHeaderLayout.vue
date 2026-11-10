<script setup lang="ts">
import AppContent from '@/components/AppContent.vue';
import AppHeader from '@/components/AppHeader.vue';
import AppShell from '@/components/AppShell.vue';
import { Toaster } from '@/components/ui/sonner';
import type { BreadcrumbItem } from '@/types';
import { onMounted, ref } from 'vue';

const isClient = ref(false);

onMounted(() => {
    isClient.value = true;
});

type Props = {
    breadcrumbs?: BreadcrumbItem[];
};

withDefaults(defineProps<Props>(), {
    breadcrumbs: () => [],
});
</script>

<template>
    <AppShell variant="header">
        <AppHeader :breadcrumbs="breadcrumbs" />
        <AppContent variant="header" class="px-3 py-4 sm:px-6 sm:py-6 lg:px-8">
            <slot />
        </AppContent>
        <Toaster v-if="isClient" rich-colors close-button position="top-right" />
    </AppShell>
</template>
