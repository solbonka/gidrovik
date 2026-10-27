<script setup lang="ts">
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { computed, reactive, ref, watch } from 'vue';
import { toast } from 'vue-sonner';
import {
    CalendarDays,
    KeyRound,
    Mail,
    Search,
    ShieldCheck,
    UserRound,
    Users,
    X,
} from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import { Button } from '@/components/ui/button';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { index } from '@/routes/admin/users';
import { update } from '@/routes/admin/users/role';
import { toggle } from '@/routes/admin/users/employee';
import type { UserRole } from '@/types/auth';

defineOptions({
    layout: AdminLayout,
});

interface UserRow {
    id: number;
    name: string;
    email: string;
    role: UserRole;
    is_employee: boolean;
    email_verified_at: string | null;
    created_at: string;
}

interface RoleOption {
    value: UserRole;
    label: string;
    description: string;
}

interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

interface PaginatedUsers {
    data: UserRow[];
    current_page: number;
    last_page: number;
    from: number | null;
    to: number | null;
    total: number;
    links: PaginationLink[];
}

interface Props {
    users: PaginatedUsers;
    filters: {
        search: string;
    };
    totalUsers: number;
    roleCounts: Partial<Record<UserRole, number>>;
    roles: RoleOption[];
}

const props = defineProps<Props>();

const page = usePage();

const search = ref(props.filters.search);
const saving = ref<number | null>(null);
const draftRoles = reactive<Record<number, string>>({});

function syncDrafts(): void {
    if (!props.users.data) return;
    props.users.data.forEach((user) => {
        draftRoles[user.id] = user.role;
    });
}

watch(() => props.users.data, (val) => {
    if (val) syncDrafts();
}, { immediate: true });

const currentUserId = computed(
    () => (page.props.auth?.user as { id?: number } | undefined)?.id ?? null,
);

const stats = computed(() => [
    {
        title: 'Всего пользователей',
        value: props.totalUsers,
        icon: Users,
        tone: 'bg-primary/10 text-primary',
    },
    {
        title: 'Администраторов',
        value: props.roleCounts.admin ?? 0,
        icon: ShieldCheck,
        tone: 'bg-rose-500/10 text-rose-600 dark:text-rose-400',
    },
    {
        title: 'Менеджеров',
        value: props.roleCounts.manager ?? 0,
        icon: KeyRound,
        tone: 'bg-amber-500/10 text-amber-600 dark:text-amber-400',
    },
    {
        title: 'На странице',
        value: props.users.data?.length ?? 0,
        icon: UserRound,
        tone: 'bg-muted text-muted-foreground',
    },
]);

const roleBadges: Record<UserRole, string> = {
    admin: 'bg-rose-500/10 text-rose-700 ring-rose-600/20 dark:text-rose-400',
    manager:
        'bg-amber-500/10 text-amber-700 ring-amber-600/20 dark:text-amber-400',
    warehouse:
        'bg-sky-500/10 text-sky-700 ring-sky-600/20 dark:text-sky-400',
    viewer: 'bg-muted text-muted-foreground ring-border',
};

function roleLabel(role: UserRole): string {
    return props.roles.find((item) => item.value === role)?.label ?? role;
}

function applySearch(): void {
    router.get(
        index().url,
        { search: search.value.trim() },
        {
            preserveState: true,
            preserveScroll: true,
            replace: true,
        },
    );
}

function clearSearch(): void {
    search.value = '';

    applySearch();
}

function changeRole(user: UserRow, value: unknown): void {
    const role = String(value);

    if (saving.value !== null || role === user.role) {
        draftRoles[user.id] = user.role;

        return;
    }

    draftRoles[user.id] = role;
    saving.value = user.id;

    router.put(
        update(user.id).url,
        { role },
        {
            preserveScroll: true,

            onError: () => {
                draftRoles[user.id] = user.role;
                toast.error('Не удалось изменить роль пользователя.');
            },

            onFinish: () => {
                saving.value = null;
            },
        },
    );
}

function toggleEmployee(user: UserRow): void {
    if (saving.value !== null || user.id === currentUserId.value) {
        return;
    }

    saving.value = user.id;

    router.put(
        toggle(user.id).url,
        {},
        {
            preserveScroll: true,
            onSuccess: () => {
                user.is_employee = !user.is_employee;
            },
            onError: () => {
                toast.error('Не удалось изменить статус сотрудника.');
            },
            onFinish: () => {
                saving.value = null;
            },
        },
    );
}

