<script setup lang="ts">
import AdminHeader from '@/components/admin/AdminHeader.vue'
import AdminSidebar from '@/components/admin/AdminSidebar.vue'
import { Toaster } from '@/components/ui/sonner'
import { ref } from 'vue'

const sidebarOpen = ref<boolean>(false)

const toggleSidebar = (): void => {
    sidebarOpen.value = !sidebarOpen.value
}
</script>

<template>
    <div class="min-h-screen bg-background">
        <AdminSidebar
            :open="sidebarOpen"
            @close="sidebarOpen = false"
        />

        <div class="lg:pl-64">
            <AdminHeader @toggle-sidebar="toggleSidebar" />

            <main class="px-3 py-4 sm:px-6 sm:py-6 lg:px-8">
                <div class="mx-auto w-full max-w-7xl space-y-6">
                    <slot />
                </div>
            </main>
        </div>

        <Toaster rich-colors close-button position="top-right" />
    </div>
</template>
