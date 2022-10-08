FROM alpine 

RUN addgroup -S secureusers && adduser -S secureuser -G secureusers

# Wykonaj wszystkie polecenia roota, zanim zajdzie potrzeba zmiany użytkownika

USER secureuser
