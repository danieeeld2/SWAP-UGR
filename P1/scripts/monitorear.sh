#!/bin/bash

# Obtener el ID y estado de todos los contenedores
containers_info=$(docker ps --format "{{.ID}}:{{.State}}")

# Iterar sobre cada contenedor
while IFS= read -r line; do
    container_id=$(echo "$line" | cut -d ':' -f1)
    container_state=$(echo "$line" | cut -d ':' -f2)
    
    echo "Container ID: $container_id"
    echo "State: $container_state"
    
    # Aquí puedes agregar lógica para tomar acciones basadas en el estado del contenedor
    # Por ejemplo, enviar una notificación si el estado no es 'running'
    
done <<< "$containers_info"
