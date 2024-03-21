#!/bin/bash

# Verificar que se haya proporcionado un script como argumento
if [ $# -eq 0 ]; then
    echo "Uso: $0 <script_a_ejecutar>"
    exit 1
fi

# Obtener el script a ejecutar
script="$1"

# Obtener IDs de los contenedores activos
containers=$(docker ps -q)

# Iterar sobre los IDs de los contenedores y ejecutar el script en cada uno (copiando la script en /tmp)
for container in $containers; do
    echo "Copiando el script $script al contenedor $container"
    docker cp "$script" "$container:/tmp/"
    echo "Ejecutando el script $script en el contenedor $container"
    docker exec "$container" sh -c "chmod +x /tmp/$(basename $script) && /tmp/$(basename $script)"
done
