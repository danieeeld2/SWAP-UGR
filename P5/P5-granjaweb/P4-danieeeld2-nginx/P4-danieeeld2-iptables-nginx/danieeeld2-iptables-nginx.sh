#!/bin/bash

# Bloquear paquetes inválidos
iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

# Bloquear paquetes nuevos que no son SYN
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

# Bloquear valoresanormales de MSS
iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

# Bloquear paquete con flags erróneos
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP 
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

# Bloquear tráfico por cantidad de conexiones
iptables -A INPUT -p tcp -m connlimit --connlimit-above 10 -j REJECT --reject-with tcp-reset

# Bloquear tráfico por cantidad de conexiones por unidad de tiempo
iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 50/s --limit-burst 2 -j ACCEPT 
iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP

# Bloquear paquetes fragmentados
iptables -t mangle -A PREROUTING -f -j DROP

# Bloquear paquetes con dirección IP de origen spoofeada
iptables -t raw -A PREROUTING -p tcp -m tcp --syn -j ACCEPT
iptables -A INPUT -p tcp -m tcp -m conntrack --ctstate INVALID,UNTRACKED -j ACCEPT 
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP