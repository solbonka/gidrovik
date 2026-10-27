<script setup lang="ts">
import { Head, router } from '@inertiajs/vue3'
import {
    ArrowLeft,
    Camera,
    Check,
    ChevronDown,
    GripVertical,
    ImagePlus,
    Trash2,
    X,
} from '@lucide/vue'
import { computed, ref } from 'vue'

import AdminLayout from '@/layouts/AdminLayout.vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

defineOptions({ layout: AdminLayout })

const props = defineProps<{
    product: {
        id: number
        name: string
        images: Array<{
            id: number
            path: string
            alt: string | null
            display_order: number
        }>
    }
}>()

const isDragging = ref(false)
const dragItem = ref<number | null>(null)
const dragOverItem = ref<number | null>(null)
const uploading = ref(false)
const uploadError = ref('')
const previewImage = ref<string | null>(null)
const editingAlt = ref<Record<number, string>>({})

const imageCount = computed(() => props.product.images.length)

function uploadImages(event: Event) {
    const input = event.target as HTMLInputElement
    const files = input.files

    if (!files || files.length === 0) return

    const formData = new FormData()

    for (let i = 0; i < files.length; i++) {
        formData.append('images[]', files[i])
    }

    uploading.value = true
    uploadError.value = ''

    router.post(
        route('admin.products.images.store', { product: props.product.id }),
        formData,
        {
            headers: { 'Content-Type': 'multipart/form-data' },
            preserveState: true,
            onSuccess: () => {
                uploading.value = false
                input.value = ''
            },
            onError: (errors) => {
                uploading.value = false
                uploadError.value = errors.images || 'Ошибка загрузки'
            },
        }
    )
}

function deleteImage(imageId: number) {
    router.delete(
        route('admin.products.images.destroy', {
            product: props.product.id,
            imageId,
        }),
        {
            preserveState: true,
        }
    )
}

function updateImageAlt(imageId: number) {
    const alt = editingAlt.value[imageId] ?? ''

    router.patch(
        route('admin.products.images.update', {
            product: props.product.id,
            imageId,
        }),
        { alt },
        {
            preserveState: true,
            onFinish: () => {
                editingAlt.value[imageId] = ''
            },
        }
    )
}

function startDrag(index: number) {
    dragItem.value = index
}

function onDragOver(index: number) {
    dragOverItem.value = index
}

function onDrop(index: number) {
    if (dragItem.value === null || dragItem.value === index) return

    const images = [...props.product.images]
    const draggedImage = images.splice(dragItem.value, 1)[0]
    images.splice(index, 0, draggedImage)

    const order = images.map((img) => img.id)

    router.post(
        route('admin.products.images.reorder', { product: props.product.id }),
        { order },
        {
            preserveState: true,
        }
    )

    dragItem.value = null
    dragOverItem.value = null
}

function cancelDrag() {
    dragItem.value = null
    dragOverItem.value = null
}
</script>

