#!/usr/bin/env bash

# shell.sh

# Ten skrypt uruchamia powłokę kontenera. Czasami jest ona potrzebna do
# diagnozowania problemów.
# Poniższe polecenie zatrzymuje uruchomiony kontener.
./stop.sh

# Uruchomienie kontenera z powłoką (/bin/bash).
docker run -it --rm --name chapter2 chapter2 /bin/bash
