#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number_of_instances>"
    exit 1
fi

num_instances=$1

cat <<EOF >docker-compose.yml
version: '2.0'

services:
EOF

for ((i=1; i<=$num_instances; i++)); do
    cat <<EOF >>docker-compose.yml
  web$i:
    image: danieeeld2-apache-image:p2
    container_name: web$i
    privileged: true
    volumes:
      - ./web_danieeeld2:/var/www/html
    networks:
      red_web:
        ipv4_address: 192.168.10.$((i+1))
        aliases:
            - web$i
      red_servicios:
        ipv4_address: 192.168.20.$((i+1))

EOF
done

cat <<EOF >>docker-compose.yml
  balanceador-traefik:
    image: traefik:latest
    container_name: balanceador-traefik
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - ./traefik.yml:/etc/traefik/traefik.yml
      - ./dynamic.yml:/etc/traefik/conf.d/dynamic.yml
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      red_web:
        ipv4_address: 192.168.10.50
    depends_on:
EOF

for ((i=1; i<=$num_instances; i++)); do
    echo "      - web$i" >>docker-compose.yml
done

cat <<EOF >>docker-compose.yml

networks:
  red_web:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.10.0/24
  red_servicios:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.20.0/24
EOF
