#!/bin/bash
# HZ-PBX - Respaldo para el comprimido de anexos, SIN contraseñas.
# Ejecutar en la VM como root cuando el proyecto esté terminado:  bash hz-respaldo-anexo.sh
set -e
F=hz-pbx-respaldo-anexo-$(date +%Y%m%d-%H%M)
D=/root/respaldos/$F; mkdir -p $D
# 1. Configuración de Asterisk con secretos ocultos
cp -r /etc/asterisk $D/asterisk
find $D/asterisk -type f -exec sed -i -E \
  -e 's/^(\s*(password|secret|md5_cred|bindpw|sippasswd)\s*=>?\s*).*/\1***OCULTO***/I' \
  -e 's/^([0-9]{3,6}\s*=>?\s*)[0-9]+,/\1******,/' {} +
# 2. Base de datos de FreePBX con secretos ocultos
mysqldump --single-transaction --skip-extended-insert asterisk > $D/asterisk.sql
python3 - "$D/asterisk.sql" <<'PY'
import re,sys
p=sys.argv[1]; s=open(p,encoding='utf-8',errors='replace').read()
s=re.sub(r"('(secret|password|vmpwd|sippasswd|outbound_auth_password|auth_password)',')[^']*'", r"\1***OCULTO***'", s)
s=re.sub(r"\b[0-9a-f]{40}\b", "***OCULTO***", s)   # hashes sha1 de usuarios del panel
open(p,'w',encoding='utf-8').write(s)
PY
# 3. Verificación: ninguna contraseña conocida debe aparecer
FALLA=0
if [ -f /root/CREDENCIALES-HZ.txt ]; then
  for s in $(awk -F' \\| ' 'NR>2{print $3; print $4}' /root/CREDENCIALES-HZ.txt | grep -v '^-$'); do
    grep -rqF -- "$s" $D && { echo "ATENCION: quedó un secreto sin ocultar"; FALLA=1; }
  done
fi
cd /root/respaldos && tar czf $F.tgz $F && rm -rf $F
[ $FALLA = 0 ] && echo "Listo y verificado: /root/respaldos/$F.tgz" || echo "Revisar antes de entregar: /root/respaldos/$F.tgz"
