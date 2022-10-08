#!/bin/bash

# start-redis.sh

# To jest nazwa usługi. Jest wykorzystywana jako nazwa kontenera 
# i umieszczana w zmiennej środowiskowej TITLE kontenera.

SERVICE=redis

# Zatrzymanie bazy MongoDB o nazwie zapisanej w zmiennej SERVICE. 

echo "Zatrzymywanie usługi $SERVICE"
docker stop $SERVICE

# Usunięcie poprzedniego kontenera.

echo "Usuwanie starej usługi $SERVICE"
docker rm $SERVICE

# Odczytanie numeru najnowszej wersji bazy MongoDB.

echo "Pobieranie usługi $SERVICE"
docker pull $SERVICE

# Start!

docker run \
  --name $SERVICE \
  -d \
  --restart always \
  -e TITLE=$SERVICE \
  -p 6379:6379 \
  $SERVICE

