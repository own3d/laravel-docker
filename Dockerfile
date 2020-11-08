FROM nanoninja/php-fpm:7.4.10

# Copy configs and start script
COPY start.sh /usr/local/bin/start

# Install depencencies
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip \
	&& docker-php-ext-configure sockets \
	&& docker-php-ext-install sockets \
	&& docker-php-ext-install pcntl \
    && docker-php-source delete

# Copy NGINX config
COPY default /etc/nginx/sites-available/

# Install Telegraf
RUN curl https://dl.influxdata.com/telegraf/releases/telegraf_1.16.1-1_amd64.deb --output telegraf.deb \
    && dpkg -i telegraf.deb

# Change php-fpm config
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

# Copy supervisord config
COPY supervisord.conf /etc/supervisord.conf

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Make start.sh executable
RUN chmod 0550 /usr/local/bin/start

EXPOSE 80

CMD ["/usr/local/bin/start"]