<script setup lang="ts">
import {
    ArrowLeft,
    Box,
    ChevronLeft,
    ChevronRight,
    Maximize2,
    Package,
    Phone,
    ShoppingCart,
    X,
} from '@lucide/vue'
import { router } from '@inertiajs/vue3'
import { ref } from 'vue'
import { onKeyStroke } from '@vueuse/core'

import { Button } from '@/components/ui/button'

const props = defineProps<{
    product: {
        id: number
        name: string
        slug: string
        sku: string | null
        description: string | null
        price: string
        stock_status: string
        manufacturer?: string | null
        category?: string | null
        meta_title: string
        meta_description: string | null
        images: Array<{ id: number, path: string, large: string, alt: string | null }>
        characteristics: Array<{
            id: number
            name: string
            value: string | null
            unit: string | null
        }>
    }
    related_products: Array<{
        id: number
        name: string
        slug: string
        price: string
        image_path?: string | null
        stock_status: string
    }>
}>()

const quantity = ref(1)
const showPreview = ref(false)
const previewIndex = ref(0)

function formatPrice(price: string): string {
    return new Intl.NumberFormat('ru-RU').format(parseFloat(price))
}

function stockStatusLabel(status: string): string {
    const map: Record<string, string> = {
        in_stock: 'В наличии',
        out_of_stock: 'Нет в наличии',
        backorder: 'Под заказ',
    }
    return map[status] || status
}

function stockStatusClass(status: string): string {
    const map: Record<string, string> = {
        in_stock: 'bg-emerald-100 text-emerald-700',
        out_of_stock: 'bg-rose-100 text-rose-700',
        backorder: 'bg-amber-100 text-amber-700',
    }
    return map[status] || 'bg-slate-100 text-slate-700'
}

function addToCart() {
    router.post(
        route('store.cart.store'),
        { product_id: props.product.id, quantity: quantity.value },
        {
            preserveState: true,
            only: ['item_count'],
        }
    )
}

function openPreview(index: number) {
    previewIndex.value = index
    showPreview.value = true
    document.body.style.overflow = 'hidden'
}

function closePreview() {
    showPreview.value = false
    document.body.style.overflow = ''
}

function prevImage() {
    if (previewIndex.value > 0) {
        previewIndex.value--
    }
}

function nextImage() {
    if (previewIndex.value < props.product.images.length - 1) {
        previewIndex.value++
    }
}

function selectThumbnail(index: number) {
    previewIndex.value = index
}

onKeyStroke('ArrowLeft', (e) => {
    if (!showPreview.value) return
    e.preventDefault()
    prevImage()
})

onKeyStroke('ArrowRight', (e) => {
    if (!showPreview.value) return
    e.preventDefault()
    nextImage()
})

onKeyStroke('Escape', () => {
    if (showPreview.value) {
        closePreview()
    }
})
</script>

