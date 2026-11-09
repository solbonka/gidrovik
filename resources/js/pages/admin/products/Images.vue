<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import { Cropper } from 'vue-advanced-cropper'
import 'vue-advanced-cropper/dist/style.css'
import {
    ArrowLeft,
    Camera,
    Check,
    Crop,
    GripVertical,
    ImagePlus,
    Package,
    Trash2,
    X,
} from '@lucide/vue'
import { computed, ref } from 'vue'

import AdminLayout from '@/layouts/AdminLayout.vue'
import { Button } from '@/components/ui/button'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { show } from '@/routes/admin/products'
import {
    destroy as destroyImage,
    reorder as reorderImages,
    store as storeImages,
    update as updateImage,
} from '@/routes/admin/products/images'

defineOptions({ layout: AdminLayout })

type ProductImage = {
    id: number
    path: string
    source_path: string | null
    alt: string | null
    display_order: number
    crop: { x: number; y: number; width: number; height: number } | null
    canonical_size: number
}

const props = defineProps<{
    product: {
        id: number
        name: string
        images: ProductImage[]
    }
}>()

const dragItem = ref<number | null>(null)
const dragOverItem = ref<number | null>(null)
const uploading = ref(false)
const uploadError = ref('')
const previewImage = ref<string | null>(null)
const editingAlt = ref<Record<number, string>>({})

const cropOpen = ref(false)
const cropSrc = ref('')
const cropFile = ref<File | null>(null)
const cropImage = ref<ProductImage | null>(null)
const cropperRef = ref<InstanceType<typeof Cropper> | null>(null)

const imageCount = computed(() => props.product.images.length)

function openCropForFile(file: File) {
    cropFile.value = file
    cropImage.value = null
    if (cropSrc.value) URL.revokeObjectURL(cropSrc.value)
    cropSrc.value = URL.createObjectURL(file)
    cropOpen.value = true
}

function openCropForExisting(image: ProductImage) {
    if (!image.source_path) return
    cropFile.value = null
    cropImage.value = image
    cropSrc.value = image.source_path
    cropOpen.value = true
}

function onPickFiles(event: Event) {
    const input = event.target as HTMLInputElement
    const files = Array.from(input.files ?? [])
    input.value = ''
    if (files.length === 0) return

    if (files.length === 1) {
        openCropForFile(files[0])
        return
    }

    const formData = new FormData()
    files.forEach((file) => formData.append('images[]', file))
    uploading.value = true
    uploadError.value = ''
    router.post(storeImages.url({ product: props.product.id }), formData, {
        forceFormData: true,
        preserveState: true,
        onFinish: () => {
            uploading.value = false
        },
        onError: (errors) => {
            uploadError.value = (errors as Record<string, string>).images || 'Ошибка загрузки'
        },
    })
}

function cropPayload() {
    const result = cropperRef.value?.getResult()
    const c = result?.coordinates
    if (!c) return null
    return {
        x: Math.round(c.left),
        y: Math.round(c.top),
        width: Math.round(c.width),
        height: Math.round(c.height),
    }
}

function submitCrop() {
    const crop = cropPayload()
    if (!crop) return

    uploading.value = true
    uploadError.value = ''

    if (cropFile.value) {
        const formData = new FormData()
        formData.append('image', cropFile.value)
        formData.append('crop[x]', String(crop.x))
        formData.append('crop[y]', String(crop.y))
        formData.append('crop[width]', String(crop.width))
        formData.append('crop[height]', String(crop.height))
        router.post(storeImages.url({ product: props.product.id }), formData, {
            forceFormData: true,
            preserveState: true,
            onSuccess: () => {
                cropOpen.value = false
            },
            onFinish: () => {
                uploading.value = false
            },
            onError: (errors) => {
                uploadError.value = (errors as Record<string, string>).image || 'Ошибка загрузки'
            },
        })
        return
    }

    if (cropImage.value) {
        router.patch(
            updateImage.url({ product: props.product.id, imageId: cropImage.value.id }),
            { crop },
            {
                preserveState: true,
                onSuccess: () => {
                    cropOpen.value = false
                },
                onFinish: () => {
                    uploading.value = false
                },
                onError: () => {
                    uploadError.value = 'Не удалось сохранить обрезку'
                },
            },
        )
    }
}

function deleteImage(imageId: number) {
    router.delete(destroyImage.url({ product: props.product.id, imageId }), {
        preserveState: true,
    })
}

