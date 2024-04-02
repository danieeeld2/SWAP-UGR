#!/bin/bash

# Función para obtener la fecha y hora actual formateada
get_timestamp() {
    date +"%Y-%m-%d %T"
}

# Pedir el número de contenedor a monitorear
read -p "Introduce el número del contenedor a monitorear (X en p1-web-X): " container_number
container_name="p1-web-$container_number"

# Verificar si el contenedor existe
docker inspect "$container_name" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "El contenedor $container_name no existe."
    exit 1
fi

# Pedir la acción a realizar
echo "Selecciona la acción a realizar:"
select action in "Estadísticas de CPU y memoria" "Conexiones entrantes" "Tráfico HTTP"; do
    case $action in
        "Estadísticas de CPU y memoria" )
            action_command="docker stats --no-stream $container_name"
            action_option="Estadísticas de CPU y memoria"
            break
            ;;
        "Conexiones entrantes" )
            action_command="sysdig -pc -A -s 2000 -z -c echo_fds 'evt.type=accept and container.name=$container_name'"
            action_option="Conexiones entrantes"
            break
            ;;
        "Tráfico HTTP" )
            number=$((container_number + 1))
            action_command="sysdig -s 2000 -A -c echo_fds fd.sip=192.168.20.$number or fd.sip=192.168.10.$number and fd.port=80"
            action_option="Tráfico HTTP"
            break
            ;;
        * ) echo "Por favor, selecciona una opción válida.";;
    esac
done

# Si la acción es estadísticas de CPU y memoria, no solicitar el tiempo máximo de captura
if [ "$action_option" == "Estadísticas de CPU y memoria" ]; then
    max_time=0
else
    # Pedir el tiempo máximo antes de abortar
    read -p "Introduce el tiempo máximo de captura (en segundos): " max_time
fi

# Pedir si se desea almacenar los datos en un archivo de logs
read -p "¿Deseas almacenar los datos en un archivo de logs? (s/n): " store_logs

# Crear la carpeta de logs si es necesario
if [ "$store_logs" = "s" ]; then
    mkdir -p ./logs
fi

# Ejecutar la acción
if [ "$store_logs" = "s" ]; then
    # Obtener el nombre del archivo de logs
    log_file="./logs/${container_name}.log"

    # Ejecutar la acción y almacenar los resultados en el archivo de logs
    echo -e "\e[33m$(printf '%80s\n' | tr ' ' '-')\e[0m" >> "$log_file"
    echo -e "\e[33m$(get_timestamp) - Opciones: $action_option\e[0m" >> "$log_file"
    echo -e "\e[33m$(printf '%80s\n' | tr ' ' '-')\e[0m" >> "$log_file"

    $action_command >> "$log_file" &
else
    $action_command 
fi

# Esperar al tiempo máximo antes de abortar si no es 0 (caso de estadísticas de CPU y memoria)
if [ $max_time -ne 0 ]; then
    sleep $max_time

    # Finalizar la ejecución de la acción
    kill $!
fi

echo "Acción finalizada."
