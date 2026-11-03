<template>
    <div class="relative w-full overflow-hidden rounded-2xl border border-white/10 bg-[#1b1f23] p-2 shadow-2xl shadow-black/40 sm:rounded-3xl sm:p-4">
        <!-- Фоновая сетка -->
        <div
            class="pointer-events-none absolute inset-0 opacity-[0.12]
             [background-image:linear-gradient(rgba(255,255,255,.35)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,.35)_1px,transparent_1px)]
             [background-size:26px_26px]"
        />

        <!-- Шапка -->
        <div class="relative flex items-center justify-between px-1.5 pb-0.5 text-[9px] font-bold uppercase tracking-[.18em] text-zinc-500 sm:px-2 sm:pb-1 sm:text-[10px] sm:tracking-[.22em]">
            <span>Сборка РВД</span>
            <span class="flex items-center gap-1 text-orange-300 sm:gap-1.5">
        <span class="size-1.5 rounded-full bg-orange-400" />
        Рабочая среда
      </span>
        </div>

        <svg
            viewBox="0 0 520 360"
            class="relative block h-auto w-full max-w-full"
            preserveAspectRatio="xMidYMid meet"
            role="img"
            aria-label="Схема рукава высокого давления с фитингами"
        >
            <defs>
                <!-- Градиенты -->
                <linearGradient id="hv-steel" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#f8fafc" />
                    <stop offset="0.12" stop-color="#e2e8f0" />
                    <stop offset="0.35" stop-color="#94a3b8" />
                    <stop offset="0.65" stop-color="#64748b" />
                    <stop offset="0.88" stop-color="#475569" />
                    <stop offset="1" stop-color="#334155" />
                </linearGradient>
                <linearGradient id="hv-zinc" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#fef9c3" />
                    <stop offset="0.18" stop-color="#fde047" />
                    <stop offset="0.45" stop-color="#eab308" />
                    <stop offset="0.75" stop-color="#a16207" />
                    <stop offset="1" stop-color="#713f12" />
                </linearGradient>
                <linearGradient id="hv-rubber" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#52525b" />
                    <stop offset="0.2" stop-color="#3f3f46" />
                    <stop offset="0.5" stop-color="#18181b" />
                    <stop offset="0.85" stop-color="#09090b" />
                    <stop offset="1" stop-color="#27272a" />
                </linearGradient>
                <linearGradient id="hv-wire" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#f1f5f9" />
                    <stop offset="0.25" stop-color="#cbd5e1" />
                    <stop offset="0.55" stop-color="#64748b" />
                    <stop offset="0.85" stop-color="#334155" />
                    <stop offset="1" stop-color="#1e293b" />
                </linearGradient>
                <linearGradient id="hv-tube" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#3f3f46" />
                    <stop offset="0.4" stop-color="#18181b" />
                    <stop offset="1" stop-color="#09090b" />
                </linearGradient>
                <linearGradient id="hv-bore" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0" stop-color="#52525b" />
                    <stop offset="0.4" stop-color="#18181b" />
                    <stop offset="1" stop-color="#000" />
                </linearGradient>
                <linearGradient id="hv-capL" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0" stop-color="#000" stop-opacity=".55" />
                    <stop offset="1" stop-color="#000" stop-opacity="0" />
                </linearGradient>
                <linearGradient id="hv-capR" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0" stop-color="#000" stop-opacity="0" />
                    <stop offset="1" stop-color="#000" stop-opacity=".55" />
                </linearGradient>

                <pattern id="dk-hatch" width="5" height="5" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
                    <line x1="0" y1="0" x2="0" y2="5" stroke="#000" stroke-opacity=".28" stroke-width="1.1" />
                </pattern>
                <pattern id="hv-weave" width="6.5" height="6.5" patternUnits="userSpaceOnUse" patternTransform="rotate(42)">
                    <path d="M0 3.25H6.5" stroke="#000" stroke-opacity=".45" stroke-width="1.4" />
                    <path d="M3.25 0V6.5" stroke="#fff" stroke-opacity=".22" stroke-width="1.1" />
                </pattern>
                <pattern id="hv-grain" width="5" height="5" patternUnits="userSpaceOnUse" patternTransform="rotate(-38)">
                    <path d="M0 2.5H5" stroke="#fff" stroke-opacity=".055" stroke-width="1" />
                </pattern>

                <filter id="hv-blur" x="-20%" y="-200%" width="140%" height="500%">
                    <feGaussianBlur stdDeviation="6" />
                </filter>
                <filter id="hv-glow" x="-10%" y="-300%" width="120%" height="700%">
                    <feGaussianBlur stdDeviation="2.8" />
                </filter>

                <clipPath id="hv-flowclip">
                    <rect x="48" y="178" width="154" height="12" />
                    <rect x="246" y="171" width="28" height="38" />
                    <rect x="318" y="178" width="154" height="12" />
                </clipPath>

                <!-- Разрез фитинга -->
                <g id="dk-cut">
                    <rect x="112" y="161.5" width="90" height="3.2" fill="#1a1a1e" />
                    <rect x="112" y="161.5" width="90" height="3.2" fill="url(#hv-grain)" />
                    <rect x="112" y="164.7" width="90" height="5.2" fill="url(#hv-wire)" />
                    <rect x="112" y="164.7" width="90" height="5.2" fill="url(#hv-weave)" />
                    <rect x="112" y="169.9" width="90" height="3.6" fill="#0a0a0c" />

                    <path d="M28 175.5 L28 171.8 L36.5 167.2 L41 165.4 L46 164.6 L49.5 165.3 L53.5 167.4 L58 163.8 L70 163.8 L70 167.2 L98 167.2 L98 172.5 L106 172.5 L106 167.2 L112.5 167.2 L112.5 173.2 L118.5 173.2 L123.8 170.8 L124.5 173.2 L125.8 173.2 L131.2 170.8 L131.9 173.2 L133.2 173.2 L138.6 170.8 L139.3 173.2 L140.6 173.2 L146 170.8 L146.7 173.2 L148 173.2 L153.4 170.8 L154.1 173.2 L155.4 173.2 L160.8 170.8 L161.5 173.2 L162.8 173.2 L168.2 170.8 L168.9 173.2 L170.2 173.2 L175.6 170.8 L176.3 173.2 L177.6 173.2 L183 170.8 L183.7 173.2 L185 173.2 L190.4 170.8 L191.1 173.2 L192.4 173.2 L197.8 170.8 L198.5 173.2 L202 173.2 L202 179.5 L61 179.5 Z" fill="url(#hv-steel)" />
                    <path d="M28 175.5 L28 171.8 L36.5 167.2 L41 165.4 L46 164.6 L49.5 165.3 L53.5 167.4 L58 163.8 L70 163.8 L70 167.2 L98 167.2 L98 172.5 L106 172.5 L106 167.2 L112.5 167.2 L112.5 173.2 L118.5 173.2 L123.8 170.8 L124.5 173.2 L125.8 173.2 L131.2 170.8 L131.9 173.2 L133.2 173.2 L138.6 170.8 L139.3 173.2 L140.6 173.2 L146 170.8 L146.7 173.2 L148 173.2 L153.4 170.8 L154.1 173.2 L155.4 173.2 L160.8 170.8 L161.5 173.2 L162.8 173.2 L168.2 170.8 L168.9 173.2 L170.2 173.2 L175.6 170.8 L176.3 173.2 L177.6 173.2 L183 170.8 L183.7 173.2 L185 173.2 L190.4 170.8 L191.1 173.2 L192.4 173.2 L197.8 170.8 L198.5 173.2 L202 173.2 L202 179.5 L61 179.5 Z" fill="url(#dk-hatch)" stroke="#1e293b" stroke-width=".75" stroke-linejoin="round" />

                    <path d="M28 153.5 L31.5 150 L78 150 L81.5 153.5 L81.5 165.8 L70.5 165.8 L70.5 159.2 L56.5 159.2 L56.5 160.4 L54.2 163.2 L51.9 160.4 L49.6 163.2 L47.3 160.4 L45 163.2 L42.7 160.4 L40.4 163.2 L38.1 160.4 L35.8 163.2 L33.5 160.4 L31.2 163.2 L28 160.4 Z" fill="url(#hv-zinc)" />
                    <path d="M28 153.5 L31.5 150 L78 150 L81.5 153.5 L81.5 165.8 L70.5 165.8 L70.5 159.2 L56.5 159.2 L56.5 160.4 L54.2 163.2 L51.9 160.4 L49.6 163.2 L47.3 160.4 L45 163.2 L42.7 160.4 L40.4 163.2 L38.1 160.4 L35.8 163.2 L33.5 160.4 L31.2 163.2 L28 160.4 Z" fill="url(#dk-hatch)" stroke="#713f12" stroke-width=".75" stroke-linejoin="round" />
                    <path d="M34 151.8H75.5" stroke="#fff" stroke-opacity=".5" stroke-linecap="round" stroke-width="1.1" />

                    <circle cx="45.6" cy="168.5" r="2.85" fill="#0c0c0e" stroke="#64748b" stroke-width=".65" />
                    <circle cx="44.7" cy="167.6" r=".8" fill="#fff" fill-opacity=".45" />

                    <path d="M112.5 159.5 L116 156 L127.5 156 L129.2 158.2 L132.2 158.2 L133.8 156 L145.5 156 L147.2 158.2 L150.2 158.2 L151.8 156 L163.5 156 L165.2 158.2 L168.2 158.2 L169.8 156 L181.5 156 L183.2 158.2 L186.2 158.2 L187.8 156 L199.5 156 L203 159.5 L203 162.8 L112.5 162.8 Z" fill="url(#hv-steel)" />
                    <path d="M112.5 159.5 L116 156 L127.5 156 L129.2 158.2 L132.2 158.2 L133.8 156 L145.5 156 L147.2 158.2 L150.2 158.2 L151.8 156 L163.5 156 L165.2 158.2 L168.2 158.2 L169.8 156 L181.5 156 L183.2 158.2 L186.2 158.2 L187.8 156 L199.5 156 L203 159.5 L203 162.8 L112.5 162.8 Z" fill="url(#dk-hatch)" stroke="#1e293b" stroke-width=".75" stroke-linejoin="round" />
                </g>

                <!-- Внешний вид -->
                <g id="dk-ext">
                    <path d="M81.5 190 L81.5 213.5 L99 213.5 L99 208 L106.5 208 L106.5 213.5 L112.5 213.5 L112.5 190 Z" fill="url(#hv-steel)" stroke="#334155" stroke-width=".75" stroke-linejoin="round" />
                    <path d="M99 192.5V208M106.5 192.5V208" stroke="#000" stroke-opacity=".32" />
                    <rect x="81.5" y="190" width="8" height="23.5" fill="url(#hv-capL)" opacity=".65" />

                    <path d="M112.5 221 L116 224.5 L127.5 224.5 L129.2 222.3 L132.2 222.3 L133.8 224.5 L145.5 224.5 L147.2 222.3 L150.2 222.3 L151.8 224.5 L163.5 224.5 L165.2 222.3 L168.2 222.3 L169.8 224.5 L181.5 224.5 L183.2 222.3 L186.2 222.3 L187.8 224.5 L199.5 224.5 L203 221 L203 190 L112.5 190 Z" fill="url(#hv-steel)" stroke="#334155" stroke-width=".75" stroke-linejoin="round" />
                    <path d="M130 192.5V222.5M148 192.5V222.5M166 192.5V222.5M184 192.5V222.5" stroke="#000" stroke-opacity=".3" />
                    <rect x="194" y="190" width="9" height="31" fill="url(#hv-capR)" opacity=".65" />

                    <path d="M28 227.5 L31.5 231 L78 231 L81.5 227.5 L81.5 190 L28 190 Z" fill="url(#hv-zinc)" stroke="#713f12" stroke-width=".75" stroke-linejoin="round" />
                    <path d="M28 210H81.5" stroke="#000" stroke-opacity=".4" />
                    <path d="M28 211.2H81.5" stroke="#fff" stroke-opacity=".28" />
                    <path d="M32 192.5V228.5M77 192.5V228.5" stroke="#000" stroke-opacity=".32" />
                    <rect x="71.5" y="190" width="10" height="37.5" fill="url(#hv-capR)" opacity=".55" />
                </g>
            </defs>

            <!-- Тень -->
            <ellipse cx="260" cy="258" rx="210" ry="8" fill="#000" opacity=".5" filter="url(#hv-blur)" />

            <!-- Каналы -->
            <rect x="28" y="160" width="35" height="31" fill="url(#hv-bore)" />
            <rect x="63" y="178.5" width="140" height="12" fill="url(#hv-bore)" />
            <rect x="457" y="160" width="35" height="31" fill="url(#hv-bore)" />
            <rect x="317" y="178.5" width="140" height="12" fill="url(#hv-bore)" />

            <!-- Рукав -->
            <g>
                <rect x="203" y="159.5" width="25" height="61" fill="url(#hv-rubber)" />
                <rect x="203" y="159.5" width="25" height="61" fill="url(#hv-grain)" />
                <rect x="292" y="159.5" width="25" height="61" fill="url(#hv-rubber)" />
                <rect x="292" y="159.5" width="25" height="61" fill="url(#hv-grain)" />

                <rect x="228" y="163.5" width="19" height="53" fill="url(#hv-wire)" />
                <rect x="228" y="163.5" width="19" height="53" fill="url(#hv-weave)" />
                <rect x="273" y="163.5" width="19" height="53" fill="url(#hv-wire)" />
                <rect x="273" y="163.5" width="19" height="53" fill="url(#hv-weave)" />

                <rect x="247" y="169.5" width="26" height="41" fill="url(#hv-tube)" />

                <rect x="228" y="163.5" width="7" height="53" fill="url(#hv-capL)" />
                <rect x="285" y="163.5" width="7" height="53" fill="url(#hv-capR)" />
                <rect x="247" y="169.5" width="6.5" height="41" fill="url(#hv-capL)" />
                <rect x="266.5" y="169.5" width="6.5" height="41" fill="url(#hv-capR)" />

                <path d="M228 159.5v61M292 159.5v61M247 163.5v53M273 163.5v53" stroke="#000" stroke-opacity=".55" />
            </g>

            <!-- Поток -->
            <g clip-path="url(#hv-flowclip)">
                <line x1="48" y1="184.5" x2="472" y2="184.5" stroke="#f97316" stroke-width="7.5" stroke-opacity=".4" filter="url(#hv-glow)" />
                <line class="hv-flow" x1="48" y1="184.5" x2="472" y2="184.5" stroke="#fb923c" stroke-width="2.8" stroke-linecap="round" stroke-dasharray="1.2 8.5" />
            </g>

            <!-- Фитинги -->
            <use href="#dk-cut" />
            <use href="#dk-ext" />
            <use href="#dk-cut" transform="translate(520 0) scale(-1 1)" />
            <use href="#dk-ext" transform="translate(520 0) scale(-1 1)" />

            <!-- Осевая -->
            <line x1="14" y1="190" x2="506" y2="190" stroke="#fff" stroke-opacity=".28" stroke-dasharray="12 4 2.5 4" />

            <!-- Выноски -->
            <g fill="none" stroke="#fb923c" stroke-opacity=".8" stroke-width="1.2">
                <path d="M70 155V58" />
                <path d="M55 226V268" />
                <path d="M150 157V112" />
                <path d="M214 160V132" />
                <path d="M237 170V150" />
                <path d="M260 211V290" />
            </g>
            <g fill="#fb923c">
                <circle cx="70" cy="155" r="2.4" />
                <circle cx="55" cy="226" r="2.4" />
                <circle cx="150" cy="157" r="2.4" />
                <circle cx="214" cy="160" r="2.4" />
                <circle cx="237" cy="170" r="2.4" />
                <circle cx="260" cy="211" r="2.4" />
            </g>

            <!-- Подписи -->
            <g fill="#e4e4e7" font-size="13" font-weight="600">
                <text x="24" y="50">Фитинг</text>
                <text x="24" y="284">Гайка</text>
                <text x="122" y="104">Обжимная муфта</text>
                <text x="200" y="126">Резина</text>
                <text x="248" y="144">Сталь</text>
                <text x="260" y="306" text-anchor="middle">Внутренняя трубка</text>
            </g>

            <!-- Нижняя линия -->
            <g stroke="#71717a" stroke-width="1.1" fill="none">
                <path d="M36 332H484" />
                <path d="M36 327v10M484 327v10" />
            </g>
            <text x="260" y="352" text-anchor="middle" font-size="12" letter-spacing="2" fill="#71717a">
                РУКАВ ВЫСОКОГО ДАВЛЕНИЯ В СБОРЕ
            </text>
        </svg>
    </div>
</template>

<style scoped>
.hv-flow {
    animation: hv-flow 0.85s linear infinite;
}
@keyframes hv-flow {
    to { stroke-dashoffset: -9.7; }
}
@media (prefers-reduced-motion: reduce) {
    .hv-flow {
        animation: none;
    }
}
</style>
