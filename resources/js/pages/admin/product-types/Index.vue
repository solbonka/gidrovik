
<script setup lang="ts">
import { computed, ref } from 'vue'
import { Head, Link, router } from '@inertiajs/vue3'
import {
    Archive,
    ArrowDown,
    ArrowUp,
    ArrowUpDown,
    Boxes,
    CheckCircle2,
    CirclePlus,
    Edit,
    FolderTree,
    Package,
    Search,
    ShieldAlert,
    Trash2,
    X,
} from '@lucide/vue'
import { toast } from 'vue-sonner'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { create, destroy, edit } from '@/routes/admin/product-types'
import ConfirmDeleteDialog from '@/components/admin/ConfirmDeleteDialog.vue'

defineOptions({
    layout: AdminLayout,
})

interface Category {
    id: number
    name: string
}

interface ProductType {
    id: number
    category: Category
    name: string
    slug: string
    is_active: boolean
    products_count: number
}

interface PaginationLink {
    url: string | null
    label: string
    active: boolean
}

interface PaginatedProductTypes {
    data: ProductType[]
    current_page: number
    last_page: number
    from: number | null
    to: number | null
    total: number
    links: PaginationLink[]
}

interface Props {
    productTypes: PaginatedProductTypes
}

const props = defineProps<Props>()

const search = ref('')
const statusFilter = ref<'all' | 'active' | 'inactive'>('all')
const sortBy = ref<'name' | 'category' | 'products_count'>('name')
const sortDirection = ref<'asc' | 'desc'>('asc')

const activeCount = computed(
    () => props.productTypes.data.filter((item) => item.is_active).length,
)

const inactiveCount = computed(
    () => props.productTypes.data.filter((item) => !item.is_active).length,
)

const productsCount = computed(
    () => props.productTypes.data.reduce(
        (total, item) => total + item.products_count,
        0,
    ),
)

const filteredProductTypes = computed(() => {
    const query = search.value.trim().toLocaleLowerCase('ru')

    const result = props.productTypes.data.filter((item) => {
        const matchesSearch = !query
            || item.name.toLocaleLowerCase('ru').includes(query)
            || item.slug.toLocaleLowerCase('ru').includes(query)
            || item.category.name.toLocaleLowerCase('ru').includes(query)

        const matchesStatus = statusFilter.value === 'all'
            || (statusFilter.value === 'active' && item.is_active)
            || (statusFilter.value === 'inactive' && !item.is_active)

        return matchesSearch && matchesStatus
    })

    return [...result].sort((a, b) => {
        let comparison = 0

        if (sortBy.value === 'name') {
            comparison = a.name.localeCompare(b.name, 'ru')
        } else if (sortBy.value === 'category') {
            comparison = a.category.name.localeCompare(b.category.name, 'ru')
        } else {
            comparison = a.products_count - b.products_count
        }

        return sortDirection.value === 'asc' ? comparison : -comparison
    })
})

const toggleSort = (field: typeof sortBy.value): void => {
    if (sortBy.value === field) {
        sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc'
        return
    }

    sortBy.value = field
    sortDirection.value = 'asc'
}

const deleteDialogOpen = ref(false)
const deletingItemName = ref('')
const deletingItemId = ref<number | null>(null)
const deleting = ref(false)

const openDeleteDialog = (id: number, name: string): void => {
    deletingItemId.value = id
    deletingItemName.value = name
    deleteDialogOpen.value = true
}

const closeDeleteDialog = (): void => {
    if (deleting.value) return

    deleteDialogOpen.value = false
    deletingItemId.value = null
    deletingItemName.value = ''
}

const confirmDelete = (): void => {
    if (deletingItemId.value === null || deleting.value) return

    deleting.value = true

    router.delete(destroy(deletingItemId.value).url, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Запись успешно удалена.')
            deleteDialogOpen.value = false
            deletingItemId.value = null
            deletingItemName.value = ''
        },
        onError: (errors) => {
            toast.error(
                errors.delete ?? 'Не удалось удалить тип товара.',
            )
        },
        onFinish: () => {
            deleting.value = false
        },
    })
}

const clearFilters = (): void => {
    search.value = ''
    statusFilter.value = 'all'
}
</script>

