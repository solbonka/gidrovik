<script lang="ts" setup>
import type { ToasterProps } from "vue-sonner"
import { PhCheck, PhInfo, PhSpinner, PhWarning, PhX } from "@phosphor-icons/vue"
import { Toaster as Sonner } from "vue-sonner"
import { cn } from "@/lib/utils"

import 'vue-sonner/style.css';

interface CustomToasterProps extends ToasterProps {
    theme?: 'light' | 'dark' | 'system'
    position?: 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right'
    gap?: number
    visibleToasts?: number
}

const props = defineProps<CustomToasterProps>()
</script>

<template>
    <!-- Тосты всегда тёмные: на светлом сайте это контрастный акцент, на тёмном — родная поверхность -->
    <Sonner
        :class="cn('toaster group', props.class)"
        :theme="props.theme ?? 'dark'"
        :position="props.position ?? 'top-right'"
        :gap="props.gap ?? 10"
        :visible-toasts="props.visibleToasts ?? 4"
    >
        <template #success-icon>
            <span class="toast-icon toast-icon--success"><PhCheck :size="16" weight="bold" /></span>
        </template>
        <template #error-icon>
            <span class="toast-icon toast-icon--error"><PhX :size="16" weight="bold" /></span>
        </template>
        <template #warning-icon>
            <span class="toast-icon toast-icon--warning"><PhWarning :size="16" weight="fill" /></span>
        </template>
        <template #info-icon>
            <span class="toast-icon toast-icon--info"><PhInfo :size="16" weight="fill" /></span>
        </template>
        <template #loading-icon>
            <span class="toast-icon toast-icon--loading"><PhSpinner :size="16" weight="bold" class="animate-spin" /></span>
        </template>
        <template #close-icon>
            <PhX :size="12" weight="bold" />
        </template>
    </Sonner>
</template>

<style>
/* =========================================================
   Тосты: тёмное стекло + свечение цвета типа у иконки
   ========================================================= */
.toaster [data-sonner-toast][data-styled='true'] {
    --accent: 249 115 22;               /* по умолчанию — фирменный оранжевый */
    --normal-border: rgb(255 255 255 / 0.1);
    --normal-text: #fafafa;
    --toast-muted: #a1a1aa;

    position: relative;
    isolation: isolate;
    overflow: visible;
    padding: 14px 16px 14px 14px;
    gap: 12px;
    align-items: center;
    border: 1px solid var(--normal-border);
    border-radius: 22px;
    color: var(--normal-text);
    font-family: inherit;
    background:
        radial-gradient(180px 90px at 0% 50%, rgb(var(--accent) / 0.22), transparent 70%),
        linear-gradient(180deg, rgb(39 39 42 / 0.92), rgb(9 9 11 / 0.94));
    backdrop-filter: blur(20px) saturate(1.6);
    -webkit-backdrop-filter: blur(20px) saturate(1.6);
    box-shadow:
        inset 0 1px 0 rgb(255 255 255 / 0.08),
        0 0 0 1px rgb(0 0 0 / 0.35),
        0 18px 40px -12px rgb(0 0 0 / 0.55),
        0 0 36px -10px rgb(var(--accent) / 0.45);
}

/* тонкий блик по верхней кромке */
.toaster [data-sonner-toast][data-styled='true']::before {
    content: '';
    position: absolute;
    inset: 0 22px auto 22px;
    height: 1px;
    background: linear-gradient(90deg, transparent, rgb(var(--accent) / 0.7), transparent);
    opacity: 0.9;
    pointer-events: none;
}

/* на тёмном сайте чуть светлее, чтобы отделяться от фона */
:root.dark .toaster [data-sonner-toast][data-styled='true'] {
    --normal-border: rgb(255 255 255 / 0.14);
    background:
        radial-gradient(180px 90px at 0% 50%, rgb(var(--accent) / 0.26), transparent 70%),
        linear-gradient(180deg, rgb(52 52 56 / 0.92), rgb(24 24 27 / 0.95));
}

/* ---------- Цвета по типам ---------- */
.toaster [data-sonner-toast][data-type='success'] { --accent: 16 185 129; }
.toaster [data-sonner-toast][data-type='error']   { --accent: 244 63 94; }
.toaster [data-sonner-toast][data-type='warning'] { --accent: 245 158 11; }
.toaster [data-sonner-toast][data-type='info']    { --accent: 56 189 248; }
.toaster [data-sonner-toast][data-type='loading'] { --accent: 161 161 170; }

/* ---------- Иконка ---------- */
.toaster [data-sonner-toast] [data-icon] {
    width: auto;
    height: auto;
    margin: 0;
}

.toast-icon {
    display: flex;
    width: 34px;
    height: 34px;
    align-items: center;
    justify-content: center;
    border-radius: 999px;
    color: rgb(var(--accent));
    background: rgb(var(--accent) / 0.16);
    box-shadow:
        inset 0 0 0 1px rgb(var(--accent) / 0.35),
        0 0 18px rgb(var(--accent) / 0.35);
}

/* ---------- Текст ---------- */
.toaster [data-sonner-toast] [data-title] {
    font-size: 14px;
    font-weight: 700;
    letter-spacing: -0.015em;
    line-height: 1.3;
    color: #fafafa;
}

.toaster [data-sonner-toast] [data-description] {
    margin-top: 2px;
    font-size: 13px;
    line-height: 1.4;
    color: var(--toast-muted);
}

/* ---------- Кнопки действия ---------- */
.toaster [data-sonner-toast] [data-button] {
    height: 32px;
    padding: 0 14px;
    border: none;
    border-radius: 999px;
    background: #fafafa;
    color: #18181b;
    font-size: 12px;
    font-weight: 700;
    transition: background-color 0.15s, transform 0.15s, box-shadow 0.15s;
}

.toaster [data-sonner-toast] [data-button]:hover {
    background: rgb(var(--accent));
    color: #09090b;
    box-shadow: 0 0 20px rgb(var(--accent) / 0.5);
}

.toaster [data-sonner-toast] [data-button]:active { transform: scale(0.95); }

.toaster [data-sonner-toast] [data-button][data-cancel] {
    background: rgb(255 255 255 / 0.08);
    color: #d4d4d8;
}

.toaster [data-sonner-toast] [data-button][data-cancel]:hover {
    background: rgb(255 255 255 / 0.16);
    color: #fff;
    box-shadow: none;
}

/* ---------- Крестик: появляется при наведении ---------- */
.toaster [data-sonner-toast] [data-close-button] {
    background: #18181b;
    border: 1px solid rgb(255 255 255 / 0.14);
    color: #a1a1aa;
    opacity: 0;
    transition: opacity 0.15s, color 0.15s, transform 0.15s;
}

.toaster [data-sonner-toast]:hover [data-close-button],
.toaster [data-sonner-toast] [data-close-button]:focus-visible {
    opacity: 1;
}

.toaster [data-sonner-toast] [data-close-button]:hover {
    color: #fff;
    transform: scale(1.12);
}

/* на сенсорных экранах hover нет — крестик виден всегда */
@media (hover: none) {
    .toaster [data-sonner-toast] [data-close-button] { opacity: 1; }
}

/* ---------- Мобильные ---------- */
@media (max-width: 600px) {
    .toaster[data-sonner-toaster] { --mobile-offset: 12px; }
}
</style>
