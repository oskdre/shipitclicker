#!/usr/bin/env bash

# debug.sh

# Uruchomienie kontenera na pierwszym planie, aby widzieć wpisy dziennika.

HOSTIP=`ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}'`

docker run \
    --rm \
    --name="subscriber" \
    -e HOSTIP=$HOSTIP \
    dockerfordevelopers/subscriber