<template>
    <div class="mx-auto max-w-7xl px-5 py-8 lg:px-10">
            <!-- Breadcrumb -->
            <a
                :href="route('store.catalog.index')"
                class="mb-6 inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-emerald-700"
            >
                <ArrowLeft :size="14" />
                Назад в каталог
            </a>

            <div class="grid gap-8 lg:grid-cols-2">
                <!-- Image gallery -->
                <div>
                    <!-- Main image -->
                    <div
                        class="group relative mb-4 aspect-square overflow-hidden rounded-2xl bg-slate-100"
                        @click="openPreview(0)"
                    >
                        <template v-if="product.images.length > 0">
                            <img
                                :src="product.images[previewIndex]?.path ?? product.images[0].path"
                                :alt="product.images[previewIndex]?.alt ?? product.images[0]?.alt ?? product.name"
                                loading="lazy"
                                decoding="async"
                                class="h-full w-full object-cover transition duration-300 group-hover:scale-105"
                            />

                            <!-- Image counter -->
                            <div
                                v-if="product.images.length > 1"
                                class="absolute bottom-3 right-3 rounded-full bg-black/60 px-2.5 py-1 text-xs font-medium text-white backdrop-blur"
                            >
                                {{ previewIndex + 1 }} / {{ product.images.length }}
                            </div>

                            <!-- Zoom hint -->
                            <div class="absolute right-3 top-3 rounded-full bg-black/40 p-1.5 opacity-0 transition group-hover:opacity-100">
                                <Maximize2 :size="16" class="text-white" />
                            </div>

                            <!-- Navigation arrows -->
                            <button
                                v-if="product.images.length > 1"
                                @click.stop="prevImage"
                                class="absolute left-3 top-1/2 -translate-y-1/2 rounded-full bg-white/80 p-2 shadow-lg opacity-0 transition hover:bg-white group-hover:opacity-100"
                            >
                                <ChevronLeft :size="18" />
                            </button>
                            <button
                                v-if="product.images.length > 1"
                                @click.stop="nextImage"
                                class="absolute right-3 top-1/2 -translate-y-1/2 rounded-full bg-white/80 p-2 shadow-lg opacity-0 transition hover:bg-white group-hover:opacity-100"
                            >
                                <ChevronRight :size="18" />
                            </button>
                        </template>
                        <div v-else class="flex h-full items-center justify-center text-slate-300">
                            <Package :size="64" />
                        </div>
                    </div>

                    <!-- Thumbnails -->
                    <div
                        v-if="product.images.length > 1"
                        class="flex gap-2 overflow-x-auto pb-1"
                    >
                        <button
                            v-for="(img, i) in product.images"
                            :key="img.id"
                            @click="selectThumbnail(i)"
                            :class="[
                                'relative h-20 w-20 shrink-0 overflow-hidden rounded-lg border-2 transition',
                                i === previewIndex
                                    ? 'border-emerald-600 ring-2 ring-emerald-600/20'
                                    : 'border-slate-200 hover:border-slate-300'
                            ]"
                        >
                            <img
                                :src="img.path"
                                :alt="img.alt || product.name"
                                class="h-full w-full object-cover"
                            />
                        </button>
                    </div>
                </div>

                <!-- Product info -->
                <div>
                    <h1 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">{{ product.name }}</h1>

                    <p v-if="product.sku" class="mt-1 text-sm text-slate-500">
                        Артикул: <span class="font-mono">{{ product.sku }}</span>
                    </p>

                    <!-- Price & status -->
                    <div class="mt-6 flex items-end justify-between rounded-xl bg-slate-50 p-4">
                        <div>
                            <div class="text-3xl font-extrabold text-slate-900">
                                {{ formatPrice(product.price) }} ₽
                            </div>
                            <div class="mt-1 text-sm text-slate-500">Розничная цена</div>
                        </div>
                        <span
                            class="rounded-full px-3 py-1.5 text-sm font-bold"
                            :class="stockStatusClass(product.stock_status)"
                        >
                            {{ stockStatusLabel(product.stock_status) }}
                        </span>
                    </div>

                    <!-- Meta info -->
                    <div class="mt-6 space-y-2 text-sm text-slate-600">
                        <div v-if="product.category">
                            <span class="font-medium text-slate-700">Категория:</span> {{ product.category }}
                        </div>
                        <div v-if="product.manufacturer">
                            <span class="font-medium text-slate-700">Производитель:</span> {{ product.manufacturer }}
                        </div>
                    </div>

                    <!-- Quantity & Add to cart -->
                    <div class="mt-6 flex items-center gap-3">
                        <div class="flex items-center rounded-lg border border-slate-200">
                            <button
                                @click="quantity = Math.max(1, quantity - 1)"
                                class="px-3 py-2.5 text-slate-600 hover:text-emerald-700"
                            >
                                −
                            </button>
                            <input
                                v-model.number="quantity"
                                type="number"
                                min="1"
                                step="0.1"
                                class="w-16 border-none text-center text-sm focus:ring-0"
                            />
                            <button
                                @click="quantity++"
                                class="px-3 py-2.5 text-slate-600 hover:text-emerald-700"
                            >
                                +
                            </button>
                        </div>

                        <Button
                            :disabled="product.stock_status === 'out_of_stock'"
                            @click="addToCart"
                            class="flex-1 rounded-xl bg-emerald-600 px-6 text-sm font-semibold text-white shadow-lg shadow-emerald-600/20 hover:bg-emerald-700"
                        >
                            <ShoppingCart :size="16" class="mr-2" />
                            В корзину
                        </Button>
                    </div>

                    <!-- Description -->
                    <div v-if="product.description" class="mt-8">
                        <h2 class="text-lg font-bold text-slate-900">Описание</h2>
                        <div class="mt-3 text-sm leading-7 text-slate-600">
                            {{ product.description }}
                        </div>
                    </div>

                    <!-- Characteristics -->
                    <div v-if="product.characteristics.length > 0" class="mt-8">
                        <h2 class="text-lg font-bold text-slate-900">Характеристики</h2>
                        <div class="mt-3 overflow-x-auto rounded-xl border border-slate-200">
                            <table class="w-full text-sm">
                                <tbody class="divide-y divide-slate-100">
                                    <tr
                                        v-for="char in product.characteristics"
                                        :key="char.id"
                                        class="hover:bg-slate-50"
                                    >
                                        <td class="whitespace-nowrap py-3 pr-4 font-medium text-slate-600">
                                            {{ char.name }}
                                        </td>
                                        <td class="py-3 pl-4 text-slate-900">
                                            {{ char.value || '—' }}
                                            <span v-if="char.unit" class="text-slate-400">({{ char.unit }})</span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Related products -->
            <div v-if="related_products.length > 0" class="mt-16">
                <h2 class="mb-6 text-xl font-extrabold text-slate-950">Похожие товары</h2>
                <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    <div
                        v-for="rp in related_products"
                        :key="rp.id"
                        class="rounded-2xl border border-slate-200 bg-white overflow-hidden transition hover:border-emerald-200"
                    >
                        <a
                            :href="route('store.products.show', { product: rp.slug })"
                            class="aspect-square bg-slate-100 flex items-center justify-center"
                        >
                            <div v-if="rp.image_path" class="h-full w-full overflow-hidden">
                                <img :src="rp.image_path" :alt="rp.name" loading="lazy" decoding="async" class="h-full w-full object-cover" />
                            </div>
                            <div v-else class="text-slate-300">
                                <Package :size="32" />
                            </div>
                        </a>
                        <div class="p-3">
                            <a
                                :href="route('store.products.show', { product: rp.slug })"
                                class="text-sm font-semibold text-slate-900 line-clamp-2 hover:text-emerald-700"
                            >
                                {{ rp.name }}
                            </a>
                            <div class="mt-2 text-sm font-extrabold text-slate-900">
                                {{ formatPrice(rp.price) }} ₽
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Fullscreen preview -->
        <div
            v-if="showPreview"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/90"
            @click.self="closePreview"
            @keydown.escape="closePreview"
        >
            <!-- Close button -->
            <button
                @click="closePreview"
                class="absolute right-4 top-4 z-10 rounded-full bg-white/10 p-2 text-white hover:bg-white/20"
            >
                <X :size="24" />
            </button>

            <!-- Prev -->
            <button
                v-if="product.images.length > 1"
                @click.stop="prevImage"
                class="absolute left-4 top-1/2 -translate-y-1/2 rounded-full bg-white/10 p-3 text-white hover:bg-white/20"
            >
                <ChevronLeft :size="24" />
            </button>

            <!-- Image -->
            <div class="max-h-[85vh] max-w-[90vw]">
                <img
                    :src="product.images[previewIndex]?.large ?? product.images[previewIndex]?.path"
                    :alt="product.images[previewIndex]?.alt ?? product.name"
                    loading="eager"
                    decoding="async"
                    class="max-h-[85vh] max-w-full object-contain"
                />
            </div>

            <!-- Next -->
            <button
                v-if="product.images.length > 1"
                @click.stop="nextImage"
                class="absolute right-4 top-1/2 -translate-y-1/2 rounded-full bg-white/10 p-3 text-white hover:bg-white/20"
            >
                <ChevronRight :size="24" />
            </button>

            <!-- Counter -->
            <div class="absolute bottom-6 left-1/2 -translate-x-1/2 rounded-full bg-black/60 px-4 py-2 text-sm font-medium text-white backdrop-blur">
                {{ previewIndex + 1 }} / {{ product.images.length }}
            </div>

            <!-- Thumbnails strip -->
            <div
                v-if="product.images.length > 1"
                class="absolute bottom-16 left-1/2 flex -translate-x-1/2 gap-2 overflow-x-auto max-w-[80vw] px-4"
            >
                <button
                    v-for="(img, i) in product.images"
                    :key="img.id"
                    @click.stop="selectThumbnail(i)"
                    :class="[
                        'h-14 w-14 shrink-0 overflow-hidden rounded-lg border-2 transition',
                        i === previewIndex
                            ? 'border-white'
                            : 'border-white/30 hover:border-white/60'
                    ]"
                >
                    <img :src="img.path" :alt="img.alt || product.name" loading="lazy" decoding="async" class="h-full w-full object-cover" />
                </button>
            </div>
        </div>
</template>
