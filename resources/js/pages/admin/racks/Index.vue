<script setup lang="ts">
import { Head, Link, router } from '@inertiajs/vue3'
import { ref, watch, computed } from 'vue'
import { toast } from 'vue-sonner'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { create, destroy, edit } from '@/routes/admin/racks'
import {
    destroy as destroyLocation,
    store as storeLocation,
} from '@/routes/admin/racks/locations'
import { Package, X } from '@lucide/vue'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import ProductSelect from '@/components/admin/ProductSelect.vue'

defineOptions({
    layout: AdminLayout,
})

interface Location {
    id: number
    rack_id: number
    number: number
    code: string
    stock_quantity: number | null
    incoming_movements_count: number
    outgoing_movements_count: number
}

interface Rack {
    id: number
    code: string
    name: string | null
    locations_count: number
    locations: Location[]
}

interface Props {
    racks: Rack[]
    allProducts: {
        id: number
        name: string
        sku: string | null
        unit: string
        characteristics?: string
        category_id?: number | null
    }[]
    allLocations: {
        id: number
        code: string
        rack_name: string | null
    }[]
    categories?: {
        id: number
        name: string
    }[]
}

interface LocationProduct {
    id: number
    name: string
    sku: string | null
    quantity: string | number
}

interface ProductStockLocation {
    id: number
    number: number
    code: string | null
    quantity: string | number
}

interface ProductDetails {
    id: number
    name: string
    sku: string | null
    quantity: string | number
}

const props = defineProps<Props>()

// Преобразуем товары для ProductSelect
const productsForSelect = computed(() => {
    return props.allProducts.map(p => ({
        id: p.id,
        name: p.name,
        sku: p.sku,
        unit: p.unit,
        characteristics: p.characteristics,
    }))
})

const locationQuantity = (location: Location): number => {
    const parsed = Number(location.stock_quantity ?? 0)

    return Number.isFinite(parsed) ? parsed : 0
}

const hasStock = (location: Location): boolean =>
    locationQuantity(location) > 0

const addingLocationRackId = ref<number | null>(null)
const newLocationNumber = ref<Record<number, string>>({})

const locationModal = ref({
    open: false,
    locationCode: '',
    locationId: null as number | null,
    products: [] as LocationProduct[],
    loading: false,
    operation: null as 'receipt' | 'write_off' | 'transfer' | 'return' | 'inventory' | null,
    operationLoading: false,
})

const operationForm = ref({
    product_id: '',
    quantity: '1',
    comment: '',
    to_location_id: '',
    current_quantity: null as number | null,
})

const productDetailsModal = ref({
    open: false,
    loading: false,
    error: '',
    product: null as ProductDetails | null,
    locations: [] as ProductStockLocation[],
    totalQuantity: 0,
})

const deleteConfirmation = ref({
    open: false,
    type: null as 'rack' | 'location' | null,
    rack: null as Rack | null,
    location: null as Location | null,
    loading: false,
})

const formatQuantity = (value: string | number | null | undefined): string => {
    const quantity = Number(value ?? 0)

    return Number.isFinite(quantity)
        ? quantity.toLocaleString('ru-RU', { maximumFractionDigits: 3 })
        : '0'
}

const startOperation = (operation: 'receipt' | 'write_off' | 'transfer' | 'return' | 'inventory'): void => {
    locationModal.value.operation = operation
    operationForm.value = {
        product_id: '',
        quantity: '1',
        comment: '',
        to_location_id: '',
        current_quantity: null,
    }
}

const closeOperation = (): void => {
    locationModal.value.operation = null
    operationForm.value = {
        product_id: '',
        quantity: '1',
        comment: '',
        to_location_id: '',
        current_quantity: null,
    }
}

