# This image is based on the https://github.com/bitinflow/bpkg-images
# which is licensed under the MIT license.
#
# MIT License
#
# Copyright (c) 2021 René Preuß trading as bitinflow GbR
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM php:8.1-cli-alpine3.15

WORKDIR /var/www/html

# STSTEM: Install required packages
RUN apk --no-cache upgrade && \
    apk --no-cache add bash git openssh npm gcc && \
    apk --no-cache add libxml2-dev postgresql-dev oniguruma-dev freetype-dev libjpeg-turbo-dev libpng-dev libzip-dev imagemagick-dev imagemagick-libs imagemagick && \
    apk --no-cache add --virtual .build-deps autoconf g++ make && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
# PHP: Install extensions
    pecl channel-update pecl.php.net && \
    pecl install swoole imagick mongodb redis && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install mbstring xml exif pcntl gd zip sockets pdo pdo_pgsql pdo_mysql bcmath && \
    docker-php-ext-enable mbstring xml gd zip swoole imagick mongodb redis exif pcntl sockets bcmath pdo pdo_pgsql pdo_mysql && \
# PHP: Configure ini
    echo 'post_max_size = 200M' >> /usr/local/etc/php/conf.d/docker-php-overrides.ini && \
    echo 'upload_max_filesize = 200M' >> /usr/local/etc/php/conf.d/docker-php-overrides.ini && \
# CONTAINER: Cleanup build dependencies
    apk del .build-deps && \
    docker-php-source delete

# CONTAINER: Expose port 8000 and set command
EXPOSE 8000
CMD ["php","artisan","octane:start", "--host=0.0.0.0"]
