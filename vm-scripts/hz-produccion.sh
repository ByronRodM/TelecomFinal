#!/bin/bash
# HZ-PBX - Pasar la PBX a su direccion de produccion en la VLAN 30 (192.168.30.5)
# Ejecutar en la consola de la VM, como root, cuando la laptop ya este conectada al puerto de acceso VLAN 30.
set -e
# El agente de la carpeta compartida solo se usa en la preparacion
systemctl disable --now hz-agente 2>/dev/null || true
IF1=$(ls /sys/class/net | grep -v lo | sort | sed -n 1p)
cp /etc/network/interfaces /root/interfaces.antes-produccion
python3 - "$IF1" <<'PY'
import sys,re
i=sys.argv[1]; p='/etc/network/interfaces'; s=open(p).read()
s=re.sub(r'(allow-hotplug|auto) %s\niface %s inet dhcp\n?'%(i,i), '', s)
s+='''
# Produccion: VLAN 30 (Voz)
auto %s
iface %s inet static
    address 192.168.30.5/24
    gateway 192.168.30.1
    dns-nameservers 192.168.30.1 1.1.1.1
'''%(i,i)
open(p,'w').write(s)
PY
echo "nameserver 192.168.30.1" > /etc/resolv.conf; echo "nameserver 1.1.1.1" >> /etc/resolv.conf
ifdown "$IF1" 2>/dev/null || true; ip addr flush dev "$IF1"; ifup "$IF1"

# Zonas del firewall de FreePBX
fwconsole firewall trust 192.168.10.0/24      # Gestion: administracion
fwconsole firewall add local 192.168.20.0/24  # Administrativa: solo telefonia
fwconsole firewall add local 192.168.30.0/24  # Voz: solo telefonia
fwconsole firewall untrust 192.168.55.0/24 2>/dev/null || true   # red de preparacion
fwconsole firewall untrust 192.168.1.0/24 2>/dev/null || true    # Wi-Fi de la casa usado en la preparacion
fwconsole reload
ip -br addr
echo "Listo. Probar http://192.168.30.5 desde la VLAN 10."
