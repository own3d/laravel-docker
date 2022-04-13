#!/usr/bin/env bash

set -e

exec /usr/bin/supervisord -n -c "/etc/supervisord_plain.conf"