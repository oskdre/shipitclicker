#!/bin/bash

# start-mosca.sh

# To jest nazwa usługi. Jest wykorzystywana jako nazwa kontenera 
# i umieszczana w zmiennej środowiskowej TITLE kontenera.
SERVICE=mosca

# Zatrzymanie bazy MongoDB o nazwie zapisanej w zmiennej SERVICE. 
# Za chwilę zostanie pobrany nowy obraz z serwisu Docker Hub.

echo "Zatrzymywanie usługi $SERVICE"
docker stop $SERVICE

# Usunięcie poprzedniego kontenera.

echo "Usuwanie starej usługi $SERVICE"
docker rm $SERVICE

# Odczytanie numeru najnowszej wersji bazy MongoDB.

echo "Pobieranie usługi $SERVICE"
docker pull matteocollina/$SERVICE

# Start!
# Usługa Mosca/MQTT wykorzystuje standardowy port 1883.
# Mosca włącza MQTT poprzez WebSocket, dzięki czemu można publikować
# i subskrybować komunikaty w przeglądarce.
# Aby uzyskać dostęp za pomocą przeglądarki należy udostępnić port 80.

docker run \
  --name $SERVICE \
  -d \
  --restart always \
  -e TITLE=$SERVICE \
  -p 1883:1883 \
  -p 80:80 \
  -v /tmp/mosca:/db \
  matteocollina/mosca

