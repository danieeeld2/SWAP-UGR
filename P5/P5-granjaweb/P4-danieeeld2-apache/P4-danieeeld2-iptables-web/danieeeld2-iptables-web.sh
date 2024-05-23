#!/bin/bash

# Denegación implícita de todo el tráfico
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Manejar el tráco de red entrante basado en el estado de las conexiones
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Manejar el tráfico de red saliente basado en el estado de las conexiones
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Manejar tráco de red de la misma máquina
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Manejar tráfico HTTP y HTTPS
iptables -A INPUT -p tcp -s 192.168.10.50 --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -s 192.168.10.50 --dport 443 -j ACCEPT