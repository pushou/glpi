FROM registry.iutbeziers.fr/debianiut:latest
MAINTAINER jean-marc.pouchoulon@iutbeziers.fr
RUN apt-get update
RUN apt-get install -y apache2
RUN apt-get install -y \
  wget \
  php \
  php-mysql \
  php-ldap \
  php-xmlrpc \
  curl \
  php-curl \
  php-gd \
  php-mbstring \
  php-simplexml \
  php-imap \
  php-apcu \
  cron
RUN a2enmod rewrite && service apache2 stop
WORKDIR /var/www/html
COPY start.sh /opt/
RUN chmod +x /opt/start.sh
RUN usermod -u 1000 www-data
CMD /opt/start.sh
EXPOSE 80
