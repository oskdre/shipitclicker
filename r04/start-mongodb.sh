#!/bin/bash
# start-mongodb.sh
SERVICE=mongodb # name of the service

# Przypisz poniższej zmiennej nazwę istniejącego katalogu na hoście, na którym będą tworzone pliki bazy MongoDB.
MONGO_DATADIR="/c/db"
# Zatrzymanie kontenera MongoDB, usunięcie poprzedniego i pobranie nowego.
docker stop $SERVICE
docker rm $SERVICE
docker pull mongo:3.4

# Start!
#docker run \
#  --name $SERVICE \
#  -d \
#  --restart always \
#  -e TITLE=$SERVICE \
#  -p 27017:27017 \
#  -v "$MONGO_DATADIR":/data/db \
#  mongo:3.4

docker run \
  --name $SERVICE \
  -d \
  --restart always \
  -e TITLE=$SERVICE \
  --network chapter4 \
  -v "$MONGO_DATADIR":/data/db \
  mongo:3.4

