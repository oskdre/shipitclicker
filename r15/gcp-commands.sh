#!/bin/bash


# Podstaw własne dane.

docker tag <obraz_źródłowy> <nazwa_hosta>/<id_projektu>/<obraz>:<znacznik>

docker push <nazwa_hosta>/<id_projektu>/<obraz>:<znacznik>
