<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { Head, Link, useForm } from '@inertiajs/vue3'
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

interface Props {
    products: ProductOption[]
    locations: LocationOption[]
    categories?: {
        id: number
        name: string
    }[]
}

interface CurrentStockResponse {
    quantity: number
}

const props = defineProps<Props>()

const form = useForm({
    product_id: '',
    location_id: '',
    actual_quantity: 0,
    comment: '',
})

const currentQuantity = ref<number | null>(null)
const loadingQuantity = ref(false)
const quantityError = ref('')

const difference = computed<number | null>(() => {
    if (currentQuantity.value === null) {
        return null
    }

    return form.actual_quantity - currentQuantity.value
})

const differenceLabel = computed<string>(() => {
    if (difference.value === null) {
        return '—'
    }

    if (difference.value > 0) {
        return `+${difference.value} шт.`
    }

    return `${difference.value} шт.`
})

const differenceClass = computed<string>(() => {
    if (difference.value === null || difference.value === 0) {
        return 'text-gray-600'
    }

    return difference.value > 0
        ? 'text-green-700'
        : 'text-red-600'
})

let requestController: AbortController | null = null

watch(
    [() => form.product_id, () => form.location_id],
    async ([productId, locationId]) => {
        requestController?.abort()
        currentQuantity.value = null
        quantityError.value = ''

        if (!productId || !locationId) {
            return
        }

        const controller = new AbortController()
        requestController = controller
        loadingQuantity.value = true

        try {
            const params = new URLSearchParams({
                product_id: productId,
                location_id: locationId,
            })

            const response = await fetch(
                `/admin/stock/inventory/current?${params.toString()}`,
                {
                    headers: {
                        Accept: 'application/json',
                    },
                    credentials: 'same-origin',
                    signal: controller.signal,
                },
            )

            if (!response.ok) {
                throw new Error('Не удалось загрузить текущий остаток.')
            }

            const data = (await response.json()) as CurrentStockResponse

            if (!controller.signal.aborted) {
                currentQuantity.value = data.quantity
            }
        } catch (error: unknown) {
            if (error instanceof DOMException && error.name === 'AbortError') {
                return
            }

            quantityError.value = error instanceof Error
                ? error.message
                : 'Не удалось загрузить текущий остаток.'
        } finally {
            if (!controller.signal.aborted) {
                loadingQuantity.value = false
            }
        }
    },
)

const submit = (): void => {
    if (currentQuantity.value === null || loadingQuantity.value) {
        return
    }

    form.post('/admin/stock/inventory', {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Инвентаризация успешно завершена.')
            form.reset()
            currentQuantity.value = null
        },
    })
}
</script>

<template>
    <Head title="Инвентаризация" />

    <div class="mx-auto max-w-3xl space-y-4 sm:space-y-6">
        <div>
            <Link
                href="/admin/stock/movements"
                class="text-sm text-gray-500 hover:text-gray-900"
            >
                ← К журналу складских операций
            </Link>

            <h1 class="mt-3 text-xl font-semibold text-gray-900 sm:text-2xl">
                Инвентаризация
            </h1>

            <p class="mt-1 text-sm text-gray-500">
                Сверка фактического количества товара с учётным остатком.
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
                    :products="props.products"
                    :categories="categories"
                    :model-value="form.product_id"
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
                    for="location_id"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Ячейка хранения
                </label>

                <LocationSelect
                    :locations="props.locations"
                    :model-value="form.location_id"
                    @update:model-value="form.location_id = $event"
                />

                <p
                    v-if="form.errors.location_id"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.location_id }}
                </p>

                <p
                    v-if="props.locations.length === 0"
                    class="mt-2 text-sm text-amber-700"
                >
                    Нет доступных ячеек. Сначала создайте стеллаж и ячейки хранения.
                </p>
            </div>

            <div class="rounded-lg border border-gray-200 bg-gray-50 p-3 sm:p-4">
                <div class="flex items-center justify-between gap-4">
                    <span class="text-sm font-medium text-gray-600">
                        Текущий остаток
                    </span>

                    <span class="text-base sm:text-lg font-semibold text-gray-900">
                        <template v-if="loadingQuantity">
                            Загрузка…
                        </template>
                        <template v-else-if="currentQuantity !== null">
                            {{ currentQuantity }} шт.
                        </template>
                        <template v-else>
                            —
                        </template>
                    </span>
                </div>

                <p
                    v-if="quantityError"
                    class="mt-2 text-sm text-red-600"
                >
                    {{ quantityError }}
                </p>
            </div>

            <div>
                <label
                    for="actual_quantity"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Фактическое количество
                </label>

                <input
                    id="actual_quantity"
                    v-model.number="form.actual_quantity"
                    type="number"
                    min="0"
                    max="2147483647"
                    step="1"
                    required
                    class="block w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm focus:border-gray-500 focus:outline-none focus:ring-1 focus:ring-gray-500"
                    :class="{
                        'border-red-500': form.errors.actual_quantity,
                    }"
                />

                <p
                    v-if="form.errors.actual_quantity"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.actual_quantity }}
                </p>

                <p class="mt-1 text-sm text-gray-500">
                    Введите количество, которое фактически обнаружено в ячейке.
                </p>
            </div>

            <div
                class="flex items-center justify-between gap-4 rounded-lg border border-gray-200 px-3 sm:px-4 py-3"
            >
                <span class="text-sm font-medium text-gray-700">
                    Расхождение
                </span>

                <span
                    class="text-base font-semibold"
                    :class="differenceClass"
                >
                    {{ differenceLabel }}
                </span>
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
                    required
                    placeholder="Например, плановая проверка остатков"
                    class="block w-full resize-y rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm placeholder:text-gray-400 focus:border-gray-500 focus:outline-none focus:ring-1 focus:ring-gray-500"
                    :class="{ 'border-red-500': form.errors.comment }"
                />

                <p
                    v-if="form.errors.comment"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.comment }}
                </p>
            </div>

            <div
                class="flex flex-col sm:flex-row items-center justify-end gap-3 border-t border-gray-100 pt-4 sm:pt-5"
            >
                <Link
                    href="/admin/stock/movements"
                    class="w-full sm:w-auto rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 text-center"
                >
                    Отмена
                </Link>

                <button
                    type="submit"
                    :disabled="
                        form.processing
                        || loadingQuantity
                        || currentQuantity === null
                        || props.products.length === 0
                        || props.locations.length === 0
                    "
                    class="w-full sm:w-auto rounded-lg bg-gray-900 px-5 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                >
                    {{
                        form.processing
                            ? 'Сохранение...'
                            : 'Завершить инвентаризацию'
                    }}
                </button>
            </div>
        </form>
    </div>
</template>
