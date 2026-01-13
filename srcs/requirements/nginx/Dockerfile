FROM debian:bullseye

RUN apt-get update && \
	apt-get install -y nginx openssl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* # supprimer les paquets inutiles.

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048\ # x509 = format de certificat, nodes = pas chiffer.
	-keyout /etc/nginx/ssl/nginx.key\ # ficher de cle
	-out /etc/nginx/ssl/nginx.crt\ # ficher de sortie
	-subj "/C=FR/ST=Paris/L=Paris/O=42/CN=localhost" #CN = common name


COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/default /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]