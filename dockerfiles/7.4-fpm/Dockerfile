FROM nanoninja/php-fpm:7.4.10

ENV TELEGRAF_CONFIG=""

# Copy configs and start script
COPY start.sh /usr/local/bin/start

# Install depencencies
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y --no-install-recommends \
        curl \
        libmemcached-dev \
        libz-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libssl-dev \
        libmcrypt-dev \
        libonig-dev \
	    libzip-dev \
        nginx \
	    nodejs \
	    git \
        supervisor \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
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
