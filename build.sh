#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

export HOST_APP_DIR=_host-volumes/app/
export CONTAINER_APP_DIR=/opt/app/
export CERTS_PATH=php/etc/nginx/certs/

if [ ! "$(ls -A $HOST_APP_DIR)" ]
then
    echo -e "${RED}O diretório da aplicação está vazio.${NC}"
    cp .env-dist .env
    git clone https://github.com/yiisoft/yii2-app-advanced.git "${HOST_APP_DIR}"
fi

if [ ! "$(ls -A $CERTS_PATH)" ]
then

# generating ssl key and certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
   -subj "/C=BR/ST=Rio Grande do Sul/L=Porto Alegre/O=Organization/OU=Unit/CN=localhost" \
   -keyout "$CERTS_PATH"dev-app.key -out "$CERTS_PATH"dev-app.crt

# generating DH key
sudo openssl dhparam -out "$CERTS_PATH"dhparam.pem 2048
fi

sudo docker-compose up -d --build
sudo docker-compose run --rm -w "$CONTAINER_APP_DIR" php composer install
cp php/environments/dev/common/config/main-local.php "${HOST_APP_DIR}"environments/dev/common/config/main-local.php
sudo docker-compose run --rm -w $CONTAINER_APP_DIR php ./init --env=Development --overwrite=All
sudo docker-compose run --rm -w $CONTAINER_APP_DIR php ./yii migrate --interactive=0
#sudo docker-compose run --rm -w "${CONTAINER_APP_DIR}" php php -d error_reporting="E_ALL ^ E_DEPRECATED" vendor/bin/phpunit frontend/tests --exclude db
