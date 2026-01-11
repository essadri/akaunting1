#!/bin/bash

# Set uid of host machine
usermod --non-unique --uid "${HOST_UID}" www-data
groupmod --non-unique --gid "${HOST_GID}" www-data

set -euo pipefail

php /usr/local/bin/wait-for-db.php
if [ ! -f "vendor/autoload.php" ]; then
#    git clone --progress -b "${AKAUNTING_VERSION}" --single-branch --depth 1 https://github.com/akaunting/akaunting /tmp/akaunting
    git clone --progress -b main --single-branch --depth 1 https://github.com/essadri/akaunting1.git /tmp/akaunting
    rsync -r /tmp/akaunting/ .
    rm -rf /tmp/akaunting
    if [ $APP_ENV == "production" ]; then
        composer install --no-dev --no-scripts
    else
        composer install --no-scripts
    fi
    cp .env.example .env
    php artisan key:generate
    composer dump-autoload
    php artisan install --no-interaction --db-host="${DB_HOST}" --db-port="${DB_PORT}" --db-name="${DB_DATABASE}" --db-username="${DB_USERNAME}" --db-password="${DB_PASSWORD}" --db-prefix="${DB_PREFIX}" --admin-email="${ADM_EMAIL}" --admin-password="${ADM_PASSWD}"
    export NVM_DIR="/root/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        . "$NVM_DIR/nvm.sh"
    fi

    npm ci
    if [ $APP_ENV == "production" ]; then
        npm run production
    else
        npm run dev
    fi
    chown -R www-data:www-data .
fi
php-fpm
