<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import { computed, ref } from 'vue'
import { Plus, Trash2, Package } from '@lucide/vue'
import { toast } from 'vue-sonner'
import AdminLayout from '@/layouts/AdminLayout.vue'
import ProductSelect from '@/components/admin/ProductSelect.vue'
import LocationSelect from '@/components/admin/LocationSelect.vue'

defineOptions({
    layout: AdminLayout,
})

interface ProductOption {
    id: number
    name: string
    sku: string | null
    unit: string
    stock_quantity?: number
    minimum_stock?: number | null
    characteristics?: string
}

interface RackOption {
    id: number
    code: string
    name: string | null
}

interface LocationOption {
    id: number
    number: number
    code: string
    rack: RackOption | null
}

interface ReceiptItem {
    product_id: string
    location_id: string
    quantity: string
    comment: string
}

interface Props {
    products: ProductOption[]
    locations: LocationOption[]
    categories?: {
        id: number
        name: string
    }[]
}

const props = defineProps<Props>()

const items = ref<ReceiptItem[]>([])

const selectedProduct = (productId: string) =>
    props.products.find((product) => String(product.id) === productId)

const isIntegerUnit = (productId: string) =>
    ['шт.', 'упаковка', 'комплект'].includes(
        selectedProduct(productId)?.unit ?? '',
    )

const quantityStep = (productId: string) =>
    isIntegerUnit(productId) ? '1' : '0.001'

const quantityMin = (productId: string) =>
    isIntegerUnit(productId) ? '1' : '0.001'

const addItem = (): void => {
    items.value.push({
        product_id: '',
        location_id: '',
        quantity: '1',
        comment: '',
    })
}

const removeItem = (index: number): void => {
    items.value.splice(index, 1)
}

const form = useForm({
    items: [] as ReceiptItem[],
})

const submit = (): void => {
    if (items.value.length === 0) {
        alert('Добавьте хотя бы один товар')
        return
    }

    form.items = items.value
    form.post('/admin/stock/receipt/batch', {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Поступление товара успешно оформлено.')
            items.value = []
            addItem()
        },
    })
}

// Add first item on mount
addItem()
</script>

