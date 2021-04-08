FROM php:8.0.3-fpm

ENV TELEGRAF_CONFIG=

# Copy configs and start script
COPY start.sh /usr/local/bin/start

# Install depencencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
        git \
        g++ \
        libbz2-dev \
        libc-client-dev \
        libcurl4-gnutls-dev \
        libedit-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libkrb5-dev \
        libldap2-dev \
        libldb-dev \
        libmagickwand-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng-dev \
        libpq-dev \
        libsqlite3-dev \
        libssl-dev \
        libreadline-dev \
        libxslt1-dev \
        libzip-dev \
        memcached \
        imagemagick \
        wget \
        unzip \
        zlib1g-dev \
        curl \
        libmemcached-dev \
        libz-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        libonig-dev \
		libzip-dev \
        nginx \
        supervisor \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        bz2 \
        calendar \
        exif \
        gettext \
        mysqli \
        opcache \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        soap \
        sockets \
        xsl \
# Install Imagick PHP Extension
    && git clone https://github.com/Imagick/imagick \
    && cd imagick \
    && git checkout master && git pull \
    && phpize && ./configure && make && make install \
    && cd .. && rm -Rf imagick \
    && docker-php-ext-enable imagick \
    && rm -rf /tmp/* \
# Install Remaining PHP Extensions
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && PHP_OPENSSL=yes docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) imap \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install ldap \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip \
    && pecl install xdebug && docker-php-ext-enable xdebug \
    && pecl install memcached && docker-php-ext-enable memcached \
    && pecl install mongodb && docker-php-ext-enable mongodb \
    && pecl install redis && docker-php-ext-enable redis \
    && docker-php-source delete \
    && apt-get remove -y g++ wget \
    && apt-get autoremove --purge -y && apt-get autoclean -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* \
	&& docker-php-ext-install pcntl \

# Copy NGINX config
COPY default /etc/nginx/sites-available/
COPY nginx.conf /etc/nginx/nginx.conf

# Install Telegraf
RUN curl https://dl.influxdata.com/telegraf/releases/telegraf_1.16.1-1_amd64.deb --output telegraf.deb \
    && dpkg -i telegraf.deb

# Change php-fpm config
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

# Copy supervisord config
COPY supervisord_telegraf.conf /etc/supervisord_telegraf.conf
COPY supervisord_plain.conf /etc/supervisord_plain.conf

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Make start.sh executable
RUN chmod 0550 /usr/local/bin/start

EXPOSE 80

CMD ["/usr/local/bin/start"]