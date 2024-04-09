import docker
from colorama import init, Fore

# Inicializa colorama
init()

def check_connectivity(container_name_prefix, subnets):
    client = docker.from_env()
    containers = client.containers.list()
    
    containers_with_no_connectivity = []
    
    for container in containers:
        if container.name.startswith(container_name_prefix):
            container_info = container.attrs
            container_networks = container_info['NetworkSettings']['Networks']
            
            connected_subnets = []
            for network in container_networks:
                if container_networks[network]['IPAddress']:
                    connected_subnets.append(network)

            missing_subnets = [subnet for subnet in subnets if subnet not in connected_subnets]
            if missing_subnets:
                containers_with_no_connectivity.append((container.name, missing_subnets))

    if containers_with_no_connectivity:
        for container_name, missing_subnets in containers_with_no_connectivity:
            print(f"{Fore.RED}Container '{container_name}' is missing connectivity to subnet(s): {', '.join(missing_subnets)}{Fore.RESET}")
    else:
        print("Todos los contenedores están correctamente conectados a las subredes especificadas.")

# Nombre del prefijo de los contenedores que deseas comprobar
container_prefix = "web"

# Subredes que se deben verificar
subnets_to_check = ["p2-danieeeld2-haproxy_red_web", "p2-danieeeld2-haproxy_red_servicios"]

check_connectivity(container_prefix, subnets_to_check)
