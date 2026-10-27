#!/bin/bash
# HZ-PBX - Paso 2: instalacion de FreePBX 17 con el instalador oficial de Sangoma
set -u
LOG=/root/hz-freepbx.log
exec > >(tee -a "$LOG") 2>&1
echo "=== $(date '+%F %T') Descargando instalador oficial FreePBX 17 ==="
cd /root
wget -O sng_freepbx_debian_install.sh \
  https://github.com/FreePBX/sng_freepbx_debian_install/raw/master/sng_freepbx_debian_install.sh
bash sng_freepbx_debian_install.sh
echo "=== $(date '+%F %T') Instalador termino (codigo $?) ==="
fwconsole -V 2>/dev/null
asterisk -V 2>/dev/null
