<?php
print("<pre>");
// Usuń komentarze z poniższych dwóch wierszy, aby wyświetlać ostrzeżenia i błędy na stronie.
ini_set('display_errors', 1);
error_reporting(E_ALL);


// Nazwa pliku przechowującego wartość licznika. Funkcja sys_get_temp_dir () zwraca katalog z uprawnieniami do zapisu.
//$COUNTER_FILE = sys_get_temp_dir() . '/' . 'counter.txt';
$COUNTER_FILE = '/data/counter.txt';

// Wyświetlenie komunikatu.
print("Witaj, świecie $COUNTER_FILE\n");

// Odczytanie licznika.
$counter = file_get_contents($COUNTER_FILE);
if ($counter == false) {
  $counter = 0;
}

// Zwiększenie i zapisanie licznika.
$counter++;
file_put_contents($COUNTER_FILE, $counter);

// Wyświetlenie licznika, aby było wiadomo, że został zapisany.
print("Counterx: $counter\n");
