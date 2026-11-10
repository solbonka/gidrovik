
<script setup lang="ts">
import AdminBreadcrumbs from '@/components/admin/AdminBreadcrumbs.vue';
import AdminHeader from '@/components/admin/AdminHeader.vue';
import AdminSidebar from '@/components/admin/AdminSidebar.vue';
import { Toaster } from '@/components/ui/sonner';
import { usePage } from '@inertiajs/vue3';
import { onMounted, ref } from 'vue';

const sidebarOpen = ref<boolean>(false);
const isClient = ref(false);

onMounted(() => {
    isClient.value = true;
});

const page = usePage();

const toggleSidebar = (): void => {
    sidebarOpen.value = !sidebarOpen.value;
};
</script>

<template>
    <div class="min-h-screen bg-background text-foreground">
        <AdminSidebar
            :open="sidebarOpen"
            @close="sidebarOpen = false"
        />

        <div class="min-h-screen lg:pl-64">
            <AdminHeader @toggle-sidebar="toggleSidebar" />

            <main class="px-3 py-4 sm:px-6 sm:py-6 lg:px-8">
                <div class="mx-auto w-full max-w-7xl space-y-6">
                    <AdminBreadcrumbs />

                    <slot />
                </div>
            </main>
        </div>

        <Toaster
            v-if="isClient"
            rich-colors
            close-button
            position="top-right"
        />
    </div>
</template>
