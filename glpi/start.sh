#!/bin/bash
# - Install GLPI if not already installed
# - Run apache in foreground

### GENERAL CONF ###############################################################

APACHE_DIR="/var/www/html"
GLPI_DIR="${APACHE_DIR}/glpi"
PLUGINS_DIR="${GLPI_DIR}/plugins"
FUSION_DIR="${GLPI_DIR}/plugins/fusioninventory"
GLPI_SOURCE_URL=${GLPI_SOURCE_URL}
FUSION_SOURCE_URL=${FUSION_SOURCE_URL}

### INSTALL GLPI IF NOT INSTALLED ALREADY ######################################

if [ "$(ls -A $GLPI_DIR)" ]; then
  echo "GLPI is already installed at ${GLPI_DIR}"
else
  echo '-----------> Install GLPI'
  echo "Using ${GLPI_SOURCE_URL}"
  wget -O /tmp/glpi.tar.gz $GLPI_SOURCE_URL --no-check-certificate
  tar -C $APACHE_DIR -xzf /tmp/glpi.tar.gz
  chown -R www-data $GLPI_DIR
fi
if [ "$(ls -A $FUSION_DIR)" ]; then
  echo "FUSION is already installed at ${FUSION_DIR}"
else
  echo '-----------> Install FUSION'
  echo "Using ${FUSION_SOURCE_URL}"
  wget -O /tmp/fusion.tar.gz $FUSION_SOURCE_URL --no-check-certificate
  tar -C $PLUGINS_DIR -xzf /tmp/fusion.tar.gz
  mv $GLPI_DIR/plugins/fusioninventory-for-glpi-glpi9.2-2.0  $GLPI_DIR/plugins/fusioninventory
  chown -R www-data $PLUGINS_DIR
fi


### REMOVE THE DEFAULT INDEX.HTML TO LET HTACCESS REDIRECTION ##################

# rm ${APACHE_DIR}/index.html

VHOST=/etc/apache2/sites-enabled/000-default.conf

# Use /var/www/html/glpi as DocumentRoot
sed -i -- 's/\/var\/www\/html$/\/var\/www\/html\/glpi/g' $VHOST
# Remove ServerSignature (secutiry)
awk '/<\/VirtualHost>/{print "ServerSignature Off" RS $0;next}1' $VHOST > tmp && mv tmp $VHOST

# HTACCESS="/var/www/html/.htaccess"
# /bin/cat <<EOM >$HTACCESS
# RewriteEngine On
# RewriteRule ^$ /glpi [L]
# EOM
# chown www-data /var/www/html/.htaccess
chown www-data .

### RUN APACHE IN FOREGROUND ###################################################

# stop apache service
# service apache2 stop
service apache2 restart
#Add scheduled task by cron and enable
echo "*/1 * * * * www-data /usr/bin/php /var/www/html/glpi/front/cron.php &>/dev/null" >> /etc/cron.d/glpi
#Start cron service
service cron start

# start apache in foreground
# source /etc/apache2/envvars
# /usr/sbin/apache2 -D FOREGROUND
tail -f /var/log/apache2/error.log -f /var/log/apache2/access.log
