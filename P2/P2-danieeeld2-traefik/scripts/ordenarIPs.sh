#!/bin/bash

# Eliminar las IPs asignadas a los contenedores en la subred red_web
for ((i=1; i<=8; i++)); do
    container_name="web$i"
    echo "Eliminando IP del contenedor $container_name en la subred red_web"
    docker network disconnect -f p2-danieeeld2-traefik_red_web $container_name
done

# Eliminar las IPs asignadas a los contenedores en la subred red_servicios
for ((i=1; i<=8; i++)); do
    container_name="web$i"
    echo "Eliminando IP del contenedor $container_name en la subred red_servicios"
    docker network disconnect -f p2-danieeeld2-traefik_red_servicios $container_name
done

# Asignar las IPs a los contenedores en la subred red_web
for ((i=1; i<=8; i++)); do
    container_name="web$i"
    container_ip="192.168.10.$((i+1))"
    echo "Asignando IP $container_ip al contenedor $container_name en la subred red_web"
    docker network connect --ip $container_ip p2-danieeeld2-traefik_red_web $container_name
done


# Asignar las IPs a los contenedores en la subred red_servicios
for ((i=1; i<=8; i++)); do
    container_name="web$i"
    container_ip="192.168.20.$((i+1))"
    echo "Asignando IP $container_ip al contenedor $container_name en la subred red_servicios"
    docker network connect --ip $container_ip p2-danieeeld2-traefik_red_servicios $container_name
done
