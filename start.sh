#!/bin/sh

set -e

ROLE=${CONTAINER_ROLE:-app}
ENV=${APP_ENV:-production}
TELEGRAF=${TELEGRAF_CONFIG}
MAX_REQUESTS=${OCTANE_MAX_REQUESTS:-250}

if [ "$ENV" != "local" ]; then
    echo "Caching configuration..."
    (cd /var/www/html/ && php artisan config:cache && php artisan route:cache && php artisan view:cache)
fi

if [ "$ROLE" = "app" ]; then
    
    if [ -z "$TELEGRAF" ]; then
        exec /usr/bin/supervisord -n -c "/etc/supervisord_plain.conf"
    else
        exec /usr/bin/supervisord -n -c "/etc/supervisord_telegraf.conf"
    fi

elif [ "$ROLE" = "queue" ]; then


    echo "Running the queue..."
    php /var/www/html/artisan horizon

elif [ "$ROLE" = "scheduler" ]; then

    while [ true ]
    do
      php /var/www/html/artisan schedule:run --verbose --no-interaction &
      sleep 60
    done

elif [ "$ROLE" = "octane" ]; then

    php /var/www/html/artisan octane:start --max-requests=${MAX_REQUESTS}

else
    echo "Could not match the container ROLE \"$ROLE\""
    exit 1
fi