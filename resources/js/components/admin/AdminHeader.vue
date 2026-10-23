<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { Link, router, usePage } from '@inertiajs/vue3'
import {
    ChevronDown,
    LogOut,
    Palette,
    ShieldCheck,
    UserRound,
} from '@lucide/vue'
import { logout as logoutRoute } from '@/routes'
import { dashboard } from '@/routes/admin'

const emit = defineEmits<{
    (event: 'toggle-sidebar'): void
}>()

const page = usePage()
const isProfileMenuOpen = ref(false)
const profileMenu = ref<HTMLElement | null>(null)

type ProfileUser = {
    name?: string | null
    role?: string | { name?: string | null } | null
}

const user = computed(
    () => page.props.auth?.user as ProfileUser | undefined,
)

const userName = computed(() => user.value?.name?.trim() || 'Пользователь')

const userInitials = computed(() => {
    const parts = userName.value
        .split(/\s+/)
        .filter(Boolean)

    if (parts.length === 0) {
        return 'П'
    }

    return parts
        .slice(0, 2)
        .map((part) => part.charAt(0).toLocaleUpperCase('ru-RU'))
        .join('')
})

const userRole = computed(() => {
    const role = user.value?.role

    const roleLabels: Record<string, string> = (page.props.roles as Record<string, string> | undefined) ?? {}

    if (typeof role === 'string' && role.trim()) {
        return roleLabels[role.trim()] ?? role.trim()
    }

    if (typeof role === 'object' && role?.name?.trim()) {
        return roleLabels[role.name.trim()] ?? role.name.trim()
    }

    return 'Учётная запись'
})

const isActive = (path: string) => page.url.split('?')[0] === path

const closeProfileMenu = () => {
    isProfileMenuOpen.value = false
}

const toggleProfileMenu = () => {
    isProfileMenuOpen.value = !isProfileMenuOpen.value
}

const handleClickOutside = (event: MouseEvent) => {
    if (
        profileMenu.value &&
        !profileMenu.value.contains(event.target as Node)
    ) {
        closeProfileMenu()
    }
}

const handleKeydown = (event: KeyboardEvent) => {
    if (event.key === 'Escape') {
        closeProfileMenu()
    }
}

const submitLogout = () => {
    closeProfileMenu()
    router.post(logoutRoute.url())
}

onMounted(() => {
    document.addEventListener('click', handleClickOutside)
    document.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
    document.removeEventListener('click', handleClickOutside)
    document.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
    <header
        class="sticky top-0 z-30 flex h-16 items-center justify-between gap-3 border-b border-border bg-background/95 px-4 backdrop-blur sm:px-6"
    >
        <div class="flex min-w-0 items-center gap-3">
            <button
                type="button"
                class="inline-flex size-10 shrink-0 items-center justify-center rounded-lg text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                aria-label="Открыть меню навигации"
                @click="emit('toggle-sidebar')"
            >
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="21"
                    height="21"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="1.8"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                >
                    <path d="M4 6h16" />
                    <path d="M4 12h16" />
                    <path d="M4 18h16" />
                </svg>
            </button>

            <Link
                :href="dashboard.url()"
                class="truncate text-sm font-semibold text-foreground transition-colors hover:text-primary"
            >
                Панель управления
            </Link>
        </div>

        <div class="flex shrink-0 items-center gap-2">
            <div
                ref="profileMenu"
                class="relative"
            >
                <button
                    type="button"
                    class="flex items-center gap-2 rounded-xl p-1.5 transition-colors hover:bg-accent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring sm:gap-3 sm:px-2"
                    :aria-expanded="isProfileMenuOpen"
                    aria-haspopup="menu"
                    aria-label="Меню пользователя"
                    @click="toggleProfileMenu"
                >
                    <span
                        class="flex size-9 shrink-0 items-center justify-center rounded-xl bg-primary text-sm font-semibold text-primary-foreground ring-1 ring-border/50"
                        aria-hidden="true"
                    >
                        {{ userInitials }}
                    </span>

                    <span class="hidden max-w-48 text-left sm:block">
                        <span
                            class="block truncate text-sm font-medium text-foreground"
                        >
                            {{ userName }}
                        </span>

                        <span
                            class="block truncate text-xs text-muted-foreground"
                        >
                            {{ userRole }}
                        </span>
                    </span>

                    <ChevronDown
                        class="hidden size-4 text-muted-foreground transition-transform sm:block"
                        :class="{ 'rotate-180': isProfileMenuOpen }"
                    />
                </button>

                <div
                    v-if="isProfileMenuOpen"
                    class="absolute right-0 top-full z-50 mt-2 w-64 overflow-hidden rounded-xl border border-border bg-popover text-popover-foreground shadow-xl"
                    role="menu"
                    aria-label="Меню пользователя"
                >
                    <div class="border-b border-border px-4 py-3">
                        <div class="flex items-center gap-3">
                            <span
                                class="flex size-11 shrink-0 items-center justify-center rounded-xl bg-primary text-sm font-semibold text-primary-foreground"
                                aria-hidden="true"
                            >
                                {{ userInitials }}
                            </span>

                            <div class="min-w-0 flex-1">
                                <p class="truncate text-sm font-semibold">
                                    {{ userName }}
                                </p>

                                <p class="truncate text-xs text-muted-foreground">
                                    {{ userRole }}
                                </p>
                            </div>
                        </div>
                    </div>

                    <div class="p-1.5">
                        <Link
                            href="/settings/profile"
                            role="menuitem"
                            class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:bg-accent focus-visible:outline-none"
                            :class="{
                                'bg-accent text-accent-foreground': isActive('/settings/profile'),
                            }"
                            @click="closeProfileMenu"
                        >
                            <UserRound class="size-4 shrink-0 text-muted-foreground" />
                            <span>Профиль</span>
                        </Link>

                        <Link
                            href="/settings/security"
                            role="menuitem"
                            class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:bg-accent focus-visible:outline-none"
                            :class="{
                                'bg-accent text-accent-foreground': isActive('/settings/security'),
                            }"
                            @click="closeProfileMenu"
                        >
                            <ShieldCheck class="size-4 shrink-0 text-muted-foreground" />
                            <span>Безопасность</span>
                        </Link>

                        <Link
                            href="/settings/appearance"
                            role="menuitem"
                            class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:bg-accent focus-visible:outline-none"
                            :class="{
                                'bg-accent text-accent-foreground': isActive('/settings/appearance'),
                            }"
                            @click="closeProfileMenu"
                        >
                            <Palette class="size-4 shrink-0 text-muted-foreground" />
                            <span>Внешний вид</span>
                        </Link>
                    </div>

                    <div class="border-t border-border p-1.5">
                        <button
                            type="button"
                            role="menuitem"
                            class="flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm text-destructive transition-colors hover:bg-destructive/10 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                            @click="submitLogout"
                        >
                            <LogOut class="size-4 shrink-0" />
                            <span>Выйти из аккаунта</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </header>
</template>
