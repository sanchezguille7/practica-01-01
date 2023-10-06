#!/bin/bash

#Muestra todos los comandos que se van ejecutadno
set -x

# Actualizamos los repositorios
apt update

# actualizamos los paquetes 
apt upgrade -y

#instalamos el servidor web Apache
#apt install apache2 -y


#INstalar  el sistema gestor de datos MySQL
#apt install mysql-server -y

#DB_USER=usuario
#DB_PASSWD=contraseña


#mysql -u $DB_USER -p$DB_PASSWD < ../sql/database.sql

#Instalamos php
sudo apt install php libapache2-mod-php php-mysql -y

# copiar el archivo de configuracion de apache
cp ../conf/000-default.conf /etc/apache2/sites-available

#Reiniciamos servicio
systemctl restart apache2