#!/bin/bash

# Ejecutar el script de iptables
./danieeeld2-iptables-web.sh

# Ejecutar el comando principar del contenedor
exec "$@"