#!/usr/bin/env bash

# persist.sh

# Uruchomienie kontenera na pierwszym planie. Dzięki temu są widoczne wyświetlane informacje.
# W kontenerze jest tworzony anonimowy udział /data, aby stan licznika był zachowywany po każdym
# zatrzymaniu i uruchomieniu kontenera.

docker run \
    --rm \
    -p8086:80 \
    --name="chapter2" \
    -v `pwd`:/home/app \
    -v name:/data \
    chapter2
