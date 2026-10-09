<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import { ref } from 'vue'
import AdminLayout from '@/layouts/AdminLayout.vue'
import {
    create,
    destroy,
    edit,
    show,
} from '@/routes/admin/products'

defineOptions({
    layout: AdminLayout,
})

interface Category {
    id: number
    name: string
}

interface ProductType {
    id: number
    category_id: number
    name: string
    category?: Category
}

interface Product {
    id: number
    name: string
    sku: string
    is_active: boolean
    stock_quantity: number | null
    category: Category
    product_type: ProductType | null
}

interface PaginationLink {
    url: string | null
    label: string
    active: boolean
}

interface PaginatedProducts {
    data: Product[]
    current_page: number
    last_page: number
    from: number | null
    to: number | null
    total: number
    links: PaginationLink[]
}

interface Filters {
    search: string
    category_id: number | null
    product_type_id: number | null
}

interface Props {
    products: PaginatedProducts
    filters: Filters
    categories: Category[]
    productTypes: ProductType[]
}

const props = defineProps<Props>()

const search = ref(props.filters.search)
const categoryId = ref(
    props.filters.category_id?.toString() ?? '',
)
const productTypeId = ref(
    props.filters.product_type_id?.toString() ?? '',
)

const submitFilters = (): void => {
    router.get(
        '/admin/products',
        {
            search: search.value || undefined,
            category_id: categoryId.value || undefined,
            product_type_id: productTypeId.value || undefined,
        },
        {
            preserveState: true,
            preserveScroll: true,
        },
    )
}

const resetFilters = (): void => {
    search.value = ''
    categoryId.value = ''
    productTypeId.value = ''

    router.get('/admin/products')
}

const deleteProduct = (product: Product): void => {
    if (
        !window.confirm(
            `Удалить товар «${product.name}»?\n\nЭто действие нельзя отменить.`,
        )
    ) {
        return
    }

    router.delete(destroy(product.id).url)
}
</script>

