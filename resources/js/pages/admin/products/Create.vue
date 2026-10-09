<script setup lang="ts">
import AdminLayout from '@/layouts/AdminLayout.vue'
import { Head, Link, useForm } from '@inertiajs/vue3'
import { computed, ref, watch } from 'vue'
import { store } from '@/routes/admin/products'
import { dashboard } from '@/routes/admin'

defineOptions({
    layout: AdminLayout,
})

interface ProductType {
    id: number
    name: string
    slug: string
}

interface Characteristic {
    id: number
    name: string
    slug: string
    type: 'string' | 'integer' | 'decimal' | 'boolean' | 'select'
    unit: string | null
    pivot: {
        is_required: boolean
        sort_order: number
    }
}

interface Category {
    id: number
    name: string
    slug: string
    product_types: ProductType[]
    characteristics: Characteristic[]
}

interface Standard {
    id: number
    code: string
    name: string
}

interface Diameter {
    id: number
    value: number
    unit: string
}

interface Thread {
    id: number
    system: string
    designation: string
    name: string
}

interface ConnectionForm {
    position: number
    standard_id: number | null
    diameter_id: number | null
    thread_id: number | null
}

interface Props {
    categories: Category[]
    standards: Standard[]
    diameters: Diameter[]
    threads: Thread[]
}

const props = defineProps<Props>()

const loadingCharacteristics = ref<boolean>(false)

const form = useForm({
    category_id: null as number | null,
    product_type_id: null as number | null,
    name: '',
    sku: '',
    angle: null as number | null,
    description: '',
    is_active: true,
    characteristics: {} as Record<number, string>,
    connections: [] as ConnectionForm[],
})

const selectedCategory = computed<Category | null>(() => {
    if (!form.category_id) {
        return null
    }

    return (
        props.categories.find(
            (category) => category.id === form.category_id,
        ) ?? null
    )
})

const productTypes = computed<ProductType[]>(() => {
    return selectedCategory.value?.product_types ?? []
})

const characteristicList = computed<Characteristic[]>(() => {
    return selectedCategory.value?.characteristics ?? []
})

const isFitting = computed<boolean>(() => {
    if (!selectedCategory.value) {
        return false
    }

    const slug = selectedCategory.value.slug.toLowerCase()

    return (
        slug.includes('fitting') ||
        slug.includes('фитинг') ||
        slug.includes('фитин')
    )
})

const resetCharacteristics = (): void => {
    form.characteristics = {}

    for (const characteristic of characteristicList.value) {
        form.characteristics[characteristic.id] = ''
    }
}

const resetConnections = (): void => {
    form.connections = []
}

const initializeCategoryData = (): void => {
    resetCharacteristics()
    resetConnections()
}

watch(
    () => form.category_id,
    () => {
        form.product_type_id = null

        if (!form.category_id) {
            form.characteristics = {}
            resetConnections()
            return
        }

        initializeCategoryData()
    },
)

const characteristicError = (id: number): string | undefined => {
    const key = `characteristics.${id}` as keyof typeof form.errors

    return form.errors[key]
}

const addConnection = (): void => {
    if (form.connections.length >= 3) {
        return
    }

    form.connections.push({
        position: form.connections.length + 1,
        standard_id: null,
        diameter_id: null,
        thread_id: null,
    })
}

const removeConnection = (index: number): void => {
    form.connections.splice(index, 1)

    form.connections.forEach((connection, connectionIndex) => {
        connection.position = connectionIndex + 1
    })
}

const submit = (): void => {
    form.post(store.url())
}
</script>

