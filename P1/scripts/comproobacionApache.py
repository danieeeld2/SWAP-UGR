import docker
import requests

def get_container_ips(container_name):
    client = docker.from_env()
    container_ips = []
    containers = client.containers.list()
    for container in containers:
        if container_name in container.name:
            container_info = container.attrs
            network_settings = container_info["NetworkSettings"]
            for network, config in network_settings["Networks"].items():
                container_ips.append(config["IPAddress"])
    return container_ips

def check_apache(ip_address):
    url = f"http://{ip_address}/"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            print(f"Apache server is running at {ip_address}")
        else:
            print(f"Failed to access Apache server at {ip_address}")
    except requests.ConnectionError:
        print(f"Failed to connect to {ip_address}")

# Nombre del contenedor
container_name = "p1-web"

# Obtiene todas las direcciones IP de los contenedores con el nombre especificado
container_ips = get_container_ips(container_name)

# Verifica el servidor Apache en cada dirección IP obtenida
for ip_address in container_ips:
    check_apache(ip_address)
