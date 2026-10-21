<script setup lang="ts">
import { Head, Link, useForm } from '@inertiajs/vue3';
import { ref, watch } from 'vue';
import { toast } from 'vue-sonner';
import { Archive, Info, LoaderCircle, Save } from '@lucide/vue';
import AdminLayout from '@/layouts/AdminLayout.vue';
import StockPageHeader from '@/components/admin/stock/StockPageHeader.vue';
import StockField from '@/components/admin/stock/StockField.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { index, store } from '@/routes/admin/product-types';

defineOptions({
    layout: AdminLayout,
});

interface Category {
    id: number;
    name: string;
}

interface Props {
    categories: Category[];
}

defineProps<Props>();

const form = useForm({
    category_id: '',
    name: '',
    slug: '',
    is_active: true,
});

const TRANSLIT: Record<string, string> = {
    а: 'a', б: 'b', в: 'v', г: 'g', д: 'd', е: 'e', ё: 'e', ж: 'zh',
    з: 'z', и: 'i', й: 'y', к: 'k', л: 'l', м: 'm', н: 'n', о: 'o',
    п: 'p', р: 'r', с: 's', т: 't', у: 'u', ф: 'f', х: 'kh', ц: 'ts',
    ч: 'ch', ш: 'sh', щ: 'shch', ъ: '', ы: 'y', ь: '', э: 'e', ю: 'yu',
    я: 'ya',
};

const slugify = (text: string): string =>
    text
        .toLowerCase()
        .split('')
        .map((char) => TRANSLIT[char] ?? char)
        .join('')
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');

const slugTouched = ref(false);

watch(() => form.name, (name) => {
    if (!slugTouched.value) {
        form.slug = slugify(name);
    }
});

const onSlugInput = (): void => {
    slugTouched.value = form.slug !== '';
};

const submit = (): void => {
    form.post(store.url(), {
        onSuccess: () => {
            toast.success('Тип товара успешно создан.');
        },
        onError: () => {
            toast.error('Проверьте правильность заполнения формы.');
        },
    });
};
</script>

<template>
    <Head title="Добавление типа товара" />

    <div class="mx-auto max-w-5xl space-y-6 pb-4">
        <StockPageHeader
            title="Новый тип товара"
            description="Создайте тип товара и укажите категорию"
            :back-href="index.url()"
            back-label="К типам товаров"
            :icon="Archive"
        />

        <div class="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_280px]">
            <form class="overflow-hidden rounded-2xl border bg-card shadow-sm" novalidate @submit.prevent="submit">
                <div class="border-b px-6 py-5">
                    <h2 class="font-semibold">Основная информация</h2>
                    <p class="mt-1 text-sm text-muted-foreground">
                        Укажите категорию, название и системный идентификатор
                    </p>
                </div>

                <div class="space-y-6 p-6">
                    <StockField label="Категория" for-id="category_id" required :error="form.errors.category_id" hint="Выберите категорию, внутри которой будет находиться тип товара.">
                        <Select v-model="form.category_id">
                            <SelectTrigger id="category_id" class="h-11 rounded-xl">
                                <SelectValue placeholder="Выберите категорию" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem v-for="category in categories" :key="category.id" :value="category.id.toString()">
                                    {{ category.name }}
                                </SelectItem>
                            </SelectContent>
                        </Select>
                    </StockField>

                    <StockField label="Название типа" for-id="name" required :error="form.errors.name" hint="Понятное название, которое будет отображаться в каталоге.">
                        <Input id="name" v-model="form.name" type="text" autofocus autocomplete="off" placeholder="Например, Фитинги" class="h-11 rounded-xl" :aria-invalid="!!form.errors.name" />
                    </StockField>

                    <StockField label="Slug" for-id="slug" required :error="form.errors.slug" hint="Уникальный идентификатор латиницей. Подставляется из названия, пока вы не измените его вручную.">
                        <Input id="slug" v-model="form.slug" type="text" autocomplete="off" placeholder="fittings" class="h-11 rounded-xl font-mono" :aria-invalid="!!form.errors.slug" @input="onSlugInput" />
                    </StockField>

                    <label class="flex cursor-pointer items-start gap-3 rounded-xl border bg-muted/40 p-4">
                        <input v-model="form.is_active" type="checkbox" class="mt-0.5 size-4 rounded border-input accent-primary" />
                        <span>
                            <span class="block text-sm font-semibold">Тип товара активен</span>
                            <span class="mt-1 block text-sm leading-5 text-muted-foreground">Активный тип будет доступен при работе с товарами.</span>
                        </span>
                    </label>
                </div>

                <div class="flex flex-col-reverse gap-3 border-t bg-muted/30 px-6 py-4 sm:flex-row sm:justify-end">
                    <Button as-child variant="outline" :disabled="form.processing">
                        <Link :href="index.url()">Отмена</Link>
                    </Button>

                    <Button type="submit" :disabled="form.processing">
                        <LoaderCircle v-if="form.processing" :size="17" class="mr-2 animate-spin" />
                        <Save v-else :size="17" class="mr-2" />
                        {{ form.processing ? 'Сохранение...' : 'Создать тип' }}
                    </Button>
                </div>
            </form>

            <aside class="space-y-4 lg:sticky lg:top-6">
                <div>
                    <p class="mb-2 text-xs font-semibold tracking-wider text-muted-foreground uppercase">Предпросмотр</p>
                    <div class="rounded-2xl border bg-card p-5 shadow-sm">
                        <div class="flex items-start justify-between gap-3">
                            <div class="min-w-0">
                                <h3 class="truncate font-bold" :class="form.name ? '' : 'text-muted-foreground/60'">{{ form.name || 'Название типа' }}</h3>
                                <p class="mt-0.5 truncate font-mono text-xs" :class="form.slug ? 'text-muted-foreground' : 'text-muted-foreground/60'">{{ form.slug || 'slug' }}</p>
                            </div>
                            <span class="inline-flex shrink-0 items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold ring-1 ring-inset" :class="form.is_active ? 'bg-emerald-500/10 text-emerald-700 ring-emerald-600/20 dark:text-emerald-400' : 'bg-muted text-muted-foreground ring-border'">
                                <span class="size-1.5 rounded-full" :class="form.is_active ? 'bg-emerald-500' : 'bg-muted-foreground/50'" />
                                {{ form.is_active ? 'Активен' : 'Неактивен' }}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="flex items-start gap-3 rounded-2xl border bg-muted/40 p-4">
                    <Info :size="18" class="mt-0.5 shrink-0 text-primary" />
                    <div>
                        <p class="text-sm font-semibold">Что дальше?</p>
                        <p class="mt-1 text-sm leading-relaxed text-muted-foreground">После создания вы сможете использовать этот тип при добавлении товаров.</p>
                    </div>
                </div>
            </aside>
        </div>
    </div>
</template>
