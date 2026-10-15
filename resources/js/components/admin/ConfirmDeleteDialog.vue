<script setup lang="ts">
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'

interface Props {
    open: boolean
    title: string
    description: string
    itemName: string
    loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
    loading: false,
})

const emit = defineEmits<{
    confirm: []
    cancel: []
}>()

const handleConfirm = (): void => {
    emit('confirm')
}

const handleCancel = (): void => {
    emit('cancel')
}
</script>

<template>
    <Dialog :open="open" @update:open="(value) => !value && emit('cancel')">
        <DialogContent>
            <DialogHeader>
                <DialogTitle>{{ title }}</DialogTitle>
                <DialogDescription>
                    {{ description }}
                    <span class="font-semibold text-gray-900">
                        "{{ itemName }}"
                    </span>
                    . Это действие нельзя отменить.
                </DialogDescription>
            </DialogHeader>

            <DialogFooter>
                <Button
                    variant="outline"
                    :disabled="loading"
                    @click="handleCancel"
                >
                    Отмена
                </Button>

                <Button
                    variant="destructive"
                    :disabled="loading"
                    @click="handleConfirm"
                >
                    {{ loading ? 'Удаление...' : 'Удалить' }}
                </Button>
            </DialogFooter>
        </DialogContent>
    </Dialog>
</template>
