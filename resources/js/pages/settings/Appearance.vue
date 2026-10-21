<script setup lang="ts">
import { Head } from '@inertiajs/vue3';
import AppearanceTabs from '@/components/AppearanceTabs.vue';
import Heading from '@/components/Heading.vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { edit } from '@/routes/appearance';

defineOptions({
    layout: AdminLayout,
});
</script>

<template>
    <Head title="Настройки оформления" />

    <div class="space-y-6">
        <Heading
            variant="small"
            title="Оформление"
            description="Выберите светлую, тёмную или системную тему интерфейса"
        />

        <AppearanceTabs />
    </div>
</template>
