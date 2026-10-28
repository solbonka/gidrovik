
<script setup lang="ts">
import { ref, computed, watch, onBeforeUnmount } from 'vue'
import { Search, Check } from '@lucide/vue'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import type { AcceptableValue } from 'reka-ui';
interface ProductOption {
    id: number
    name: string
    code: string | null
    article: string | null
    unit?: string
    stock_quantity?: number
    minimum_stock?: number | null
    characteristics?: string
    category_id?: number | string | null
    category?: {
        id: number | string
        name?: string
    } | null
}

interface CategoryOption {
    id: number | string
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
const selectedCategoryId = ref('')

const open = ref(false)

let debounceTimer: ReturnType<typeof setTimeout> | null = null

// Задержка поиска, чтобы не фильтровать при каждом нажатии клавиши
watch(searchQuery, (newValue) => {
    if (debounceTimer !== null) {
        clearTimeout(debounceTimer)
    }

    debounceTimer = setTimeout(() => {
        debouncedSearchQuery.value = newValue
    }, 200)
})

onBeforeUnmount(() => {
    if (debounceTimer !== null) {
        clearTimeout(debounceTimer)
    }
})

// Сбрасываем категорию при полной очистке поискового запроса
watch(debouncedSearchQuery, (newValue) => {
    if (!newValue.trim()) {
        selectedCategoryId.value = ''
    }
})

// Определяем категорию товара: из category_id или из связи category.id
const getProductCategoryId = (
    product: ProductOption,
): string | null => {
    const categoryId = product.category_id ?? product.category?.id

    return categoryId == null ? null : String(categoryId)
}

// Фильтрация по категории и поисковому запросу
const filteredProducts = computed(() => {
    let result = props.products

    if (selectedCategoryId.value !== '') {
        result = result.filter((product) => {
            return (
                getProductCategoryId(product) ===
                String(selectedCategoryId.value)
            )
        })
    }

    const query = debouncedSearchQuery.value.trim().toLowerCase()

    if (query) {
        const searchTerms = query.split(/\s+/).filter(Boolean)

        result = result.filter((product) => {
            const name = product.name.toLowerCase()
            const code = product.code?.toLowerCase() ?? ''
            const article = product.article?.toLowerCase() ?? ''
            const characteristics =
                product.characteristics?.toLowerCase() ?? ''

            return searchTerms.every(
                (term) =>
                    name.includes(term) ||
                    code.includes(term) ||
                    article.includes(term) ||
                    characteristics.includes(term),
            )
        })
    }

    // При пустом поиске показываем максимум 50 товаров.
    // При выбранной категории сначала фильтруем, затем ограничиваем список.
    if (!query && selectedCategoryId.value === '') {
        return result.slice(0, 50)
    }

    return result.slice(0, 100)
})

const selectedProduct = computed(() =>
    props.products.find(
        (product) => String(product.id) === String(props.modelValue),
    ),
)

const formatQuantity = (quantity: number | undefined): string => {
    if (quantity === undefined || !Number.isFinite(Number(quantity))) {
        return '0'
    }

    return Number(quantity).toString()
}

const getStockColorClass = (
    quantity: number | undefined,
    minimumStock?: number | null,
): string => {
    const stock = Number(quantity ?? 0)

    if (stock <= 0) {
        return 'text-red-600'
    }

    if (minimumStock != null && stock < Number(minimumStock)) {
        return 'text-orange-600'
    }

    return 'text-emerald-600'
}

const handleSelect = (value: AcceptableValue): void => {
    if (typeof value !== 'string') {
        return;
    }

    emit('update:modelValue', value);
    open.value = false;
    searchQuery.value = '';
    debouncedSearchQuery.value = '';
    selectedCategoryId.value = '';
};
</script>

<template>
    <Select
        :model-value="modelValue"
        :open="open"
        @update:model-value="handleSelect"
        @update:open="open = $event"
    >
        <SelectTrigger class="w-full min-h-10">
            <SelectValue placeholder="Выберите товар">
                <template v-if="selectedProduct">
                    <div class="flex min-w-0 flex-col text-left">
                        <span class="truncate font-medium">
                            {{ selectedProduct.name }}
                        </span>

                        <div class="flex flex-wrap items-center gap-x-2 text-xs">
                            <span
                                v-if="selectedProduct.code || selectedProduct.article"
                                class="text-muted-foreground"
                            >
                                <span v-if="selectedProduct.code">{{ selectedProduct.code }}</span>
                                <span v-if="selectedProduct.code && selectedProduct.article"> / </span>
                                <span v-if="selectedProduct.article">{{ selectedProduct.article }}</span>
                            </span>