function formatDate(value: string | null): string {
    if (!value) {
        return '—';
    }

    return new Date(value).toLocaleDateString('ru-RU', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
    });
}
</script>

<template>
    <Head title="Пользователи" />

    <div class="space-y-6 pb-4">
        <header class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div class="flex items-center gap-4">
                <div class="flex size-12 shrink-0 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm">
                    <Users :size="24" />
                </div>
                <div>
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl">Пользователи</h1>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Роли и права доступа к панели управления складом
                    </p>
                </div>
            </div>
        </header>

        <section class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4" aria-label="Сводка">
            <div
                v-for="stat in stats"
                :key="stat.title"
                class="flex items-center gap-4 rounded-2xl border bg-card p-5 shadow-sm"
            >
                <div
                    class="flex size-11 shrink-0 items-center justify-center rounded-xl"
                    :class="stat.tone"
                >
                    <component :is="stat.icon" :size="22" />
                </div>
                <div class="min-w-0">
                    <p class="truncate text-sm text-muted-foreground">{{ stat.title }}</p>
                    <p class="mt-0.5 text-2xl font-bold tracking-tight tabular-nums">{{ stat.value }}</p>
                </div>
            </div>
        </section>

        <section
            class="overflow-hidden rounded-2xl border bg-card shadow-sm"
            aria-labelledby="users-title"
        >
            <div
                class="flex flex-col gap-4 border-b px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6"
            >
                <div>
                    <h2 id="users-title" class="font-semibold">Список пользователей</h2>
                    <p class="mt-0.5 text-sm text-muted-foreground">
                        Показано:
                        <span class="font-medium text-foreground tabular-nums">
                            {{ props.users.data?.length ?? 0 }}
                        </span>
                        из
                        <span class="font-medium text-foreground tabular-nums">
                            {{ props.users.total }}
                        </span>
                    </p>
                </div>

                <form class="relative w-full sm:max-w-xs" @submit.prevent="applySearch">
                    <Search
                        :size="16"
                        class="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-muted-foreground"
                    />
                    <input
                        v-model="search"
                        type="search"
                        placeholder="Имя или e-mail"
                        aria-label="Поиск пользователей"
                        class="w-full rounded-xl border border-input bg-background py-2.5 pr-9 pl-9 text-sm shadow-xs outline-none transition placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/30"
                    />
                    <button
                        v-if="search"
                        type="button"
                        aria-label="Очистить поиск"
                        class="absolute top-1/2 right-3 -translate-y-1/2 text-muted-foreground transition hover:text-foreground"
                        @click="clearSearch"
                    >
                        <X :size="16" />
                    </button>
                </form>
            </div>

            <div
                v-if="!props.users.data || props.users.data.length === 0"
                class="flex flex-col items-center px-6 py-16 text-center"
            >
                <div class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted">
                    <Users :size="28" class="text-muted-foreground" />
                </div>
                <p class="font-medium">
                    {{ search ? 'Ничего не найдено' : 'Пользователей пока нет' }}
                </p>
                <p class="mt-1 max-w-sm text-sm text-muted-foreground">
                    {{
                        search
                            ? 'Попробуйте изменить поисковый запрос.'
                            : 'Зарегистрированные пользователи появятся в этом списке.'
                    }}
                </p>

                <Button v-if="search" variant="outline" class="mt-5" @click="clearSearch">
                    <X :size="15" class="mr-1.5" />
                    Очистить поиск
                </Button>
            </div>

            <template v-else>
                <ul class="divide-y md:hidden">
                    <li v-for="user in props.users.data" :key="user.id" class="space-y-3 p-4">
                        <div class="flex items-start justify-between gap-3">
                            <div class="flex min-w-0 items-center gap-3">
                                <div
                                    class="flex size-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"
                                >
                                    <UserRound :size="17" />
                                </div>
                                <div class="min-w-0">
                                    <h3 class="text-sm font-semibold break-words">
                                        {{ user.name }}
                                        <span
                                            v-if="user.id === currentUserId"
                                            class="ml-1 text-xs font-normal text-muted-foreground"
                                        >
                                            (это вы)
                                        </span>
                                    </h3>
                                    <p class="truncate text-xs text-muted-foreground">
                                        {{ user.email }}
                                    </p>
                                </div>
                            </div>

                            <span
                                class="inline-flex shrink-0 items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset"
                                :class="roleBadges[user.role]"
                            >
                                {{ roleLabel(user.role) }}
                            </span>
                        </div>

                        <div class="space-y-1.5">
                            <button
                                :disabled="user.id === currentUserId || saving !== null"
                                @click="toggleEmployee(user)"
                                :class="[
                                    'inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset transition',
                                    user.is_employee
                                        ? 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400'
                                        : 'bg-slate-100 text-slate-500 ring-slate-300 dark:bg-slate-800 dark:text-slate-400 dark:ring-slate-700',
                                    (user.id === currentUserId || saving !== null) ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer',
                                ]"
                            >
                                <span :class="user.is_employee ? 'bg-emerald-500' : 'bg-slate-400'" class="size-2 rounded-full" />
                                {{ user.is_employee ? 'Сотрудник' : 'Покупатель' }}
                            </button>
                        </div>

                        <div class="space-y-1.5">
                            <label class="text-xs font-medium text-muted-foreground" :for="`role-${user.id}`">
                                Роль
                            </label>
                            <Select
                                :model-value="draftRoles[user.id]"
                                :disabled="user.id === currentUserId || saving !== null"
                                @update:model-value="(value) => changeRole(user, value)"
                            >
                                <SelectTrigger :id="`role-${user.id}`" class="h-10 w-full rounded-xl">
                                    <SelectValue placeholder="Выберите роль" />
                                </SelectTrigger>

                                <SelectContent>
                                    <SelectItem
                                        v-for="role in props.roles"
                                        :key="role.value"
                                        :value="role.value"
                                    >
                                        {{ role.label }}
                                    </SelectItem>
                                </SelectContent>
                            </Select>
                        </div>

                        <p class="flex items-center gap-1.5 text-xs text-muted-foreground">
                            <CalendarDays :size="13" />
                            Регистрация: {{ formatDate(user.created_at) }}
                        </p>
                    </li>
                </ul>

                <div class="hidden overflow-x-auto md:block">
                    <table class="w-full min-w-[760px] text-left text-sm">
                        <thead>
                            <tr class="border-b bg-muted/40">
                                <th
                                    scope="col"
                                    class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                                >
                                    Пользователь
                                </th>
                                <th
                                    scope="col"
                                    class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                                >
                                    Роль
                                </th>
                                <th
                                    scope="col"
                                    class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                                >
                                    Статус
                                </th>
                                <th
                                    scope="col"
                                    class="px-4 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                                >
                                    Регистрация
                                </th>
                                <th
                                    scope="col"
                                    class="px-6 py-3.5 text-xs font-semibold tracking-wider text-muted-foreground uppercase"
                                >
                                    Изменение роли
                                </th>
                            </tr>
                        </thead>

                        <tbody class="divide-y">
                            <tr
                                v-for="user in props.users.data"
                                :key="user.id"
                                class="transition-colors hover:bg-muted/40"
                            >
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        <div
                                            class="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary"
                                        >
                                            <UserRound :size="19" />
                                        </div>
                                        <div class="min-w-0">
                                            <p class="font-semibold break-words">
                                                {{ user.name }}
                                                <span
                                                    v-if="user.id === currentUserId"
                                                    class="ml-1 text-xs font-normal text-muted-foreground"
                                                >
                                                    (это вы)
                                                </span>
                                            </p>
                                            <p
                                                class="flex items-center gap-1.5 text-xs text-muted-foreground"
                                            >
                                                <Mail :size="12" />
                                                {{ user.email }}
                                            </p>
                                        </div>
                                    </div>
                                </td>

                                <td class="px-6 py-4">
                                    <span
                                        class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset"
                                        :class="roleBadges[user.role]"
                                    >
                                        {{ roleLabel(user.role) }}
                                    </span>
                                </td>

                                <td class="px-6 py-4">
                                    <button
                                        :disabled="user.id === currentUserId || saving !== null"
                                        @click="toggleEmployee(user)"
                                        :class="[
                                            'inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset transition',
                                            user.is_employee
                                                ? 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400 hover:bg-emerald-500/20'
                                                : 'bg-slate-100 text-slate-500 ring-slate-300 dark:bg-slate-800 dark:text-slate-400 dark:ring-slate-700',
                                            (user.id === currentUserId || saving !== null) ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer',
                                        ]"
                                    >
                                        <span :class="user.is_employee ? 'bg-emerald-500' : 'bg-slate-400'" class="size-2 rounded-full" />
                                        {{ user.is_employee ? 'Сотрудник' : 'Покупатель' }}
                                    </button>
                                </td>

                                <td class="px-4 py-4 text-muted-foreground">
                                    {{ formatDate(user.created_at) }}
                                </td>

                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        <Select
                                            :model-value="draftRoles[user.id]"
                                            :disabled="
                                                user.id === currentUserId || saving !== null
                                            "
                                            @update:model-value="
                                                (value) => changeRole(user, value)
                                            "
                                        >
                                            <SelectTrigger
                                                class="h-9 w-56 rounded-xl"
                                                :aria-label="`Роль пользователя ${user.name}`"
                                            >
                                                <SelectValue placeholder="Выберите роль" />
                                            </SelectTrigger>

                                            <SelectContent>
                                                <SelectItem
                                                    v-for="role in props.roles"
                                                    :key="role.value"
                                                    :value="role.value"
                                                >
                                                    {{ role.label }}
                                                </SelectItem>
                                            </SelectContent>
                                        </Select>

                                        <p
                                            v-if="user.id === currentUserId"
                                            class="text-xs text-muted-foreground"
                                        >
                                            Свою роль изменить нельзя
                                        </p>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </template>
        </section>

        <section
            class="rounded-2xl border bg-card p-5 shadow-sm sm:p-6"
            aria-labelledby="roles-title"
        >
            <h2 id="roles-title" class="font-semibold">Роли и права</h2>
            <p class="mt-0.5 text-sm text-muted-foreground">
                Что может делать пользователь с каждой ролью
            </p>

            <dl class="mt-4 grid gap-3 sm:grid-cols-2">
                <div
                    v-for="role in props.roles"
                    :key="role.value"
                    class="rounded-xl border bg-muted/30 p-4"
                >
                    <dt class="flex items-center gap-2">
                        <span
                            class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset"
                            :class="roleBadges[role.value]"
                        >
                            {{ role.label }}
                        </span>
                    </dt>
                    <dd class="mt-2 text-sm text-muted-foreground">
                        {{ role.description }}
                    </dd>
                </div>
            </dl>
        </section>

        <nav
            v-if="props.users.last_page > 1"
            class="flex flex-col gap-4 border-t border-border px-5 py-4 sm:flex-row sm:items-center sm:justify-between"
            aria-label="Пагинация пользователей"
        >
            <p class="text-sm text-muted-foreground">
                Показано
                <span class="font-medium text-foreground tabular-nums">
                    {{ props.users.from }}–{{ props.users.to }}
                </span>
                из
                <span class="font-medium text-foreground tabular-nums">
                    {{ props.users.total }}
                </span>
            </p>

            <div class="flex items-center gap-1">
                <Button
                    v-if="props.users.links[0]?.url"
                    as-child
                    variant="outline"
                    size="icon"
                    class="size-9"
                >
                    <Link :href="props.users.links[0].url" preserve-scroll>
                        <span class="sr-only">Предыдущая страница</span>
                        <span aria-hidden="true">←</span>
                    </Link>
                </Button>

                <template v-for="(link, index) in props.users.links.slice(1, -1)" :key="index">
                    <Button
                        v-if="link.url"
                        as-child
                        :variant="link.active ? 'default' : 'outline'"
                        size="icon"
                        class="size-9"
                    >
                        <Link :href="link.url" preserve-scroll>{{ link.label }}</Link>
                    </Button>
                    <span v-else class="inline-flex size-9 items-center justify-center text-sm">
                        {{ link.label }}
                    </span>
                </template>

                <Button
                    v-if="props.users.links[props.users.links.length - 1]?.url"
                    as-child
                    variant="outline"
                    size="icon"
                    class="size-9"
                >
                    <Link
                        :href="props.users.links[props.users.links.length - 1].url!"
                        preserve-scroll
                    >
                        <span class="sr-only">Следующая страница</span>
                        <span aria-hidden="true">→</span>
                    </Link>
                </Button>
            </div>
        </nav>
    </div>
</template>
