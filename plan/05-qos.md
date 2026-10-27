# 05 · Clasificación de tráfico y QoS (criterio F)

## Clases de tráfico

| Clase | Qué incluye | Identificación | DSCP | Tratamiento |
|---|---|---|---|---|
| 1. Medios de voz | Audio RTP de llamadas | UDP 10000-20000 desde/hacia 192.168.30.5 | **EF (46)** | Cola de prioridad estricta |
| 2. Señalización | SIP de teléfonos y troncal | UDP 5060 (extensiones), 5160 (troncal) | **CS3 (24)** | Prioridad alta, después de EF |
| 3. Datos críticos y gestión | Administración de equipos, controladora Omada, web de la PBX | Tráfico de la VLAN 10 | AF21 (18) | Prioridad media |
| 4. Mejor esfuerzo | Navegación y datos del personal administrativo | VLAN 20, resto del tráfico | DF (0) | Cola normal |
| 5. Invitados | Internet para visitas | VLAN 40 | CS1 (8) | Prioridad mínima y límite fijo de ancho de banda |

**Por qué CS3 para la señalización.** RFC 4594 sugiere CS5 para señalización, pero la práctica más extendida en telefonía IP (y el valor por defecto de Asterisk y de la mayoría de teléfonos) es CS3. Elegimos CS3 para que la PBX, los softphones y la red usen el mismo valor sin reescribir marcas, y porque la señalización ocupa muy poco ancho de banda: lo importante es que no compita con el audio (EF) y que quede por encima de los datos.

## Dónde se marca y dónde se prioriza

Asterisk marca sus propios paquetes: en FreePBX (Settings → Asterisk SIP Settings) el audio sale con `tos_audio = ef` y la señalización con `tos_sip = cs3`. Como todo el audio pasa por la PBX (*direct media* desactivado), la mitad de cada llamada (PBX → teléfono) siempre llega bien marcada. En el sentido teléfono → PBX, los softphones de Windows no siempre pueden marcar DSCP, así que el SG2210P y el ER605 clasifican por puertos y por destino 192.168.30.5 y aplican la prioridad aunque el paquete llegue con DSCP 0.

En el SG2210P se activa QoS en modo DSCP (confiar en la marca) y se mapea EF a la cola más alta. En el EAP610 se deja WMM activo, que traduce EF a la categoría de acceso de voz del Wi-Fi. En el ER605 se configura el control de ancho de banda: un límite por VLAN para invitados (por ejemplo 5 Mbps bajada / 2 Mbps subida) y, durante la prueba, un límite artificial al enlace.

## Prueba bajo congestión

1. Llamada activa entre una extensión en la VLAN 20 (laptop) y otra en la VLAN 30 (celular en HZ-Voz).
2. Se limita el enlace del ER605 (por ejemplo a 10 Mbps) para que se pueda saturar.
3. En la PBX corre `iperf3 -s`; desde otra laptop en la VLAN 20 o 40 se envía `iperf3 -c <servidor> -u -b 50M -t 60` (UDP por encima del límite).
4. **Sin QoS:** se mide durante 60 s con Wireshark en la laptop (Telephony → RTP → RTP Streams: jitter, pérdida, delta máximo) y se anota la calidad percibida.
5. **Con QoS:** se activa la política y se repite igual.
6. Se toman capturas de Wireshark con el campo DSCP visible (filtro `rtp`, columna `ip.dsfield.dscp`).

| Métrica | Objetivo (ITU-T G.114 y enunciado) | Sin QoS | Con QoS |
|---|---|---|---|
| Retardo unidireccional | ≤ 150 ms | pendiente | pendiente |
| Jitter | < 30 ms | pendiente | pendiente |
| Pérdida | < 1 % | pendiente | pendiente |
| Calidad percibida | Clara | pendiente | pendiente |

El retardo unidireccional se estima como la mitad del RTT de `ping` entre los terminales más el búfer de jitter del softphone.
