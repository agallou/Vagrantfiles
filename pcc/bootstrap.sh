#!/usr/bin/env bash

apt-get update
apt-get install -y ruby1.9.3 make libsqlite3-dev libpq-dev

#pour nodejs
sudo apt-get install -y python-software-properties python g++ make
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install -y nodejs

#heroku
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh


gem install rails


cd /vagrant
bundle install
