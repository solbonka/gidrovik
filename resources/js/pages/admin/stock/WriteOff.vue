<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import AdminLayout from '@/layouts/AdminLayout.vue'

defineOptions({ layout: AdminLayout })

interface ProductOption {
    id: number
    name: string
    sku: string
}

interface LocationOption {
    id: number
    code: string
    rack_name: string | null
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
    form.post('/admin/stock/write-off', {
        preserveScroll: true,
    })
}
</script>

<template>
    <Head title="Списание товара" />

    <div class="mx-auto max-w-3xl space-y-6">
        <div>
            <Link
                href="/admin/stock/movements"
                class="text-sm text-gray-500 hover:text-gray-900"
            >
                ← Журнал движений
            </Link>

            <h1 class="mt-3 text-2xl font-semibold text-gray-900">
                Списание товара
            </h1>

            <p class="mt-1 text-sm text-gray-500">
                Списываемое количество будет вычтено из остатка выбранной ячейки.
            </p>
        </div>

        <form
            class="space-y-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            @submit.prevent="submit"
        >
            <div>
                <label for="product_id" class="mb-2 block text-sm font-medium">
                    Товар
                </label>

                <select
                    id="product_id"
                    v-model="form.product_id"
                    required
                    class="w-full rounded-lg border-gray-300"
                >
                    <option value="" disabled>Выберите товар</option>
                    <option
                        v-for="product in products"
                        :key="product.id"
                        :value="String(product.id)"
                    >
                        {{ product.name }} — {{ product.sku }}
                    </option>
                </select>

                <p v-if="form.errors.product_id" class="mt-1 text-sm text-red-600">
                    {{ form.errors.product_id }}
                </p>
            </div>

            <div>
                <label for="location_id" class="mb-2 block text-sm font-medium">
                    Ячейка
                </label>

                <select
                    id="location_id"
                    v-model="form.location_id"
                    required
                    class="w-full rounded-lg border-gray-300"
                >
                    <option value="" disabled>Выберите ячейку</option>
                    <option
                        v-for="location in locations"
                        :key="location.id"
                        :value="String(location.id)"
                    >
                        {{ location.code }}
                        {{ location.rack_name ? `— ${location.rack_name}` : '' }}
                    </option>
                </select>

                <p v-if="form.errors.location_id" class="mt-1 text-sm text-red-600">
                    {{ form.errors.location_id }}
                </p>
            </div>

            <div>
                <label for="quantity" class="mb-2 block text-sm font-medium">
                    Количество
                </label>

                <input
                    id="quantity"
                    v-model.number="form.quantity"
                    type="number"
                    min="1"
                    step="1"
                    required
                    class="w-full rounded-lg border-gray-300"
                />

                <p v-if="form.errors.quantity" class="mt-1 text-sm text-red-600">
                    {{ form.errors.quantity }}
                </p>
            </div>

            <div>
                <label for="comment" class="mb-2 block text-sm font-medium">
                    Причина списания
                </label>

                <textarea
                    id="comment"
                    v-model="form.comment"
                    rows="3"
                    maxlength="5000"
                    required
                    placeholder="Например, брак или повреждение"
                    class="w-full rounded-lg border-gray-300"
                />

                <p v-if="form.errors.comment" class="mt-1 text-sm text-red-600">
                    {{ form.errors.comment }}
                </p>
            </div>

            <div class="flex justify-end gap-3 border-t border-gray-100 pt-5">
                <Link
                    href="/admin/stock/movements"
                    class="rounded-lg border border-gray-300 px-4 py-2 text-sm"
                >
                    Отмена
                </Link>

                <button
                    type="submit"
                    :disabled="form.processing || !products.length || !locations.length"
                    class="rounded-lg bg-red-700 px-5 py-2 text-sm font-medium text-white hover:bg-red-800 disabled:opacity-50"
                >
                    {{ form.processing ? 'Сохранение...' : 'Оформить списание' }}
                </button>
            </div>
        </form>
    </div>
</template>