const submitOperation = async (): Promise<void> => {
    if (!locationModal.value.locationId) return

    locationModal.value.operationLoading = true

    try {
        const formData = new FormData()
        formData.append('product_id', operationForm.value.product_id)
        formData.append('comment', operationForm.value.comment)

        let url = ''
        let method = 'POST'

        switch (locationModal.value.operation) {
            case 'receipt':
                url = '/admin/stock/receipt'
                formData.append('location_id', String(locationModal.value.locationId))
                formData.append('quantity', operationForm.value.quantity)
                break
            case 'write_off':
                url = '/admin/stock/write-off'
                formData.append('location_id', String(locationModal.value.locationId))
                formData.append('quantity', operationForm.value.quantity)
                break
            case 'transfer':
                url = '/admin/stock/transfer'
                formData.append('from_location_id', String(locationModal.value.locationId))
                formData.append('to_location_id', operationForm.value.to_location_id)
                formData.append('quantity', operationForm.value.quantity)
                break
            case 'return':
                url = '/admin/stock/return'
                formData.append('location_id', String(locationModal.value.locationId))
                formData.append('quantity', operationForm.value.quantity)
                break
            case 'inventory':
                url = '/admin/stock/inventory'
                formData.append('location_id', String(locationModal.value.locationId))
                formData.append('actual_quantity', operationForm.value.quantity)
                break
        }

        const response = await fetch(url, {
            method,
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json',
            },
            body: formData,
        })

        if (response.ok) {
            toast.success('Операция успешно выполнена.')
            closeOperation()
            // Обновить список товаров в ячейке
            if (locationModal.value.locationId) {
                const location = props.racks
                    .flatMap(r => r.locations || [])
                    .find(l => l.id === locationModal.value.locationId)
                if (location) {
                    await viewLocationProducts(location)
                }
            }
        } else {
            const data = await response.json().catch(() => null)
            const errorMessage = data?.message || data?.errors ?
                (typeof data.errors === 'string' ? data.errors : Object.values(data.errors).flat().join(', ')) :
                'Ошибка при выполнении операции.'
            toast.error(errorMessage)
        }
    } catch (error) {
        console.error('Operation error:', error)
        toast.error('Ошибка при выполнении операции.')
    } finally {
        locationModal.value.operationLoading = false
    }
}

// Watch for product selection to update current quantity
watch(
    () => operationForm.value.product_id,
    (productId) => {
        if (productId && locationModal.value.operation) {
            const product = locationModal.value.products.find(p => p.id === Number(productId))
            if (product) {
                operationForm.value.current_quantity = Number(product.quantity)
                // For inventory, pre-fill with current quantity
                if (locationModal.value.operation === 'inventory') {
                    operationForm.value.quantity = String(product.quantity)
                }
            }
        }
    },
)

const startAddLocation = (rackId: number): void => {
    addingLocationRackId.value = rackId

    const rack = props.racks.find(
        (item) => item.id === rackId,
    )

    if (!rack) {
        return
    }

    const numbers = rack.locations.map(
        (location) => location.number,
    )

    let nextNumber = 1

    while (numbers.includes(nextNumber)) {
        nextNumber++
    }

    newLocationNumber.value[rackId] = String(nextNumber)
}

const cancelAddLocation = (): void => {
    addingLocationRackId.value = null
}

const addLocation = (rack: Rack): void => {
    const value = newLocationNumber.value[rack.id] ?? ''

    if (!value) {
        return
    }

    router.post(
        storeLocation(rack.id).url,
        {
            number: Number(value),
        },
        {
            preserveScroll: true,
            onSuccess: () => {
                addingLocationRackId.value = null
            },
        },
    )
}

const deleteRack = (rack: Rack): void => {
    deleteConfirmation.value = {
        open: true,
        type: 'rack',
        rack,
        location: null,
        loading: false,
    }
}

const deleteLocation = (rack: Rack, location: Location): void => {
    deleteConfirmation.value = {
        open: true,
        type: 'location',
        rack,
        location,
        loading: false,
    }
}

const closeDeleteConfirmation = (): void => {
    deleteConfirmation.value.open = false
    deleteConfirmation.value.type = null
    deleteConfirmation.value.rack = null
    deleteConfirmation.value.location = null
}

