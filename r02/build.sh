#!/bin/sh

# build.sh

# Polecenie "docker build" buduje w bieżącym katalogu kontener o nazwie "chapter2".
# W bieżącym katalogu znajduje się plik Dockerfile opisujący proces budowania kontenera.

docker build -t chapter2 .
