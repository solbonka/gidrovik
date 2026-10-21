<script setup lang="ts">
import { Link, router } from '@inertiajs/vue3';
import { ChevronRight, LogOut, Palette, Settings, Shield, User } from '@lucide/vue';
import {
    DropdownMenuGroup,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator,
    DropdownMenuSub,
    DropdownMenuSubContent,
    DropdownMenuSubTrigger,
} from '@/components/ui/dropdown-menu';
import UserInfo from '@/components/UserInfo.vue';
import { logout } from '@/routes';
import { edit as editProfile } from '@/routes/profile';
import { edit as editSecurity } from '@/routes/security';
import { edit as editAppearance } from '@/routes/appearance';
import type { User as UserType } from '@/types';

type Props = {
    user: UserType;
};

const handleLogout = () => {
    router.flushAll();
};

defineProps<Props>();
</script>

<template>
    <DropdownMenuLabel class="p-0 font-normal">
        <div class="flex items-center gap-2 px-1 py-1.5 text-left text-sm">
            <UserInfo :user="user" :show-email="true" />
        </div>
    </DropdownMenuLabel>
    <DropdownMenuSeparator />
    <DropdownMenuGroup>
        <DropdownMenuSub>
            <DropdownMenuSubTrigger as-child>
                <DropdownMenuItem class="flex items-center gap-2 cursor-pointer">
                    <Settings class="mr-2 h-4 w-4" />
                    Settings
                    <ChevronRight class="ml-auto size-4" />
                </DropdownMenuItem>
            </DropdownMenuSubTrigger>
            <DropdownMenuSubContent class="w-56 pl-2">
                <DropdownMenuItem :as-child="true">
                    <Link class="block w-full cursor-pointer px-3 py-2" :href="editProfile()" prefetch>
                        <User class="mr-2 h-4 w-4" />
                        Profile
                    </Link>
                </DropdownMenuItem>
                <DropdownMenuItem :as-child="true">
                    <Link class="block w-full cursor-pointer px-3 py-2" :href="editSecurity()" prefetch>
                        <Shield class="mr-2 h-4 w-4" />
                        Security
                    </Link>
                </DropdownMenuItem>
                <DropdownMenuItem :as-child="true">
                    <Link class="block w-full cursor-pointer px-3 py-2" :href="editAppearance()" prefetch>
                        <Palette class="mr-2 h-4 w-4" />
                        Appearance
                    </Link>
                </DropdownMenuItem>
            </DropdownMenuSubContent>
        </DropdownMenuSub>
    </DropdownMenuGroup>
    <DropdownMenuSeparator />
    <DropdownMenuItem :as-child="true">
        <Link
            class="block w-full cursor-pointer"
            :href="logout()"
            @click="handleLogout"
            as="button"
            data-test="logout-button"
        >
            <LogOut class="mr-2 h-4 w-4" />
            Log out
        </Link>
    </DropdownMenuItem>
</template>
