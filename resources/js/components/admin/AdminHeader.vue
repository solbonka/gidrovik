<script setup lang="ts">
import { Link, usePage } from '@inertiajs/vue3'
import { dashboard } from '@/routes/admin'
import { logout as logoutRoute } from '@/routes'
import { Menu } from '@lucide/vue'

interface Props {
    title?: string
}

withDefaults(defineProps<Props>(), {
    title: 'Панель управления',
})

const emit = defineEmits<{
    'toggle-sidebar': []
}>()

const page = usePage()

const submitLogout = (): void => {
    const form = document.createElement('form')

    form.method = 'POST'
    form.action = logoutRoute.url()

    const token = document
        .querySelector('meta[name="csrf-token"]')
        ?.getAttribute('content')

    if (token) {
        const input = document.createElement('input')

        input.type = 'hidden'
        input.name = '_token'
        input.value = token

        form.appendChild(input)
    }

    document.body.appendChild(form)
    form.submit()
}
</script>

<template>
    <header class="sticky top-0 z-30 border-b border-gray-200 bg-white">
        <div class="flex h-16 items-center justify-between px-4 sm:px-6 lg:px-8">
            <div class="flex items-center gap-3">
                <button
                    type="button"
                    class="rounded-lg p-2 text-gray-600 hover:bg-gray-100 lg:hidden"
                    @click="emit('toggle-sidebar')"
                    aria-label="Открыть меню"
                >
                    <Menu :size="20" />
                </button>

                <h1 class="text-base font-semibold text-gray-900 sm:text-lg">
                    {{ title }}
                </h1>
            </div>

            <div class="flex items-center gap-2 sm:gap-4">
                <div class="hidden text-right sm:block">
                    <div class="text-sm font-medium text-gray-900">
                        {{ page.props.auth?.user?.name ?? 'Пользователь' }}
                    </div>

                    <div class="text-xs text-gray-500">
                        Администратор
                    </div>
                </div>

                <Link
                    :href="dashboard.url()"
                    class="hidden rounded-lg px-3 py-2 text-sm text-gray-600 hover:bg-gray-100 sm:block"
                >
                    На сайт
                </Link>

                <button
                    type="button"
                    class="rounded-lg px-3 py-2 text-sm font-medium text-red-600 hover:bg-red-50"
                    @click="submitLogout"
                >
                    <span class="hidden sm:inline">Выйти</span>
                    <span class="sm:hidden">↪</span>
                </button>
            </div>
        </div>
    </header>
</template>
