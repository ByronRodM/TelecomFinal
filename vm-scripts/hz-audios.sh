#!/bin/bash
# HZ-PBX - Grabaciones del IVR en espanol (voz sintetica Piper, uso offline) y musica en espera propia.
# Las grabaciones finales deben reemplazarse por la voz de un integrante.
set -e
LOG=/root/hz-audios.log
exec > >(tee -a "$LOG") 2>&1
echo "=== $(date '+%F %T') Generando audios ==="
W=/root/piper-tts; mkdir -p $W; cd $W
if [ ! -x piper/piper ]; then
  wget -q https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_x86_64.tar.gz
  tar xzf piper_linux_x86_64.tar.gz
fi
V=es_MX-claude-high
for e in onnx onnx.json; do
  [ -s $V.$e ] || wget -q -O $V.$e "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/es/es_MX/claude/high/$V.$e"
done

OUT=/var/lib/asterisk/sounds/en/custom
mkdir -p $OUT
hablar() { # nombre "texto"
  echo "$2" | ./piper/piper --model $V.onnx --length_scale 1.08 --sentence_silence 0.45 --output_file /tmp/$1.wav
  sox /tmp/$1.wav -r 8000 -c 1 -b 16 $OUT/$1.wav norm -3 pad 0.3 0.2
  echo "  $OUT/$1.wav"
}
hablar hz-bienvenida "Gracias por llamar al Centro Médico Horizonte. Para Recepción y citas, marque uno. Para Consulta Externa, marque dos. Para Enfermería y Emergencias, marque tres. Para Administración y Contabilidad, marque cuatro. Si desea hablar con la operadora, marque cero, o espere en la línea."
hablar hz-fuera-horario "Gracias por llamar al Centro Médico Horizonte. En este momento estamos fuera del horario de atención, que es de lunes a viernes, de siete de la mañana a siete de la noche, y los sábados de siete de la mañana a doce del mediodía. Si se trata de una emergencia, marque tres. Para dejar un mensaje a Recepción, marque uno."
hablar hz-opcion-invalida "La opción que marcó no es válida. Por favor, intente de nuevo."
hablar hz-sin-respuesta "No recibimos ninguna opción. Le repetimos el menú."
hablar hz-transfiriendo "Le comunicamos con la operadora. Un momento, por favor."

# Musica en espera original (generada con sox, sin derechos de autor)
MOH=/var/lib/asterisk/moh/horizonte; mkdir -p $MOH; cd /tmp
i=0
for acorde in "C4 E4 G4 C5" "A3 C4 E4 A4" "F3 A3 C4 F4" "G3 B3 D4 G4" "C4 E4 G4 C5" "E3 G3 B3 E4" "F3 A3 C4 F4" "G3 B3 D4 G4"; do
  for n in $acorde $acorde; do
    i=$((i+1)); sox -n -r 8000 -c 1 -b 16 n$(printf %03d $i).wav synth 0.42 pluck $n fade 0 0.42 0.3 vol 0.5
  done
done
sox n*.wav $MOH/horizonte-ciclo.wav repeat 3 reverb 40 norm -6
rm -f n*.wav
chown -R asterisk:asterisk $OUT $MOH
ls -la $OUT $MOH
echo "=== Audios listos ==="
