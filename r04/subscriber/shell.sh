#!/usr/bin/env bash

# shell.sh

# Ten skrypt uruchamia powłokę w zbudowanym kontenerze. Czasami trzeba użyć powłoki,
# aby zdiagnozować problem.

# Zatrzymanie wszystkich kontenerów.
#docker stop subscriber

# Uruchomienie kontenera i powłoki (/bin/bash).
docker run -it --rm --name subscriber dockerfordevelopers/subscriber /bin/bash || docker container exec -it subscriber /bin/bash
