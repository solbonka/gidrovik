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

        {{-- Extract OG meta from Inertia shared data --}}
        @php
            $inertiaMeta = $page['shared']['meta'] ?? [];
        @endphp

        <x-inertia::head>
            <title>{{ config('app.name', 'Laravel') }}</title>

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
    </head>
    <body class="font-sans antialiased">
        <x-inertia::app :inertia-page="$page" />
    </body>
</html>
