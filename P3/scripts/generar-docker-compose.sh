#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number_of_instances>"
    exit 1
fi

num_instances=$1

cat <<EOF >docker-compose.yml
version: '3.0'

services:
EOF

for ((i=1; i<=$num_instances; i++)); do
    cat <<EOF >>docker-compose.yml
  web$i:
    image: danieeeld2-apache-image:p3
    container_name: web$i
    privileged: true
    command: apachectl -D FOREGROUND
    volumes:
      - ./web_danieeeld2:/var/www/html
      - ./P3-danieeeld2-certificados:/etc/apache2/ssl
      - ./P3-danieeeld2-apache/danieeeld2-apache-ssl.conf:/etc/apache2/sites-available/danieeeld2-apache-ssl.conf
    networks:
      red_web:
        ipv4_address: 192.168.10.$((i+1))
      red_servicios:
        ipv4_address: 192.168.20.$((i+1))

EOF
done

cat <<EOF >>docker-compose.yml
  balanceador-nginx:
    image: danieeeld2-nginx-image:p3
    container_name: balanceador-nginx
    ports:
      - "80:80"
      - "443:443"
    command: ['nginx', '-g', 'daemon off;']
    volumes:
      - ./P3-danieeeld2-nginx/danieeeld2-nginx-ssl.conf:/etc/nginx/nginx.conf
      - ./P3-danieeeld2-certificados:/etc/nginx/ssl
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
