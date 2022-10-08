#!/bin/sh

# build.sh

# Polecenie "docker build" tworzy kontener o nazwie "dockerfordevelopers/publisher"
# na podstawie pliku Dockerfile zapisanego w bieżącym katalogu.

docker build -t dockerfordevelopers/publisher .
