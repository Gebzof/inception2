#!/bin/bash

set -e

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_DATABASE_PASSWORD" ] || [ -z "$WP_ADMIN_USER" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_ADMIN_EMAIL" ]; then
    echo "Error: Required environment variables WP_DATABASE, WP_DATABASE_USER, WP_DATABASE_PASSWORD, BASE_HOST, WP_ADMIN_USER, WP_ADMIN_PASSWORD, or WP_ADMIN_EMAIL are not set."
    exit 1
fi

echo "Initializing mariadb..."

if [ ! -d /var/lib/mysql/mysql]; then
	echo "init bdd of mariadb"
	mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

echo "stating mariadb"
mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking & MYSQL_PID=$!

echo "waiting for mariadb to start"

until mysqladmin ping --silent 2>/dev/null; do
	echo "waiting"
	sleep 1
done

echo "mariadb is ready"

echo "Creating database and users"

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

CREATE USER IF NOT EXISTS '${DB_ADMIN_USER}'@'%' IDENTIFIED BY '${DB_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_ADMIN_USER}'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

echo "stop mariadb temporary"
mysqladmin shutdown
wait $MYSQL_PID

chown -R mysql:mysql /var/lib/mysql

echo "MariaDB est configuré et prêt !"

exec mysqld --user=mysql

