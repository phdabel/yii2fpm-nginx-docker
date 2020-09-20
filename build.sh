#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

export HOST_APP_DIR=_host-volumes/app/
export CONTAINER_APP_DIR=/opt/app/

if [ ! "$(ls -A $HOST_APP_DIR)" ]
then
    echo -e "${RED}O diretório da aplicação está vazio.${NC}"
    cp .env-dist .env
    git clone https://github.com/yiisoft/yii2-app-advanced.git "${HOST_APP_DIR}"
fi

sudo docker-compose up -d --build
sudo docker-compose run --rm -w "$CONTAINER_APP_DIR" php composer install
cp php/environments/dev/common/config/main-local.php "${HOST_APP_DIR}"environments/dev/common/config/main-local.php
sudo docker-compose run --rm -w $CONTAINER_APP_DIR php ./init --env=Development --overwrite=All
sudo docker-compose run --rm -w $CONTAINER_APP_DIR php ./yii migrate --interactive=0
#sudo docker-compose run --rm -w "${CONTAINER_APP_DIR}" php php -d error_reporting="E_ALL ^ E_DEPRECATED" vendor/bin/phpunit frontend/tests --exclude db
