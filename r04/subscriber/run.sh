#!/bin/sh

export SERVICE=subscriber
docker rm $SERVICE
./build.sh

echo "*************** Uruchamianie subskrybenta"
docker run \
  --name $SERVICE \
  -d \
  --restart always \
  -e TITLE=$SERVICE \
  --network chapter4 \
  dockerfordevelopers/$SERVICE
echo "*************** Subskrybent uruchomiony"
