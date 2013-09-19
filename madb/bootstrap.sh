#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive 
apt-get update
apt-get install -y apache2 php5 php5-mysql mysql-server-5.5 unzip git
rm -rf /var/www
ln -fs /vagrant/web /var/www

mysql -uroot -e "CREATE DATABASE madb"
cd /var/www

cat > /etc/apache2/sites-available/default <<DELIM
<VirtualHost *:80>
    DocumentRoot "/var/www"
    DirectoryIndex index.php

    Alias /sf /var/www/lib/vendor/symfony/data/web/sf

    <Directory "/var/www/web">
        AllowOverride All
        Allow from All
    </Directory>

    <Directory "/var/www//lib/vendor/symfony/data/web/sf">
        AllowOverride all
        Allow from all
    </Directory>

</VirtualHost>
DELIM

a2enmod rewrite
service apache2 restart

cd /vagrant

sh ./init_submodules.sh

if [ ! -f ./config/madbconf.yml ]
then
  cp ./config/madbconf.yml-dist ./config/madbconf.yml
fi

./symfony init --no-confirmation
./symfony insert-test-data --load-cli
