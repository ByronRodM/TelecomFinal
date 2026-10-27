#!/bin/bash
# Uso: bash /media/cdrom/hz.sh
# Copia los scripts a /root/hz-scripts, activa el agente de la carpeta compartida y prepara el sistema base.
D=$(dirname "$0")
mkdir -p /root/hz-scripts && cp "$D"/*.sh /root/hz-scripts/ && chmod +x /root/hz-scripts/*.sh
cp /root/hz-scripts/hz-produccion.sh /root/
bash /root/hz-scripts/hz-ga.sh
bash /root/hz-scripts/hz-base.sh
echo
echo "BASE LISTA."
