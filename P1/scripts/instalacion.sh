#!/bin/bash

# Verificar si se proporcionó un argumento
if [ $# -eq 0 ]; then
    echo "Error: Debes proporcionar el nombre de la herramienta a instalar."
    echo "Uso: $0 <nombre_herramienta>"
    exit 1
fi

# Nombre de la herramienta a instalar
herramienta=$1

# Lista de contenedores que siguen el patrón p1-web-
contenedores=$(docker ps --format '{{.Names}}' | grep 'p1-web-')

# Función para instalar la herramienta en un contenedor
instalar_herramienta_contenedor() {
    echo "Instalando $herramienta en el contenedor $1..."
    docker exec $1 apt-get update
    docker exec $1 apt-get install -y $herramienta
}

# Iterar sobre los contenedores y ejecutar la función de instalación
for contenedor in $contenedores; do
    instalar_herramienta_contenedor $contenedor
done
