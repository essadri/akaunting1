#!/bin/bash
set -e

# Fix UID/GID to match host
usermod --non-unique --uid "${HOST_UID}" www-data
groupmod --non-unique --gid "${HOST_GID}" www-data

# Wait for database
php /usr/local/bin/wait-for-db.php

# Clean previous installs (LOCAL REPO)
rm -rf vendor node_modules bootstrap/cache/*.php

# Install PHP dependencies
composer install --no-interaction --no-scripts

# Create env only if missing
if [ ! -f .env ]; then
  cp .env.example .env
fi

# Laravel setup
php artisan key:generate --force
php artisan migrate --force || true
composer dump-autoload

# Frontend
npm ci
npm run dev   # ⬅ change to production if needed

# Permissions
chown -R www-data:www-data .

# Start PHP
exec php-fpm





















































# # Set uid of host machine
# usermod --non-unique --uid "${HOST_UID}" www-data
# groupmod --non-unique --gid "${HOST_GID}" www-data

# php /usr/local/bin/wait-for-db.php
# if [ ! -f "vendor/autoload.php" ]; then
# #    git clone --progress -b "${AKAUNTING_VERSION}" --single-branch --depth 1 https://github.com/akaunting/akaunting /tmp/akaunting
#     git clone --progress -b main --single-branch --depth 1 https://github.com/essadri/akaunting1.git /tmp/akaunting
#     rsync -r /tmp/akaunting/ .

#     if [ $APP_ENV == "production" ]; then
#         composer install --no-dev --no-scripts
#     else
#         composer install --no-scripts
#     fi
#     cp .env.example .env
#     php artisan key:generate
#     composer dump-autoload
#     php artisan install --no-interaction --db-host="${DB_HOST}" --db-port="${DB_PORT}" --db-name="${DB_DATABASE}" --db-username="${DB_USERNAME}" --db-password="${DB_PASSWORD}" --db-prefix="${DB_PREFIX}" --admin-email="${ADM_EMAIL}" --admin-password="${ADM_PASSWD}"
#     npm ci
#     if [ $APP_ENV == "production" ]; then
#         npm run production
#     else
#         npm run dev
#     fi
#     chown -R www-data:www-data .
# fi
# php-fpm
