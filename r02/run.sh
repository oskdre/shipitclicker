#!/usr/bin/env bash

# run.sh

# Uruchomienie kontenera w tle systemu.
# Katalog /data jest montowany jako nazwany udział. Jego zawartość jest zachowywana.

docker run \
    --detach \
    --rm \
    -p8086:80 \
    -v name:/data \
    --name="chapter2" \
    chapter2
