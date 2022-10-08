#!/bin/bash


echo "Lista wszystkich woluminów:"
echo 

# Pętla przetwarzająca wszystkie woluminy danych.
for docker_volume_id in $(docker volume ls -q)
do
	echo "(Nie)nazwany wolumin: ${docker_volume_id}"
	
	# Uruchomienie kontenera w celu odczytanie wielkości woluminu.
	docker_volume_size=$(docker run --rm -t -v ${docker_volume_id}:/volume_data alpine sh -c "du -hs /volume_data | cut -f1" ) 

	echo "    Wielkość: ${docker_volume_size}"
	
	# Odczytanie liczby uruchomionych i zatrzymanych kontenerów wykorzystujących dany wolumin.
	num_related_containers=$(docker ps -a --filter=volume=${docker_volume_id} -q | wc -l)

   # Jeżeli liczba jest większa od zera, wyświetlamy informację o kontenerze i obrazie.
   # W przeciwnym wypadku wyświetlamy komunikat, że nie ma podłączonych kontenerów.
	if (( $num_related_containers > 0 )) 
	then
		echo "    Podłączone kontenery:"
		docker ps -a --filter=volume=${docker_volume_id} --format "{{.Names}} [{{.Image}}] ({{.Status}})" | while read containerDetails
		do
			echo "        ${containerDetails}"
		done
	else
		echo "    Brak podłączonych kontenerów."
	fi
	
	echo
done