const confirmDelete = (): void => {
    const confirmation = deleteConfirmation.value

    if (confirmation.loading || !confirmation.type) return

    confirmation.loading = true

    if (confirmation.type === 'rack' && confirmation.rack) {
        router.delete(destroy(confirmation.rack.id).url, {
            onSuccess: () => {
                toast.success('Стеллаж успешно удалён.')
                closeDeleteConfirmation()
            },
            onError: () => {
                toast.error('Не удалось удалить стеллаж. Проверьте, нет ли в нём остатков или истории движений.')
            },
            onFinish: () => {
                deleteConfirmation.value.loading = false
            },
        })
        return
    }

    if (confirmation.type === 'location' && confirmation.rack && confirmation.location) {
        router.delete(
            destroyLocation({
                rack: confirmation.rack.id,
                location: confirmation.location.id,
            }).url,
            {
                preserveScroll: true,
                onSuccess: () => {
                    toast.success('Ячейка успешно удалена.')
                    closeDeleteConfirmation()
                },
                onError: () => {
                    toast.error('Не удалось удалить ячейку. Возможно, в ней есть остатки или история движений.')
                },
                onFinish: () => {
                    deleteConfirmation.value.loading = false
                },
            },
        )
    }
}

const viewLocationProducts = async (location: Location): Promise<void> => {
    locationModal.value.loading = true
    locationModal.value.locationCode = location.code
    locationModal.value.locationId = location.id
    locationModal.value.open = true

    try {
        const response = await fetch(`/admin/locations/${location.id}/products`, {
            headers: {
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
            },
        })
        if (!response.ok) {
            throw new Error('Failed to fetch')
        }
        const data = await response.json()
        locationModal.value.products = data
    } catch (error) {
        console.error('Failed to load location products:', error)
        locationModal.value.products = []
    } finally {
        locationModal.value.loading = false
    }
}

const closeLocationModal = (): void => {
    locationModal.value.open = false
    locationModal.value.products = []
}

const showProductDetails = async (product: LocationProduct): Promise<void> => {
    productDetailsModal.value = {
        open: true,
        loading: true,
        error: '',
        product: {
            id: product.id,
            name: product.name,
            sku: product.sku,
            quantity: product.quantity,
        },
        locations: [],
        totalQuantity: 0,
    }

    try {
        const response = await fetch(`/admin/locations?product_id=${product.id}`, {
            headers: {
                Accept: 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
            },
        })

        if (!response.ok) {
            throw new Error('Не удалось загрузить распределение товара по ячейкам.')
        }

        const data = await response.json()
        const locations = (Array.isArray(data.locations) ? data.locations as ProductStockLocation[] : [])
            .filter((location) => Number(location.quantity) > 0)

        // Показываем только ячейки, в которых действительно есть остаток товара.
        productDetailsModal.value.locations = locations
        productDetailsModal.value.totalQuantity = locations.reduce(
            (sum, location) => sum + (Number(location.quantity) || 0),
            0,
        )
    } catch (error) {
        console.error('Error fetching product details:', error)
        productDetailsModal.value.error = 'Не удалось загрузить данные о расположении товара. Попробуйте ещё раз.'
    } finally {
        productDetailsModal.value.loading = false
    }
}

const closeProductDetails = (): void => {
    productDetailsModal.value.open = false
}

</script>

