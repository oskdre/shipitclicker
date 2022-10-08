# Utworzenie kontenera na podstawie obrazu NodeJS v13 dostępnego w serwisie Docker Hub.
FROM node:13

# Ustawienie strefy czasowej, aby znaczniki czasu plików były poprawne.
ENV TZ=America/Los_Angeles

# Instalacja pakietów apache i php 7.3.
# Dołączenie pakietów procps i telnet, dzięki czemu będzie można je stosować w wierszu poleceń.
RUN apt-get update -qq >/dev/null && apt-get install -y -qq curl procps telnet >/dev/null

# Utworzenie konta użytkownika, który będzie właścicielem plików w katalogu /home/app.
RUN useradd --user-group --create-home --shell /bin/false app

# Przygotowane plików i skopiowanie ich do katalogu /home/app.
ENV HOME=/usr/app
WORKDIR /home/app
COPY . /home/app

# Instalacja pakietów NodeJS (opisanych w pliku package.json).
RUN yarn install

# Polecenie uruchamiające serwer. Dzięki tablicowej składni polecenia
# będzie można za pomocą klawiszy Ctrl-C zatrzymać serwer.
CMD  ["yarn", "start"]
