ARG PHP_VERSION=8.0

FROM php:${PHP_VERSION}-fpm

ARG PICKLE_EXTENSIONS

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    git \
    ssh \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libmemcached-dev \
    libzip-dev \
    libicu-dev \
    libpq-dev \
    libssh2-1 \
    libssh2-1-dev \
    libxml2-dev \
    libwebp-dev \
    libmagickwand-dev \
    libonig-dev \
    libxslt1-dev \
    && rm -rf /var/lib/apt/lists/* \
    && dpkg-reconfigure -f noninteractive locales \
    && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
    && echo 'fr_FR.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) intl gd opcache mbstring zip pdo_mysql mysqli soap exif xsl

# Install APCu
RUN pecl install apcu && docker-php-ext-enable apcu
# Install Memcached
RUN pecl install memcached && docker-php-ext-enable memcached
# Install PCOV
RUN pecl install pcov && docker-php-ext-enable pcov

# Install Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Set up user and permissions
RUN usermod -u 1000 www-data && usermod -G staff www-data

# Set working directory
WORKDIR /var/www/symfony

# Copy configuration files
COPY symfony.ini $PHP_INI_DIR/conf.d/
COPY symfony.pool.conf $PHP_INI_DIR/pool.d/
COPY xdebug.ini $PHP_INI_DIR/conf.d/99-custom-xdebug.ini
COPY blackfire.ini $PHP_INI_DIR/conf.d/99-custom-blackfire.ini
