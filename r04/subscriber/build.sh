#!/bin/sh

# build.sh

# Za pomocą polecenia "docker build" budujemy kontener o nazwie "subscriber" w bieżącym katalogu.
# Plik Dockerfile opisujący budowany kontener znajduje się w bieżącym katalogu.

docker build -t dockerfordevelopers/subscriber .
