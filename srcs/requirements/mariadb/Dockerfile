FROM debian:bullseye

RUN apt update && upgrade -y && apt install -y \
	mariadb-server mariadb-client && \
	apt clean && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d

COPY ./init_mariadb.sh /init_mariadb.sh

RUN chmod +x /init_mariadb.sh

# port par defaut de mariadb
EXPOSE 3306

ENTRYPOINT ["/init_mariadb.sh"]