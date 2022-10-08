#!/bin/bash
# start-mongodb.sh
SERVICE=mongodb # Nazwa usługi.

# Możesz zmienić poniższy katalog na inny, utworzony w hoście.
# W tym katalogu będą zapisywane i przetwarzane pliki bazy MongoDB.
#MONGO_DATADIR="$HOME/data"
# Zatrzymanie uruchomionego kontenera MongoDB, usunięcie go i pobranie nowej wersji.
docker stop $SERVICE
docker rm $SERVICE
docker pull mongo:3.4

# Uruchomienie kontenera.
docker run \
  --name $SERVICE \
  -d \
  --restart always \
  -e TITLE=$SERVICE \
  -p 27017:27017 \
  -v "$MONGO_DATADIR":/data/db \
  mongo:3.4

