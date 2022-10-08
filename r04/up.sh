#!/bin/sh

./stop-all.sh
docker network create chapter4
./start-mosca.sh
./start-mongodb.sh
./start-redis.sh

###### SUBSKRYBENT
cd subscriber
./run.sh

###### NADAWCA
# Aby móc korzystać z interfejsu WWW nadawca musi udostępnić port 3000.
cd ../publisher
./run.sh
