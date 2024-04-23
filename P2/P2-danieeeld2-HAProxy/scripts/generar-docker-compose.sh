#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number_of_instances>"
    exit 1
fi

num_instances=$1
echo "$num_instances" > instancias.env

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
      red_servicios:
        ipv4_address: 192.168.20.$((i+1))

EOF
done

cat <<EOF >>docker-compose.yml
  balanceador-haproxy:
    image: danieeeld2-haproxy-image:p2
    container_name: balanceador-haproxy
    ports:
      - "80:80"
      - "9000:9000"
    command: ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg", "-d"]
    volumes:
      - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg
    networks:
      red_web:
        ipv4_address: 192.168.10.50
    depends_on:
EOF

for ((i=1; i<=$num_instances; i++)); do
    echo "      - web$i" >>docker-compose.yml
done

cat <<EOF >>docker-compose.yml

  cAdvisor:
      image: gcr.io/cadvisor/cadvisor:v0.49.1
      container_name: cAdvisor
      privileged: true
      ports:
        - "8080:8080"
      volumes:
        - /:/rootfs:ro
        - /var/run:/var/run:ro
        - /sys:/sys:ro
        - /var/lib/docker/:/var/lib/docker:ro
      devices:
        - /dev/kmsg

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
