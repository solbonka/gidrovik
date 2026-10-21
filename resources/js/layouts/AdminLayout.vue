
<script setup lang="ts">
import AdminBreadcrumbs from '@/components/admin/AdminBreadcrumbs.vue';
import AdminHeader from '@/components/admin/AdminHeader.vue';
import AdminSidebar from '@/components/admin/AdminSidebar.vue';
import { Toaster } from '@/components/ui/sonner';
import { usePage } from '@inertiajs/vue3';
import { ref, watch } from 'vue';
import { toast } from 'vue-sonner';

const sidebarOpen = ref<boolean>(false);

const page = usePage();

const toggleSidebar = (): void => {
    sidebarOpen.value = !sidebarOpen.value;
};

watch(
    () =>
        page.props.flash as
            | { success?: string | null; error?: string | null }
            | undefined,
    (flash) => {
        if (!flash) {
            return;
        }

        if (flash.error) {
            toast.error(flash.error);

            return;
        }

        if (flash.success) {
            toast.success(flash.success);
        }
    },
    { immediate: true },
);
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
            rich-colors
            close-button
            position="top-right"
        />
    </div>
</template>
