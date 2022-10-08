#!/usr/bin/env bash

# debug.sh

# Uruchomienie kontenera na pierwszym planie. Dzięki temu widoczne są wyświetlane informacje.

docker run \
    --rm \
    -p8086:80 \
    --name="chapter2" \
    -v `pwd`:/home/app \
    chapter2
