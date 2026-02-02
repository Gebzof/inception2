#!/bin/bash

set -e

if echo "${WP_ADMIN_USER:-}" | grep -qiE 'admin|administrator'; then
	echo "Error: WP_ADMIN_USER must not contain 'admin' or 'administrator'. Use e.g. superuser or manager."
	exit 1
fi

# Lire les mots de passe depuis les secrets si disponibles
if [ -n "${WP_ADMIN_PASSWORD_FILE:-}" ] && [ -f "$WP_ADMIN_PASSWORD_FILE" ]; then
	WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")
fi
if [ -n "${DB_PASSWORD_FILE:-}" ] && [ -f "$DB_PASSWORD_FILE" ]; then
	DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")
fi

if [ ! -f /var/www/html/index.php ]; then
	echo "Copying WordPress files to volume..."
	cp -a /usr/src/wordpress/. /var/www/html/
fi

echo "Downloading wordpress"

echo "waiting for mariadb"
#je ping mariadb silencieusement voir si c'est bon 
until mysqladmin ping -h "${DB_HOST:-mariadb}" -P 3306 --silent 2>/dev/null; do
	echo "mariadb is not ready yet"
	sleep 1
done

echo "mariadb is ready"

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "configuring wordpress.."
	wp core config \
		--dbname="${DB_NAME:-wordpress}" \
		--dbuser="${DB_USER:-wordpress}" \
		--dbpass="${DB_PASSWORD:-wordpress}" \
		--dbhost="${DB_HOST:-mariadb}" \
		--allow-root \
		--skip-check || true
fi

if ! wp core is-installed -path=/var/www/html --allow-root 2>/dev/null; then
	echo "installing wordpress"
	wp core install \
	--url="${WP_URL:-https://localhost}"\
	--title="${WP_TITLE:-WordPress inception}"\
	--admin_user="${WP_ADMIN_USER}"\
	--admin_password="${WP_ADMIN_PASSWORD}"\
	--admin_email="${WP_ADMIN_EMAIL:-admin@example.com}"\
	--path=/var/www/html\
	--allow-root || true
fi

chown -R www-data:www-data /var/www/html

echo "wordpress is ready"

exec php-fpm7.4 -F