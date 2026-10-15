<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { Search, Check } from '@lucide/vue'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'

interface ProductOption {
    id: number
    name: string
    sku: string | null
    unit: string
    stock_quantity?: number
    minimum_stock?: number | null
    characteristics?: string
    category_id?: number | null
}

interface CategoryOption {
    id: number
    name: string
}

interface Props {
    products: ProductOption[]
    categories?: CategoryOption[]
    modelValue: string
    showStockQuantity?: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
    'update:modelValue': [value: string]
}>()

const searchQuery = ref('')
const debouncedSearchQuery = ref('')
const selectedCategoryId = ref<number | null>(null)
const open = ref(false)
let debounceTimer: number | null = null

// Debounce для поиска
watch(searchQuery, (newValue) => {
    if (debounceTimer !== null) {
        clearTimeout(debounceTimer)
    }
    debounceTimer = window.setTimeout(() => {
        debouncedSearchQuery.value = newValue
    }, 200)
})

// Сброс категории при сбросе поиска
watch(debouncedSearchQuery, (newValue) => {
    if (!newValue) {
        selectedCategoryId.value = null
    }
})

const filteredProducts = computed(() => {
    let products = props.products

    // Фильтрация по категории
    if (selectedCategoryId.value !== null) {
        products = products.filter(p => p.category_id === selectedCategoryId.value)
    }

    // Фильтрация по поиску
    if (!debouncedSearchQuery.value) return products.slice(0, 50)

    const query = debouncedSearchQuery.value.toLowerCase().trim()
    // Разбиваем запрос на слова для умного поиска
    const searchTerms = query.split(/\s+/).filter(term => term.length > 0)

    return products.filter((product) => {
        const name = product.name.toLowerCase()
        const sku = product.sku?.toLowerCase() || ''
        const characteristics = product.characteristics?.toLowerCase() || ''

        // Проверяем, что ВСЕ слова из запроса есть в названии, SKU или характеристиках
        return searchTerms.every(term =>
            name.includes(term) || sku.includes(term) || characteristics.includes(term)
        )
    })
})

const selectedProduct = computed(() =>
    props.products.find((product) => String(product.id) === props.modelValue),
)

const formatQuantity = (quantity: number): string => {
    if (quantity === 0) return '0'
    // Убираем лишние нули после запятой
    return parseFloat(quantity.toString()).toString()
}

const getStockColorClass = (quantity: number, minimumStock?: number | null): string => {
    if (quantity === 0) return 'text-red-600'
    if (minimumStock && quantity < minimumStock) return 'text-orange-600'
    return 'text-green-600'
}

const handleSelect = (value: string): void => {
    emit('update:modelValue', value)
    open.value = false
    searchQuery.value = ''
}
</script>

<template>
    <Select
        :model-value="modelValue"
        @update:model-value="handleSelect"
        :open="open"
        @update:open="open = $event"
    >
        <SelectTrigger class="w-full">
            <SelectValue :placeholder="'Выберите товар'">
                <template v-if="selectedProduct">
                    <div class="flex flex-col">
                        <span class="font-medium">{{ selectedProduct.name }}</span>
                        <div class="flex items-center gap-2 text-xs">
                            <span v-if="selectedProduct.sku" class="text-gray-500">
                                {{ selectedProduct.sku }}
                            </span>
                            <span
                                v-if="showStockQuantity && selectedProduct.stock_quantity !== undefined"
                                :class="getStockColorClass(selectedProduct.stock_quantity, selectedProduct.minimum_stock) + ' font-medium'"
                            >
                                • {{ formatQuantity(selectedProduct.stock_quantity) }} {{ selectedProduct.unit }}
                            </span>
                        </div>
                    </div>
                </template>
            </SelectValue>
        </SelectTrigger>

        <SelectContent class="max-h-96">
            <div class="px-3 py-2 border-b">
                <!-- Фильтр по категориям -->
                <div v-if="categories && categories.length > 0" class="mb-2">
                    <select
                        v-model="selectedCategoryId"
                        class="w-full rounded-md border border-gray-200 px-2 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-gray-500 text-sm"
                        @click.stop
                    >
                        <option :value="null">Все категории</option>
                        <option
                            v-for="category in categories"
                            :key="category.id"
                            :value="category.id"
                        >
                            {{ category.name }}
                        </option>
                    </select>
                </div>

                <!-- Поиск -->
                <div class="relative">
                    <Search :size="14" class="absolute left-2 top-1/2 -translate-y-1/2 text-gray-400" />
                    <input
                        v-model="searchQuery"
                        type="search"
                        placeholder="Поиск..."
                        class="w-full rounded-md border border-gray-200 pl-8 pr-2 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-gray-500"
                        @click.stop
                    />
                </div>
            </div>

            <div class="max-h-72 overflow-y-auto">
                <SelectItem
                    v-for="product in filteredProducts"
                    :key="product.id"
                    :value="String(product.id)"
                >
                    <div class="flex items-center justify-between w-full pr-6">
                        <div class="flex flex-col min-w-0 flex-1">
                            <span class="font-medium truncate">{{ product.name }}</span>
                            <div class="flex items-center gap-2 mt-0.5">
                                <span v-if="product.sku" class="text-xs text-gray-500">
                                    {{ product.sku }}
                                </span>
                                <span
                                    v-if="showStockQuantity && product.stock_quantity !== undefined"
                                    :class="'text-xs ' + getStockColorClass(product.stock_quantity, product.minimum_stock) + ' font-medium'"
                                >
                                    • {{ formatQuantity(product.stock_quantity) }} {{ product.unit }}
                                </span>
                            </div>
                            <span v-if="product.characteristics && searchQuery" class="text-xs text-gray-400 truncate mt-0.5">
                                {{ product.characteristics }}
                            </span>
                        </div>
                    </div>
                    <Check
                        v-if="String(product.id) === modelValue"
                        :size="14"
                        class="absolute right-2 text-gray-900"
                    />
                </SelectItem>

                <div
                    v-if="filteredProducts.length === 0"
                    class="px-3 py-4 text-sm text-gray-500 text-center"
                >
                    Товары не найдены
                </div>
            </div>
        </SelectContent>
    </Select>
</template>
