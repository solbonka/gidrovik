<script setup lang="ts">
import { Link, usePage } from '@inertiajs/vue3';
import { dashboard } from '@/routes/admin';
import { logout as logoutRoute } from '@/routes';
import { Menu, ExternalLink, LogOut } from '@lucide/vue';
import { Button } from '@/components/ui/button';

interface Props {
    title?: string;
}

withDefaults(defineProps<Props>(), {
    title: 'Панель управления',
});

const emit = defineEmits<{
    'toggle-sidebar': [];
}>();

const page = usePage();

const submitLogout = (): void => {
    const form = document.createElement('form');

    form.method = 'POST';
    form.action = logoutRoute.url();

    const token = document
        .querySelector('meta[name="csrf-token"]')
        ?.getAttribute('content');

    if (token) {
        const input = document.createElement('input');

        input.type = 'hidden';
        input.name = '_token';
        input.value = token;

        form.appendChild(input);
    }

    document.body.appendChild(form);
    form.submit();
};
</script>

<template>
    <header
        class="sticky top-0 z-30 border-b border-border/10 bg-white/80 shadow-sm backdrop-blur-xl supports-[backdrop-filter]:bg-white/60"
    >
        <div
            class="flex h-16 items-center justify-between px-3 sm:px-6 lg:px-8"
        >
            <div class="flex items-center gap-2 sm:gap-3">
                <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    class="text-muted-foreground hover:bg-muted/50 hover:text-foreground lg:hidden"
                    @click="emit('toggle-sidebar')"
                    aria-label="Открыть меню"
                >
                    <Menu :size="20" />
                </Button>

                <div class="flex items-center gap-2">
                    <div
                        class="hidden h-8 w-1 rounded-full bg-gradient-to-b from-primary to-indigo-600 sm:flex"
                    />
                    <h1
                        class="bg-gradient-to-r from-foreground to-muted-foreground bg-clip-text text-base font-semibold text-transparent sm:text-lg"
                    >
                        {{ title }}
                    </h1>
                </div>
            </div>

            <div class="flex items-center gap-1 sm:gap-2">
                <div class="mr-2 hidden text-right sm:block">
                    <div class="text-sm font-medium text-foreground">
                        {{ page.props.auth?.user?.name ?? 'Пользователь' }}
                    </div>

                    <div class="text-xs text-muted-foreground">
                        Администратор
                    </div>
                </div>

                <Button
                    variant="ghost"
                    size="sm"
                    class="hidden text-muted-foreground hover:bg-muted/50 hover:text-foreground sm:flex"
                    as-child
                >
                    <Link :href="dashboard.url()">
                        <ExternalLink :size="16" class="mr-1.5" />
                        На сайт
                    </Link>
                </Button>

                <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    class="text-muted-foreground transition-colors hover:bg-destructive/5 hover:text-destructive"
                    @click="submitLogout"
                >
                    <LogOut :size="16" class="sm:mr-1.5" />
                    <span class="hidden sm:inline">Выйти</span>
                </Button>
            </div>
        </div>
    </header>
</template>
