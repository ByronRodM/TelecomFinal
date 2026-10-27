#!/bin/bash
# Instala Guest Additions (el CD de Guest Additions debe estar insertado) y el
# "agente" que ejecuta scripts dejados en la carpeta compartida C:\Telecom\vmshare.
# SOLO PARA LA PREPARACION: hz-produccion.sh lo desactiva.
if ! lsmod | grep -q vboxsf; then
  mkdir -p /media/cdrom; mount /dev/sr0 /media/cdrom 2>/dev/null
  if [ -f /media/cdrom/VBoxLinuxAdditions.run ]; then
    apt-get -y install build-essential dkms linux-headers-amd64 bzip2
    sh /media/cdrom/VBoxLinuxAdditions.run --nox11
  else
    echo "AVISO: inserta el CD de Guest Additions (Devices > Insert Guest Additions CD image) y ejecuta: bash /root/hz-scripts/hz-ga.sh"
  fi
  umount /media/cdrom 2>/dev/null
fi
usermod -aG vboxsf root 2>/dev/null || true
cat > /usr/local/sbin/hz-agente <<'AG'
#!/bin/bash
S=/media/sf_vmshare
while true; do
  if [ -d $S/cmd ]; then
    mkdir -p $S/out $S/hecho
    for f in $S/cmd/*.sh; do
      [ -e "$f" ] || continue
      n=$(basename "$f" .sh)
      cp "$f" /tmp/agente-$n.sh && rm -f "$f"
      { echo "### $(date '+%F %T') $n"; bash /tmp/agente-$n.sh; echo "### EXIT $? $(date '+%T')"; } > $S/out/$n.out 2>&1
    done
  fi
  sleep 2
done
AG
chmod +x /usr/local/sbin/hz-agente
cat > /etc/systemd/system/hz-agente.service <<'SV'
[Unit]
Description=Agente de preparacion HZ (carpeta compartida)
After=vboxadd-service.service
[Service]
ExecStart=/usr/local/sbin/hz-agente
Restart=always
[Install]
WantedBy=multi-user.target
SV
systemctl daemon-reload; systemctl enable --now hz-agente
echo "Guest Additions y agente listos. Reiniciar con: reboot"
