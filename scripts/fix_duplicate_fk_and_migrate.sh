#!/usr/bin/env bash
set -euo pipefail

# fix_duplicate_fk_and_migrate.sh
# Usage: run from repo root on host where Docker is running
# This script:
#  - creates a DB dump inside the mysql container and copies it to host
#  - finds any owner table for constraint name `original_media_id` and drops it
#  - shows CREATE TABLE for `media`
#  - runs `php artisan migrate --force` inside the php container
#  - fixes permissions on storage and bootstrap/cache
#  - tails the latest laravel log

MYSQL_CONTAINER=${MYSQL_CONTAINER:-akaunting-docker-mysql-1}
PHP_CONTAINER=${PHP_CONTAINER:-akaunting-docker-php-1}
DB_NAME=${DB_NAME:-akaunting}
BACKUP_HOST_PATH="./akaunting_backup_$(date +%Y%m%d_%H%M%S).sql"
TMP_BACKUP="/tmp/$(basename "$BACKUP_HOST_PATH")"

echo "Using MYSQL_CONTAINER=$MYSQL_CONTAINER PHP_CONTAINER=$PHP_CONTAINER DB_NAME=$DB_NAME"

function die(){ echo "ERROR: $*" >&2; exit 1; }

docker inspect --format '{{.State.Running}}' "$MYSQL_CONTAINER" &>/dev/null || die "MySQL container '$MYSQL_CONTAINER' not found or not running"
docker inspect --format '{{.State.Running}}' "$PHP_CONTAINER" &>/dev/null || die "PHP container '$PHP_CONTAINER' not found or not running"

# try to read MYSQL root password from container env, fallback to 'root'
ROOT_PW=$(docker exec "$MYSQL_CONTAINER" printenv MYSQL_ROOT_PASSWORD 2>/dev/null || true)
if [ -z "$ROOT_PW" ]; then
  echo "MYSQL_ROOT_PASSWORD not set in container, defaulting to 'root'"
  ROOT_PW=root
fi

echo "Backing up database '$DB_NAME' inside container to $TMP_BACKUP..."
docker exec "$MYSQL_CONTAINER" bash -lc "mysqldump -uroot -p'${ROOT_PW}' ${DB_NAME} > '${TMP_BACKUP}' || mysqldump -uroot ${DB_NAME} > '${TMP_BACKUP}'"

echo "Copying backup to host: $BACKUP_HOST_PATH"
docker cp "$MYSQL_CONTAINER:$TMP_BACKUP" "$BACKUP_HOST_PATH"
docker exec "$MYSQL_CONTAINER" rm -f "$TMP_BACKUP" || true

echo "Searching information_schema for constraint name 'original_media_id'..."
LOCATIONS_FILE="/tmp/constraint_locations_$(date +%s).txt"
docker exec "$MYSQL_CONTAINER" bash -lc "mysql -uroot -p'${ROOT_PW}' -N -e \"SELECT TABLE_SCHEMA, TABLE_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE CONSTRAINT_NAME='original_media_id'\"" > "$LOCATIONS_FILE" || true
if [ -s "$LOCATIONS_FILE" ]; then
  echo "Found constraint owner rows:" && cat "$LOCATIONS_FILE"
  while read -r schema table; do
    if [ -n "$schema" ] && [ -n "$table" ]; then
      echo "Dropping foreign key 'original_media_id' from $schema.$table"
      docker exec "$MYSQL_CONTAINER" bash -lc "mysql -uroot -p'${ROOT_PW}' -e 'USE \`$schema\`; ALTER TABLE \`$table\` DROP FOREIGN KEY original_media_id;'" || echo "Warning: failed to drop FK on $schema.$table"
    fi
  done < "$LOCATIONS_FILE"
else
  echo "No existing constraint named 'original_media_id' found in information_schema."
fi

echo "SHOW CREATE TABLE for 'media' (to inspect remaining FKs):"
docker exec "$MYSQL_CONTAINER" bash -lc "mysql -uroot -p'${ROOT_PW}' -e \"USE ${DB_NAME}; SHOW CREATE TABLE media\G\""

echo "Running migrations inside PHP container..."
docker exec "$PHP_CONTAINER" bash -lc "cd /var/www/html && php artisan migrate --force" || echo "artisan migrate finished with issues"

echo "Fixing permissions on storage and bootstrap/cache"
docker exec "$PHP_CONTAINER" bash -lc "chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache || true; chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache || true"

echo "Tail of latest laravel log (if present):"
LOG_PATH_DATE="/var/www/html/storage/logs/laravel-$(date +%Y-%m-%d).log"
docker exec "$PHP_CONTAINER" bash -lc "if [ -f '${LOG_PATH_DATE}' ]; then tail -n 200 '${LOG_PATH_DATE}'; else ls -l /var/www/html/storage/logs && tail -n 200 /var/www/html/storage/logs/*.log || true; fi"

echo "Done. Inspect output above. If migrations still fail, paste the last log section here."
