#!/bin/bash

#Muestra todos los comandos que se van ejecutadno
set -x

# Actualizamos los repositorios
#apt update

# actualizamos los paquetes 
#apt upgrade -y

#instalamos el servidor web Apache
apt install apache2 -y


#INstalar  el sistema gestor de datos MySQL
apt install mysql-server -y