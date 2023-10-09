#!/bin/bash

#Muestra todos los comandos que se van ejecutadno
set -x

# Configuramos las variables
#-----------------------------------------------------
PHPMYADMIN_APP_PASSWORD=123456
APP_USER=Guille
APP_PASSWORD=1234
#-----------------------------------------------------

# Actualizamos los repositorios
apt update

# actualizamos los paquetes 
#apt upgrade -y

# Configuramos las respuestas de la instalaion de phpMyAdmin
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