<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3'
import { computed, watch } from 'vue'
import {
    ArrowLeft,
    Check,
    CirclePlus,
    FileText,
    Info,
    LoaderCircle,
    Package,
    Save,
    Trash2,
} from '@lucide/vue'
import { toast } from 'vue-sonner'
import AdminLayout from '@/layouts/AdminLayout.vue'
import ProductSelect from '@/components/admin/ProductSelect.vue'
import LocationSelect from '@/components/admin/LocationSelect.vue'

defineOptions({ layout: AdminLayout })

interface ProductOption {
    id: number
    name: string
    sku: string
    unit: string
    stock_quantity?: number
    minimum_stock?: number | null
    characteristics?: string
}

interface LocationOption {
    id: number
    code: string
    rack_name: string | null
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
    location_id: '',
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
    form.post('/admin/stock/write-off', {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Списание товара успешно оформлено.')
            form.reset()
        },
    })
}
</script>

<template>
    <Head title="Списание товара" />

    <div class="space-y-6 p-4 sm:p-6">
        <!-- Заголовок -->
        <div
            class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-indigo-950 to-violet-900 p-6 text-white shadow-lg sm:p-8"
        >
            <div
                class="pointer-events-none absolute -right-10 -top-16 h-52 w-52 rounded-full bg-violet-400/20 blur-3xl"
            />

            <div class="relative">
                <Link
                    href="/admin/stock/movements"
                    class="mb-5 inline-flex items-center gap-2 rounded-lg border border-white/20 bg-white/10 px-3 py-2 text-sm text-indigo-100 transition hover:bg-white/20 hover:text-white"
                >
                    <ArrowLeft class="h-4 w-4" />
                    Журнал движений
                </Link>

                <div class="flex items-center gap-4">
                    <div class="hidden rounded-2xl border border-white/15 bg-white/10 p-3 sm:block">
                        <Trash2 class="h-8 w-8 text-indigo-200" />
                    </div>

                    <div>
                        <div class="mb-2 flex items-center gap-2 text-sm text-indigo-200">
                            <Package class="h-4 w-4" />
                            Склад
                        </div>

                        <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                            Списание товара
                        </h1>

                        <p class="mt-2 max-w-xl text-sm text-slate-300 sm:text-base">
                            Списываемое количество будет вычтено из остатка выбранной ячейки.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 items-start gap-6 xl:grid-cols-[minmax(0,1fr)_300px]">
            <form
                class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900"
                @submit.prevent="submit"
            >
                <div class="border-b border-slate-200 px-5 py-5 dark:border-slate-800 sm:px-7">
                    <div class="flex items-center gap-3">
                        <div class="rounded-xl bg-rose-50 p-2.5 dark:bg-rose-500/10">
                            <Trash2 class="h-5 w-5 text-rose-600 dark:text-rose-400" />
                        </div>

                        <div>
                            <h2 class="font-semibold text-slate-900 dark:text-white">
                                Данные списания
                            </h2>
                            <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
                                Заполните обязательные поля формы.
                            </p>
                        </div>
                    </div>
                </div>

                <div class="space-y-6 p-5 sm:p-7">
                    <div>
                        <label
                            for="product_id"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Товар
                            <span class="text-rose-500">*</span>
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
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.product_id }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="location_id"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Ячейка
                            <span class="text-rose-500">*</span>
                        </label>

                        <LocationSelect
                            :locations="locations"
                            :model-value="form.location_id"
                            @update:model-value="form.location_id = $event"
                        />

                        <p
                            v-if="form.errors.location_id"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.location_id }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="quantity"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Количество
                            <template v-if="selectedProduct">
                                ({{ selectedProduct.unit }})
                            </template>
                            <span class="text-rose-500">*</span>
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
                            class="w-full rounded-xl border bg-slate-50 py-3 px-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                            :class="{ 'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500': form.errors.quantity, 'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700': !form.errors.quantity }"
                        />

                        <p
                            v-if="selectedProduct"
                            class="mt-2 text-xs text-slate-500 dark:text-slate-400"
                        >
                            <template v-if="isIntegerUnit">
                                Для этой единицы измерения допускаются только целые количества.
                            </template>
                            <template v-else>
                                Можно указать до трёх знаков после десятичного разделителя.
                            </template>
                        </p>

                        <p
                            v-if="form.errors.quantity"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.quantity }}
                        </p>
                    </div>

                    <div>
                        <label
                            for="comment"
                            class="mb-2 block text-sm font-semibold text-slate-700 dark:text-slate-200"
                        >
                            Причина списания
                            <span class="text-rose-500">*</span>
                        </label>

                        <textarea
                            id="comment"
                            v-model="form.comment"
                            rows="3"
                            maxlength="5000"
                            required
                            placeholder="Например, брак или повреждение"
                            class="w-full resize-y rounded-xl border bg-slate-50 py-3 px-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:bg-white focus:ring-4 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                            :class="{ 'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10 dark:border-rose-500': form.errors.comment, 'border-slate-200 focus:border-indigo-500 focus:ring-indigo-500/10 dark:border-slate-700': !form.errors.comment }"
                        />

                        <p
                            v-if="form.errors.comment"
                            class="mt-2 flex items-center gap-1.5 text-sm text-rose-600 dark:text-rose-400"
                        >
                            <Info class="h-4 w-4 shrink-0" />
                            {{ form.errors.comment }}
                        </p>
                    </div>
                </div>

                <div
                    class="flex flex-col-reverse gap-3 border-t border-slate-200 bg-slate-50/70 px-5 py-4 dark:border-slate-800 dark:bg-slate-950/40 sm:flex-row sm:justify-end sm:px-7"
                >
                    <Link
                        href="/admin/stock/movements"
                        class="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-5 py-2.5 text-sm font-semibold text-slate-700 transition hover:bg-slate-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-400 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
                    >
                        <ArrowLeft class="h-4 w-4" />
                        Отмена
                    </Link>

                    <button
                        type="submit"
                        :disabled="form.processing || !products.length || !locations.length"
                        class="inline-flex items-center justify-center gap-2 rounded-xl bg-rose-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-rose-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-rose-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60 dark:focus-visible:ring-offset-slate-900"
                    >
                        <LoaderCircle
                            v-if="form.processing"
                            class="h-4 w-4 animate-spin"
                        />
                        <Trash2 v-else class="h-4 w-4" />

                        {{ form.processing ? 'Сохранение...' : 'Оформить списание' }}
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>