<template>
    <Head title="Новый товар" />

    <div class="mx-auto max-w-6xl">
        <div class="mb-6 flex items-center justify-between">
            <div>
                <h1 class="text-2xl font-bold text-gray-900">
                    Новый товар
                </h1>

                <p class="mt-1 text-sm text-gray-500">
                    Создание товара с характеристиками категории
                </p>
            </div>

            <Link
                :href="dashboard.url()"
                class="rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
                Назад
            </Link>
        </div>

        <form
            class="space-y-6"
            @submit.prevent="submit"
        >
            <!-- Основная информация -->
            <section
                class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            >
                <h2 class="mb-5 text-lg font-semibold text-gray-900">
                    Основная информация
                </h2>

                <div class="grid gap-5 md:grid-cols-2">
                    <div>
                        <label
                            class="mb-2 block text-sm font-medium text-gray-700"
                        >
                            Категория
                        </label>

                        <select
                            v-model="form.category_id"
                            class="w-full rounded-lg border-gray-300"
                        >
                            <option :value="null">
                                Выберите категорию
                            </option>

                            <option
                                v-for="category in categories"
                                :key="category.id"
                                :value="category.id"
                            >
                                {{ category.name }}
                            </option>
                        </select>

                        <div
                            v-if="form.errors.category_id"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.category_id }}
                        </div>
                    </div>

                    <div>
                        <label
                            class="mb-2 block text-sm font-medium text-gray-700"
                        >
                            Тип товара
                        </label>

                        <select
                            v-model="form.product_type_id"
                            class="w-full rounded-lg border-gray-300"
                            :disabled="!form.category_id"
                        >
                            <option :value="null">
                                Выберите тип
                            </option>

                            <option
                                v-for="type in productTypes"
                                :key="type.id"
                                :value="type.id"
                            >
                                {{ type.name }}
                            </option>
                        </select>

                        <div
                            v-if="form.errors.product_type_id"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.product_type_id }}
                        </div>
                    </div>

                    <div>
                        <label
                            class="mb-2 block text-sm font-medium text-gray-700"
                        >
                            Название
                        </label>

                        <input
                            v-model="form.name"
                            type="text"
                            class="w-full rounded-lg border-gray-300"
                            placeholder="Например: Фитинг BSP 90°"
                        />

                        <div
                            v-if="form.errors.name"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.name }}
                        </div>
                    </div>

                    <div>
                        <label
                            class="mb-2 block text-sm font-medium text-gray-700"
                        >
                            Артикул
                        </label>

                        <input
                            v-model="form.sku"
                            type="text"
                            class="w-full rounded-lg border-gray-300"
                            placeholder="Например: BSP-90-12-G1/2"
                        />

                        <div
                            v-if="form.errors.sku"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.sku }}
                        </div>
                    </div>

                    <div v-if="isFitting">
                        <label
                            class="mb-2 block text-sm font-medium text-gray-700"
                        >
                            Угол
                        </label>

                        <select
                            v-model="form.angle"
                            class="w-full rounded-lg border-gray-300"
                        >
                            <option :value="null">
                                Без угла
                            </option>

                            <option :value="45">
                                45°
                            </option>

                            <option :value="90">
                                90°
                            </option>
                        </select>
                    </div>

                    <div class="md:col-span-2">
                        <label
                            class="mb-2 block text-sm font-medium text-gray-700"
                        >
                            Описание
                        </label>

                        <textarea
                            v-model="form.description"
                            rows="4"
                            class="w-full rounded-lg border-gray-300"
                            placeholder="Дополнительное описание товара"
                        />

                        <div
                            v-if="form.errors.description"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ form.errors.description }}
                        </div>
                    </div>
                </div>
            </section>

            <!-- Характеристики -->
            <section
                v-if="form.category_id"
                class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            >
                <div class="mb-5 flex items-center justify-between">
                    <div>
                        <h2 class="text-lg font-semibold text-gray-900">
                            Характеристики
                        </h2>

                        <p class="mt-1 text-sm text-gray-500">
                            Характеристики автоматически определяются
                            категорией.
                        </p>
                    </div>

                    <div
                        v-if="loadingCharacteristics"
                        class="text-sm text-gray-500"
                    >
                        Загрузка...
                    </div>
                </div>

                <div
                    v-if="characteristicList.length"
                    class="grid gap-5 md:grid-cols-2"
                >
                    <div
                        v-for="characteristic in characteristicList"
                        :key="characteristic.id"
                    >
                        <label
                            class="mb-2 block text-sm font-medium text-gray-700"
                        >
                            {{ characteristic.name }}

                            <span
                                v-if="characteristic.pivot.is_required"
                                class="text-red-500"
                            >
                                *
                            </span>

                            <span
                                v-if="characteristic.unit"
                                class="ml-1 text-xs text-gray-400"
                            >
                                ({{ characteristic.unit }})
                            </span>
                        </label>

                        <input
                            v-model="
                                form.characteristics[characteristic.id]
                            "
                            :type="
                                characteristic.type === 'integer'
                                    ? 'number'
                                    : characteristic.type === 'decimal'
                                      ? 'number'
                                      : 'text'
                            "
                            :step="
                                characteristic.type === 'decimal'
                                    ? '0.01'
                                    : undefined
                            "
                            class="w-full rounded-lg border-gray-300"
                        />

                        <div
                            v-if="characteristicError(characteristic.id)"
                            class="mt-1 text-sm text-red-600"
                        >
                            {{ characteristicError(characteristic.id) }}
                        </div>
                    </div>
                </div>

                <div
                    v-else
                    class="rounded-lg bg-gray-50 p-4 text-sm text-gray-500"
                >
                    Для этой категории дополнительные характеристики
                    не настроены.
                </div>
            </section>

            <!-- Подключения -->
            <section
                v-if="isFitting"
                class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            >
                <div class="mb-5 flex items-center justify-between">
                    <div>
                        <h2 class="text-lg font-semibold text-gray-900">
                            Подключения
                        </h2>

                        <p class="mt-1 text-sm text-gray-500">
                            До трёх сторон подключения для фитинга.
                        </p>
                    </div>

                    <button
                        v-if="form.connections.length < 3"
                        type="button"
                        class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white hover:bg-gray-800"
                        @click="addConnection"
                    >
                        + Добавить
                    </button>
                </div>

                <div
                    v-if="form.connections.length"
                    class="space-y-4"
                >
                    <div
                        v-for="(connection, connectionIndex) in form.connections"
                        :key="connection.position"
                        class="rounded-lg border border-gray-200 p-4"
                    >
                        <div class="mb-4 flex items-center justify-between">
                            <h3 class="font-medium text-gray-900">
                                Подключение №{{ connection.position }}
                            </h3>

                            <button
                                type="button"
                                class="text-sm text-red-600 hover:text-red-700"
                                @click="removeConnection(connectionIndex)"
                            >
                                Удалить
                            </button>
                        </div>

                        <div class="grid gap-4 md:grid-cols-3">
                            <div>
                                <label
                                    class="mb-2 block text-sm font-medium text-gray-700"
                                >
                                    Стандарт
                                </label>

                                <select
                                    v-model="connection.standard_id"
                                    class="w-full rounded-lg border-gray-300"
                                >
                                    <option :value="null">
                                        Не выбран
                                    </option>

                                    <option
                                        v-for="standard in standards"
                                        :key="standard.id"
                                        :value="standard.id"
                                    >
                                        {{ standard.code }} —
                                        {{ standard.name }}
                                    </option>
                                </select>
                            </div>

                            <div>
                                <label
                                    class="mb-2 block text-sm font-medium text-gray-700"
                                >
                                    Диаметр
                                </label>

                                <select
                                    v-model="connection.diameter_id"
                                    class="w-full rounded-lg border-gray-300"
                                >
                                    <option :value="null">
                                        Не выбран
                                    </option>

                                    <option
                                        v-for="diameter in diameters"
                                        :key="diameter.id"
                                        :value="diameter.id"
                                    >
                                        {{ diameter.value }}
                                        {{ diameter.unit }}
                                    </option>
                                </select>
                            </div>

                            <div>
                                <label
                                    class="mb-2 block text-sm font-medium text-gray-700"
                                >
                                    Резьба
                                </label>

                                <select
                                    v-model="connection.thread_id"
                                    class="w-full rounded-lg border-gray-300"
                                >
                                    <option :value="null">
                                        Не выбрана
                                    </option>

                                    <option
                                        v-for="thread in threads"
                                        :key="thread.id"
                                        :value="thread.id"
                                    >
                                        {{ thread.system }} —
                                        {{ thread.name }}
                                    </option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div
                    v-else
                    class="rounded-lg bg-gray-50 p-4 text-sm text-gray-500"
                >
                    Добавьте хотя бы одно подключение.
                </div>
            </section>

            <!-- Активность -->
            <section
                class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            >
                <label class="flex items-center gap-3">
                    <input
                        v-model="form.is_active"
                        type="checkbox"
                        class="rounded border-gray-300"
                    />

                    <span class="text-sm font-medium text-gray-700">
                        Товар активен
                    </span>
                </label>
            </section>

            <!-- Кнопки -->
            <div class="flex justify-end gap-3">
                <Link
                    :href="dashboard.url()"
                    class="rounded-lg border border-gray-300 bg-white px-5 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                    Отмена
                </Link>

                <button
                    type="submit"
                    class="rounded-lg bg-gray-900 px-5 py-2.5 text-sm font-medium text-white hover:bg-gray-800 disabled:opacity-50"
                    :disabled="form.processing"
                >
                    {{
                        form.processing
                            ? 'Сохранение...'
                            : 'Создать товар'
                    }}
                </button>
            </div>
        </form>
    </div>
</template>
