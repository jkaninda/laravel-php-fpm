#!/bin/sh
# Integration test: create a Laravel project with the image, serve it through
# Nginx, run migrations and check that PHP-FPM, the queue worker and the
# scheduler are running.
# Usage: IMAGE=jkaninda/laravel-php-fpm:8.5 [HTTP_PORT=8080] ./tests/integration.sh
set -eu

IMAGE="${IMAGE:-jkaninda/laravel-php-fpm:latest}"
HTTP_PORT="${HTTP_PORT:-80}"
export IMAGE HTTP_PORT
cd "$(dirname "$0")"

cleanup() {
    docker compose logs php-fpm || true
    docker compose down -v --remove-orphans || true
}
trap cleanup EXIT

echo "==> Checking PHP extensions"
docker run --rm "$IMAGE" php -m > modules.txt
for ext in bcmath exif gd intl mbstring memcached pcntl pdo_mysql pdo_pgsql rdkafka redis zip "Zend OPcache"; do
    grep -qx "$ext" modules.txt || { echo "Missing extension: $ext"; exit 1; }
done
if docker run --rm "$IMAGE" sh -c 'php -m 2>&1' 2>/dev/null | grep -iE 'warning|unable to load'; then
    echo "PHP startup warnings detected"; exit 1
fi
rm -f modules.txt
docker run --rm "$IMAGE" sh -c 'php -v && composer -V && node -v && npm -v'

echo "==> Creating Laravel project"
rm -rf laravel
# Older Laravel releases (for PHP 8.1/8.2) are flagged by security advisories;
# this throwaway test project only checks that the image can serve Laravel.
docker run --rm -v "$PWD:/app" -w /app -e COMPOSER_NO_SECURITY_BLOCKING=1 "$IMAGE" \
    composer create-project --prefer-dist --no-interaction --no-progress laravel/laravel laravel
docker run --rm -v "$PWD/laravel:/var/www/html" "$IMAGE" \
    chown -R www-data:www-data storage bootstrap/cache database

echo "==> Starting stack"
docker compose up -d

echo "==> Waiting for PHP-FPM to be healthy"
i=0
until [ "$(docker inspect -f '{{.State.Health.Status}}' php-fpm)" = "healthy" ]; do
    i=$((i + 1)); [ "$i" -gt 60 ] && { echo "PHP-FPM not healthy"; exit 1; }
    sleep 2
done

echo "==> Running migrations"
docker exec --user www-data php-fpm php artisan migrate --force

echo "==> Checking HTTP response"
# Request Nginx from inside the compose network so host port conflicts cannot interfere
code=$(docker exec php-fpm curl -s -o /dev/null -w '%{http_code}' http://nginx-server)
echo "HTTP $code"
[ "$code" = "200" ]

echo "==> Checking supervisor programs"
for program in php-fpm Laravel-worker Laravel-scheduler; do
    i=0
    until docker exec php-fpm supervisorctl status | grep "^$program" | grep -q RUNNING; do
        i=$((i + 1)); [ "$i" -gt 30 ] && { echo "$program is not running"; docker exec php-fpm supervisorctl status; exit 1; }
        sleep 2
    done
done
docker exec php-fpm supervisorctl status

echo "==> All tests passed"
