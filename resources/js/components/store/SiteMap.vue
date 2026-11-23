<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
    query: string
    latitude?: number | string | null
    longitude?: number | string | null
}>()

const src = computed(() => {
    const params: Record<string, string> = { l: 'map' }
    const lat = props.latitude
    const lng = props.longitude

    if (lat !== null && lat !== undefined && lat !== '' && lng !== null && lng !== undefined && lng !== '') {
        params.ll = `${lng},${lat}`
        params.pt = `${lng},${lat}`
        params.z = '17'
    } else {
        params.text = props.query
        params.z = '16'
    }

    return `https://yandex.ru/map-widget/v1/?${new URLSearchParams(params).toString()}`
})
</script>

<template>
    <iframe
        :src="src"
        title="Яндекс Карта"
        class="h-full w-full border-0"
        loading="lazy"
        allowfullscreen
    />
</template>
