FROM php:7.4-fpm-bullseye
LABEL authors="Sylvain Marty <sylvain@guidap.co>"

ARG TIMEZONE=Europe/Paris

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libmagickwand-dev \
        libmagickcore-dev \
        libcurl4-gnutls-dev \
        zlib1g-dev \
        libicu-dev \
        libzip-dev \
        libonig-dev \
        libpng-dev \
        supervisor \
        curl \
        make \
        pngquant \
        jpegoptim \
        wkhtmltopdf \
        tzdata \
    && cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo "$TIMEZONE" > /etc/timezone \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install \
        xdebug-3.1.5 \
    && docker-php-ext-install \
        pdo_mysql \
        intl \
        bcmath \
        mbstring \
        zip \
        sockets \
        gd \
    && docker-php-ext-enable \
        opcache \
        imagick \
        gd

COPY php.ini /usr/local/etc/php/
COPY 00-supervisor.conf /etc/supervisor/conf.d/

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /tmp/* /var/tmp/*

# Fixes permissions
RUN chmod -R g+rwx /var/www/html \
    && umask 0007
