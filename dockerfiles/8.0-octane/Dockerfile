FROM php:8.0-fpm-alpine

ENV TELEGRAF_CONFIG=""
ENV TELEGRAF_VERSION=1.18.1

# Install depencencies
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update && apk upgrade && apk add --no-cache --virtual \
        .build-deps $PHPIZE_DEPS g++ make libstdc++ curl-dev openssl-dev pcre-dev pcre2-dev zlib-dev bash build-base libzip-dev \
        freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
        php8-curl php8-mbstring php8-xml php8-zip php8-bcmath php8-intl php8-gd php8-pcntl \
        php8-pdo_mysql php8-sqlite3 php8-pecl-redis php8-pecl-mongodb \
        nginx \
        supervisor \
        nodejs npm \
        git \
        imagemagick php8-dev imagemagick imagemagick-libs imagemagick-dev \
        bash

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
	&& docker-php-ext-install pcntl

# Install Redis & MongoDB PHP Extension
RUN pecl install redis \
    && pecl install mongodb \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable mongodb

# Install Imagick PHP Extension
RUN git clone https://github.com/Imagick/imagick \
    && cd imagick \
    && git checkout master && git pull \
    && phpize && ./configure && make && make install \
    && cd .. && rm -Rf imagick \
    && docker-php-ext-enable imagick

# Install Swoole PHP Extension
RUN mkdir -p /usr/src/php/ext/swoole \
    && curl -sfL https://github.com/swoole/swoole-src/archive/v4.6.5.tar.gz -o swoole.tar.gz \
    && tar xfz swoole.tar.gz --strip-components=1 -C /usr/src/php/ext/swoole \
    && docker-php-ext-configure swoole \
        --enable-http2   \
        --enable-mysqlnd \
        --enable-openssl \
        --enable-sockets --enable-swoole-curl --enable-swoole-json \
    && docker-php-ext-install -j$(nproc) swoole \
    && rm -f swoole.tar.gz $HOME/.composer/*-old.phar

# Clean Up
RUN docker-php-source delete \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /tmp/* /var/cache/apk/*

# Install Telegraf
ADD https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_amd64.tar.gz ./
RUN tar -C . -xzf telegraf-${TELEGRAF_VERSION}_linux_amd64.tar.gz \
        && chmod +x telegraf-${TELEGRAF_VERSION}* \
        && cp -R telegraf-${TELEGRAF_VERSION}/etc /etc \
        && cp -R telegraf-${TELEGRAF_VERSION}/usr/bin /usr/bin \
        && cp -R telegraf-${TELEGRAF_VERSION}/usr/lib /usr/lib \
        && cp -R telegraf-${TELEGRAF_VERSION}/var/log /var/log \
        && rm -rf *.tar.gz* telegraf-${TELEGRAF_VERSION}/

# Copy configs and start script
COPY default /etc/nginx/sites-available/default
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /usr/local/bin/start
COPY supervisord_plain.conf /etc/supervisord_plain.conf
COPY supervisord_telegraf.conf /etc/supervisord_telegraf.conf
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY overrides.ini  /usr/local/etc/php/conf.d/docker-php-overrides.ini

# Make start.sh executable
RUN chmod 0550 /usr/local/bin/start

EXPOSE 80

CMD ["/usr/local/bin/start"]