<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import { ref, computed } from 'vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { Button } from '@/components/ui/button';
import { index as stockIndex } from '@/routes/admin/stock';

defineOptions({ layout: AdminLayout });

interface LocationRow {
    location_label: string
    status: string
    status_label: string
    count: number
    total_mm: string
    max_mm: string
}

interface ProductRow {
    product_id: number
    name: string
    code: string | null
    available_mm: string
    available_count: number
    reserved_mm: string
    reserved_count: number
    quarantined_mm: string
    scrapped_mm: string
    consumed_mm: string
    locations: LocationRow[]
}

const props = defineProps<{
    products: ProductRow[]
    scrap_last_30_days_mm: string
}>()

const expanded = ref<Set<number>>(new Set())

const toggle = (id: number) => {
    if (expanded.value.has(id)) expanded.value.delete(id)
    else expanded.value.add(id)
}

const mmToM = (mm: string | number): string => (Number(mm) / 1000).toFixed(3)

const totals = computed(() => {
    const t = { available: 0, reserved: 0, quarantined: 0, scrapped: 0, consumed: 0 }
    for (const p of props.products) {
        t.available += Number(p.available_mm)
        t.reserved += Number(p.reserved_mm)
        t.quarantined += Number(p.quarantined_mm)
        t.scrapped += Number(p.scrapped_mm)
        t.consumed += Number(p.consumed_mm)
    }
    return t
})
</script>

<template>
    <Head title="Отчёт по отрезкам" />

    <div class="space-y-6 p-6">
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-2xl font-bold">Отчёт по складским отрезкам</h1>
                <p class="mt-1 text-sm text-muted-foreground">
                    Мерные товары: физические остатки, резервы и списания
                </p>
            </div>
            <Button variant="outline" as-child>
                <Link :href="stockIndex()">К остаткам</Link>
            </Button>
        </div>

        <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
            <div class="rounded-xl border bg-card p-4">
                <p class="text-xs text-muted-foreground">Доступно</p>
                <p class="mt-1 text-xl font-bold tabular-nums">{{ mmToM(totals.available) }} м</p>
            </div>
            <div class="rounded-xl border bg-card p-4">
                <p class="text-xs text-muted-foreground">Зарезервировано</p>
                <p class="mt-1 text-xl font-bold tabular-nums">{{ mmToM(totals.reserved) }} м</p>
            </div>
            <div class="rounded-xl border bg-card p-4">
                <p class="text-xs text-muted-foreground">Карантин</p>
                <p class="mt-1 text-xl font-bold tabular-nums">{{ mmToM(totals.quarantined) }} м</p>
            </div>
            <div class="rounded-xl border bg-card p-4">
                <p class="text-xs text-muted-foreground">Списано (всего)</p>
                <p class="mt-1 text-xl font-bold tabular-nums">{{ mmToM(totals.scrapped) }} м</p>
            </div>
            <div class="rounded-xl border bg-card p-4">
                <p class="text-xs text-muted-foreground">Продано/использовано</p>
                <p class="mt-1 text-xl font-bold tabular-nums">{{ mmToM(totals.consumed) }} м</p>
            </div>
            <div class="rounded-xl border bg-card p-4">
                <p class="text-xs text-muted-foreground">Отходы за 30 дней</p>
                <p class="mt-1 text-xl font-bold tabular-nums">{{ mmToM(scrap_last_30_days_mm) }} м</p>
            </div>
        </div>

        <div class="overflow-hidden rounded-2xl border bg-card">
            <table class="w-full text-sm">
                <thead class="border-b bg-muted/50 text-left text-xs text-muted-foreground">
                    <tr>
                        <th class="px-4 py-3">Товар</th>
                        <th class="px-4 py-3 text-right">Доступно</th>
                        <th class="px-4 py-3 text-right">Резерв</th>
                        <th class="px-4 py-3 text-right">Карантин</th>
                        <th class="px-4 py-3 text-right">Списано</th>
                        <th class="px-4 py-3 text-right">Использовано</th>
                        <th class="px-4 py-3"></th>
                    </tr>
                </thead>
                <tbody class="divide-y">
                    <template v-for="p in products" :key="p.product_id">
                        <tr
                            class="cursor-pointer hover:bg-muted/40"
                            @click="toggle(p.product_id)"
                        >
                            <td class="px-4 py-3">
                                <span class="font-medium">{{ p.name }}</span>
                                <span v-if="p.code" class="ml-2 text-xs text-muted-foreground">{{ p.code }}</span>
                            </td>
                            <td class="px-4 py-3 text-right tabular-nums">
                                {{ mmToM(p.available_mm) }} м
                                <span class="text-xs text-muted-foreground">({{ p.available_count }} шт.)</span>
                            </td>
                            <td class="px-4 py-3 text-right tabular-nums">{{ mmToM(p.reserved_mm) }} м</td>
                            <td class="px-4 py-3 text-right tabular-nums">{{ mmToM(p.quarantined_mm) }} м</td>
                            <td class="px-4 py-3 text-right tabular-nums">{{ mmToM(p.scrapped_mm) }} м</td>
                            <td class="px-4 py-3 text-right tabular-nums">{{ mmToM(p.consumed_mm) }} м</td>
                            <td class="px-4 py-3 text-right text-muted-foreground">
                                {{ expanded.has(p.product_id) ? '▲' : '▼' }}
                            </td>
                        </tr>
                        <tr v-if="expanded.has(p.product_id)">
                            <td colspan="7" class="bg-muted/30 px-4 py-3">
                                <table class="w-full text-xs">
                                    <thead class="text-muted-foreground">
                                        <tr>
                                            <th class="py-1 text-left">Ячейка</th>
                                            <th class="py-1 text-left">Статус</th>
                                            <th class="py-1 text-right">Кусков</th>
                                            <th class="py-1 text-right">Сумма</th>
                                            <th class="py-1 text-right">Макс.</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr v-for="(l, i) in p.locations" :key="i" class="border-t">
                                            <td class="py-1">{{ l.location_label }}</td>
                                            <td class="py-1">{{ l.status_label }}</td>
                                            <td class="py-1 text-right tabular-nums">{{ l.count }}</td>
                                            <td class="py-1 text-right tabular-nums">{{ mmToM(l.total_mm) }} м</td>
                                            <td class="py-1 text-right tabular-nums">{{ mmToM(l.max_mm) }} м</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </template>
                    <tr v-if="!products.length">
                        <td colspan="7" class="px-4 py-8 text-center text-muted-foreground">
                            Нет товаров с учётом по отрезкам
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</template>
