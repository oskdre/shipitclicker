# Utworzenie kontenera na podstawie obrazu dostępnego NodeJS v13 w serwisie Docker Hub.
FROM node:13

# Ustawienie strefy czasowej, aby znaczniki czasu plików były poprawne.
ENV TZ=America/Los_Angeles

# Dołączenie pakietów procps i telnet, dzięki czemu będzie można je stosować w wierszu poleceń.
RUN apt-get update -qq >/dev/null && apt-get install -y -qq curl procps telnet >/dev/null

# Utworzenie konta użytkownika, który będzie właścicielem plików w katalogu /home/app.
RUN useradd --user-group --create-home --shell /bin/false app

# Przygotowane plików i skopiowanie ich do katalogu /home/app.
ENV HOME=/usr/app
WORKDIR /home/app
COPY . /home/app
RUN yarn install

# Polecenie uruchamiające serwer. Dzięki tablicowej składni polecenia
# będzie można za pomocą klawiszy Ctrl-C zatrzymać serwer.
CMD  ["yarn", "start"]
