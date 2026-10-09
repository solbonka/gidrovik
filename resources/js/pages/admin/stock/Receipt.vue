<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'

defineOptions({
    layout: AdminLayout,
})

interface ProductOption {
    id: number
    name: string
    sku: string | null
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
}

defineProps<Props>()

const form = useForm({
    product_id: '',
    location_id: '',
    quantity: 1,
    comment: '',
})

const submit = (): void => {
    form.post('/admin/stock/return', {
        preserveScroll: true,
    })
}
</script>

<template>
    <Head title="Возврат товара" />

    <div class="mx-auto max-w-3xl space-y-6">
        <div>
            <Link
                href="/admin/products"
                class="text-sm text-gray-500 hover:text-gray-900"
            >
                ← К списку товаров
            </Link>

            <h1 class="mt-3 text-2xl font-semibold text-gray-900">
                Возврат товара
            </h1>

            <p class="mt-1 text-sm text-gray-500">
                Возврат товара на склад с записью в историю движений.
            </p>
        </div>

        <form
            class="space-y-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            @submit.prevent="submit"
        >
            <div>
                <label
                    for="product_id"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Товар
                </label>

                <select
                    id="product_id"
                    v-model="form.product_id"
                    required
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                    :class="{ 'border-red-500': form.errors.product_id }"
                >
                    <option value="" disabled>
                        Выберите товар
                    </option>

                    <option
                        v-for="product in products"
                        :key="product.id"
                        :value="String(product.id)"
                    >
                        {{ product.name }}
                        <template v-if="product.sku">
                            — {{ product.sku }}
                        </template>
                    </option>
                </select>

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
                    Ячейка назначения
                </label>

                <select
                    id="location_id"
                    v-model="form.location_id"
                    required
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                    :class="{ 'border-red-500': form.errors.location_id }"
                >
                    <option value="" disabled>
                        Выберите ячейку
                    </option>

                    <option
                        v-for="location in locations"
                        :key="location.id"
                        :value="String(location.id)"
                    >
                        {{ location.code }}
                        <template v-if="location.rack?.name">
                            — {{ location.rack.name }}
                        </template>
                    </option>
                </select>

                <p
                    v-if="form.errors.location_id"
                    class="mt-1 text-sm text-red-600"
                >
                    {{ form.errors.location_id }}
                </p>

                <p
                    v-if="locations.length === 0"
                    class="mt-2 text-sm text-amber-700"
                >
                    Нет доступных ячеек. Сначала создайте стеллаж и ячейки хранения.
                </p>
            </div>

            <div>
                <label
                    for="quantity"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Количество
                </label>

                <input
                    id="quantity"
                    v-model.number="form.quantity"
                    type="number"
                    min="1"
                    max="2147483647"
                    step="1"
                    required
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                    :class="{ 'border-red-500': form.errors.quantity }"
                />

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
                    Причина возврата
                </label>

                <textarea
                    id="comment"
                    v-model="form.comment"
                    rows="3"
                    maxlength="5000"
                    required
                    placeholder="Например, возврат от покупателя или результат проверки качества"
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
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
                class="flex items-center justify-end gap-3 border-t border-gray-100 pt-5"
            >
                <Link
                    href="/admin/products"
                    class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                    Отмена
                </Link>

                <button
                    type="submit"
                    :disabled="
                        form.processing
                        || products.length === 0
                        || locations.length === 0
                    "
                    class="rounded-lg bg-gray-900 px-5 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
                >
                    {{
                        form.processing
                            ? 'Сохранение...'
                            : 'Оформить возврат'
                    }}
                </button>
            </div>
        </form>
    </div>
</template>
