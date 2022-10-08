# Utworzenie kontenera na podstawie obrazu dostępnego w serwisie Docker Hub.
FROM debian:10

# Ustawienie strefy czasowej, aby znaczniki czasu plików były poprawne.
ENV TZ=America/Los_Angeles

# Instalacja Apache i PHP 7.3.
# Dołączenie pakietów procps i telnet, aby można było z nich korzystać w pliku shell.sh.
RUN apt-get update -qq >/dev/null && apt-get install -y -qq procps telnet apache2 php7.3 -qq >/dev/null

# Utworzenie konta użytkownika, który będzie właścicielem plików w katalogu /home/app.
RUN useradd --user-group --create-home --shell /bin/false app

# Przygotowane plików i skopiowanie ich do katalogu /home/app.
ENV HOME=/usr/app
WORKDIR /home/app
COPY . /home/app

# Tworzymy katalog /data, w którym program PHP będzie zapisywał swój stan.
RUN mkdir /data && chown -R app /data && chmod 777 /data

# Tworzymy niestandardowy plik konfiguracyjny, aby program PHP mógł korzystać z katalogu użytkownika.
COPY php.conf /etc/apache2/mods-available/php7.3.conf

# Włączenie modułów userdir i php.
RUN a2enmod userdir && a2enmod php7.3

# Wywołanie skryptu uruchamiającego serwer. Dzięki tablicowej składni polecenia
# będzie można za pomocą klawiszy Ctrl-C zatrzymać serwer.
CMD  ["./entrypoint.sh"]
