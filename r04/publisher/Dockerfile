# Utworzenie kontenera na podstawie obrazu dostępnego NodeJS v12 w serwisie Docker Hub.

FROM node:12-alpine
ENV TZ=America/Los_Angeles

# Utworzenie konta użytkownika, który będzie właścicielem plików w katalogu /home/app.
RUN adduser -S app

ENV HOME=/home/app
WORKDIR /home/app
COPY . /home/app
# Usuń poniższy wiersz, jeżeli korzystasz z woluminu modułu node_modules.
RUN yarn install

# Polecenie uruchamiające serwer. Dzięki tablicowej składni polecenia
# będzie można za pomocą klawiszy Ctrl-C zatrzymać serwer.
CMD  ["yarn", "start"]
