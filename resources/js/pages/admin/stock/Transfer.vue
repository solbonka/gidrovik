<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import { computed, watch } from 'vue'
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
    sku: string
    unit: string
    stock_quantity?: number
    minimum_stock?: number | null
    characteristics?: string
}

interface RackOption {
    code: string
    name: string | null
}

interface LocationOption {
    id: number
    code: string
    rack: RackOption
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

const form = useForm({
    product_id: '',
    from_location_id: '',
    to_location_id: '',
    quantity: '1',
    comment: '',
})

const selectedProduct = computed(() =>
    props.products.find(
        (product) => String(product.id) === form.product_id,
    ),
)

const isIntegerUnit = computed(() =>
    ['шт.', 'упаковка', 'комплект'].includes(
        selectedProduct.value?.unit ?? '',
    ),
)

const quantityStep = computed(() =>
    isIntegerUnit.value ? '1' : '0.001',
)

const quantityMin = computed(() =>
    isIntegerUnit.value ? '1' : '0.001',
)

watch(
    () => form.product_id,
    () => {
        form.clearErrors('quantity')
    },
)

const submit = (): void => {
    form.post('/admin/stock/transfer', {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Товар успешно перемещён.')
            form.reset()
        },
    })
}
</script>

<template>
    <Head title="Перемещение товара" />

    <div class="mx-auto max-w-3xl space-y-4 sm:space-y-6">
        <div>
            <Link
                href="/admin/products"
                class="text-sm text-gray-500 hover:text-gray-900"
            >
                ← К списку товаров
            </Link>

            <h1 class="mt-3 text-xl font-semibold text-gray-900 sm:text-2xl">
                Перемещение товара
            </h1>

            <p class="mt-1 text-sm text-gray-500">
                Перенос товара из одной ячейки хранения в другую.
            </p>
        </div>

        <form
            class="space-y-4 sm:space-y-6 rounded-xl border border-gray-200 bg-white p-4 sm:p-6 shadow-sm"
            @submit.prevent="submit"
        >
            <div>
                <label
                    for="product_id"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Товар
                </label>

                <ProductSelect
                    :products="products"
                    :categories="categories"
                    :model-value="form.product_id"
                    :show-stock-quantity="true"
                    @update:model-value="form.product_id = $event !== null ? String($event) : ''"
                />

                <p
                    v-if="form.errors.product_id"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.product_id }}
                </p>
            </div>

            <div>
                <label
                    for="from_location_id"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Откуда переместить
                </label>

                <LocationSelect
                    :locations="locations"
                    :model-value="form.from_location_id"
                    @update:model-value="form.from_location_id = $event"
                />

                <p
                    v-if="form.errors.from_location_id"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.from_location_id }}
                </p>
            </div>

            <div>
                <label
                    for="to_location_id"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Куда переместить
                </label>

                <LocationSelect
                    :locations="locations"
                    :model-value="form.to_location_id"
                    @update:model-value="form.to_location_id = $event"
                />

                <p
                    v-if="form.errors.to_location_id"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.to_location_id }}
                </p>
            </div>

            <div>
                <label
                    for="quantity"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Количество
                    <template v-if="selectedProduct">
                        ({{ selectedProduct.unit }})
                    </template>
                </label>

                <input
                    id="quantity"
                    v-model="form.quantity"
                    type="number"
                    inputmode="decimal"
                    :min="quantityMin"
                    max="999999999.999"
                    :step="quantityStep"
                    required
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500 text-sm"
                />

                <p
                    v-if="selectedProduct"
                    class="mt-1 text-xs text-gray-500"
                >
                    <template v-if="isIntegerUnit">
                        Для этой единицы измерения допускаются только целые
                        количества.
                    </template>
                    <template v-else>
                        Можно указать до трёх знаков после десятичного
                        разделителя.
                    </template>
                </p>

                <p
                    v-if="form.errors.quantity"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.quantity }}
                </p>
            </div>

            <div>
                <label
                    for="comment"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Комментарий
                </label>

                <textarea
                    id="comment"
                    v-model="form.comment"
                    rows="3"
                    maxlength="5000"
                    placeholder="Причина перемещения"
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500 text-sm"
                />

                <p
                    v-if="form.errors.comment"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.comment }}
                </p>
            </div>

            <div
                v-if="locations.length === 0"
                class="rounded-lg bg-amber-50 p-3 text-sm text-amber-800"
            >
                Сначала создайте ячейки хранения.
            </div>

            <div class="flex flex-col sm:flex-row items-center justify-end gap-3 border-t border-gray-100 pt-4 sm:pt-5">
                <Link
                    href="/admin/products"
                    class="w-full sm:w-auto rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 text-center"
                >
                    Отмена
                </Link>

                <button
                    type="submit"
                    :disabled="
                        form.processing
                        || products.length === 0
                        || locations.length < 2
                    "
                    class="w-full sm:w-auto rounded-lg bg-gray-900 px-5 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                >
                    {{
                        form.processing
                            ? 'Сохранение...'
                            : 'Переместить товар'
                    }}
                </button>
            </div>
        </form>
    </div>
</template>
