#!/bin/bash
# HZ-PBX - Paso 1: preparacion del sistema base (Debian 12)
# Grupo 2 - Telecomunicaciones I - UMG Jutiapa
set -u
LOG=/root/hz-base.log
exec > >(tee -a "$LOG") 2>&1
echo "=== $(date '+%F %T') Inicio preparacion base ==="

timedatectl set-timezone America/Guatemala
hostnamectl set-hostname hz-pbx

# Interfaz 2 (solo-anfitrion de VirtualBox): IP fija para administrar desde la laptop
IF2=$(ls /sys/class/net | grep -v lo | sort | sed -n 2p)
if [ -n "$IF2" ] && ! grep -q "$IF2" /etc/network/interfaces; then
cat >> /etc/network/interfaces <<NET

# Administracion local desde la laptop (VirtualBox solo-anfitrion)
allow-hotplug $IF2
iface $IF2 inet static
    address 192.168.56.10/24
NET
ifup "$IF2" || true
fi

export DEBIAN_FRONTEND=noninteractive

# La instalacion desatendida trae escritorio grafico; un servidor PBX no lo necesita
systemctl set-default multi-user.target
for p in $(dpkg-query -W -f='${Package}\n' 'task-*desktop*' gdm3 gnome-core gnome-shell 2>/dev/null); do
    apt-get -y purge "$p" || true
done
apt-get -y autoremove --purge
apt-get update
apt-get -y full-upgrade
apt-get -y install curl wget sudo htop tcpdump sngrep net-tools dnsutils \
    chrony unattended-upgrades openssh-server iperf3 rsync \
    build-essential dkms linux-headers-amd64 bzip2
systemctl enable --now chrony ssh

echo "=== $(date '+%F %T') Base lista ==="
ip -br addr
