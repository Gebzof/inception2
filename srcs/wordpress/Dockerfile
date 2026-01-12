FROM debian:bullseye

RUN apt update && apt upgrade -y && apt install -y\
	php-fpm php-mysql php-mysqli php-curl php-gd php-xml php-mbstring php-zip php-dom php-intl wget curl mariadb-client &&\
	apt clean &&\
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

RUN wget https://wordpress.org/latest.tar.gz && tar -xvf latest.tar.gz -C /var/www/html --strip-cc rm latest.tar.gz

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's/;listen.owner = www-data/listen.owner = www-data/g' /etc/php/7.4/fpm/pool.d/www.conf && \
	sed -i 's/;listen.group = www-data/listen.group = www-data/g' /etc/php/7.4/fpm/pool.d/www.conf

RUN chown -R www-data:www-data /var/www/html

COPY tools/init_wordpress.sh /init_wordpress.sh 

RUN chmod 777 /init_wordpress.sh

EXPOSE 9000

ENTRYPOINT ["/init_wordpress.sh"] #point dentre pour le conteneur