function updateImageAlt(imageId: number) {
    const alt = editingAlt.value[imageId] ?? ''
    router.patch(
        updateImage.url({ product: props.product.id, imageId }),
        { alt },
        {
            preserveState: true,
            onFinish: () => {
                editingAlt.value[imageId] = ''
            },
        },
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
    router.post(
        reorderImages.url({ product: props.product.id }),
        { order: images.map((img) => img.id) },
        { preserveState: true },
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
    <Head title="Изображения" />

    <div class="space-y-6 pb-4">
        <header>
            <Link
                :href="show(product.id).url"
                class="mb-4 inline-flex items-center gap-2 text-sm font-medium text-muted-foreground transition-colors hover:text-primary"
            >
                <ArrowLeft :size="16" />
                К товару
            </Link>

            <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
                <div class="flex min-w-0 items-start gap-4">
                    <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary/10 ring-1 ring-primary/15">
                        <Camera :size="20" class="text-primary" />
                    </div>
                    <div class="min-w-0">
                        <h1 class="truncate text-xl font-semibold tracking-tight sm:text-2xl">
                            {{ product.name }}
                        </h1>
                        <p class="mt-0.5 text-sm text-muted-foreground">
                            Квадратные фото 1200×1200, обрезка при загрузке · {{ imageCount }} шт.
                        </p>
                    </div>
                </div>

                <label
                    class="inline-flex cursor-pointer items-center justify-center gap-2 rounded-xl bg-primary px-4 py-2.5 text-sm font-semibold text-primary-foreground shadow-sm transition hover:bg-primary/90"
                    :class="uploading && 'pointer-events-none opacity-60'"
                >
                    <ImagePlus :size="16" />
                    {{ uploading ? 'Загрузка…' : 'Добавить фото' }}
                    <input
                        type="file"
                        multiple
                        accept="image/jpeg,image/png,image/webp,image/jpg"
                        class="hidden"
                        @change="onPickFiles"
                    />
                </label>
            </div>
        </header>

        <p
            v-if="uploadError"
            class="rounded-xl border border-destructive/20 bg-destructive/5 px-4 py-3 text-sm text-destructive"
        >
            {{ uploadError }}
        </p>

        <div
            v-if="product.images.length"
            class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5"
        >
            <div
                v-for="(image, index) in product.images"
                :key="image.id"
                class="group relative overflow-hidden rounded-2xl border border-border bg-card shadow-sm transition hover:shadow-md"
                draggable="true"
                @dragstart="startDrag(index)"
                @dragover.prevent="onDragOver(index)"
                @drop="onDrop(index)"
                @dragend="cancelDrag"
            >
                <button
                    type="button"
                    class="aspect-square w-full cursor-zoom-in overflow-hidden bg-muted"
                    @click="previewImage = image.path"
                >
                    <img :src="image.path" :alt="image.alt || ''" class="h-full w-full object-cover" />
                </button>

                <div class="space-y-2 p-2.5">
                    <div class="flex items-center gap-1.5">
                        <GripVertical :size="14" class="shrink-0 cursor-grab text-muted-foreground" />
                        <Input
                            v-model="editingAlt[image.id]"
                            :placeholder="image.alt || 'Alt текст'"
                            class="h-8 text-xs"
                            @keyup.enter="updateImageAlt(image.id)"
                        />
                        <Button
                            v-if="editingAlt[image.id] !== undefined && editingAlt[image.id] !== ''"
                            type="button"
                            variant="ghost"
                            size="icon"
                            class="h-8 w-8 shrink-0"
                            @click="updateImageAlt(image.id)"
                        >
                            <Check :size="14" />
                        </Button>
                    </div>

                    <div class="flex items-center justify-between gap-2">
                        <span class="text-[11px] text-muted-foreground">#{{ index + 1 }}</span>
                        <div class="flex items-center gap-1">
                            <Button
                                v-if="image.source_path"
                                type="button"
                                variant="ghost"
                                size="icon"
                                class="h-8 w-8 text-muted-foreground hover:text-foreground"
                                title="Изменить обрезку"
                                @click="openCropForExisting(image)"
                            >
                                <Crop :size="14" />
                            </Button>
                            <Button
                                type="button"
                                variant="ghost"
                                size="icon"
                                class="h-8 w-8 text-muted-foreground hover:text-destructive"
                                @click="deleteImage(image.id)"
                            >
                                <Trash2 :size="14" />
                            </Button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div
            v-else
            class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-border bg-card/50 px-6 py-16 text-center"
        >
            <div class="mb-3 flex h-12 w-12 items-center justify-center rounded-xl bg-muted">
                <Package :size="22" class="text-muted-foreground" />
            </div>
            <p class="text-sm font-medium">Нет изображений</p>
            <p class="mt-1 text-sm text-muted-foreground">
                Выберите фото — откроется редактор обрезки 1:1, итог сохранится как 1200×1200.
            </p>
        </div>
    </div>

    <Dialog v-model:open="cropOpen">
        <DialogContent class="max-w-3xl gap-4">
            <DialogHeader>
                <DialogTitle>Обрезка изображения</DialogTitle>
                <DialogDescription>
                    Перемещайте и масштабируйте область 1:1. Результат сохранится как 1200×1200.
                </DialogDescription>
            </DialogHeader>

            <div v-if="cropSrc" class="overflow-hidden rounded-xl bg-black/90">
                <Cropper
                    ref="cropperRef"
                    :src="cropSrc"
                    :stencil-props="{ aspectRatio: 1 }"
                    class="h-[min(60vh,520px)]"
                />
            </div>

            <DialogFooter class="gap-2 sm:gap-0">
                <Button type="button" variant="outline" @click="cropOpen = false">
                    Отмена
                </Button>
                <Button type="button" :disabled="uploading" @click="submitCrop">
                    {{ uploading ? 'Сохранение…' : 'Сохранить 1200×1200' }}
                </Button>
            </DialogFooter>
        </DialogContent>
    </Dialog>

    <div
        v-if="previewImage"
        class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-4"
        @click="previewImage = null"
    >
        <button
            type="button"
            class="absolute right-4 top-4 rounded-full bg-white/10 p-2 text-white hover:bg-white/20"
            @click="previewImage = null"
        >
            <X :size="20" />
        </button>
        <img :src="previewImage" alt="" class="max-h-full max-w-full rounded-xl object-contain" />
    </div>
</template>
