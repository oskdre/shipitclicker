#!/bin/bash

# Aby poprawnie skonfigurować Apache trzeba pozyskać zmienne środowiskowe.
. /etc/apache2/envvars

echo "entrypoint.sh"
ls -l
ls -ldg /data
ls -l /data/

# W niektórych powłokach użytkownik może kliknąć adres URL w poniższym wierszu.
echo && echo && echo "----> Wpisz w przeglądarce adres http://localhost:8086/~app/index.php" && echo && echo

# Uruchom Apache na pierwszym planie (nie jako demona).
exec apache2 -D FOREGROUND

