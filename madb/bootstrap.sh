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

    Alias /sf /vagrant/vendor/symfony/symfony1/data/web/sf

    <Directory "/var/www/web">
        AllowOverride All
        Allow from All
    </Directory>

    <Directory "/vagrant/vendor/symfony/symfony1/data/web/sf">
        AllowOverride all
        Allow from all
    </Directory>

</VirtualHost>
DELIM

#installation xhprof
apt-get install -y php5-dev make

wget http://pecl.php.net/get/xhprof-0.9.3.tgz
tar -zxf xhprof-0.9.3.tgz
cd xhprof-0.9.3/extension
phpize
./configure
make
make install

mkdir /tmp/xhprof
chmod 777 /tmp/xhprof

cat >> /etc/php5/apache2/php.ini << EOF
[xhprof]
extension=xhprof.so
  
xhprof.output_dir=/tmp/xhprof
EOF
#fin installation xhprof

a2enmod rewrite
service apache2 restart

cd /vagrant

if [ ! -f ./config/madbconf.yml ]
then
  cp ./config/madbconf.yml-dist ./config/madbconf.yml
fi

cp -f config/databases.yml-dist config/databases.yml
cp -f config/propel.ini-dist config/propel.ini

sed --in-place "s/%%host%%/localhost/" config/databases.yml
sed --in-place "s/%%host%%/localhost/" config/propel.ini

sed --in-place "s/%%database%%/madb/" config/databases.yml
sed --in-place "s/%%database%%/madb/" config/propel.ini

sed --in-place "s/%%user%%/root/" config/databases.yml
sed --in-place "s/%%user%%/root/" config/propel.ini

sed --in-place "s/%%pass%%//" config/databases.yml
sed --in-place "s/%%pass%%//" config/propel.ini

./symfony init --no-confirmation
./symfony insert-test-data --load-cli
