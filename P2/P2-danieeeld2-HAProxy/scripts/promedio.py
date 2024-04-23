import requests
import json
import re
import docker
from datetime import datetime

def obtener_promedio_cpu(container_id):
    # Obtener las métricas de CPU de un contenedor desde la API de cAdvisor
    url = "http://localhost:8080/api/v1.3/docker/" + container_id
    # Realizar la petición GET
    response = requests.get(url)
    
    if response.status_code == 200:
        json_data = response.text  # Obtener el contenido de la respuesta
        try:
            data = json.loads(json_data) # Convertir el contenido a un objeto JSON
            # Obtener las métricas de CPU del último minuto (últimos 30 registros)
            pattern = r'"cpu":{"usage":{"total":(\d+)'
            match = re.findall(pattern, json_data)
            cpu_metrics = [int(x) for x in match[-30:]]
            # Calcular el promedio de uso de CPU
            cpu_avg = sum(cpu_metrics) / len(cpu_metrics)
            return cpu_avg
        except json.JSONDecodeError as e:
            print("Error decoding JSON:", e)
    else:
        print("Error:", response.status_code)

def main():
   # Obtener todos los contenedores con nombre webX
    docker_client = docker.from_env()
    containers = docker_client.containers.list()
    web_containers = [container for container in containers if container.name.startswith("web")]
    cpu_general_avg = 0

    # Calcular el promedio de uso de CPU para cada contenedor
    for container in web_containers:
        container_id = container.id
        cpu_avg = obtener_promedio_cpu(container_id)
        if cpu_avg is not None:
            cpu_general_avg += cpu_avg
            # Escribir el promedio en un archivo
            container_name = container.name
            container_number = re.findall(r'\d+', container_name)[-1]
            file_path = f'estadisticas/web{container_number}.data'
            now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            with open(file_path, 'a') as f:
                f.write(f"{now}: {cpu_avg}\n")
            print(f"Promedio de uso de CPU para {container_name}: {cpu_avg}")  

    # Calcular el promedio general de uso de CPU
    cpu_general_avg /= len(web_containers)
    file_path = f'estadisticas/general.data'
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(file_path, 'a') as f:
        f.write(f"{now}: {cpu_general_avg}\n")
    print(f"Promedio general de uso de CPU: {cpu_general_avg}")

if __name__ == "__main__":
    main()