<template>
    <Head title="Приёмка товара" />

    <div class="mx-auto max-w-6xl space-y-4 sm:space-y-6">
        <div>
            <Link
                href="/admin/stock"
                class="text-sm text-gray-500 hover:text-gray-900"
            >
                ← К складу
            </Link>

            <h1 class="mt-3 text-xl font-semibold text-gray-900 sm:text-2xl">
                Приёмка товара
            </h1>

            <p class="mt-1 text-sm text-gray-500">
                Приёмка нескольких товаров на склад в одном документе.
            </p>
        </div>

        <form
            class="space-y-4 sm:space-y-6 rounded-xl border border-gray-200 bg-white p-4 sm:p-6 shadow-sm"
            @submit.prevent="submit"
        >
            <!-- Items -->
            <div class="space-y-4">
                <div class="flex items-center justify-between gap-2">
                    <h2 class="text-base font-medium text-gray-900 sm:text-lg">
                        Товары ({{ items.length }})
                    </h2>

                    <button
                        type="button"
                        class="inline-flex items-center gap-2 rounded-lg bg-gray-900 px-3 py-2 text-sm font-medium text-white hover:bg-gray-800 transition-colors sm:px-4"
                        @click="addItem"
                    >
                        <Plus :size="16" />
                        <span class="hidden sm:inline">Добавить товар</span>
                        <span class="sm:hidden">Добавить</span>
                    </button>
                </div>

                <div
                    v-if="items.length === 0"
                    class="rounded-lg border border-dashed border-gray-300 p-6 sm:p-8 text-center"
                >
                    <Package :size="40" class="mx-auto text-gray-300 mb-4 sm:size-48" />
                    <p class="text-sm text-gray-500">
                        Список товаров пуст. Добавьте первый товар.
                    </p>
                </div>

                <div
                    v-for="(item, index) in items"
                    :key="index"
                    class="rounded-lg border border-gray-200 p-3 sm:p-4 space-y-3 sm:space-y-4"
                >
                    <div class="flex items-center justify-between">
                        <span class="text-sm font-medium text-gray-700">
                            Товар #{{ index + 1 }}
                        </span>

                        <button
                            type="button"
                            class="text-sm text-red-600 hover:text-red-700 transition-colors p-1"
                            @click="removeItem(index)"
                        >
                            <Trash2 :size="16" />
                        </button>
                    </div>

                    <div class="grid gap-3 sm:gap-4 sm:grid-cols-2">
                        <!-- Product -->
                        <div class="sm:col-span-2">
                            <label
                                :for="`product_${index}`"
                                class="mb-2 block text-sm font-medium text-gray-700"
                            >
                                Товар
                            </label>

                            <ProductSelect
                                :products="products"
                                :categories="categories"
                                :model-value="item.product_id"
                                :show-stock-quantity="true"
                                @update:model-value="item.product_id = $event !== null ? String($event) : ''"
                            />

                            <p
                                v-if="form.errors[`items.${index}.product_id`]"
                                class="mt-1 text-sm text-red-600"
                            >
                                {{ form.errors[`items.${index}.product_id`] }}
                            </p>
                        </div>

                        <!-- Location -->
                        <div class="sm:col-span-2">
                            <label
                                :for="`location_${index}`"
                                class="mb-2 block text-sm font-medium text-gray-700"
                            >
                                Ячейка назначения
                            </label>

                            <LocationSelect
                                :locations="locations"
                                :model-value="item.location_id"
                                @update:model-value="item.location_id = $event"
                            />

                            <p
                                v-if="form.errors[`items.${index}.location_id`]"
                                class="mt-1 text-sm text-red-600"
                            >
                                {{ form.errors[`items.${index}.location_id`] }}
                            </p>

                            <p
                                v-if="locations.length === 0"
                                class="mt-2 text-sm text-amber-700"
                            >
                                Нет доступных ячеек. Сначала создайте стеллаж и ячейки хранения.
                            </p>
                        </div>

                        <!-- Quantity -->
                        <div>
                            <label
                                :for="`quantity_${index}`"
                                class="mb-2 block text-sm font-medium text-gray-700"
                            >
                                Количество
                                <template v-if="selectedProduct(item.product_id)">
                                    ({{ selectedProduct(item.product_id).unit }})
                                </template>
                            </label>

                            <input
                                :id="`quantity_${index}`"
                                v-model="item.quantity"
                                type="number"
                                inputmode="decimal"
                                :min="quantityMin(item.product_id)"
                                max="999999999.999"
                                :step="quantityStep(item.product_id)"
                                required
                                class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500 text-sm"
                                :class="{ 'border-red-500': form.errors[`items.${index}.quantity`] }"
                            />

                            <p
                                v-if="selectedProduct(item.product_id)"
                                class="mt-1 text-xs text-gray-500"
                            >
                                <template v-if="isIntegerUnit(item.product_id)">
                                    Для этой единицы измерения допускаются только целые количества.
                                </template>
                                <template v-else>
                                    Можно указать до трёх знаков после десятичного разделителя.
                                </template>
                            </p>

                            <p
                                v-if="form.errors[`items.${index}.quantity`]"
                                class="mt-1 text-sm text-red-600"
                            >
                                {{ form.errors[`items.${index}.quantity`] }}
                            </p>
                        </div>

                        <!-- Comment -->
                        <div>
                            <label
                                :for="`comment_${index}`"
                                class="mb-2 block text-sm font-medium text-gray-700"
                            >
                                Комментарий
                            </label>

                            <textarea
                                :id="`comment_${index}`"
                                v-model="item.comment"
                                rows="2"
                                maxlength="5000"
                                placeholder="Например, поступление от поставщика"
                                class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500 text-sm"
                                :class="{ 'border-red-500': form.errors[`items.${index}.comment`] }"
                            />

                            <p
                                v-if="form.errors[`items.${index}.comment`]"
                                class="mt-1 text-sm text-red-600"
                            >
                                {{ form.errors[`items.${index}.comment`] }}
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <div
                class="flex flex-col sm:flex-row items-center justify-end gap-3 border-t border-gray-100 pt-4 sm:pt-5"
            >
                <Link
                    href="/admin/stock"
                    class="w-full sm:w-auto rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors text-center"
                >
                    Отмена
                </Link>

                <button
                    type="submit"
                    :disabled="
                        form.processing
                        || items.length === 0
                        || locations.length === 0
                    "
                    class="w-full sm:w-auto rounded-lg bg-gray-900 px-5 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50 transition-colors"
                >
                    {{
                        form.processing
                            ? 'Сохранение...'
                            : 'Оформить поступление'
                    }}
                </button>
            </div>
        </form>
    </div>
</template>
