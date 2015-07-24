#!/bin/bash
#
#iptables script
#Author : ftlynx

#Clear all rule
iptables -t filter -F
iptables -t filter -X
iptables -t filter -Z
iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z

#Default policy
iptables -t filter -P INPUT ACCEPT
iptables -t filter -P OUTPUT ACCEPT
iptables -t filter -P FORWARD ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT
iptables -t nat -P PREROUTING ACCEPT

#LAN 
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A INPUT -i eth0 -j ACCEPT

# DDOS CC
################################################################
### peer ip connect number
#iptables -t filter -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 10 --connlimit-mask 32 -j DROP

### peer ip in N seconds request number
#iptables -t filter -A INPUT -p tcp --syn --dport 80 -m recent --name ippool --rcheck --rsource --seconds 60 --hitcount 20 -j DROP
#iptables -t filter -A INPUT -p tcp --syn --dport 80 -m recent --name ippool --set --rsource -j ACCEPT

### rate
#iptables -t filter -A INPUT -p tcp --syn --dport 80 -m limit --limit 500/s --limit-burst 800 -j ACCEPT
#iptables -t filter -A INPUT -p tcp --syn --dport 80 -j DROP 

################################################################

#Default base rule
iptables -t filter -A INPUT -f -j DROP
iptables -t filter -A INPUT -p all -m state --state INVALID -j DROP
iptables -t filter -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t filter -A INPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t filter -A INPUT -p icmp --icmp-type 8 -m limit --limit 2/s --limit-burst 3 -j ACCEPT
iptables -t filter -A INPUT -p icmp --icmp-type 8 -j DROP

#ssh
iptables -t filter -A INPUT -p tcp -m multiport --dport 22 -j ACCEPT

#zabbix
#iptables -t filter -A INPUT -p tcp -m multiport --dport 10051 -j ACCEPT

###############################################################
#Deny All
iptables -t filter -A INPUT -p tcp -j  DROP
iptables -t filter -A INPUT -p udp -j  DROP
