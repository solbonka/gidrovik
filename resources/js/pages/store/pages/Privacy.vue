<script setup lang="ts">
defineProps<{ content: string }>()
</script>
<template>
    <div class="mx-auto max-w-3xl px-5 py-8 lg:px-10">
        <h1 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">Обработка персональных данных</h1>
        <div v-html="content" class="prose prose-slate mt-6 max-w-none" />
    </div>
</template>
