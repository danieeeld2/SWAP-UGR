#!/bin/bash

paquetes=("apache2" "htop" "net-tools" "lynx")

# Instalar paquetes necesarios
for paquete in "${paquetes[@]}"; do
    ./scripts/instalacion.sh "$paquete"
done
