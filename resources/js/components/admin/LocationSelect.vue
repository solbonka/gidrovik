<script setup lang="ts">
import { ref, computed } from 'vue';
import { Search, Check } from '@lucide/vue';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import type { AcceptableValue } from 'reka-ui';

interface RackOption {
    id?: number;
    code: string;
    name: string | null;
}

interface LocationOption {
    id: number;
    number?: number;
    code: string;
    rack?: RackOption | null;
    rack_name?: string | null;
}

interface Props {
    locations: LocationOption[];
    modelValue: string;
}

const props = defineProps<Props>();

const emit = defineEmits<{
    'update:modelValue': [value: string];
}>();

const searchQuery = ref('');
const open = ref(false);

const filteredLocations = computed(() => {
    if (!searchQuery.value) return props.locations.slice(0, 50);
    const query = searchQuery.value.toLowerCase();
    return props.locations.filter(
        (location) =>
            location.code.toLowerCase().includes(query) ||
            (location.rack?.name?.toLowerCase().includes(query) ||
                location.rack_name?.toLowerCase().includes(query)),
    );
});

const selectedLocation = computed(() =>
    props.locations.find(
        (location) => String(location.id) === props.modelValue,
    ),
);

const handleSelect = (value: AcceptableValue): void => {
    if (typeof value !== 'string') {
        return;
    }

    emit('update:modelValue', value);
    open.value = false;
    searchQuery.value = '';
};
</script>

<template>
    <Select
        :model-value="modelValue"
        @update:model-value="handleSelect"
        :open="open"
        @update:open="open = $event"
    >
        <SelectTrigger class="w-full">
            <SelectValue
                :placeholder="
                    selectedLocation ? selectedLocation.code : 'Выберите ячейку'
                "
            />
        </SelectTrigger>

        <SelectContent class="max-h-96">
            <div class="border-b px-3 py-2">
                <div class="relative">
                    <Search
                        :size="14"
                        class="absolute top-1/2 left-2 -translate-y-1/2 text-gray-400"
                    />
                    <input
                        v-model="searchQuery"
                        type="search"
                        placeholder="Поиск..."
                        class="w-full rounded-md border border-gray-200 py-1.5 pr-2 pl-8 text-sm focus:ring-2 focus:ring-gray-500 focus:outline-none"
                        @click.stop
                    />
                </div>
            </div>

            <div class="max-h-72 overflow-y-auto">
                <SelectItem
                    v-for="location in filteredLocations"
                    :key="location.id"
                    :value="String(location.id)"
                >
                    <div class="flex w-full items-center justify-between">
                        <div class="flex flex-col">
                            <span class="font-medium">{{ location.code }}</span>
                            <span
                                v-if="location.rack?.name || location.rack_name"
                                class="text-xs text-gray-500"
                            >
                                {{ location.rack?.name ?? location.rack_name }}
                            </span>
                        </div>
                    </div>
                    <Check
                        v-if="String(location.id) === modelValue"
                        :size="14"
                        class="ml-2 text-gray-900"
                    />
                </SelectItem>

                <div
                    v-if="filteredLocations.length === 0"
                    class="px-3 py-4 text-center text-sm text-gray-500"
                >
                    Ячейки не найдены
                </div>
            </div>
        </SelectContent>
    </Select>
</template>
