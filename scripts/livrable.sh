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
