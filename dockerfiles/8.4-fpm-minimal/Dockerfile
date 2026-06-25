FROM php:8.4-fpm-alpine

WORKDIR /var/www/html

# Install depencencies
RUN apk update && apk upgrade && apk add --no-cache --virtual \
        .build-deps $PHPIZE_DEPS linux-headers g++ make libstdc++ curl-dev openssl-dev pcre-dev pcre2-dev zlib-dev bash build-base libzip-dev \
        freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev icu-dev \
        nginx supervisor \
        imagemagick imagemagick-libs imagemagick-dev \
        bash git nano ffmpeg

# Install Composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# Enable php extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install exif \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip \
	&& docker-php-ext-configure sockets \
	&& docker-php-ext-install sockets \
	&& docker-php-ext-install pcntl \
	&& docker-php-ext-install intl

# Install Redis, MongoDB & Imagick PHP Extensions
RUN pecl install redis \
    && pecl install mongodb \
    && pecl install imagick \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-enable imagick

# Install Swoole PHP Extension
RUN pecl install swoole \
    && docker-php-ext-enable swoole

# Clean Up
RUN docker-php-source delete \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /tmp/* /var/cache/apk/*

COPY dockerfiles/8.4-fpm-minimal/entrypoint.sh /usr/local/bin/entrypoint
COPY dockerfiles/8.4-fpm-minimal/supervisord_plain.conf /etc/supervisord_plain.conf
COPY dockerfiles/8.4-fpm-minimal/nginx.conf /etc/nginx/nginx.conf
COPY dockerfiles/8.4-fpm-minimal/www.conf /usr/local/etc/php-fpm.d/www.conf

# Fixes for file upload
RUN mkdir -p /var/lib/nginx/tmp/client_body \
    && chmod -R 777 /var/lib/nginx/tmp/client_body \
    && chmod -R 777 /var/lib/nginx/tmp \
    && chmod -R 777 /var/lib/nginx \
    && chown -R www-data:www-data /var/www/html

EXPOSE 8000

CMD ["/usr/local/bin/entrypoint"]
