#!/usr/bin/env bash
set -euo pipefail

cd /var/www/html

if [[ ! -f .env ]]; then
  cp .env.example .env
fi

update_env() {
  local key="$1"
  local value="$2"
  if grep -q "^${key}=" .env; then
    sed -i "s#^${key}=.*#${key}=${value}#g" .env
  else
    echo "${key}=${value}" >> .env
  fi
}

update_env "APP_URL" "${APP_URL:-http://localhost:8000}"
update_env "APP_LOCALE" "${APP_LOCALE:-en-GB}"
update_env "DB_CONNECTION" "${DB_CONNECTION:-mysql}"
update_env "DB_HOST" "${DB_HOST:-mysql}"
update_env "DB_PORT" "${DB_PORT:-3306}"
update_env "DB_DATABASE" "${DB_DATABASE:-akaunting}"
update_env "DB_USERNAME" "${DB_USERNAME:-akaunting}"
update_env "DB_PASSWORD" "${DB_PASSWORD:-akauntingpass}"
update_env "DB_PREFIX" "${DB_PREFIX:-}"

if grep -q "^APP_KEY=$" .env; then
  php artisan key:generate --force
fi

if [[ "${INSTALL_APP:-false}" == "true" ]] && ! grep -q "^APP_INSTALLED=true" .env; then
  until mysqladmin ping -h"${DB_HOST:-mysql}" -P"${DB_PORT:-3306}" -u"${DB_USERNAME:-akaunting}" -p"${DB_PASSWORD:-akauntingpass}" --silent; do
    echo "Waiting for database..."
    sleep 3
  done

  php artisan install \
    --db-host="${DB_HOST:-mysql}" \
    --db-port="${DB_PORT:-3306}" \
    --db-name="${DB_DATABASE:-akaunting}" \
    --db-username="${DB_USERNAME:-akaunting}" \
    --db-password="${DB_PASSWORD:-akauntingpass}" \
    --db-prefix="${DB_PREFIX:-}" \
    --company-name="${COMPANY_NAME:-My Company}" \
    --company-email="${COMPANY_EMAIL:-my@company.com}" \
    --admin-email="${ADMIN_EMAIL:-admin@company.com}" \
    --admin-password="${ADMIN_PASSWORD:-123456}" \
    --locale="${APP_LOCALE:-en-GB}"
fi

if [[ "${RUN_MIGRATIONS:-false}" == "true" ]]; then
  php artisan migrate --force
fi

exec "$@"
