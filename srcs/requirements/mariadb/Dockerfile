FROM debian:bullseye

RUN apt update && apt upgrade -y && apt install -y \
	mariadb-server mariadb-client && \
	apt clean && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d

# Écouter sur toutes les interfaces pour accepter les connexions depuis WordPress (autre conteneur)
RUN printf '[mysqld]\nbind-address = 0.0.0.0\n' > /etc/mysql/mariadb.conf.d/99-docker.cnf

COPY ./init_mariadb.sh /init_mariadb.sh

RUN chmod +x /init_mariadb.sh

# port par defaut de mariadb
EXPOSE 3306

ENTRYPOINT ["/init_mariadb.sh"]