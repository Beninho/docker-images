ARG PHP_VERSION=8.0

FROM php:${PHP_VERSION}-fpm

ARG PICKLE_EXTENSIONS

RUN apt-get update \
  && apt-get full-upgrade -y \
  && apt-get install -y --no-install-recommends \
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
    libssh2-1 libssh2-1-dev \
    libxml2-dev \
    libwebp-dev \
    libmagickwand-dev \
    # oniguruma not bundled in php, use libonig: https://www.php.net/manual/en/migration74.other-changes.php
    libonig-dev \
    libxslt1-dev \
  && rm -rf /var/lib/apt/lists/* \
  && dpkg-reconfigure -f noninteractive locales \
  && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
  && echo 'fr_FR.UTF-8 UTF-8' >> /etc/locale.gen \
  && locale-gen

# migrating to pkg-config: https://www.php.net/manual/en/migration74.other-changes.php#migration74.other-changes.pkg-config
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install -j$(nproc) intl gd opcache mbstring zip pdo_mysql mysqli soap exif xsl

# Extra extensions using pickle: https://github.com/docker-library/php/pull/840#issuecomment-502251019
ADD https://github.com/FriendsOfPHP/pickle/releases/download/v0.7.7/pickle.phar /usr/local/bin/pickle
ENV PICKLE_EXTENSIONS=${PICKLE_EXTENSIONS:-"apcu memcached imagick pcov"}
RUN chmod +x /usr/local/bin/pickle && \
  ( \
    for extension in $PICKLE_EXTENSIONS; do \
      pickle install -n $extension; \
      docker-php-ext-enable $extension; \
    done \
  )

# Install Composer
ENV COMPOSER_ALLOW_SUPERUSER 1
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

RUN usermod -u 1000 www-data
RUN usermod -G staff www-data

WORKDIR /var/www/symfony

# Config
COPY symfony.ini $PHP_INI_DIR/conf.d/
COPY symfony.pool.conf $PHP_INI_DIR/pool.d/
COPY blackfire.ini $PHP_INI_DIR/conf.d/99-custom-blackfire.ini
