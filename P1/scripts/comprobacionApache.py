import docker
import requests
from colorama import Fore, Style

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
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            server_header = response.headers.get('Server')
            if server_header and 'Apache' in server_header:
                print(f"{Fore.GREEN}Apache server is running at {ip_address}{Style.RESET_ALL}")
            else:
                print(f"{Fore.BLUE}Server at {ip_address} is not Apache{Style.RESET_ALL}")
        else:
            print(f"{Fore.RED}Failed to access Apache server at {ip_address}{Style.RESET_ALL}")
    except requests.ConnectionError:
        print(f"{Fore.RED}Failed to connect to {ip_address}{Style.RESET_ALL}")

# Nombre del contenedor
container_name = "p1-web"

# Obtiene todas las direcciones IP de los contenedores con el nombre especificado
container_ips = get_container_ips(container_name)

# Verifica el servidor Apache en cada dirección IP obtenida
for ip_address in container_ips:
    check_apache(ip_address)
