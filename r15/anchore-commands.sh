#!/bin/bash

mkdir ~/aevolume
cd ~/aevolume

docker pull docker.io/anchore/anchore-engine:latest
docker create --name ae docker.io/anchore/anchore-engine:latest

# Opcja curl: curl https://docs.anchore.com/current/docs/engine/quickstart/docker-compose.yaml > docker-compose.yaml
docker cp ae:/docker-compose.yaml ~/aevolume/docker-compose.yaml
docker rm ae

docker-compose pull
docker-compose up -d

# Opcja kontenerowa: docker pull anchore/engine-cli:latest

# Instalacja Pythona
apt-get update
apt-get install python-pip
pip install anchorecli

# CLI kontenera: docker run  -it anchore/engine-cli


anchore-cli --u admin --p foobar --url http://localhost:8228/v1/ system status


anchore-cli --u admin --p foobar --url http://localhost:8228/v1/ image add alpine:latest
anchore-cli --u admin --p foobar --url http://localhost:8228/v1/ image wait alpine:latest
anchore-cli --u admin --p foobar --url http://localhost:8228/v1/ image vuln alpine:latest os

# Dodanie polis - uzyj swoich wartości.
# anchore-cli policy add /ścieżka/do/pliku.json
# anchore-cli policy activate <identyfikator_polisy>


anchore-cli --u admin --p foobar policy list


