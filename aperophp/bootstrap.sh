#!/usr/bin/env bash

sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password rootpass'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password rootpass'
apt-get update
apt-get install -y apache2 php5 php5-mysql mysql-server-5.5
rm -rf /var/www
ln -fs /vagrant/web /var/www

mysql -uroot -prootpass -e "CREATE DATABASE aperophp"
/vagrant/app/console db:install
/vagrant/app/console db:load-fixtures

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

#pour génération des assets
sudo apt-get install -y python-software-properties python g++ make
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install -y nodejs

npm install -g jshint recess uglify-js
