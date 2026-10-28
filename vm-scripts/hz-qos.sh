#!/bin/bash
# HZ-PBX - Prueba de QoS (criterio F). Ejecutar en la VM como root.
#   bash hz-qos.sh servidor   -> arranca iperf3 en la PBX (puerto 5201)
#   bash hz-qos.sh sin        -> enlace de salida limitado a 4 Mbps, una sola cola (SIN QoS)
#   bash hz-qos.sh con        -> mismo límite, pero voz EF y señalización CS3 en cola prioritaria (CON QoS)
#   bash hz-qos.sh medir      -> mide jitter, pérdida y RTT de las llamadas activas durante 60 s
#   bash hz-qos.sh stats      -> estadísticas de la política (paquetes por clase)
#   bash hz-qos.sh quitar     -> elimina el límite y deja la red normal
IF=${IF:-$(ip route | awk '/default/{print $5; exit}')}
RATE=4mbit
case "$1" in
  servidor)
    pkill iperf3 2>/dev/null; iperf3 -s -D && echo "iperf3 escuchando en el puerto 5201 de $(hostname -I | awk '{print $1}')";;
  sin)
    tc qdisc del dev $IF root 2>/dev/null
    tc qdisc add dev $IF root tbf rate $RATE burst 32kbit latency 400ms
    echo "SIN QoS: salida de $IF limitada a $RATE, una sola cola FIFO";;
  con)
    tc qdisc del dev $IF root 2>/dev/null
    tc qdisc add dev $IF root handle 1: htb default 20
    tc class add dev $IF parent 1: classid 1:1 htb rate $RATE
    tc class add dev $IF parent 1:1 classid 1:10 htb rate 1mbit ceil $RATE prio 0      # voz y señalización
    tc class add dev $IF parent 1:1 classid 1:20 htb rate 3mbit ceil $RATE prio 1      # resto (mejor esfuerzo)
    tc qdisc add dev $IF parent 1:10 handle 10: pfifo limit 50
    tc qdisc add dev $IF parent 1:20 handle 20: pfifo limit 100
    tc filter add dev $IF parent 1: protocol ip prio 1 u32 match ip dsfield 0xb8 0xfc flowid 1:10   # EF (46) audio
    tc filter add dev $IF parent 1: protocol ip prio 2 u32 match ip dsfield 0x60 0xfc flowid 1:10   # CS3 (24) SIP
    echo "CON QoS: salida de $IF limitada a $RATE; EF y CS3 en la clase prioritaria 1:10";;
  medir)
    OUT=/root/qos-medicion-$(date +%H%M%S).txt
    for i in 1 2 3 4 5 6; do
      { echo "== $(date +%T)"; asterisk -rx "pjsip show channelstats"; } | tee -a $OUT
      sleep 10
    done
    echo "Guardado en $OUT";;
  stats)
    echo "== Interfaz $IF"; tc -s qdisc show dev $IF; echo; tc -s class show dev $IF;;
  quitar)
    tc qdisc del dev $IF root 2>/dev/null; pkill iperf3 2>/dev/null; echo "Límite eliminado en $IF";;
  *) sed -n '2,9p' "$0";;
esac
