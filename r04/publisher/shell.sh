#!/usr/bin/env bash

# shell.sh

# Ten skrypt uruchamia powłokę w zbudowanym kontenerze. Czasami trzeba użyć powłoki,
# aby zdiagnozować problem.

# Zatrzymanie wszystkich kontenerów.
./stop.sh

# Uruchomienie kontenera i powłoki (/bin/bash).
docker run -it --rm --name publisher dockerfordevelopers/publisher /bin/bash
