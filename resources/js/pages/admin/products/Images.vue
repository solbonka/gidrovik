<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import {
    ArrowLeft,
    ArrowRight,
    Camera,
    Check,
    ChevronDown,
    GripVertical,
    ImagePlus,
    Package,
    Trash2,
    X,
} from '@lucide/vue'
import { computed, ref } from 'vue'

import AdminLayout from '@/layouts/AdminLayout.vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { show } from '@/routes/admin/products'

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
    <Head title="Изображения" />

    <div class="space-y-6 pb-4">
        <!-- Заголовок -->
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
                    <div
                        class="flex size-14 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm"
                    >
                        <Camera :size="28" />
                    </div>

                    <div class="min-w-0">
                        <h1 class="text-2xl font-bold tracking-tight break-words sm:text-3xl">
                            Изображения
                        </h1>
                        <p class="mt-1 text-sm text-muted-foreground">
                            {{ product.name }}
                        </p>
                    </div>
                </div>

                <div class="flex flex-col gap-3 sm:flex-row">
                    <Button as-child variant="outline" class="w-full sm:flex-1">
                        <Link :href="show(product.id).url">
                            <ArrowLeft :size="16" class="mr-2" />
                            Назад к товару
                        </Link>
                    </Button>
                </div>
            </div>
        </header>

        <!-- Загрузка изображений -->
        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm">
            <div class="flex items-center gap-3 border-b px-5 py-4 sm:px-6">
                <div
                    class="flex size-10 items-center justify-center rounded-xl bg-blue-500/10 text-blue-600 dark:text-blue-400"
                >
                    <ImagePlus :size="20" />
                </div>
                <div>
                    <h2 class="font-semibold">Загрузка изображений</h2>
                    <p class="mt-0.5 text-xs text-muted-foreground">
                        Перетащите файлы или нажмите для выбора
                    </p>
                </div>
            </div>

            <div class="p-5 sm:p-6">
                <div
                    class="rounded-xl border-2 border-dashed border-border p-8 text-center transition hover:border-primary/50"
                    :class="{ 'border-primary/50 bg-primary/5': isDragging }"
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
                        <div class="mx-auto flex size-16 items-center justify-center rounded-full bg-muted text-muted-foreground">
                            <ImagePlus :size="32" />
                        </div>
                        <p class="mt-4 text-sm font-medium text-foreground">
                            Нажмите для загрузки или перетащите файлы
                        </p>
                        <p class="mt-1 text-xs text-muted-foreground">
                            JPEG, PNG, JPG, WebP до 5 МБ каждое
                        </p>
                    </label>
                </div>

                <p v-if="uploadError" class="mt-3 text-sm text-destructive">
                    {{ uploadError }}
                </p>

                <div v-if="uploading" class="mt-3 text-sm text-muted-foreground">
                    Загрузка...
                </div>
            </div>
        </section>

        <!-- Список изображений -->
        <section class="overflow-hidden rounded-2xl border bg-card shadow-sm">
            <div class="flex items-center justify-between border-b px-5 py-4 sm:px-6">
                <div class="flex items-center gap-3">
                    <div
                        class="flex size-10 items-center justify-center rounded-xl bg-blue-500/10 text-blue-600 dark:text-blue-400"
                    >
                        <Package :size="20" />
                    </div>
                    <div>
                        <h2 class="font-semibold">Загруженные изображения</h2>
                        <p class="mt-0.5 text-xs text-muted-foreground">
                            {{ imageCount }} {{ imageCount === 1 ? 'изображение' : imageCount < 5 ? 'изображения' : 'изображений' }}
                        </p>
                    </div>
                </div>
                <span
                    class="rounded-lg bg-muted px-2.5 py-1 text-xs font-semibold tabular-nums"
                >
                    {{ imageCount }}
                </span>
            </div>

            <div v-if="product.images.length > 0" class="grid gap-4 p-5 sm:grid-cols-2 lg:grid-cols-3">
                <div
                    v-for="(image, index) in product.images"
                    :key="image.id"
                    class="group relative overflow-hidden rounded-xl border border-border bg-card transition hover:shadow-md"
                    draggable="true"
                    @dragstart="startDrag(index)"
                    @dragover.prevent="onDragOver(index)"
                    @drop.prevent="onDrop(index)"
                    @dragend="cancelDrag"
                    :class="{ 'ring-2 ring-primary': dragItem === index }"
                >
                    <!-- Drag handle -->
                    <div class="absolute left-2 top-2 z-10 flex size-8 items-center justify-center rounded-lg bg-card/90 text-muted-foreground opacity-0 transition group-hover:opacity-100">
                        <GripVertical :size="16" />
                    </div>

                    <!-- Image -->
                    <div
                        class="aspect-square cursor-pointer bg-muted"
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
                                class="w-full rounded-lg border border-border bg-card px-3 py-1.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/20"
                                @keyup.enter="updateImageAlt(image.id)"
                                @blur="updateImageAlt(image.id)"
                                autofocus
                            />
                        </div>
                        <div v-else class="mb-3 flex items-center justify-between">
                            <span class="text-sm text-muted-foreground">
                                {{ image.alt || 'Без описания' }}
                            </span>
                            <button
                                @click="editingAlt[image.id] = image.alt || ''"
                                class="text-xs text-primary hover:text-primary/80"
                            >
                                Изменить
                            </button>
                        </div>

                        <!-- Actions -->
                        <div class="flex items-center justify-between">
                            <span class="text-xs text-muted-foreground">
                                Изображение {{ index + 1 }} из {{ product.images.length }}
                            </span>
                            <div class="flex items-center gap-1">
                                <button
                                    @click="previewImage = image.path"
                                    class="rounded-lg p-1.5 text-muted-foreground hover:bg-muted hover:text-foreground"
                                    title="Просмотр"
                                >
                                    <Check :size="16" />
                                </button>
                                <button
                                    @click="deleteImage(image.id)"
                                    class="rounded-lg p-1.5 text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
                                    title="Удалить"
                                >
                                    <Trash2 :size="16" />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Empty state -->
            <div v-else class="flex flex-col items-center px-6 py-16 text-center">
                <div
                    class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted text-muted-foreground"
                >
                    <Camera :size="32" />
                </div>
                <p class="font-medium">Нет изображений</p>
                <p class="mt-1 max-w-sm text-sm text-muted-foreground">
                    Загрузите изображения для этого товара, используя форму выше.
                </p>
            </div>
        </section>
    </div>

    <!-- Preview modal -->
    <div
        v-if="previewImage"
        class="fixed inset-0 z-50 flex items-center justify-center bg-background/80 backdrop-blur-sm p-4"
        @click.self="previewImage = null"
        @keydown.escape="previewImage = null"
    >
        <div class="max-h-[90vh] max-w-[90vw]">
            <img
                :src="previewImage"
                class="max-h-[90vh] max-w-full rounded-xl object-contain"
            />
        </div>
        <button
            @click="previewImage = null"
            class="absolute right-4 top-4 rounded-full bg-card p-2 text-foreground shadow-lg hover:bg-muted"
        >
            <X :size="24" />
        </button>
    </div>
</template>
