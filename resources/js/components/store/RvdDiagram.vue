<template>
    <div class="relative overflow-hidden rounded-3xl border border-white/10 bg-[#1b1f23] p-3 shadow-2xl shadow-black/40 sm:p-4">
        <div
            class="pointer-events-none absolute inset-0 opacity-[0.12] [background-image:linear-gradient(rgba(255,255,255,.35)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,.35)_1px,transparent_1px)] [background-size:26px_26px]"
        />
        <div class="relative flex items-center justify-between px-2 pb-1 text-[10px] font-bold uppercase tracking-[.22em] text-zinc-500">
            <span>Сборка РВД</span>
            <span class="flex items-center gap-1.5 text-orange-300">
        <span class="size-1.5 rounded-full bg-orange-400" />
        Рабочая среда
      </span>
        </div>

        <svg viewBox="0 0 520 380" class="relative block h-auto w-full" role="img" aria-label="Схема: рукав высокого давления с фитингами DKOL, верхняя половина в разрезе">
            <defs>
                <linearGradient id="hv-steel" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#fafafa" />
                    <stop offset=".14" stop-color="#e4e4e7" />
                    <stop offset=".4" stop-color="#a1a1aa" />
                    <stop offset=".72" stop-color="#6b6b73" />
                    <stop offset="1" stop-color="#52525b" />
                </linearGradient>
                <linearGradient id="hv-zinc" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#fef3c7" />
                    <stop offset=".2" stop-color="#fcd34d" />
                    <stop offset=".6" stop-color="#d19a1f" />
                    <stop offset="1" stop-color="#8a5a0b" />
                </linearGradient>
                <linearGradient id="hv-rubber" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#5a5a63" />
                    <stop offset=".16" stop-color="#3a3a42" />
                    <stop offset=".5" stop-color="#151518" />
                    <stop offset=".86" stop-color="#08080a" />
                    <stop offset="1" stop-color="#2a2a30" />
                </linearGradient>
                <linearGradient id="hv-wire" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#f4f4f5" />
                    <stop offset=".2" stop-color="#b4b4bb" />
                    <stop offset=".55" stop-color="#6b6b73" />
                    <stop offset=".9" stop-color="#34343a" />
                    <stop offset="1" stop-color="#55555c" />
                </linearGradient>
                <linearGradient id="hv-tube" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#4a4a52" />
                    <stop offset=".45" stop-color="#0c0c0e" />
                    <stop offset="1" stop-color="#1c1c20" />
                </linearGradient>
                <linearGradient id="hv-bore" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#52525b" />
                    <stop offset=".45" stop-color="#101012" />
                    <stop offset="1" stop-color="#050506" />
                </linearGradient>
                <linearGradient id="hv-capL" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0" stop-color="#000" stop-opacity=".55" />
                    <stop offset="1" stop-color="#000" stop-opacity="0" />
                </linearGradient>
                <linearGradient id="hv-capR" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0" stop-color="#000" stop-opacity="0" />
                    <stop offset="1" stop-color="#000" stop-opacity=".55" />
                </linearGradient>
                <pattern id="dk-hatch" width="4.5" height="4.5" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
                    <line x1="0" y1="0" x2="0" y2="4.5" stroke="#000" stroke-opacity=".3" stroke-width="1" />
                </pattern>
                <pattern id="hv-weave" width="7" height="7" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
                    <path d="M0 3.5H7" stroke="#000" stroke-opacity=".4" stroke-width="1.5" />
                    <path d="M3.5 0V7" stroke="#fff" stroke-opacity=".3" stroke-width="1.2" />
                </pattern>
                <pattern id="hv-grain" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(-45)">
                    <path d="M0 3H6" stroke="#fff" stroke-opacity=".06" stroke-width="1" />
                </pattern>
                <filter id="hv-blur" x="-20%" y="-200%" width="140%" height="500%">
                    <feGaussianBlur stdDeviation="6" />
                </filter>
                <filter id="hv-glow" x="-10%" y="-300%" width="120%" height="700%">
                    <feGaussianBlur stdDeviation="3" />
                </filter>

                <clipPath id="hv-flowclip">
                    <rect x="46" y="179" width="156" height="11" />
                    <rect x="247" y="172" width="26" height="36" />
                    <rect x="318" y="179" width="156" height="11" />
                </clipPath>

                <!-- ===== ИСПРАВЛЕННЫЙ КОНУС 24° ===== -->
                <g id="dk-cut">
                    <!-- Стержень + насечки -->
                    <rect x="113" y="162.5" width="89" height="3" fill="#1b1b1f" />
                    <rect x="113" y="162.5" width="89" height="3" fill="url(#hv-grain)" />
                    <rect x="113" y="165.5" width="89" height="4.5" fill="url(#hv-wire)" />
                    <rect x="113" y="165.5" width="89" height="4.5" fill="url(#hv-weave)" />
                    <rect x="113" y="170" width="89" height="3.5" fill="#0c0c0e" />

                    <!-- Основной контур ниппеля с правильным конусом 24° -->
                    <path d="M30 175
                   L30 172.5
                   L38 168.2
                   L42 166.8
                   L46.5 166.2
                   L49.5 166.8
                   L53 168.5
                   L57.5 165
                   L69 165
                   L69 168
                   L99 168
                   L99 173
                   L106 173
                   L106 168
                   L112.5 168
                   L112.5 173.5
                   L118 173.5
                   L123.4 171.5 L124 173.5
                   L125.2 173.5 L130.6 171.5 L131.2 173.5
                   L132.4 173.5 L137.8 171.5 L138.4 173.5
                   L139.6 173.5 L145 171.5 L145.6 173.5
                   L146.8 173.5 L152.2 171.5 L152.8 173.5
                   L154 173.5 L159.4 171.5 L160 173.5
                   L161.2 173.5 L166.6 171.5 L167.2 173.5
                   L168.4 173.5 L173.8 171.5 L174.4 173.5
                   L175.6 173.5 L181 171.5 L181.6 173.5
                   L182.8 173.5 L188.2 171.5 L188.8 173.5
                   L190 173.5 L195.4 171.5 L196 173.5
                   L201 173.5 L201 179
                   L62.5 179 Z"
                          fill="url(#hv-steel)" />

                    <path d="M30 175
                   L30 172.5
                   L38 168.2
                   L42 166.8
                   L46.5 166.2
                   L49.5 166.8
                   L53 168.5
                   L57.5 165
                   L69 165
                   L69 168
                   L99 168
                   L99 173
                   L106 173
                   L106 168
                   L112.5 168
                   L112.5 173.5
                   L118 173.5
                   L123.4 171.5 L124 173.5
                   L125.2 173.5 L130.6 171.5 L131.2 173.5
                   L132.4 173.5 L137.8 171.5 L138.4 173.5
                   L139.6 173.5 L145 171.5 L145.6 173.5
                   L146.8 173.5 L152.2 171.5 L152.8 173.5
                   L154 173.5 L159.4 171.5 L160 173.5
                   L161.2 173.5 L166.6 171.5 L167.2 173.5
                   L168.4 173.5 L173.8 171.5 L174.4 173.5
                   L175.6 173.5 L181 171.5 L181.6 173.5
                   L182.8 173.5 L188.2 171.5 L188.8 173.5
                   L190 173.5 L195.4 171.5 L196 173.5
                   L201 173.5 L201 179
                   L62.5 179 Z"
                          fill="url(#dk-hatch)" stroke="#1c1c1f" stroke-width=".8" stroke-linejoin="round" />

                    <!-- Гайка -->
                    <path d="M30 154 L33 151 L77.6 151 L80.6 154 L80.6 165.5 L70.5 165.5 L70.5 159.5 L56 159.5 L56 160.5 L53.83 163 L51.67 160.5 L49.5 163 L47.33 160.5 L45.17 163 L43 160.5 L40.83 163 L38.67 160.5 L36.5 163 L34.33 160.5 L32.17 163 L30 160.5 Z"
                          fill="url(#hv-zinc)" />
                    <path d="M30 154 L33 151 L77.6 151 L80.6 154 L80.6 165.5 L70.5 165.5 L70.5 159.5 L56 159.5 L56 160.5 L53.83 163 L51.67 160.5 L49.5 163 L47.33 160.5 L45.17 163 L43 160.5 L40.83 163 L38.67 160.5 L36.5 163 L34.33 160.5 L32.17 163 L30 160.5 Z"
                          fill="url(#dk-hatch)" stroke="#3b2a05" stroke-width=".8" stroke-linejoin="round" />
                    <path d="M36 152.5H74.6" stroke="#fff" stroke-opacity=".55" stroke-linecap="round" />

                    <!-- O-Ring в канавке на конусе 24° -->
                    <circle cx="45.8" cy="168.9" r="2.7" fill="#0a0a0b" stroke="#6b6b73" stroke-width=".7" />
                    <circle cx="45.0" cy="168.1" r=".75" fill="#fff" fill-opacity=".5" />

                    <!-- Гильза (верх) -->
                    <path d="M112.5 160 L115.5 157 L127 157 L128.5 159 L131.5 159 L133 157 L145 157 L146.5 159 L149.5 159 L151 157 L163 157 L164.5 159 L167.5 159 L169 157 L181 157 L182.5 159 L185.5 159 L187 157 L199 157 L202 160 L202 162.5 L112.5 162.5 Z"
                          fill="url(#hv-steel)" />
                    <path d="M112.5 160 L115.5 157 L127 157 L128.5 159 L131.5 159 L133 157 L145 157 L146.5 159 L149.5 159 L151 157 L163 157 L164.5 159 L167.5 159 L169 157 L181 157 L182.5 159 L185.5 159 L187 157 L199 157 L202 160 L202 162.5 L112.5 162.5 Z"
                          fill="url(#dk-hatch)" stroke="#1c1c1f" stroke-width=".8" stroke-linejoin="round" />
                </g>

                <!-- Нижняя половина (внешний вид) -->
                <g id="dk-ext">
                    <path d="M80.6 190 L80.6 212 L99 212 L99 207 L106 207 L106 212 L112.5 212 L112.5 190 Z" fill="url(#hv-steel)" stroke="#27272a" stroke-width=".8" stroke-linejoin="round" />
                    <path d="M99 192V207M106 192V207" stroke="#000" stroke-opacity=".35" />
                    <rect x="80.6" y="190" width="8" height="22" fill="url(#hv-capL)" opacity=".7" />
                    <path d="M112.5 220 L115.5 223 L127 223 L128.5 221 L131.5 221 L133 223 L145 223 L146.5 221 L149.5 221 L151 223 L163 223 L164.5 221 L167.5 221 L169 223 L181 223 L182.5 221 L185.5 221 L187 223 L199 223 L202 220 L202 190 L112.5 190 Z" fill="url(#hv-steel)" stroke="#27272a" stroke-width=".8" stroke-linejoin="round" />
                    <path d="M130 192V221M148 192V221M166 192V221M184 192V221" stroke="#000" stroke-opacity=".35" />
                    <rect x="193" y="190" width="9" height="30" fill="url(#hv-capR)" opacity=".7" />
                    <path d="M30 226 L33 229 L77.6 229 L80.6 226 L80.6 190 L30 190 Z" fill="url(#hv-zinc)" stroke="#3b2a05" stroke-width=".8" stroke-linejoin="round" />
                    <path d="M30 209.5H80.6" stroke="#000" stroke-opacity=".45" />
                    <path d="M30 210.5H80.6" stroke="#fff" stroke-opacity=".35" />
                    <path d="M33 192V227M77.6 192V227" stroke="#000" stroke-opacity=".35" />
                    <rect x="70.6" y="190" width="10" height="36" fill="url(#hv-capR)" opacity=".6" />
                </g>
            </defs>

            <!-- Тень -->
            <ellipse cx="260" cy="262" rx="215" ry="9" fill="#000" opacity=".55" filter="url(#hv-blur)" />

            <!-- Каналы -->
            <rect x="30" y="160.5" width="34" height="29.5" fill="url(#hv-bore)" />
            <rect x="64" y="179" width="138" height="11" fill="url(#hv-bore)" />
            <rect x="456" y="160.5" width="34" height="29.5" fill="url(#hv-bore)" />
            <rect x="318" y="179" width="138" height="11" fill="url(#hv-bore)" />

            <!-- Рукав -->
            <g>
                <rect x="202" y="160" width="26" height="60" fill="url(#hv-rubber)" />
                <rect x="202" y="160" width="26" height="60" fill="url(#hv-grain)" />
                <rect x="292" y="160" width="26" height="60" fill="url(#hv-rubber)" />
                <rect x="292" y="160" width="26" height="60" fill="url(#hv-grain)" />
                <rect x="228" y="164" width="19" height="52" fill="url(#hv-wire)" />
                <rect x="228" y="164" width="19" height="52" fill="url(#hv-weave)" />
                <rect x="273" y="164" width="19" height="52" fill="url(#hv-wire)" />
                <rect x="273" y="164" width="19" height="52" fill="url(#hv-weave)" />
                <rect x="247" y="170" width="26" height="40" fill="url(#hv-tube)" />
                <rect x="228" y="164" width="8" height="52" fill="url(#hv-capL)" />
                <rect x="284" y="164" width="8" height="52" fill="url(#hv-capR)" />
                <rect x="247" y="170" width="7" height="40" fill="url(#hv-capL)" />
                <rect x="266" y="170" width="7" height="40" fill="url(#hv-capR)" />
                <path d="M228 160v60M292 160v60M247 164v52M273 164v52" stroke="#000" stroke-opacity=".6" />
            </g>

            <!-- Поток -->
            <g clip-path="url(#hv-flowclip)">
                <line x1="46" y1="185" x2="474" y2="185" stroke="#f97316" stroke-width="8" stroke-opacity=".45" filter="url(#hv-glow)" />
                <line class="hv-flow" x1="46" y1="185" x2="474" y2="185" stroke="#fb923c" stroke-width="3" stroke-linecap="round" stroke-dasharray="1 9" />
            </g>

            <!-- Фитинги -->
            <use href="#dk-cut" />
            <use href="#dk-ext" />
            <use href="#dk-cut" transform="translate(520 0) scale(-1 1)" />
            <use href="#dk-ext" transform="translate(520 0) scale(-1 1)" />

            <!-- Осевая -->
            <line x1="14" y1="190" x2="506" y2="190" stroke="#fff" stroke-opacity=".3" stroke-dasharray="14 5 3 5" />

            <!-- Выноски -->
            <g fill="none" stroke="#fb923c" stroke-opacity=".75" stroke-width="1.2">
                <path d="M45.8 166V48" />
                <path d="M468.2 176.3V82" />
                <path d="M150 157V112" />
                <path d="M214 160V138" />
                <path d="M260 164V148" />
                <path d="M55 229V276" />
                <path d="M260 210V302" />
            </g>
            <g fill="#fb923c">
                <circle cx="45.8" cy="166" r="2" />
                <circle cx="468.2" cy="176.3" r="3" />
                <circle cx="150" cy="157" r="3" />
                <circle cx="214" cy="160" r="3" />
                <circle cx="260" cy="164" r="3" />
                <circle cx="55" cy="229" r="3" />
                <circle cx="260" cy="210" r="3" />
            </g>

            <!-- Подписи -->
            <g fill="#e4e4e7" font-size="14.5" font-weight="600">
                <text x="24" y="40">Уплотнительное кольцо</text>
                <text x="24" y="56" font-size="11" fill="#a1a1aa">(O-Ring на конусе 24°)</text>
                <text x="496" y="74" text-anchor="end">Конус 24°</text>
                <text x="118" y="104">Гильза</text>
                <text x="118" y="119" font-size="11" fill="#a1a1aa">(обжимная муфта)</text>
                <text x="200" y="132">Наружный слой</text>
                <text x="268" y="148">Оплётка</text>
                <text x="24" y="294">Гайка DKOL</text>
                <text x="24" y="309" font-size="11" fill="#a1a1aa">(накидная)</text>
                <text x="260" y="320" text-anchor="middle">Внутренняя трубка</text>
            </g>

            <g stroke="#71717a" stroke-width="1.2" fill="none">
                <path d="M30 346H490" />
                <path d="M30 340v12M490 340v12" />
            </g>
            <text x="260" y="372" text-anchor="middle" font-size="12" letter-spacing="3" fill="#71717a">
                РУКАВ В СБОРЕ · DKOL (DIN 2353 / ISO 8434-1)
            </text>
        </svg>
    </div>
</template>

<style scoped>
.hv-flow {
    animation: hv-flow 0.9s linear infinite;
}
@keyframes hv-flow {
    to { stroke-dashoffset: -10; }
}
@media (prefers-reduced-motion: reduce) {
    .hv-flow { animation: none; }
}
</style>
