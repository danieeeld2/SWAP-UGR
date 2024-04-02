#!/bin/bash

# Crear la carpeta de logs si no existe
mkdir -p logs

# Obtener lista de contenedores que coinciden con el patrón p1-web-
contenedores=$(docker ps --format '{{.Names}}' | grep 'p1-web-')

# Función para verificar el estado de Apache dentro del contenedor
verificar_estado_apache() {
    echo -e "\e[34mEstado de Apache en el contenedor $1:\e[0m"
    docker exec $1 apache2ctl status
}

# Función para verificar el uso de recursos del contenedor
verificar_recursos_contenedor() {
    echo -e "\e[34mUso de recursos en el contenedor $1:\e[0m"
    docker exec $1 top -b -n 1
}

# Función para verificar las conexiones de red del contenedor
verificar_conexiones_red() {
    echo -e "\e[34mConexiones de red en el contenedor $1:\e[0m"
    docker exec $1 netstat -tuln
}

# Obtener la hora actual
hora_actual=$(date "+%Y-%m-%d %H:%M:%S")

# Iterar sobre los contenedores y ejecutar las funciones de verificación
for contenedor in $contenedores; do
    echo -e "\e[33m$(printf '%80s\n' | tr ' ' '-')\e[0m" >> logs/serverStatus-${contenedor##*-}.log
    echo -e "\e[33m$hora_actual\e[0m"  >> logs/serverStatus-${contenedor##*-}.log
    echo -e "\e[33m$(printf '%80s\n' | tr ' ' '-')\e[0m" >> logs/serverStatus-${contenedor##*-}.log
    verificar_estado_apache $contenedor >> logs/serverStatus-${contenedor##*-}.log
    verificar_recursos_contenedor $contenedor >> logs/serverStatus-${contenedor##*-}.log
    verificar_conexiones_red $contenedor >> logs/serverStatus-${contenedor##*-}.log
done
