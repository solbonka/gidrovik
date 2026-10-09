<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'

defineOptions({
    layout: AdminLayout,
})

interface ProductOption {
    id: number
    name: string
    sku: string
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
}

defineProps<Props>()

const form = useForm({
    product_id: '',
    from_location_id: '',
    to_location_id: '',
    quantity: 1,
    comment: '',
})

const submit = (): void => {
    form.post('/admin/stock/transfer', {
        preserveScroll: true,
    })
}
</script>

<template>
    <Head title="Перемещение товара" />

    <div class="mx-auto max-w-3xl space-y-6">
        <div>
            <Link
                href="/admin/products"
                class="text-sm text-gray-500 hover:text-gray-900"
            >
                ← К списку товаров
            </Link>

            <h1 class="mt-3 text-2xl font-semibold text-gray-900">
                Перемещение товара
            </h1>

            <p class="mt-1 text-sm text-gray-500">
                Перенос товара из одной ячейки хранения в другую.
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
                >
                    <option value="" disabled>
                        Выберите товар
                    </option>

                    <option
                        v-for="product in products"
                        :key="product.id"
                        :value="String(product.id)"
                    >
                        {{ product.name }} — {{ product.sku }}
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
                    for="from_location_id"
                    class="mb-2 block text-sm font-medium text-gray-700"
                >
                    Откуда переместить
                </label>

                <select
                    id="from_location_id"
                    v-model="form.from_location_id"
                    required
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                >
                    <option value="" disabled>
                        Исходная ячейка
                    </option>

                    <option
                        v-for="location in locations"
                        :key="location.id"
                        :value="String(location.id)"
                    >
                        {{ location.code }}
                        <template v-if="location.rack.name">
                            — {{ location.rack.name }}
                        </template>
                    </option>
                </select>

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

                <select
                    id="to_location_id"
                    v-model="form.to_location_id"
                    required
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
                >
                    <option value="" disabled>
                        Целевая ячейка
                    </option>

                    <option
                        v-for="location in locations"
                        :key="location.id"
                        :value="String(location.id)"
                        :disabled="form.from_location_id === String(location.id)"
                    >
                        {{ location.code }}
                        <template v-if="location.rack.name">
                            — {{ location.rack.name }}
                        </template>
                    </option>
                </select>

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
                </label>

                <input
                    id="quantity"
                    v-model.number="form.quantity"
                    type="number"
                    min="1"
                    step="1"
                    required
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
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
                    Комментарий
                </label>

                <textarea
                    id="comment"
                    v-model="form.comment"
                    rows="3"
                    maxlength="5000"
                    placeholder="Причина перемещения"
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-gray-500 focus:ring-gray-500"
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

            <div class="flex items-center justify-end gap-3 border-t border-gray-100 pt-5">
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
                        || locations.length < 2
                    "
                    class="rounded-lg bg-gray-900 px-5 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
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
