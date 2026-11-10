<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}"  @class(['dark' => ($appearance ?? 'system') == 'dark'])>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        {{-- Inline script to detect system dark mode preference and apply it immediately --}}
        <script>
            (function() {
                const appearance = '{{ $appearance ?? "system" }}';

                if (appearance === 'system') {
                    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

                    if (prefersDark) {
                        document.documentElement.classList.add('dark');
                    }
                }
            })();
        </script>

        {{-- Inline style to set the HTML background color based on our theme in app.css --}}
        <style>
            html {
                background-color: oklch(1 0 0);
            }

            html.dark {
                background-color: oklch(0.145 0 0);
            }
        </style>

        <link rel="icon" href="/favicon.ico" sizes="any">
        <link rel="icon" href="/favicon.svg" type="image/svg+xml">
        <link rel="apple-touch-icon" href="/apple-touch-icon.png">

        @fonts

        @vite(['resources/css/app.css', 'resources/js/app.ts', "resources/js/pages/{$page['component']}.vue"])

        {{-- Extract OG meta from Inertia page props --}}
        @php
            $inertiaMeta = array_intersect_key(
                $page['props'] ?? [],
                array_flip(['title', 'description', 'image', 'type', 'url', 'canonical', 'robots']),
            );
        @endphp

        <x-inertia::head>
            <title>{{ $inertiaMeta['title'] ?? config('app.name', 'Laravel') }}</title>

            @if(isset($inertiaMeta['robots']))
                <meta name="robots" content="{{ $inertiaMeta['robots'] }}" />
            @endif

            {{-- Canonical URL --}}
            @if(isset($inertiaMeta['canonical']))
                <link rel="canonical" href="{{ $inertiaMeta['canonical'] }}" />
            @endif

            {{-- OG / Social tags --}}
            @if(isset($inertiaMeta['title']))
                <meta property="og:title" content="{{ $inertiaMeta['title'] }}" />
            @endif
            @if(isset($inertiaMeta['description']))
                <meta name="description" content="{{ $inertiaMeta['description'] }}" />
                <meta property="og:description" content="{{ $inertiaMeta['description'] }}" />
            @endif
            @if(isset($inertiaMeta['image']))
                <meta property="og:image" content="{{ $inertiaMeta['image'] }}" />
            @endif
            @if(isset($inertiaMeta['type']))
                <meta property="og:type" content="{{ $inertiaMeta['type'] }}" />
            @endif
            @if(isset($inertiaMeta['url']))
                <meta property="og:url" content="{{ $inertiaMeta['url'] }}" />
            @endif
        </x-inertia::head>

        {{-- Schema.org JSON-LD --}}
        @php
            $siteUrl = url('/');
            $schemaGraph = [
                [
                    '@type' => 'Organization',
                    '@id' => $siteUrl . '#organization',
                    'name' => config('app.name'),
                    'url' => $siteUrl,
                    'logo' => $siteUrl . '/og-home.png',
                ],
                [
                    '@type' => 'WebSite',
                    '@id' => $siteUrl . '#website',
                    'url' => $siteUrl,
                    'name' => config('app.name'),
                    'publisher' => ['@id' => $siteUrl . '#organization'],
                    'potentialAction' => [
                        '@type' => 'SearchAction',
                        'target' => [
                            '@type' => 'EntryPoint',
                            'urlTemplate' => url('/search') . '?q={search_term_string}',
                        ],
                        'query-input' => 'required name=search_term_string',
                    ],
                ],
            ];

            if (($page['component'] ?? '') === 'store/products/Show' && isset($page['props']['product'])) {
                $p = $page['props']['product'];
                $productUrl = $inertiaMeta['canonical'] ?? $siteUrl . '/products/' . ($p['slug'] ?? '');
                $availability = ($p['stock_status'] ?? '') === 'in_stock'
                    ? 'https://schema.org/InStock'
                    : 'https://schema.org/LimitedAvailability';

                $productSchema = [
                    '@type' => 'Product',
                    '@id' => $productUrl . '#product',
                    'name' => $p['name'] ?? '',
                    'url' => $productUrl,
                    'description' => $inertiaMeta['description'] ?? null,
                    'sku' => $p['code'] ?? null,
                    'mpn' => $p['article'] ?? null,
                    'image' => isset($p['images'][0]['large'])
                        ? [$p['images'][0]['large']]
                        : [$siteUrl . '/og-product.png'],
                    'brand' => [
                        '@type' => 'Brand',
                        'name' => $p['manufacturer'] ?? config('app.name'),
                    ],
                    'offers' => [
                        '@type' => 'Offer',
                        'url' => $productUrl,
                        'priceCurrency' => 'RUB',
                        'price' => $p['price'] ?? '0',
                        'availability' => $availability,
                        'itemCondition' => 'https://schema.org/NewCondition',
                        'seller' => ['@id' => $siteUrl . '#organization'],
                    ],
                ];

                $schemaGraph[] = array_filter($productSchema, fn ($v) => $v !== null);
                $schemaGraph[] = [
                    '@type' => 'BreadcrumbList',
                    'itemListElement' => [
                        ['@type' => 'ListItem', 'position' => 1, 'name' => 'Главная', 'item' => $siteUrl],
                        ['@type' => 'ListItem', 'position' => 2, 'name' => 'Каталог', 'item' => url('/catalog')],
                        ['@type' => 'ListItem', 'position' => 3, 'name' => $p['name'] ?? '', 'item' => $productUrl],
                    ],
                ];
            }

            $schemaJson = json_encode(
                ['@context' => 'https://schema.org', '@graph' => $schemaGraph],
                JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT,
            );
        @endphp
        <script type="application/ld+json">{!! $schemaJson !!}</script>

        @if(config('services.yandex_metrika.id'))
            <!-- Yandex.Metrika counter -->
            <script>
                window.__YANDEX_METRIKA_ID__ = {{ (int) config('services.yandex_metrika.id') }};
            </script>
            <script>
                (function(m,e,t,r,i,k,a){m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)};
                m[i].l=1*new Date();
                for (var j = 0; j < document.scripts.length; j++) {if (document.scripts[j].src === r) { return; }}
                k=e.createElement(t),a=e.getElementsByTagName(t)[0],k.async=1,k.src=r,a.parentNode.insertBefore(k,a)})
                (window, document, "script", "https://mc.yandex.ru/metrika/tag.js", "ym");

                ym({{ (int) config('services.yandex_metrika.id') }}, "init", {
                    defer: true,
                    ecommerce: "dataLayer",
                    clickmap: true,
                    trackLinks: true,
                    accurateTrackBounce: true,
                    webvisor: true
                });
            </script>
            <noscript>
                <div><img src="https://mc.yandex.ru/watch/{{ (int) config('services.yandex_metrika.id') }}"
                          style="position:absolute; left:-9999px;" alt="" /></div>
            </noscript>
        @endif
    </head>
    <body class="font-sans antialiased">
        <x-inertia::app :inertia-page="$page" />
    </body>
</html>
