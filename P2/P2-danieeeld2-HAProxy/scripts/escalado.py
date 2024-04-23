import re
import docker
import subprocess

def get_last_cpu_usage(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()
        last_line = lines[-1]
        partes = last_line.split(':')
        last_value = partes[-1].strip()
    return last_value

def stop_highest_webX():
    # Inicializamos el cliente de docker y obtenemos los contendores webX
    client = docker.from_env()
    containers = client.containers.list()
    web_containers = [container for container in containers if 'web' in container.name]
    # Ordenamos los contenedores por el número de webX
    sorted_web_compose_containers = sorted(web_containers, key=lambda x: int(re.search(r'web(\d+)', x.name).group(1)))
    # Detenemos el contenedor con mayor número en caso de haber más de dos
    if len(sorted_web_compose_containers) <= 2:
        print('No se pueden detener más contenedores')
        return False
    else:
        container_to_stop = sorted_web_compose_containers[-1]
        numero_contenedor = int(container_to_stop.name.split("web")[-1])
        command = "./scripts/generar-docker-compose.sh " + str(numero_contenedor -1)
        subprocess.run(command, shell=True)
        container_to_stop.stop()
        command = "docker rm web" + str(numero_contenedor)
        print(f'Se ha detenido el contenedor {container_to_stop.name}')
        return True
    
def start_highest_webX():
    # Inicializamos el cliente de docker y obtenemos los contendores webX
    client = docker.from_env()
    containers = client.containers.list()
    web_containers = [container for container in containers if 'web' in container.name]
    # Ordenamos los contenedores por el número de webX
    sorted_web_compose_containers = sorted(web_containers, key=lambda x: int(re.search(r'web(\d+)', x.name).group(1)))
    last_container = sorted_web_compose_containers[-1]
    numero_contenedor = int(last_container.name.split("web")[-1])
    # Leemos el numero del .env
    with open('instancias.env', 'r') as archivo:
            valor = archivo.read().strip()  # Lee el contenido y elimina espacios en blanco al inicio y al final
            valor_numerico = int(valor)

    if numero_contenedor >= valor_numerico:
        command = "./scripts/generar-docker-compose.sh " + str(numero_contenedor +1)
        subprocess.run(command, shell=True)

    command = "docker-compose up -d web" + str(numero_contenedor+1)
    subprocess.run(command, shell=True)
    print(f'Se ha iniciado el contenedor web{numero_contenedor+1}')
    
def modify_haproxy_config(bool):
    haproxy_config_path = './haproxy.cfg'
    if bool:
        # Lee el contenido del archivo
        with open(haproxy_config_path, 'r') as file:
            lines = file.readlines()
        # Elimina la última línea cuya primera palabra empiece por "server web"
        for i in range(len(lines) - 1, -1, -1):
            if lines[i].strip().startswith('server web'):
                del lines[i]
                break
        # Escribe el contenido modificado de nuevo al archivo
        with open(haproxy_config_path, 'w') as file:
            file.writelines(lines)

        return True
    else:
        return False

def add_haproxy_config():
    haproxy_config_path = './haproxy.cfg'
    with open(haproxy_config_path, 'r') as f:
        lines = f.readlines()

    # Encontrar la última línea que empiece por "server web"
    for i in range(len(lines) - 1, -1, -1):
            if lines[i].strip().startswith('server web'):
                last_server_line_index = i
                break

    if last_server_line_index == -1:
        # No se encontraron líneas que empiecen por "server web"
        return False

    # Extraer el número del último servidor
    last_server = lines[last_server_line_index].split()[1]
    last_server_number = last_server.split("web")[-1]
    
    # Construir la nueva línea
    new_server_line = f"    server web{int(last_server_number) + 1} 192.168.10.{int(last_server_number) + 2}:80 maxconn 32 check\n"

    # Insertar la nueva línea debajo de la última línea que empiece por "server web"
    lines.insert(last_server_line_index + 1, new_server_line)

    with open(haproxy_config_path, 'w') as f:
        f.writelines(lines)
    
    return True


def restart_haproxy(bool):
    if bool:
        # Reiniciar el servicio de HAProxy
        command = "docker kill -s HUP balanceador-haproxy"
        subprocess.run(command, shell=True)        
    else:
        pass
    


def escalado(cpu_average,umbral):
    if cpu_average > umbral:
        start_highest_webX()
        bool = add_haproxy_config()
        restart_haproxy(bool)
        return True
    else:
        bool = stop_highest_webX()
        bool2 = modify_haproxy_config(bool)
        restart_haproxy(bool2)
        return False
    
def main():
    cpu = get_last_cpu_usage('estadisticas/general.data')
    umb = 100000000.0
    v = escalado(float(cpu), umb)
    if v:
        print('Escalando')
    else:
        print('Desescalando')


if __name__ == '__main__':
    main()