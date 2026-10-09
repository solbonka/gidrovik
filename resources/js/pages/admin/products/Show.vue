<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { create, index, edit } from '@/routes/admin/products';

defineOptions({
    layout: AdminLayout,
});

interface Category {
    id: number;
    name: string;
    slug: string;
}

interface ProductType {
    id: number;
    name: string;
    slug: string;
}

interface Characteristic {
    id: number;
    characteristic_id: number;
    name: string;
    slug: string;
    type: string;
    unit: string | null;
    value: string | null;
}

interface Standard {
    id: number;
    code: string;
    name: string;
}

interface Diameter {
    id: number;
    value: number;
    unit: string;
}

interface Thread {
    id: number;
    system: string;
    designation: string;
    name: string;
}

interface Connection {
    id: number;
    position: number;
    standard: Standard | null;
    diameter: Diameter | null;
    thread: Thread | null;
}

interface Rack {
    id: number;
    code: string;
    name: string | null;
}

interface Location {
    id: number;
    code: string;
    rack: Rack;
    number: number;
    quantity: number;
}

interface Product {
    id: number;
    name: string;
    sku: string;
    angle: number | null;
    description: string | null;
    is_active: boolean;
    category: Category | null;
    product_type: ProductType | null;
    stock_quantity: number;
    characteristics: Characteristic[];
    connections: Connection[];
    locations: Location[];
}

interface Props {
    product: Product;
}

const props = defineProps<Props>();

const formatCharacteristicValue = (
    characteristic: Characteristic,
): string => {
    if (characteristic.value === null || characteristic.value === '') {
        return '—';
    }

    if (characteristic.unit) {
        return `${characteristic.value} ${characteristic.unit}`;
    }

    return characteristic.value;
};

const connectionTitle = (connection: Connection): string => {
    const parts: string[] = [];

    if (connection.standard) {
        parts.push(connection.standard.code);
    }

    if (connection.diameter) {
        parts.push(
            `${connection.diameter.value} ${connection.diameter.unit}`,
        );
    }

    if (connection.thread) {
        parts.push(connection.thread.designation);
    }

    return parts.length > 0 ? parts.join(' / ') : 'Параметры не указаны';
};
</script>

