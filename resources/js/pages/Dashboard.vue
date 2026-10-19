<script setup lang="ts">
import { Head } from '@inertiajs/vue3';
import PlaceholderPattern from '@/components/PlaceholderPattern.vue';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { dashboard } from '@/routes';

defineOptions({
    layout: {
        breadcrumbs: [
            {
                title: 'Dashboard',
                href: dashboard(),
            },
        ],
    },
});
</script>

<template>
    <Head title="Dashboard" />

    <div class="flex flex-1 flex-col gap-4 sm:gap-6">
        <div class="grid gap-4 sm:grid-cols-2 md:grid-cols-3">
            <Card class="shadow-sm transition-all hover:shadow-md">
                <CardHeader
                    class="flex flex-row items-center justify-between space-y-0 pb-2"
                >
                    <CardTitle class="text-sm font-medium text-muted-foreground"
                        >Total</CardTitle
                    >
                </CardHeader>
                <CardContent>
                    <div class="text-2xl font-semibold">-</div>
                    <p class="mt-1 text-xs text-muted-foreground">
                        Last updated just now
                    </p>
                </CardContent>
            </Card>
            <Card class="shadow-sm transition-all hover:shadow-md">
                <CardHeader
                    class="flex flex-row items-center justify-between space-y-0 pb-2"
                >
                    <CardTitle class="text-sm font-medium text-muted-foreground"
                        >Active</CardTitle
                    >
                </CardHeader>
                <CardContent>
                    <div class="text-2xl font-semibold">-</div>
                    <p class="mt-1 text-xs text-muted-foreground">No changes</p>
                </CardContent>
            </Card>
            <Card class="shadow-sm transition-all hover:shadow-md">
                <CardHeader
                    class="flex flex-row items-center justify-between space-y-0 pb-2"
                >
                    <CardTitle class="text-sm font-medium text-muted-foreground"
                        >New</CardTitle
                    >
                </CardHeader>
                <CardContent>
                    <div class="text-2xl font-semibold">-</div>
                    <p class="mt-1 text-xs text-muted-foreground">
                        This period
                    </p>
                </CardContent>
            </Card>
        </div>
        <Card class="relative flex-1 shadow-sm">
            <CardContent
                class="relative h-full min-h-[60vh] p-0 md:min-h-[50vh]"
            >
                <div class="absolute inset-0 overflow-hidden rounded-xl">
                    <PlaceholderPattern />
                </div>
            </CardContent>
        </Card>
    </div>
</template>
