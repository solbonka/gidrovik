FROM php:8.4-fpm

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libicu-dev \
    libpq-dev \
    libxpm-dev \
    libvpx-dev \
    libzip-dev \
    ghostscript \
    libmagickwand-dev \
    gnupg2 \
    libtool \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Установка Node.js через nvm
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=22.12.0

RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    npm install -g pnpm@$PNPM_VERSION && \
    ln -sf $NVM_DIR/versions/node/v$NODE_VERSION/bin/node /usr/local/bin/node && \
    ln -sf $NVM_DIR/versions/node/v$NODE_VERSION/bin/npm  /usr/local/bin/npm && \
    ln -sf $NVM_DIR/versions/node/v$NODE_VERSION/bin/npx  /usr/local/bin/npx && \
    ln -sf $NVM_DIR/versions/node/v$NODE_VERSION/bin/pnpm /usr/local/bin/pnpm

# Установка и включение Imagick через PECL
RUN pecl install imagick && docker-php-ext-enable imagick

# Разрешаем работу с PDF в ImageMagick
RUN mkdir -p /etc/ImageMagick-6/ /etc/ImageMagick-7/ && \
    echo '<?xml version="1.0" encoding="UTF-8"?> \
<policymap> \
  <policy domain="coder" rights="read|write" pattern="PDF" /> \
</policymap>' | tee /etc/ImageMagick-6/policy.xml /etc/ImageMagick-7/policy.xml

# Установка и настройка PHP-расширений
RUN pecl install xdebug && docker-php-ext-enable xdebug && \
    docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-xpm && \
    docker-php-ext-install -j$(nproc) gd intl zip pgsql pdo_pgsql exif sockets bcmath && \
    docker-php-ext-enable sockets

# Установка Composer через официальный образ (надёжнее и быстрее)
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Проверка версий (можно закомментировать)
RUN php -v && node -v && npm -v && composer -V

# Создаем пользователя и группу для приложения
RUN groupadd -g 1000 www && \
    useradd -u 1000 -ms /bin/bash -g www www

# Устанавливаем рабочую директорию
WORKDIR /var/www/html
RUN chown -R www:www /var/www/html

# Переключаемся на пользователя приложения
USER www