<template>
    <Head title="Типы товаров" />

    <div class="space-y-6 p-4 sm:p-6">
        <!-- Заголовок -->
        <div
            class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-indigo-950 to-violet-900 p-6 text-white shadow-lg sm:p-8"
        >
            <div
                class="pointer-events-none absolute -right-12 -top-16 h-56 w-56 rounded-full bg-violet-400/20 blur-3xl"
            />
            <div
                class="pointer-events-none absolute -bottom-20 right-1/3 h-48 w-48 rounded-full bg-blue-400/10 blur-3xl"
            />

            <div class="relative flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between">
                <div>
                    <div class="mb-3 flex items-center gap-2 text-sm text-indigo-200">
                        <FolderTree class="h-4 w-4" />
                        <span>Каталог товаров</span>
                    </div>

                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">
                        Типы товаров
                    </h1>

                    <p class="mt-2 max-w-xl text-sm text-slate-300 sm:text-base">
                        Управление типами товаров и их принадлежностью к категориям.
                    </p>
                </div>

                <Link
                    :href="create.url()"
                    class="inline-flex shrink-0 items-center justify-center gap-2 rounded-xl bg-white px-5 py-3 text-sm font-semibold text-slate-900 shadow-lg transition hover:bg-indigo-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-2 focus-visible:ring-offset-indigo-950"
                >
                    <CirclePlus class="h-5 w-5" />
                    Добавить тип
                </Link>
            </div>
        </div>

        <!-- Статистика -->
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p class="text-sm text-slate-500 dark:text-slate-400">
                            Всего типов
                        </p>
                        <p class="mt-2 text-3xl font-bold text-slate-900 dark:text-white">
                            {{ props.productTypes.total }}
                        </p>
                    </div>
                    <div class="rounded-xl bg-indigo-50 p-3 dark:bg-indigo-500/10">
                        <Boxes class="h-6 w-6 text-indigo-600 dark:text-indigo-400" />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    Во всех страницах каталога
                </p>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p class="text-sm text-slate-500 dark:text-slate-400">
                            Активные
                        </p>
                        <p class="mt-2 text-3xl font-bold text-emerald-600 dark:text-emerald-400">
                            {{ activeCount }}
                        </p>
                    </div>
                    <div class="rounded-xl bg-emerald-50 p-3 dark:bg-emerald-500/10">
                        <CheckCircle2 class="h-6 w-6 text-emerald-600 dark:text-emerald-400" />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    На текущей странице
                </p>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p class="text-sm text-slate-500 dark:text-slate-400">
                            Неактивные
                        </p>
                        <p class="mt-2 text-3xl font-bold text-amber-600 dark:text-amber-400">
                            {{ inactiveCount }}
                        </p>
                    </div>
                    <div class="rounded-xl bg-amber-50 p-3 dark:bg-amber-500/10">
                        <ShieldAlert class="h-6 w-6 text-amber-600 dark:text-amber-400" />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    На текущей странице
                </p>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-center justify-between gap-3">
                    <div>
                        <p class="text-sm text-slate-500 dark:text-slate-400">
                            Привязано товаров
                        </p>
                        <p class="mt-2 text-3xl font-bold text-slate-900 dark:text-white">
                            {{ productsCount }}
                        </p>
                    </div>
                    <div class="rounded-xl bg-sky-50 p-3 dark:bg-sky-500/10">
                        <Package class="h-6 w-6 text-sky-600 dark:text-sky-400" />
                    </div>
                </div>
                <p class="mt-3 text-xs text-slate-500 dark:text-slate-400">
                    На текущей странице
                </p>
            </div>
        </div>

        <!-- Таблица -->
        <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="border-b border-slate-200 p-4 dark:border-slate-800 sm:p-5">
                <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
                    <div>
                        <h2 class="text-lg font-semibold text-slate-900 dark:text-white">
                            Список типов
                        </h2>
                        <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
                            Найдено: {{ filteredProductTypes.length }}
                            <span class="text-slate-400">
                                из {{ props.productTypes.data.length }} на странице
                            </span>
                        </p>
                    </div>

                    <div class="flex flex-col gap-3 sm:flex-row">
                        <div class="relative min-w-0 sm:min-w-64">
                            <Search class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                            <input
                                v-model="search"
                                type="search"
                                placeholder="Название, категория, slug..."
                                class="w-full rounded-xl border border-slate-200 bg-slate-50 py-2.5 pl-9 pr-9 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 dark:border-slate-700 dark:bg-slate-950 dark:text-white dark:focus:bg-slate-950"
                            />
                            <button
                                v-if="search"
                                type="button"
                                aria-label="Очистить поиск"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 transition hover:text-slate-700 dark:hover:text-slate-200"
                                @click="search = ''"
                            >
                                <X class="h-4 w-4" />
                            </button>
                        </div>

                        <select
                            v-model="statusFilter"
                            aria-label="Фильтр по статусу"
                            class="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm text-slate-700 outline-none transition focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-200"
                        >
                            <option value="all">Все статусы</option>
                            <option value="active">Активные</option>
                            <option value="inactive">Неактивные</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full min-w-[850px] text-sm">
                    <thead class="bg-slate-50 dark:bg-slate-950/60">
                    <tr class="border-b border-slate-200 dark:border-slate-800">
                        <th class="px-5 py-4 text-left font-semibold text-slate-600 dark:text-slate-300">
                            <button
                                type="button"
                                class="inline-flex items-center gap-2 transition hover:text-indigo-600 dark:hover:text-indigo-400"
                                @click="toggleSort('name')"
                            >
                                Название
                                <ArrowUp v-if="sortBy === 'name' && sortDirection === 'asc'" class="h-3.5 w-3.5" />
                                <ArrowDown v-else-if="sortBy === 'name' && sortDirection === 'desc'" class="h-3.5 w-3.5" />
                                <ArrowUpDown v-else class="h-3.5 w-3.5 opacity-40" />
                            </button>
                        </th>

                        <th class="px-5 py-4 text-left font-semibold text-slate-600 dark:text-slate-300">
                            <button
                                type="button"
                                class="inline-flex items-center gap-2 transition hover:text-indigo-600 dark:hover:text-indigo-400"
                                @click="toggleSort('category')"
                            >
                                Категория
                                <ArrowUp v-if="sortBy === 'category' && sortDirection === 'asc'" class="h-3.5 w-3.5" />
                                <ArrowDown v-else-if="sortBy === 'category' && sortDirection === 'desc'" class="h-3.5 w-3.5" />
                                <ArrowUpDown v-else class="h-3.5 w-3.5 opacity-40" />
                            </button>
                        </th>

                        <th class="px-5 py-4 text-left font-semibold text-slate-600 dark:text-slate-300">
                            Slug
                        </th>

                        <th class="px-5 py-4 text-center font-semibold text-slate-600 dark:text-slate-300">
                            <button
                                type="button"
                                class="inline-flex items-center gap-2 transition hover:text-indigo-600 dark:hover:text-indigo-400"
                                @click="toggleSort('products_count')"
                            >
                                Товаров
                                <ArrowUp v-if="sortBy === 'products_count' && sortDirection === 'asc'" class="h-3.5 w-3.5" />
                                <ArrowDown v-else-if="sortBy === 'products_count' && sortDirection === 'desc'" class="h-3.5 w-3.5" />
                                <ArrowUpDown v-else class="h-3.5 w-3.5 opacity-40" />
                            </button>
                        </th>

                        <th class="px-5 py-4 text-center font-semibold text-slate-600 dark:text-slate-300">
                            Статус
                        </th>

                        <th class="px-5 py-4 text-right font-semibold text-slate-600 dark:text-slate-300">
                            Действия
                        </th>
                    </tr>
                    </thead>

                    <tbody class="divide-y divide-slate-100 dark:divide-slate-800">
                    <tr
                        v-for="productType in filteredProductTypes"
                        :key="productType.id"
                        class="transition-colors hover:bg-slate-50/80 dark:hover:bg-slate-800/40"
                    >
                        <td class="px-5 py-4">
                            <div class="flex items-center gap-3">
                                <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400">
                                    <Archive class="h-5 w-5" />
                                </div>
                                <div>
                                    <p class="font-semibold text-slate-900 dark:text-white">
                                        {{ productType.name }}
                                    </p>
                                    <p class="mt-0.5 text-xs text-slate-500 dark:text-slate-400">
                                        ID: {{ productType.id }}
                                    </p>
                                </div>
                            </div>
                        </td>

                        <td class="px-5 py-4">
                                <span class="inline-flex items-center gap-2 rounded-lg bg-slate-100 px-3 py-1.5 text-slate-700 dark:bg-slate-800 dark:text-slate-300">
                                    <FolderTree class="h-3.5 w-3.5 text-slate-400" />
                                    {{ productType.category.name }}
                                </span>
                        </td>

                        <td class="px-5 py-4">
                            <code class="rounded-md bg-slate-100 px-2 py-1 text-xs text-slate-600 dark:bg-slate-800 dark:text-slate-300">
                                {{ productType.slug }}
                            </code>
                        </td>

                        <td class="px-5 py-4 text-center">
                                <span
                                    :class="[
                                        'inline-flex min-w-10 items-center justify-center rounded-lg px-2.5 py-1.5 font-semibold tabular-nums',
                                        productType.products_count > 0
                                            ? 'bg-sky-50 text-sky-700 dark:bg-sky-500/10 dark:text-sky-300'
                                            : 'bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400',
                                    ]"
                                >
                                    {{ productType.products_count }}
                                </span>
                        </td>

                        <td class="px-5 py-4 text-center">
                                <span
                                    :class="[
                                        'inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium',
                                        productType.is_active
                                            ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400'
                                            : 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400',
                                    ]"
                                >
                                    <span
                                        :class="[
                                            'h-1.5 w-1.5 rounded-full',
                                            productType.is_active ? 'bg-emerald-500' : 'bg-slate-400',
                                        ]"
                                    />
                                    {{ productType.is_active ? 'Активен' : 'Неактивен' }}
                                </span>
                        </td>

                        <td class="px-5 py-4">
                            <div class="flex items-center justify-end gap-2">
                                <Link
                                    :href="edit(productType.id).url"
                                    :aria-label="`Изменить тип ${productType.name}`"
                                    class="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-3 py-2 text-xs font-medium text-slate-700 transition hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-indigo-500 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:border-indigo-500/50 dark:hover:bg-indigo-500/10 dark:hover:text-indigo-300"
                                >
                                    <Edit class="h-3.5 w-3.5" />
                                    Изменить
                                </Link>

                                <button
                                    type="button"
                                    :aria-label="`Удалить тип ${productType.name}`"
                                    :disabled="productType.products_count > 0"
                                    :title="productType.products_count > 0
                                            ? 'Нельзя удалить тип, пока к нему привязаны товары'
                                            : 'Удалить тип товара'"
                                    class="inline-flex items-center gap-2 rounded-lg border border-rose-200 bg-white px-3 py-2 text-xs font-medium text-rose-600 transition hover:border-rose-300 hover:bg-rose-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-rose-500 disabled:cursor-not-allowed disabled:opacity-40 disabled:hover:border-rose-200 disabled:hover:bg-white dark:border-rose-900/60 dark:bg-slate-900 dark:text-rose-400 dark:hover:border-rose-700 dark:hover:bg-rose-500/10 dark:disabled:hover:bg-slate-900"
                                    @click="openDeleteDialog(productType.id, productType.name)"
                                >
                                    <Trash2 class="h-3.5 w-3.5" />
                                    Удалить
                                </button>
                            </div>
                        </td>
                    </tr>

                    <tr v-if="filteredProductTypes.length === 0">
                        <td colspan="6" class="px-5 py-16 text-center">
                            <div class="mx-auto flex max-w-sm flex-col items-center">
                                <div class="mb-4 rounded-2xl bg-slate-100 p-4 dark:bg-slate-800">
                                    <Search class="h-7 w-7 text-slate-400" />
                                </div>
                                <p class="font-semibold text-slate-900 dark:text-white">
                                    Типы товаров не найдены
                                </p>
                                <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
                                    Измените поисковый запрос или сбросьте фильтры.
                                </p>
                                <button
                                    v-if="search || statusFilter !== 'all'"
                                    type="button"
                                    class="mt-4 inline-flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-sm font-medium text-slate-700 transition hover:bg-slate-50 dark:border-slate-700 dark:text-slate-300 dark:hover:bg-slate-800"
                                    @click="clearFilters"
                                >
                                    <X class="h-4 w-4" />
                                    Сбросить фильтры
                                </button>
                            </div>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <!-- Пагинация -->
            <div
                v-if="props.productTypes.last_page > 1"
                class="flex flex-col gap-4 border-t border-slate-200 px-4 py-4 dark:border-slate-800 sm:flex-row sm:items-center sm:justify-between sm:px-5"
            >
                <p class="text-sm text-slate-500 dark:text-slate-400">
                    Показаны
                    <span class="font-semibold text-slate-700 dark:text-slate-200">
                        {{ props.productTypes.from ?? 0 }}–{{ props.productTypes.to ?? 0 }}
                    </span>
                    из
                    <span class="font-semibold text-slate-700 dark:text-slate-200">
                        {{ props.productTypes.total }}
                    </span>
                    типов
                </p>

                <div class="flex flex-wrap items-center gap-1.5">
                    <Link
                        v-for="(link, index) in props.productTypes.links"
                        :key="`${index}-${link.label}`"
                        :href="link.url ?? '#'"
                        preserve-scroll
                        :class="[
                            'inline-flex min-h-9 min-w-9 items-center justify-center rounded-lg border px-3 py-2 text-sm transition',
                            link.active
                                ? 'border-indigo-600 bg-indigo-600 font-semibold text-white shadow-sm'
                                : 'border-slate-200 bg-white text-slate-600 hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-700 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300 dark:hover:border-indigo-500/50 dark:hover:bg-indigo-500/10',
                            !link.url ? 'pointer-events-none opacity-40' : '',
                        ]"
                    >
                        <span v-html="link.label" />
                    </Link>
                </div>
            </div>
        </div>
    </div>

    <ConfirmDeleteDialog
        :open="deleteDialogOpen"
        :item-name="deletingItemName"
        description="Это действие нельзя отменить."
        :processing="deleting"
        @confirm="confirmDelete"
        @cancel="closeDeleteDialog"
    />
</template>
