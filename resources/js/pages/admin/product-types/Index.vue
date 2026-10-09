<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { create, destroy, edit } from '@/routes/admin/product-types'

defineOptions({
    layout: AdminLayout,
})

interface Category {
    id: number
    name: string
}

interface ProductType {
    id: number
    category: Category
    name: string
    slug: string
    is_active: boolean
    products_count: number
}

interface PaginationLink {
    url: string | null
    label: string
    active: boolean
}

interface PaginatedProductTypes {
    data: ProductType[]
    current_page: number
    last_page: number
    from: number | null
    to: number | null
    total: number
    links: PaginationLink[]
}

interface Props {
    productTypes: PaginatedProductTypes
}

const props = defineProps<Props>()

const remove = (productType: ProductType): void => {
    if (
        !confirm(
            `Удалить тип товара «${productType.name}»?`,
        )
    ) {
        return
    }

    router.delete(destroy(productType.id).url)
}
</script>

<template>
    <Head title="Типы товаров" />

    <div class="space-y-6 p-6">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-2xl font-semibold">
                    Типы товаров
                </h1>

                <p class="mt-1 text-sm text-muted-foreground">
                    Типы товаров внутри категорий.
                </p>
            </div>

            <Link
                :href="create.url()"
                class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground"
            >
                Добавить тип
            </Link>
        </div>

        <div class="overflow-hidden rounded-xl border bg-card">
            <table class="w-full text-sm">
                <thead class="border-b bg-muted/40">
                <tr>
                    <th class="px-4 py-3 text-left">Название</th>
                    <th class="px-4 py-3 text-left">Категория</th>
                    <th class="px-4 py-3 text-left">Slug</th>
                    <th class="px-4 py-3 text-center">Товаров</th>
                    <th class="px-4 py-3 text-center">Статус</th>
                    <th class="px-4 py-3 text-right">Действия</th>
                </tr>
                </thead>

                <tbody class="divide-y">
                <tr
                    v-for="productType in props.productTypes.data"
                    :key="productType.id"
                >
                    <td class="px-4 py-3 font-medium">
                        {{ productType.name }}
                    </td>

                    <td class="px-4 py-3">
                        {{ productType.category.name }}
                    </td>

                    <td class="px-4 py-3 text-muted-foreground">
                        {{ productType.slug }}
                    </td>

                    <td class="px-4 py-3 text-center">
                        {{ productType.products_count }}
                    </td>

                    <td class="px-4 py-3 text-center">
                            <span
                                :class="
                                    productType.is_active
                                        ? 'text-green-600'
                                        : 'text-muted-foreground'
                                "
                            >
                                {{
                                    productType.is_active
                                        ? 'Активен'
                                        : 'Неактивен'
                                }}
                            </span>
                    </td>

                    <td class="px-4 py-3 text-right">
                        <div class="flex justify-end gap-2">
                            <Link
                                :href="edit(productType.id).url"
                                class="rounded-md border px-3 py-1.5"
                            >
                                Изменить
                            </Link>

                            <button
                                type="button"
                                class="rounded-md border border-red-300 px-3 py-1.5 text-red-600"
                                @click="remove(productType)"
                            >
                                Удалить
                            </button>
                        </div>
                    </td>
                </tr>

                <tr
                    v-if="props.productTypes.data.length === 0"
                >
                    <td
                        colspan="6"
                        class="px-4 py-10 text-center text-muted-foreground"
                    >
                        Типов товаров пока нет.
                    </td>
                </tr>
                </tbody>
            </table>
        </div>

        <div
            v-if="props.productTypes.last_page > 1"
            class="flex flex-wrap gap-2"
        >
            <Link
                v-for="link in props.productTypes.links"
                :key="link.label"
                :href="link.url ?? '#'"
                :class="[
                    'rounded-md border px-3 py-1.5 text-sm',
                    link.active
                        ? 'bg-primary text-primary-foreground'
                        : 'bg-background',
                    !link.url
                        ? 'pointer-events-none opacity-50'
                        : '',
                ]"
                preserve-scroll
            >
                <span v-html="link.label" />
            </Link>
        </div>
    </div>
</template>
