#!/bin/bash

#Muestra todos los comandos que se van ejecutadno
set -x

# Paso1. Se importan las variables de configuracion
source .env

# Actualizamos los repositorios
apt update

# actualizamos los paquetes 
apt upgrade -y

# Paso2. Configuramos las respuestas de la instalaion de phpMyAdmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections

# INstalamos phpMyAdmin
apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

# creamos un usuario que tenga acceso a todas las bases de datos
mysql -u root <<< "DROP USER IF EXISTS '$APP_USER'@'%'"
mysql -u root <<< "CREATE USER '$APP_USER'@'%' IDENTIFIED BY '$APP_PASSWORD';"
mysql -u root <<< "GRANT ALL PRIVILEGES ON *.* TO '$APP_USER'@'%';"

# instalar adminer
# creamos directorio para adminer
mkdir -p /var/www/html/adminer

# Descargamos el archivo de adminer
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer

#Renombramos el nombre del archivo adminer
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php

# Modificamos l propietario del directorio /var/www/html
chown -R www-data:www-data /var/www/html

# Descaragamos GoAcces
apt install goaccess -y

# Iniciar GoAcces

#Creamos un directorio paralos informes html de GoAcces
mkdir -p /var/www/html/stats

# ejecutamos GoAcces en sugundo plano
sudo goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize

#Creamos el archivo .htpasswd
htpasswd -bc /etc/apache2/.htpasswd $STATS_USERNAME $STATS_PASSWORD

# Copiamos el archivo de configurcion de apache con la configuracion del acceso al directorio
cp ../conf/000-default-stats.conf /etc/apache2/sites-available/000-default.conf

# Reiniciamos el servidor apache
systemctl restart apache2