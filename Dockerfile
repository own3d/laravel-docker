FROM php:8.0.3-fpm-alpine

ENV TELEGRAF_CONFIG=
ENV TELEGRAF_VERSION=1.18.1

# Copy configs and start script
COPY start.sh /usr/local/bin/start

# Install depencencies
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update && apk upgrade && apk add --no-cache --virtual \
        g++ make libstdc++ curl-dev openssl-dev pcre-dev pcre2-dev zlib-dev bash build-base \
        php8-curl php8-mbstring php8-xml php8-zip php8-bcmath php8-intl php8-gd php8-pcntl \
        php8-pdo_mysql php8-sqlite3 php8-pecl-redis php8-pecl-swoole php8-pecl-mongodb \
        nginx \
        supervisor \
        nodejs npm \
        git \
        imagemagick php8-dev imagemagick imagemagick-libs imagemagick-dev \
        bash
        
# Install Composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# Install Imagick PHP Extension
RUN git clone https://github.com/Imagick/imagick \
    && cd imagick \
    && git checkout master && git pull \
    && phpize && ./configure && make && make install \
    && cd .. && rm -Rf imagick \
    && docker-php-ext-enable imagick \
    && rm -rf /tmp/*

# RUN pecl install imagick

# Install Remaining PHP Extensions
RUN docker-php-source delete \
    && apk del g++ wget \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /tmp/* /var/cache/apk/*

# Copy NGINX config
COPY default /etc/nginx/sites-available/
COPY nginx.conf /etc/nginx/nginx.conf

# Install Telegraf
ADD https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_amd64.tar.gz ./
RUN tar -C . -xzf telegraf-${TELEGRAF_VERSION}_linux_amd64.tar.gz \
        && chmod +x telegraf-${TELEGRAF_VERSION}* \
        && cp -R telegraf-${TELEGRAF_VERSION}/etc /etc \
        && cp -R telegraf-${TELEGRAF_VERSION}/usr/bin /usr/bin \
        && cp -R telegraf-${TELEGRAF_VERSION}/usr/lib /usr/lib \
        && cp -R telegraf-${TELEGRAF_VERSION}/var/log /var/log \
        && rm -rf *.tar.gz* telegraf-${TELEGRAF_VERSION}/

# Change php-fpm config
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

# Copy supervisord config
COPY supervisord_telegraf.conf /etc/supervisord_telegraf.conf
COPY supervisord_plain.conf /etc/supervisord_plain.conf

# Make start.sh executable
RUN chmod 0550 /usr/local/bin/start

EXPOSE 80

CMD ["/usr/local/bin/start"]