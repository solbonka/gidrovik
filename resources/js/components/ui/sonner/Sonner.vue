<script lang="ts" setup>
import type { ToasterProps } from "vue-sonner"
import { CircleCheckIcon, InfoIcon, Loader2Icon, OctagonXIcon, TriangleAlertIcon, XIcon } from "@lucide/vue"
import { Toaster as Sonner } from "vue-sonner"
import { cn } from "@/lib/utils"

import 'vue-sonner/style.css';

const props = defineProps<ToasterProps>()
</script>

<template>
  <Sonner
    :class="cn('toaster group', props.class)"
    :style="{
        '--normal-bg': 'var(--popover)',
        '--normal-text': 'var(--popover-foreground)',
        '--normal-border': 'var(--border)',
        '--border-radius': 'var(--radius)',

        '--success-bg': '#f0fdf4',
        '--success-text': '#166534',
        '--success-border': '#86efac',

        '--error-bg': '#fef2f2',
        '--error-text': '#991b1b',
        '--error-border': '#fca5a5',
    }"
    v-bind="props"
  >
    <template #success-icon>
      <CircleCheckIcon class="size-4" />
    </template>
    <template #info-icon>
      <InfoIcon class="size-4" />
    </template>
    <template #warning-icon>
      <TriangleAlertIcon class="size-4" />
    </template>
    <template #error-icon>
      <OctagonXIcon class="size-4" />
    </template>
    <template #loading-icon>
      <div>
        <Loader2Icon class="size-4 animate-spin" />
      </div>
    </template>
    <template #close-icon>
      <XIcon class="size-4" />
    </template>
  </Sonner>
</template>

<style>
.toaster [data-sonner-toast][data-type='success'] {
    background: #f0fdf4 !important;
    border: 1px solid #86efac !important;
    color: #166534 !important;
}

.toaster [data-sonner-toast][data-type='success'] svg {
    color: #15803d !important;
}

.toaster [data-sonner-toast][data-type='error'] {
    background: #fef2f2 !important;
    border: 1px solid #fca5a5 !important;
    color: #991b1b !important;
}

.toaster [data-sonner-toast][data-type='error'] svg {
    color: #b91c1c !important;
}
</style>