                            <span
                                v-if="
                                    showStockQuantity &&
                                    selectedProduct.stock_quantity !== undefined
                                "
                                :class="
                                    getStockColorClass(
                                        selectedProduct.stock_quantity,
                                        selectedProduct.minimum_stock,
                                    ) + ' font-medium'
                                "
                            >
                                {{ formatQuantity(selectedProduct.stock_quantity) }}
                                {{ selectedProduct.unit ?? '' }}
                            </span>
                        </div>
                    </div>
                </template>
            </SelectValue>
        </SelectTrigger>

        <SelectContent class="max-h-96">
            <div class="border-b p-3">
                <!-- Фильтр по категориям -->
                <div
                    v-if="categories && categories.length > 0"
                    class="mb-2"
                >
                    <label
                        class="mb-1 block text-xs font-medium text-muted-foreground"
                    >
                        Категория товара
                    </label>

                    <select
                        v-model="selectedCategoryId"
                        class="w-full rounded-md border border-input bg-background px-2 py-2 text-sm outline-none focus:ring-2 focus:ring-ring"
                        @click.stop
                        @pointerdown.stop
                        @change.stop
                    >
                        <option value="">Все категории</option>

                        <option
                            v-for="category in categories"
                            :key="category.id"
                            :value="String(category.id)"
                        >
                            {{ category.name }}
                        </option>
                    </select>
                </div>

                <!-- Поиск -->
                <div class="relative">
                    <Search
                        :size="15"
                        class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground"
                    />

                    <input
                        v-model="searchQuery"
                        type="search"
                        placeholder="Название, артикул или характеристика..."
                        class="w-full rounded-md border border-input bg-background py-2 pl-8 pr-3 text-sm outline-none focus:ring-2 focus:ring-ring"
                        @click.stop
                        @pointerdown.stop
                        @keydown.stop
                    />
                </div>

                <div class="mt-2 text-xs text-muted-foreground">
                    Найдено товаров: {{ filteredProducts.length }}
                </div>
            </div>

            <div class="max-h-64 overflow-y-auto p-1">
                <SelectItem
                    v-for="product in filteredProducts"
                    :key="product.id"
                    :value="String(product.id)"
                    class="py-2"
                >
                    <div class="flex min-w-0 flex-col">
                        <span class="truncate font-medium">
                            {{ product.name }}
                        </span>

                        <div class="mt-0.5 flex flex-wrap items-center gap-x-2 text-xs">
                            <span
                                v-if="product.code || product.article"
                                class="text-muted-foreground"
                            >
                                <span v-if="product.code">{{ product.code }}</span>
                                <span v-if="product.code && product.article"> / </span>
                                <span v-if="product.article">{{ product.article }}</span>
                            </span>

                            <span
                                v-if="
                                    showStockQuantity &&
                                    product.stock_quantity !== undefined
                                "
                                :class="
                                    getStockColorClass(
                                        product.stock_quantity,
                                        product.minimum_stock,
                                    )
                                "
                            >
                                Остаток:
                                {{ formatQuantity(product.stock_quantity) }}
                                {{ product.unit }}
                            </span>
                        </div>

                        <span
                            v-if="
                                product.characteristics &&
                                debouncedSearchQuery.trim()
                            "
                            class="mt-1 truncate text-xs text-muted-foreground"
                        >
                            {{ product.characteristics }}
                        </span>
                    </div>

                    <Check
                        v-if="String(product.id) === String(modelValue)"
                        :size="15"
                        class="ml-2 shrink-0"
                    />
                </SelectItem>

                <div
                    v-if="filteredProducts.length === 0"
                    class="px-3 py-8 text-center"
                >
                    <Search
                        :size="24"
                        class="mx-auto mb-2 text-muted-foreground/50"
                    />

                    <p class="text-sm font-medium">
                        Товары не найдены
                    </p>

                    <p class="mt-1 text-xs text-muted-foreground">
                        Попробуйте выбрать другую категорию или изменить поиск.
                    </p>

                    <button
                        type="button"
                        class="mt-3 text-xs font-medium text-primary hover:underline"
                        @click.stop="
                            selectedCategoryId = '';
                            searchQuery = '';
                            debouncedSearchQuery = ''
                        "
                    >
                        Сбросить фильтры
                    </button>
                </div>
            </div>
        </SelectContent>
    </Select>
</template>