<template>
    <Head :title="product.name" />

    <div class="space-y-6">
        <!-- Header -->
        <div
            class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between"
        >
            <div>
                <div class="mb-2 flex items-center gap-2 text-sm text-gray-500">
                    <Link
                        :href="index().url"
                        class="transition hover:text-gray-900"
                    >
                        Товары
                    </Link>

                    <span>/</span>

                    <span>{{ product.name }}</span>
                </div>

                <h1 class="text-2xl font-semibold text-gray-900">
                    {{ product.name }}
                </h1>

                <div class="mt-2 flex flex-wrap items-center gap-2">
                    <span
                        class="rounded bg-gray-100 px-2 py-1 font-mono text-sm text-gray-700"
                    >
                        {{ product.sku }}
                    </span>

                    <span
                        class="rounded-full px-2.5 py-1 text-xs font-medium"
                        :class="
                            product.is_active
                                ? 'bg-green-100 text-green-700'
                                : 'bg-gray-100 text-gray-600'
                        "
                    >
                        {{ product.is_active ? 'Активен' : 'Неактивен' }}
                    </span>
                </div>
            </div>

            <div class="flex items-center gap-2">
                <Link
                    :href="index().url"
                    class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 transition hover:bg-gray-50"
                >
                    Назад
                </Link>

                <Link
                    :href="edit(product.id).url"
                    class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white transition hover:bg-gray-800"
                >
                    Редактировать
                </Link>

                <Link
                    :href="create().url"
                    class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-medium text-white transition hover:bg-gray-800"
                >
                    Создать товар
                </Link>
            </div>
        </div>

        <!-- Main information -->
        <div class="grid gap-6 lg:grid-cols-3">
            <!-- Basic information -->
            <section
                class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm lg:col-span-2"
            >
                <h2 class="text-lg font-semibold text-gray-900">
                    Основная информация
                </h2>

                <div class="mt-5 grid gap-5 sm:grid-cols-2">
                    <div>
                        <div class="text-sm text-gray-500">Название</div>
                        <div class="mt-1 font-medium text-gray-900">
                            {{ product.name }}
                        </div>
                    </div>

                    <div>
                        <div class="text-sm text-gray-500">Артикул</div>
                        <div class="mt-1 font-mono font-medium text-gray-900">
                            {{ product.sku }}
                        </div>
                    </div>

                    <div>
                        <div class="text-sm text-gray-500">Категория</div>
                        <div class="mt-1 font-medium text-gray-900">
                            {{ product.category?.name ?? '—' }}
                        </div>
                    </div>

                    <div>
                        <div class="text-sm text-gray-500">Тип товара</div>
                        <div class="mt-1 font-medium text-gray-900">
                            {{ product.product_type?.name ?? '—' }}
                        </div>
                    </div>

                    <div v-if="product.angle !== null">
                        <div class="text-sm text-gray-500">Угол</div>
                        <div class="mt-1 font-medium text-gray-900">
                            {{ product.angle }}°
                        </div>
                    </div>
                </div>

                <div
                    v-if="product.description"
                    class="mt-6 border-t border-gray-100 pt-5"
                >
                    <div class="text-sm text-gray-500">Описание</div>

                    <div
                        class="mt-2 whitespace-pre-wrap text-sm leading-6 text-gray-700"
                    >
                        {{ product.description }}
                    </div>
                </div>
            </section>

            <!-- Stock -->
            <section
                class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
            >
                <h2 class="text-lg font-semibold text-gray-900">
                    Остаток
                </h2>

                <div class="mt-6">
                    <div class="text-4xl font-semibold text-gray-900">
                        {{ product.stock_quantity }}
                    </div>

                    <div class="mt-1 text-sm text-gray-500">
                        единиц на складе
                    </div>
                </div>

                <div class="mt-6 border-t border-gray-100 pt-5">
                    <div class="flex items-center justify-between">
            <span class="text-sm text-gray-500">
                Ячеек с товаром
            </span>

                        <span class="font-medium text-gray-900">
                {{ product.locations.length }}
            </span>
                    </div>
                </div>

                <div class="mt-5">
                    <Link
                        :href="`/admin/stock/movements?product_id=${product.id}`"
                        class="inline-flex w-full items-center justify-center rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium text-gray-700 transition hover:bg-gray-50"
                    >
                        Журнал движений товара
                    </Link>
                </div>
            </section>
        </div>

        <!-- Characteristics -->
        <section
            class="rounded-xl border border-gray-200 bg-white shadow-sm"
        >
            <div class="border-b border-gray-100 px-6 py-4">
                <h2 class="text-lg font-semibold text-gray-900">
                    Характеристики
                </h2>
            </div>

            <div v-if="product.characteristics.length" class="divide-y">
                <div
                    v-for="characteristic in product.characteristics"
                    :key="characteristic.id"
                    class="grid gap-2 px-6 py-4 sm:grid-cols-2"
                >
                    <div class="text-sm text-gray-500">
                        {{ characteristic.name }}
                    </div>

                    <div class="text-sm font-medium text-gray-900">
                        {{ formatCharacteristicValue(characteristic) }}
                    </div>
                </div>
            </div>

            <div
                v-else
                class="px-6 py-8 text-center text-sm text-gray-500"
            >
                Характеристики не указаны.
            </div>
        </section>

        <!-- Connections -->
        <section
            class="rounded-xl border border-gray-200 bg-white shadow-sm"
        >
            <div class="border-b border-gray-100 px-6 py-4">
                <h2 class="text-lg font-semibold text-gray-900">
                    Подключения
                </h2>
            </div>

            <div v-if="product.connections.length" class="divide-y">
                <div
                    v-for="connection in product.connections"
                    :key="connection.id"
                    class="px-6 py-5"
                >
                    <div class="flex items-start gap-4">
                        <div
                            class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-gray-100 text-sm font-semibold text-gray-700"
                        >
                            {{ connection.position }}
                        </div>

                        <div class="min-w-0 flex-1">
                            <div class="font-medium text-gray-900">
                                {{ connectionTitle(connection) }}
                            </div>

                            <div class="mt-3 grid gap-3 text-sm sm:grid-cols-3">
                                <div>
                                    <div class="text-gray-500">
                                        Стандарт
                                    </div>

                                    <div class="mt-1 text-gray-900">
                                        {{
                                            connection.standard
                                                ? `${connection.standard.code} — ${connection.standard.name}`
                                                : '—'
                                        }}
                                    </div>
                                </div>

                                <div>
                                    <div class="text-gray-500">
                                        Диаметр
                                    </div>

                                    <div class="mt-1 text-gray-900">
                                        {{
                                            connection.diameter
                                                ? `${connection.diameter.value} ${connection.diameter.unit}`
                                                : '—'
                                        }}
                                    </div>
                                </div>

                                <div>
                                    <div class="text-gray-500">
                                        Резьба
                                    </div>

                                    <div class="mt-1 text-gray-900">
                                        {{
                                            connection.thread
                                                ? `${connection.thread.designation} — ${connection.thread.name}`
                                                : '—'
                                        }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div
                v-else
                class="px-6 py-8 text-center text-sm text-gray-500"
            >
                Подключения не указаны.
            </div>
        </section>

        <!-- Locations -->
        <section
            class="rounded-xl border border-gray-200 bg-white shadow-sm"
        >
            <div class="border-b border-gray-100 px-6 py-4">
                <h2 class="text-lg font-semibold text-gray-900">
                    Расположение на складе
                </h2>
            </div>

            <div v-if="product.locations.length" class="overflow-x-auto">
                <table class="w-full text-left text-sm">
                    <thead
                        class="border-b border-gray-100 bg-gray-50 text-xs uppercase text-gray-500"
                    >
                    <tr>
                        <th class="px-6 py-3 font-medium">
                            Ячейка
                        </th>

                        <th class="px-6 py-3 font-medium">
                            Стеллаж
                        </th>

                        <th class="px-6 py-3 text-right font-medium">
                            Количество
                        </th>
                    </tr>
                    </thead>

                    <tbody class="divide-y divide-gray-100">
                    <tr
                        v-for="location in product.locations"
                        :key="location.id"
                    >
                        <td class="px-6 py-4">
                                <span class="font-mono font-medium text-gray-900">
                                    {{ location.code }}
                                </span>
                        </td>

                        <td class="px-6 py-4 text-gray-600">
                                <span class="font-medium text-gray-900">
                                    {{ location.rack.code }}
                                </span>

                            <span v-if="location.rack.name">
                                    — {{ location.rack.name }}
                                </span>
                        </td>

                        <td
                            class="px-6 py-4 text-right font-semibold text-gray-900"
                        >
                            {{ location.quantity }}
                        </td>
                    </tr>
                    </tbody>

                    <tfoot class="border-t border-gray-200 bg-gray-50">
                    <tr>
                        <td
                            colspan="2"
                            class="px-6 py-4 text-right font-medium text-gray-700"
                        >
                            Итого
                        </td>

                        <td
                            class="px-6 py-4 text-right font-semibold text-gray-900"
                        >
                            {{ product.stock_quantity }}
                        </td>
                    </tr>
                    </tfoot>
                </table>
            </div>

            <div
                v-else
                class="px-6 py-8 text-center text-sm text-gray-500"
            >
                Товар пока не размещён ни в одной ячейке склада.
            </div>
        </section>
    </div>
</template>
