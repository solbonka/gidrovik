<script setup lang="ts">
import AdminHeader from '@/components/admin/AdminHeader.vue'
import AdminSidebar from '@/components/admin/AdminSidebar.vue'
import { ref } from 'vue'

const sidebarOpen = ref<boolean>(false)

const toggleSidebar = (): void => {
    sidebarOpen.value = !sidebarOpen.value
}
</script>

<template>
    <div class="min-h-screen bg-gray-100">
        <AdminSidebar
            :open="sidebarOpen"
            @close="sidebarOpen = false"
        />

        <div class="lg:pl-64">
            <AdminHeader @toggle-sidebar="toggleSidebar" />

            <main class="p-4 sm:p-6 lg:p-8">
                <slot />
            </main>
        </div>
    </div>
</template>