<template>
    <Head title="Стеллажи" />

    <div class="space-y-4 sm:space-y-6">
        <div
            class="flex flex-col justify-between gap-4 sm:flex-row sm:items-center"
        >
            <div>
                <h1 class="text-xl font-semibold text-gray-900 sm:text-2xl">
                    Стеллажи
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    Управление стеллажами и складскими ячейками.
                </p>
            </div>

            <Link
                :href="create().url"
                class="inline-flex items-center justify-center rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white transition hover:bg-gray-800 w-full sm:w-auto"
            >
                Добавить стеллаж
            </Link>
        </div>

        <div
            v-if="props.racks.length === 0"
            class="rounded-xl border border-gray-200 bg-white p-6 sm:p-8 text-center"
        >
            <p class="text-sm text-gray-500">
                Стеллажи ещё не созданы.
            </p>

            <Link
                :href="create().url"
                class="mt-4 inline-flex text-sm font-medium text-gray-900 underline"
            >
                Создать первый стеллаж
            </Link>
        </div>

        <div
            v-for="rack in props.racks"
            :key="rack.id"
            class="overflow-hidden rounded-xl border border-gray-200 bg-white"
        >
            <div
                class="flex flex-col gap-4 border-b border-gray-200 p-4 sm:p-5 sm:flex-row sm:items-center sm:justify-between"
            >
                <div>
                    <div class="flex items-center gap-3">
                        <h2 class="text-base font-semibold text-gray-900 sm:text-lg">
                            {{ rack.code }}
                        </h2>

                        <span
                            class="rounded-full bg-gray-100 px-2.5 py-1 text-xs font-medium text-gray-600"
                        >
                            {{ rack.locations_count }} ячеек
                        </span>
                    </div>

                    <p
                        v-if="rack.name"
                        class="mt-1 text-sm text-gray-500"
                    >
                        {{ rack.name }}
                    </p>
                </div>

                <div class="flex items-center gap-3">
                    <Link
                        :href="edit(rack.id).url"
                        class="text-sm font-medium text-gray-600 hover:text-gray-900"
                    >
                        Изменить
                    </Link>

                    <button
                        type="button"
                        class="text-sm font-medium text-red-600 hover:text-red-800"
                        @click="deleteRack(rack)"
                    >
                        Удалить
                    </button>
                </div>
            </div>

            <div class="p-4 sm:p-5">
                <div
                    v-if="rack.locations.length === 0"
                    class="rounded-lg border border-dashed border-gray-300 p-4 sm:p-6 text-center"
                >
                    <p class="text-sm text-gray-500">
                        В этом стеллаже пока нет ячеек.
                    </p>

                    <button
                        type="button"
                        class="mt-3 text-sm font-medium text-gray-900 underline"
                        @click="startAddLocation(rack.id)"
                    >
                        Добавить ячейку
                    </button>
                </div>

                <div
                    v-else
                    class="grid grid-cols-2 gap-2 sm:gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6"
                >
                    <div
                        v-for="location in rack.locations"
                        :key="location.id"
                        class="group cursor-pointer rounded-lg border p-3 sm:p-4 transition"
                        :class="
                            hasStock(location)
                                ? 'border-green-300 bg-green-50 hover:border-green-400'
                                : 'border-dashed border-gray-300 bg-gray-50 hover:border-gray-400'
                        "
                        @click="viewLocationProducts(location)"
                    >
                        <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                            <span
                                class="text-xs"
                                :class="
                                    hasStock(location)
                                        ? 'text-green-700'
                                        : 'text-gray-500'
                                "
                            >
                                Остаток:
                                <span
                                    class="tabular-nums"
                                    :class="
                                        hasStock(location)
                                            ? 'font-semibold text-green-900'
                                            : 'text-gray-900'
                                    "
                                >
                                    {{ location.stock_quantity ?? 0 }}
                                </span>
                            </span>

                            <div class="flex items-center gap-2">
                                <span
                                    class="inline-flex h-2 w-2 shrink-0 rounded-full"
                                    :class="
                                        hasStock(location)
                                            ? 'bg-green-500'
                                            : 'bg-gray-300'
                                    "
                                />

                                <span class="text-sm font-medium text-gray-700">{{ location.code }}</span>

                                <button
                                    type="button"
                                    class="text-xs text-red-500 opacity-0 transition group-hover:opacity-100 hover:text-red-700"
                                    title="Удалить ячейку"
                                    @click.stop="deleteLocation(rack, location)"
                                >
                                    ×
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <div
                    v-if="addingLocationRackId === rack.id"
                    class="mt-5 rounded-lg border border-gray-200 bg-gray-50 p-4"
                >
                    <div class="flex flex-col gap-3 sm:flex-row sm:items-end">
                        <div>
                            <label
                                :for="`location-number-${rack.id}`"
                                class="mb-1 block text-sm font-medium text-gray-700"
                            >
                                Номер ячейки
                            </label>

                            <input
                                :id="`location-number-${rack.id}`"
                                v-model="
                                    newLocationNumber[rack.id]
                                "
                                type="number"
                                min="1"
                                class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm outline-none focus:border-gray-500 focus:ring-1 focus:ring-gray-500 sm:w-40"
                            />
                        </div>

                        <div class="flex items-center gap-2">
                            <button
                                type="button"
                                class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800"
                                @click="addLocation(rack)"
                            >
                                Добавить
                            </button>

                            <button
                                type="button"
                                class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-white"
                                @click="cancelAddLocation"
                            >
                                Отмена
                            </button>
                        </div>
                    </div>
                </div>

                <button
                    v-else
                    type="button"
                    class="mt-5 text-sm font-medium text-gray-700 hover:text-gray-900"
                    @click="startAddLocation(rack.id)"
                >
                    + Добавить ячейку
                </button>
            </div>
        </div>

        <!-- Location Products Modal -->
        <Dialog :open="locationModal.open" @update:open="closeLocationModal">
            <DialogContent class="max-w-3xl max-h-[90vh] overflow-y-auto w-[95vw] sm:w-full">
                <DialogHeader>
                    <DialogTitle class="text-base sm:text-lg">
                        Товары в ячейке {{ locationModal.locationCode }}
                    </DialogTitle>
                    <DialogDescription class="text-sm">
                        Список товаров и их количество
                    </DialogDescription>
                </DialogHeader>

                <!-- Operation buttons -->
                <div
                    v-if="!locationModal.operation"
                    class="flex flex-wrap gap-2 border-b border-gray-200 pb-4"
                >
                    <button
                        type="button"
                        class="rounded-lg bg-green-600 px-3 py-2 text-sm font-medium text-white hover:bg-green-700 flex-1 sm:flex-none"
                        @click="startOperation('receipt')"
                    >
                        + Пополнение
                    </button>

                    <button
                        type="button"
                        class="rounded-lg bg-red-600 px-3 py-2 text-sm font-medium text-white hover:bg-red-700 flex-1 sm:flex-none"
                        @click="startOperation('write_off')"
                    >
                        − Списание
                    </button>

                    <button
                        type="button"
                        class="rounded-lg bg-blue-600 px-3 py-2 text-sm font-medium text-white hover:bg-blue-700 flex-1 sm:flex-none"
                        @click="startOperation('transfer')"
                    >
                        → Перемещение
                    </button>

                    <button
                        type="button"
                        class="rounded-lg bg-purple-600 px-3 py-2 text-sm font-medium text-white hover:bg-purple-700 flex-1 sm:flex-none"
                        @click="startOperation('return')"
                    >
                        ↩ Возврат
                    </button>

                    <button
                        type="button"
                        class="rounded-lg bg-gray-600 px-3 py-2 text-sm font-medium text-white hover:bg-gray-700 flex-1 sm:flex-none"
                        @click="startOperation('inventory')"
                    >
                        ⚖ Инвентаризация
                    </button>
                </div>

                <!-- Operation form -->
                <div
                    v-if="locationModal.operation"
                    class="space-y-4 border-b border-gray-200 pb-4"
                >
                    <div class="flex items-center justify-between">
                        <h3 class="text-base font-medium sm:text-lg">
                            {{
                                locationModal.operation === 'receipt' ? 'Пополнение' :
                                    locationModal.operation === 'write_off' ? 'Списание' :
                                        locationModal.operation === 'transfer' ? 'Перемещение' :
                                            locationModal.operation === 'return' ? 'Возврат' :
                                                'Инвентаризация'
                            }}
                        </h3>
                        <button
                            type="button"
                            class="text-sm text-gray-500 hover:text-gray-700"
                            @click="closeOperation"
                        >
                            Отмена
                        </button>
                    </div>

                    <div class="grid gap-4 sm:grid-cols-2">
                        <div class="sm:col-span-2">
                            <label class="mb-2 block text-sm font-medium text-gray-700">
                                Товар
                            </label>
                            <template v-if="locationModal.operation === 'receipt' || locationModal.operation === 'return'">
                                <ProductSelect
                                    :products="productsForSelect"
                                    :categories="categories"
                                    :model-value="operationForm.product_id"
                                    @update:model-value="operationForm.product_id = $event !== null ? String($event) : ''"
                                />
                            </template>
                            <template v-else>
                                <select
                                    v-model="operationForm.product_id"
                                    class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
                                >
                                    <option value="">Выберите товар</option>
                                    <option
                                        v-for="product in locationModal.products"
                                        :key="product.id"
                                        :value="product.id"
                                    >
                                        {{ product.name }} ({{ product.quantity }})
                                    </option>
                                </select>
                            </template>
                        </div>

                        <div>
                            <label class="mb-2 block text-sm font-medium text-gray-700">
                                {{
                                    locationModal.operation === 'inventory' ? 'Фактическое количество' : 'Количество'
                                }}
                            </label>
                            <input
                                v-model="operationForm.quantity"
                                type="number"
                                step="0.001"
                                min="0"
                                class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
                            />
                            <p
                                v-if="operationForm.current_quantity !== null && locationModal.operation !== 'receipt' && locationModal.operation !== 'return'"
                                class="mt-1 text-xs text-gray-500"
                            >
                                Текущее количество: {{ operationForm.current_quantity }}
                            </p>
                        </div>

                        <div v-if="locationModal.operation === 'transfer'">
                            <label class="mb-2 block text-sm font-medium text-gray-700">
                                Ячейка назначения
                            </label>
                            <select
                                v-model="operationForm.to_location_id"
                                class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
                            >
                                <option value="">Выберите ячейку</option>
                                <option
                                    v-for="location in props.allLocations"
                                    :key="location.id"
                                    :value="location.id"
                                    :disabled="location.id === locationModal.locationId"
                                >
                                    {{ location.code }} ({{ location.rack_name }})
                                </option>
                            </select>
                        </div>

                        <div>
                            <label class="mb-2 block text-sm font-medium text-gray-700">
                                {{
                                    locationModal.operation === 'write_off' ? 'Причина списания' :
                                        locationModal.operation === 'return' ? 'Причина возврата' :
                                            'Комментарий'
                                }}
                            </label>
                            <textarea
                                v-model="operationForm.comment"
                                rows="2"
                                class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
                            />
                        </div>

                        <button
                            type="button"
                            :disabled="locationModal.operationLoading || !operationForm.product_id"
                            class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800 disabled:opacity-50"
                            @click="submitOperation"
                        >
                            {{ locationModal.operationLoading ? 'Выполнение...' : 'Выполнить' }}
                        </button>
                    </div>
                </div>

                <div
                    v-if="locationModal.loading"
                    class="flex items-center justify-center py-8"
                >
                    <div class="text-sm text-gray-500">Загрузка...</div>
                </div>

                <div
                    v-else-if="locationModal.products.length === 0"
                    class="flex flex-col items-center justify-center py-8 text-center"
                >
                    <Package :size="48" class="text-gray-300 mb-4" />
                    <p class="text-sm text-gray-500">
                        В этой ячейке нет товаров
                    </p>
                </div>

                <div
                    v-else
                    class="space-y-2 max-h-96 overflow-y-auto"
                >
                    <div
                        v-for="product in locationModal.products"
                        :key="product.id"
                        class="flex w-full items-center justify-between rounded-lg border border-gray-200 p-4 text-left transition hover:border-gray-300 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-300" @click="showProductDetails(product)"
                    >
                        <div class="flex-1">
                            <div class="font-medium text-gray-900">
                                {{ product.name }}
                            </div>
                            <div
                                v-if="product.sku"
                                class="text-sm text-gray-500"
                            >
                                {{ product.sku }}
                            </div>
                        </div>
                        <div class="ml-4 text-right">
                            <div class="text-lg font-semibold text-gray-900">
                                {{ product.quantity }}
                            </div>
                        </div>
                    </div>
                </div>
            </DialogContent>
        </Dialog>

        <!-- Product stock details modal -->
        <Dialog :open="productDetailsModal.open" @update:open="productDetailsModal.open = $event">
            <DialogContent class="w-[calc(100%-2rem)] max-w-xl overflow-hidden rounded-2xl border-0 p-0 shadow-2xl sm:w-full">
                <div class="bg-gradient-to-br from-slate-900 to-slate-700 px-5 py-6 text-white sm:px-7">
                    <div class="flex items-start gap-4">
                        <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-white/10 ring-1 ring-white/15">
                            <Package :size="24" />
                        </div>
                        <div class="min-w-0 flex-1">
                            <DialogHeader>
                                <DialogTitle class="text-left text-lg font-semibold leading-snug text-white sm:text-xl">
                                    {{ productDetailsModal.product?.name ?? 'Информация о товаре' }}
                                </DialogTitle>
                                <DialogDescription class="mt-1 text-left text-sm text-slate-300">
                                    Подробная информация об остатках на складе
                                </DialogDescription>
                            </DialogHeader>
                            <div class="mt-3 flex flex-wrap items-center gap-2">
                                <span class="rounded-md bg-white/10 px-2.5 py-1 text-xs font-medium text-slate-100">
                                    SKU: {{ productDetailsModal.product?.sku || 'Не указан' }}
                                </span>
                                <span class="rounded-md bg-white/10 px-2.5 py-1 text-xs text-slate-100">
                                    Ячейка: {{ locationModal.locationCode }}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="space-y-5 p-5 sm:p-7">
                    <div class="grid grid-cols-2 gap-3">
                        <div class="rounded-xl border border-slate-200 bg-slate-50 p-4">
                            <p class="text-xs font-medium uppercase tracking-wide text-slate-500">В этой ячейке</p>
                            <p class="mt-2 text-2xl font-semibold tabular-nums text-slate-900">
                                {{ formatQuantity(productDetailsModal.product?.quantity) }}
                            </p>
                            <p class="mt-1 text-xs text-slate-500">единиц товара</p>
                        </div>
                        <div class="rounded-xl border border-emerald-200 bg-emerald-50 p-4">
                            <p class="text-xs font-medium uppercase tracking-wide text-emerald-700">Всего на складе</p>
                            <p class="mt-2 text-2xl font-semibold tabular-nums text-emerald-900">
                                {{ formatQuantity(productDetailsModal.totalQuantity) }}
                            </p>
                            <p class="mt-1 text-xs text-emerald-700">единиц товара</p>
                        </div>
                    </div>

                    <div>
                        <div class="mb-3 flex items-center justify-between gap-3">
                            <h3 class="text-sm font-semibold text-slate-900">Распределение по ячейкам</h3>
                            <span class="rounded-full bg-slate-100 px-2.5 py-1 text-xs font-medium text-slate-600">
                                {{ productDetailsModal.locations.length }}
                                {{ productDetailsModal.locations.length === 1 ? 'ячейка' : 'ячеек' }}
                            </span>
                        </div>

                        <div v-if="productDetailsModal.loading" class="flex items-center justify-center gap-3 rounded-xl border border-slate-200 py-8 text-sm text-slate-500">
                            <span class="h-5 w-5 animate-spin rounded-full border-2 border-slate-300 border-t-slate-700" />
                            Загружаем остатки...
                        </div>

                        <div v-else-if="productDetailsModal.error" class="rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-700">
                            {{ productDetailsModal.error }}
                        </div>

                        <div v-else-if="productDetailsModal.locations.length === 0" class="rounded-xl border border-dashed border-slate-300 px-4 py-8 text-center">
                            <Package :size="28" class="mx-auto text-slate-300" />
                            <p class="mt-2 text-sm font-medium text-slate-700">Остатки по ячейкам не найдены</p>
                            <p class="mt-1 text-xs text-slate-500">Проверьте движения и складские остатки этого товара.</p>
                        </div>

                        <div v-else class="max-h-64 space-y-2 overflow-y-auto pr-1">
                            <div
                                v-for="stockLocation in productDetailsModal.locations"
                                :key="stockLocation.id"
                                class="flex items-center justify-between gap-4 rounded-xl border border-slate-200 px-4 py-3"
                            >
                                <div class="flex min-w-0 items-center gap-3">
                                    <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                                        <Package :size="17" />
                                    </span>
                                    <div class="min-w-0">
                                        <p class="truncate text-sm font-semibold text-slate-900">
                                            {{ stockLocation.code || `Ячейка №${stockLocation.number}` }}
                                        </p>
                                        <p class="text-xs text-slate-500">ID ячейки: {{ stockLocation.id }}</p>
                                    </div>
                                </div>
                                <p class="shrink-0 text-base font-semibold tabular-nums text-slate-900">
                                    {{ formatQuantity(stockLocation.quantity) }}
                                </p>
                            </div>
                        </div>
                    </div>

                    <div class="flex justify-end border-t border-slate-100 pt-4">
                        <button type="button" class="inline-flex items-center justify-center rounded-lg bg-slate-900 px-5 py-2.5 text-sm font-medium text-white transition hover:bg-slate-700 focus:outline-none focus:ring-2 focus:ring-slate-400 focus:ring-offset-2" @click="closeProductDetails">
                            Готово
                        </button>
                    </div>
                </div>
            </DialogContent>
        </Dialog>

        <!-- Custom delete confirmation modal -->
        <Dialog :open="deleteConfirmation.open" @update:open="(open) => { if (!open) closeDeleteConfirmation() }">
            <DialogContent class="w-[calc(100%-2rem)] max-w-md rounded-2xl p-6 sm:p-7">
                <div class="flex items-start gap-4">
                    <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-red-50 text-red-600">
                        <X :size="22" />
                    </div>
                    <div class="min-w-0 flex-1">
                        <DialogHeader>
                            <DialogTitle class="text-left text-lg font-semibold text-slate-900">
                                {{ deleteConfirmation.type === 'rack' ? 'Удалить стеллаж?' : 'Удалить ячейку?' }}
                            </DialogTitle>
                            <DialogDescription class="mt-2 text-left text-sm leading-6 text-slate-600">
                                <template v-if="deleteConfirmation.type === 'rack'">
                                    Стеллаж «{{ deleteConfirmation.rack?.code }}» можно удалить только если в его ячейках нет остатков и истории движений.
                                </template>
                                <template v-else>
                                    Вы собираетесь удалить ячейку «{{ deleteConfirmation.location?.code }}». Это действие нельзя отменить. Удаление будет запрещено, если есть остатки или история движений.
                                </template>
                            </DialogDescription>
                        </DialogHeader>
                    </div>
                </div>
                <div class="mt-6 flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
                    <button type="button" :disabled="deleteConfirmation.loading" class="rounded-lg border border-slate-200 px-4 py-2.5 text-sm font-medium text-slate-700 transition hover:bg-slate-50 disabled:opacity-50" @click="closeDeleteConfirmation">
                        Отмена
                    </button>
                    <button type="button" :disabled="deleteConfirmation.loading" class="rounded-lg bg-red-600 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-red-700 disabled:cursor-not-allowed disabled:opacity-60" @click="confirmDelete">
                        {{ deleteConfirmation.loading ? 'Удаление...' : 'Да, удалить' }}
                    </button>
                </div>
            </DialogContent>
        </Dialog>
    </div>
</template>
