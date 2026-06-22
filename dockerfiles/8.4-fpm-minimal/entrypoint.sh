#!/usr/bin/env bash

set -e

echo "clear_env = no" >> /usr/local/etc/php-fpm.d/www.conf

exec /usr/bin/supervisord -n -c "/etc/supervisord_plain.conf"
