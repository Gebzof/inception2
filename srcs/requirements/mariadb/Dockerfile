FROM debian:bullseye

RUN apt update && apgrade -y && apt install -y \
	mariadb-server mariadb-client && \
	apt clean && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d

COPY ./imit_mariadb.sh /imit_mariadb.sh

Run chmod +x /imit_mariadb.sh

# port par defaut de mariadb
EXPOSE 3306

ENTRYPOINT ["/imit_mariadb.sh"]