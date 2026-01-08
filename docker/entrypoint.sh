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

if [[ "${RUN_MIGRATIONS:-false}" == "true" ]]; then
  php artisan migrate --force
fi

exec "$@"