<template>
    <Head title="Товары" />

    <div class="space-y-6">
        <div class="flex items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-semibold text-gray-900">
                    Товары
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    Каталог товаров и их складские остатки.
                </p>
            </div>

            <Link
                :href="create().url"
                class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800"
            >
                Добавить товар
            </Link>
        </div>

        <div
            class="rounded-xl border border-gray-200 bg-white p-5 shadow-sm"
        >
            <div class="grid gap-4 lg:grid-cols-4">
                <div class="lg:col-span-2">
                    <label
                        for="search"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Поиск
                    </label>

                    <input
                        id="search"
                        v-model="search"
                        type="search"
                        placeholder="Название или артикул..."
                        class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                        @keyup.enter="submitFilters"
                    />
                </div>

                <div>
                    <label
                        for="category"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Категория
                    </label>

                    <select
                        id="category"
                        v-model="categoryId"
                        class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                        @change="submitFilters"
                    >
                        <option value="">
                            Все категории
                        </option>

                        <option
                            v-for="category in categories"
                            :key="category.id"
                            :value="category.id"
                        >
                            {{ category.name }}
                        </option>
                    </select>
                </div>

                <div>
                    <label
                        for="product-type"
                        class="mb-2 block text-sm font-medium text-gray-700"
                    >
                        Тип товара
                    </label>

                    <select
                        id="product-type"
                        v-model="productTypeId"
                        class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                        @change="submitFilters"
                    >
                        <option value="">
                            Все типы
                        </option>

                        <option
                            v-for="productType in productTypes"
                            :key="productType.id"
                            :value="productType.id"
                        >
                            {{ productType.name }}
                        </option>
                    </select>
                </div>
            </div>

            <div class="mt-4 flex justify-between">
                <button
                    type="button"
                    class="text-sm text-gray-500 hover:text-gray-900"
                    @click="resetFilters"
                >
                    Сбросить фильтры
                </button>

                <button
                    type="button"
                    class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800"
                    @click="submitFilters"
                >
                    Найти
                </button>
            </div>
        </div>

        <div
            class="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm"
        >
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead
                        class="border-b border-gray-200 bg-gray-50 text-xs uppercase text-gray-500"
                    >
                    <tr>
                        <th class="px-6 py-3">
                            Товар
                        </th>

                        <th class="px-6 py-3">
                            Артикул
                        </th>

                        <th class="px-6 py-3">
                            Категория
                        </th>

                        <th class="px-6 py-3">
                            Тип
                        </th>

                        <th class="px-6 py-3">
                            Остаток
                        </th>

                        <th class="px-6 py-3">
                            Статус
                        </th>

                        <th class="px-6 py-3 text-right">
                            Действия
                        </th>
                    </tr>
                    </thead>

                    <tbody class="divide-y divide-gray-200">
                    <tr
                        v-for="product in products.data"
                        :key="product.id"
                        class="hover:bg-gray-50"
                    >
                        <td class="px-6 py-4">
                            <div class="font-medium text-gray-900">
                                {{ product.name }}
                            </div>
                        </td>

                        <td class="px-6 py-4">
                                <span class="font-mono text-sm text-gray-600">
                                    {{ product.sku }}
                                </span>
                        </td>

                        <td class="px-6 py-4 text-gray-600">
                            {{ product.category.name }}
                        </td>

                        <td class="px-6 py-4 text-gray-600">
                            {{ product.product_type?.name ?? '—' }}
                        </td>

                        <td class="px-6 py-4">
                                <span
                                    class="font-medium"
                                    :class="
                                        Number(product.stock_quantity ?? 0) > 0
                                            ? 'text-gray-900'
                                            : 'text-gray-400'
                                    "
                                >
                                    {{ product.stock_quantity ?? 0 }}
                                </span>
                        </td>

                        <td class="px-6 py-4">
                                <span
                                    class="inline-flex rounded-full px-2.5 py-1 text-xs font-medium"
                                    :class="
                                        product.is_active
                                            ? 'bg-green-100 text-green-700'
                                            : 'bg-gray-100 text-gray-600'
                                    "
                                >
                                    {{
                                        product.is_active
                                            ? 'Активен'
                                            : 'Неактивен'
                                    }}
                                </span>
                        </td>

                        <td class="px-6 py-4 text-right">
                            <div class="flex items-center justify-end gap-3">
                                <Link
                                    :href="show(product.id).url"
                                    class="text-sm font-medium text-gray-600 hover:text-gray-900"
                                >
                                    Просмотр
                                </Link>

                                <Link
                                    :href="edit(product.id).url"
                                    class="text-sm font-medium text-gray-600 hover:text-gray-900"
                                >
                                    Изменить
                                </Link>

                                <button
                                    type="button"
                                    class="text-sm font-medium text-red-600 hover:text-red-800"
                                    @click="deleteProduct(product)"
                                >
                                    Удалить
                                </button>
                            </div>
                        </td>
                    </tr>

                    <tr v-if="products.data.length === 0">
                        <td
                            colspan="7"
                            class="px-6 py-12 text-center text-gray-500"
                        >
                            Товары не найдены.
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <div
                v-if="products.last_page > 1"
                class="flex items-center justify-between border-t border-gray-200 px-6 py-4"
            >
                <div class="text-sm text-gray-500">
                    Показано {{ products.from }}–{{ products.to }}
                    из {{ products.total }}
                </div>

                <div class="flex gap-1">
                    <template
                        v-for="(link, index) in products.links"
                        :key="index"
                    >
                        <Link
                            v-if="link.url"
                            :href="link.url"
                            class="rounded-md px-3 py-1.5 text-sm"
                            :class="
                                link.active
                                    ? 'bg-gray-900 text-white'
                                    : 'text-gray-600 hover:bg-gray-100'
                            "
                            v-html="link.label"
                        />

                        <span
                            v-else
                            class="rounded-md px-3 py-1.5 text-sm text-gray-300"
                            v-html="link.label"
                        />
                    </template>
                </div>
            </div>
        </div>
    </div>
</template>
