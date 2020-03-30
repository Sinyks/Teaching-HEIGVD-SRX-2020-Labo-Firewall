#!/bin/bash

# Autoriser les ping depuis le lan -> DMZ
iptables -A FORWARD -s 192.168.100.0/24 -d 192.168.200.0/24 -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -s 192.168.200.0/24 -d 192.168.100.0/24 -p icmp --icmp-type 0 -j ACCEPT

# Autoriser les ping depuis le lan -> WAN

iptables -A FORWARD -s 192.168.100.0/24 -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -d 192.168.100.0/24 -p icmp --icmp-type 0 -j ACCEPT

# Autoriser les ping depuis le DMZ -> lan

iptables -A FORWARD -s 192.168.200.0/24 -d 192.168.100.0/24 -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD -s 192.168.100.0/24 -d 192.168.200.0/24 -p icmp --icmp-type 0 -j ACCEPT


# Autoriser les requetes DNS

# avec UDP
iptables -A FORWARD -s 192.168.100.0/24 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -d 192.168.100.0/24 -p udp --sport 53 -j ACCEPT

# avec TCP
iptables -A FORWARD -s 192.168.100.0/24 -p tcp --dport 53 -m conntrack --ctstate NEW
iptables -A FORWARD -d 192.168.100.0/24 -p tcp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT

iptables -A FORWARD -d 192.168.100.0/24 -p tcp --sport 53 -m conntrack --ctstate INVALID -j DROP

# Autoriser les les paquets HTTP/S

iptables -A FORWARD -s 192.168.100.0/24 -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 192.168.100.0/24 -p tcp --dport 8080 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

iptables -A FORWARD -d 192.168.100.0/24 -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -d 192.168.100.0/24 -p tcp --sport 8080 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -s 192.168.100.0/24 -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -d 192.168.100.0/24 -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -d 192.168.100.0/24 -p tcp --sport 80 -m conntrack --ctstate INVALID -j DROP
iptables -A FORWARD -d 192.168.100.0/24 -p tcp --sport 8080 -m conntrack --ctstate INVALID -j DROP
iptables -A FORWARD -d 192.168.100.0/24 -p tcp --sport 443 -m conntrack --ctstate INVALID -j DROP

# Autoriser les packets HTTP allant vers la DMZ

iptables -A FORWARD -d 192.168.200.3 -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 192.168.100.3 -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -d 192.168.100.3 -p tcp --sport 80 -m conntrack --ctstate INVALID -j DROP

# Autoriser les packets SSH pour la clientLan->DMZ et clientLan->firewall

iptables -A FORWARD -s 192.168.100.3 -d 192.168.200.3 -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 192.168.200.3 -d 192.168.100.3 -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -s 192.168.100.3 -d 192.168.100.2 -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -s 192.168.100.2 -d 192.168.100.3 -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -d 192.168.100.3 -p tcp --sport 22 -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -d 192.168.100.2 -p tcp --sport 22 -m conntrack --ctstate INVALID -j DROP


# Bloquer toute les autres communication Strategie ALL BLOCK

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
