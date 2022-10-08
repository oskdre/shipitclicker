#!/bin/sh

# build.sh
# Budowanie kontenerów nadawcy i subskrybenta i instalowanie w każdym z nich modułu node_modules.

docker-compose build --force-rm --no-cache
docker-compose run publisher yarn install
docker-compose run subscriber yarn install