<template>
    <Head title="Изображения — Гидровик" />

    <div class="p-6 lg:p-8">
        <!-- Header -->
        <div class="mb-6 flex items-center justify-between">
            <div class="flex items-center gap-4">
                <a
                    :href="route('admin.products.show', { product: product.id })"
                    class="flex items-center gap-1.5 text-sm text-slate-500 hover:text-emerald-700"
                >
                    <ArrowLeft :size="16" />
                    Назад к товару
                </a>
                <div>
                    <h1 class="text-2xl font-extrabold tracking-tight text-slate-950 sm:text-3xl">
                        Изображения
                    </h1>
                    <p class="mt-1 text-sm text-slate-500">
                        {{ product.name }}
                    </p>
                </div>
            </div>
        </div>

        <!-- Upload area -->
        <div class="mb-8">
            <div
                class="rounded-xl border-2 border-dashed border-slate-300 p-8 text-center transition hover:border-emerald-400"
                :class="{ 'border-emerald-400 bg-emerald-50': isDragging }"
                @dragover.prevent="isDragging = true"
                @dragleave.prevent="isDragging = false"
                @drop.prevent="isDragging = false"
            >
                <input
                    type="file"
                    multiple
                    accept="image/jpeg,image/png,image/jpg,image/webp"
                    @change="uploadImages"
                    class="hidden"
                    id="image-upload"
                />
                <label for="image-upload" class="cursor-pointer">
                    <div class="mx-auto flex size-16 items-center justify-center rounded-full bg-slate-100 text-slate-400">
                        <ImagePlus :size="32" />
                    </div>
                    <p class="mt-4 text-sm font-medium text-slate-700">
                        Нажмите для загрузки или перетащите файлы
                    </p>
                    <p class="mt-1 text-xs text-slate-400">
                        JPEG, PNG, JPG, WebP до 5 МБ каждое
                    </p>
                </label>
            </div>

            <p v-if="uploadError" class="mt-3 text-sm text-rose-600">
                {{ uploadError }}
            </p>

            <div v-if="uploading" class="mt-3 text-sm text-slate-500">
                Загрузка...
            </div>
        </div>

        <!-- Images grid -->
        <div v-if="product.images.length > 0" class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            <div
                v-for="(image, index) in product.images"
                :key="image.id"
                class="group relative overflow-hidden rounded-xl border border-slate-200 bg-white"
                draggable="true"
                @dragstart="startDrag(index)"
                @dragover.prevent="onDragOver(index)"
                @drop.prevent="onDrop(index)"
                @dragend="cancelDrag"
                :class="{ 'ring-2 ring-emerald-500': dragItem === index }"
            >
                <!-- Image -->
                <div
                    class="aspect-square cursor-pointer bg-slate-100"
                    @click="previewImage = image.path"
                >
                    <img
                        :src="image.path"
                        :alt="image.alt || product.name"
                        loading="lazy"
                        decoding="async"
                        class="h-full w-full object-cover transition group-hover:scale-105"
                    />
                </div>

                <!-- Info -->
                <div class="p-4">
                    <!-- Alt text -->
                    <div v-if="editingAlt[image.id]" class="mb-3">
                        <input
                            v-model="editingAlt[image.id]"
                            type="text"
                            placeholder="Описание изображения"
                            class="w-full rounded-lg border border-slate-200 px-3 py-1.5 text-sm focus:border-emerald-400"
                            @keyup.enter="updateImageAlt(image.id)"
                            @blur="updateImageAlt(image.id)"
                            autofocus
                        />
                    </div>
                    <div v-else class="mb-3 flex items-center justify-between">
                        <span class="text-sm text-slate-600">
                            {{ image.alt || 'Без описания' }}
                        </span>
                        <button
                            @click="editingAlt[image.id] = image.alt || ''"
                            class="text-xs text-emerald-700 hover:text-emerald-800"
                        >
                            Изменить
                        </button>
                    </div>

                    <!-- Actions -->
                    <div class="flex items-center justify-between">
                        <span class="text-xs text-slate-400">
                            Изображение {{ index + 1 }} из {{ product.images.length }}
                        </span>
                        <div class="flex items-center gap-1">
                            <button
                                @click="previewImage = image.path"
                                class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-600"
                                title="Просмотр"
                            >
                                <Check :size="16" />
                            </button>
                            <button
                                @click="deleteImage(image.id)"
                                class="rounded-lg p-1.5 text-slate-400 hover:bg-rose-50 hover:text-rose-600"
                                title="Удалить"
                            >
                                <Trash2 :size="16" />
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Drag handle -->
                <div class="absolute left-2 top-2 flex size-8 items-center justify-center rounded-lg bg-white/80 text-slate-400 opacity-0 transition group-hover:opacity-100">
                    <GripVertical :size="16" />
                </div>
            </div>
        </div>

        <!-- Empty state -->
        <div v-else class="rounded-xl border border-slate-200 bg-white p-16 text-center">
            <div class="mx-auto flex size-16 items-center justify-center rounded-2xl bg-slate-100 text-slate-400">
                <Camera :size="32" />
            </div>
            <h3 class="mt-4 text-lg font-bold text-slate-900">Нет изображений</h3>
            <p class="mt-2 text-sm text-slate-500">
                Загрузите изображения для этого товара
            </p>
        </div>

        <!-- Image count -->
        <div v-if="product.images.length > 0" class="mt-6 text-sm text-slate-500">
            Всего изображений: {{ product.images.length }}
        </div>
    </div>

    <!-- Preview modal -->
    <div
        v-if="previewImage"
        class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-4"
        @click.self="previewImage = null"
        @keydown.escape="previewImage = null"
    >
        <div class="max-h-[90vh] max-w-[90vw]">
            <img
                :src="previewImage"
                class="max-h-[90vh] max-w-full object-contain"
            />
        </div>
        <button
            @click="previewImage = null"
            class="absolute right-4 top-4 rounded-full bg-white/20 p-2 text-white hover:bg-white/30"
        >
            <X :size="24" />
        </button>
    </div>
</template>
