FROM debian:bullseye

RUN apt-get update && \
	apt-get install -y nginx openssl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* # supprimer les paquets inutiles.

RUN mkdir -p /etc/nginx/ssl

#x509 = format de certificat, nodes = pas chiffer.# ficher de cle #CN = common name
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048\
	-keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt\
	-subj "/C=FR/ST=Paris/L=Paris/O=42/CN=gebz.42.fr"


COPY /conf/nginx.conf /etc/nginx/nginx.conf
COPY /conf/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]