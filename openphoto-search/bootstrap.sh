#!/usr/bin/env bash

sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password rootpass'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password rootpass'
apt-get update
apt-get install -y apache2 php5 php5-mysql mysql-server-5.5 php5-curl
rm -rf /var/www
ln -fs /vagrant/web /var/www

mysql -uroot -prootpass -e "CREATE DATABASE openphotosearch"

cat > /etc/apache2/sites-available/default <<DELIM
<VirtualHost *:80>
    DocumentRoot "/var/www"

    <Directory /var/www>
        Options Indexes Includes FollowSymLinks -MultiViews
        AllowOverride All
        Order allow,deny
        Allow from all

        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php [QSA,L]    
    </Directory>

</VirtualHost>
DELIM

a2enmod rewrite
service apache2 restart

cd /vagrant
cp config/browserid.yml-dist config/browserid.yml
cp config/database.yml-dist config/database.yml
sed --in-place "s/password: \"\"/password: \"rootpass\"/" config/database.yml


php bin/search init
