# Creamos un archivo llamado "install_lamp.sh", dentro de este instalaremos Apache2, MySQL y PHP

Al ser en bash debemos poner esto al principio del archivo

    #!/bin/bash

  

Muestra todos los comandos que se van ejecutando

    set  -x

  

Actualizamos los repositorios

    apt  update

  

Actualizamos los paquetes

    #apt upgrade -y

  

# Instalamos el servidor web Apache

    apt install apache2 -y

# Instalar el sistema gestor de datos MySQL

    apt install mysql-server -y

Con estas variables llamamos a las que tenemos guardadas en un archivo ".env" que crearemos más adelante

    DB_USER=usuario
    DB_PASSWD=contraseña
    

Iniciaremos SQL con los credenciales anteriores

    mysql -u $DB_USER -p$DB_PASSWD < ../sql/database.sql

Instalamos php

    sudo  apt  install  php  libapache2-mod-php  php-mysql  -y

  

Copiar el archivo de configuración de apache

    cp  ../conf/000-default.conf  /etc/apache2/sites-available

  

Reiniciamos servicio

    systemctl  restart  apache2

Copiamos el archivo de prueba de php

    cp  ../php/index.php  /var/www/html

  

Modificamos el propietario

    chown  -R  www-data:www-data  /var/www/html

# ---------------------------------------------

# Ahora creamos otro archivo llamado "install_tools.sh" para descargar otros programas útiles.

Al ser en bash debemos poner esto al principio del archivo

    #!/bin/bash

  

Muestra todos los comandos que se van ejecutando

    set  -x

  

Se importan las variables de configuración

    source  .env

  

Actualizamos los repositorios

    apt  update

  

Actualizamos los paquetes

    apt  upgrade  -y

  

Configuramos las respuestas de la instalaion de phpMyAdmin

    echo  "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"  |  debconf-set-selections

    echo  "phpmyadmin phpmyadmin/dbconfig-install boolean true"  |  debconf-set-selections

    echo  "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD"  |  debconf-set-selections

    echo  "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD"  |  debconf-set-selections

  

Instalamos phpMyAdmin

    apt  install  phpmyadmin  php-mbstring  php-zip  php-gd  php-json  php-curl  -y

  

Creamos un usuario que tenga acceso a todas las bases de datos

    mysql  -u  root  <<<  "DROP USER IF EXISTS '$APP_USER'@'%'"
    mysql  -u  root  <<<  "CREATE USER '$APP_USER'@'%' IDENTIFIED BY '$APP_PASSWORD';"

    mysql  -u  root  <<<  "GRANT ALL PRIVILEGES ON *.* TO '$APP_USER'@'%';"

  

# Instalar adminer

Creamos directorio para adminer

    mkdir  -p  /var/www/html/adminer

  

Descargamos el archivo de adminer

    wget  https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php  -P  /var/www/html/adminer

  

Renombramos el nombre del archivo adminer

    mv  /var/www/html/adminer/adminer-4.8.1-mysql.php  /var/www/html/adminer/index.php

  

Modificamos l propietario del directorio /var/www/html

    chown  -R  www-data:www-data  /var/www/html

  

Descargamos GoAcces

    apt  install  goaccess  -y

  

# Iniciar GoAcces

Creamos un directorio para los informes HTML de GoAcces

    mkdir  -p  /var/www/html/stats

  

Ejecutamos GoAcces en segundo plano

    sudo  goaccess  /var/log/apache2/access.log  -o  /var/www/html/stats/index.html  --log-format=COMBINED  --real-time-html  --daemonize

  

Creamos el archivo .htpasswd

    htpasswd  -bc  /etc/apache2/.htpasswd  $STATS_USERNAME  $STATS_PASSWORD

  

Copiamos el archivo de configuración de apache con la configuración del acceso al directorio

    cp  ../conf/000-default-stats.conf  /etc/apache2/sites-available/000-default.conf

  

Reiniciamos el servidor apache

    systemctl  restart  apache2


# Creamos el archivo ".env" con las credenciales guardadas.

## **Configuramos las variables**

**Credenciales de PHPMyAdmin**

    PHPMYADMIN_APP_PASSWORD=123456
    APP_USER=Guille

    APP_PASSWORD=1234

**Credenciales del archivo .htpasswd**

    STATS_USERNAME=Guille

    STATS_PASSWORD=12345



# Crearemos otro archivo de php llamado "index.php"

    <?php
    
    phpinfo();
    
    ?>


# Tendremos que crear 2 archivos ".conf" 

**El primero seria: "000-default.conf":**

    ServerSignature Off
    ServerTokens Prod
    
    <VirtualHost *:80>
        #ServerName www.example.com
        DocumentRoot /var/www/html
        DirectoryIndex index.php index.html
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>




**El segundo seria: "000-default-stats.conf":**

    ServerSignature Off
    ServerTokens Prod
    
    <VirtualHost *:80>
        #ServerName www.example.com
        DocumentRoot /var/www/html
        DirectoryIndex index.php index.html
    
        <Directory "/var/www/html/stats">
              AuthType Basic
              AuthName "Acceso restringido"
              AuthBasicProvider file
              AuthUserFile "/etc/apache2/.htpasswd"
              Require valid-user
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>
