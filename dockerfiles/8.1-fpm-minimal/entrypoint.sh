#!/usr/bin/env bash

set -e

env > /var/www/html/.env
exec /usr/bin/supervisord -n -c "/etc/supervisord_plain.conf"
