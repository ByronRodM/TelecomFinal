# Guía de la prueba de QoS (criterio F, 15 puntos)

Esta guía es para el responsable de QoS y quien lo ayude. Se hace con la red Omada ya funcionando y la PBX en 192.168.30.5. Tiempo estimado: 45 minutos.

## Qué se va a demostrar

El enunciado pide limitar artificialmente un enlace, saturarlo con iperf3 mientras hay una llamada y comparar la calidad con y sin QoS. El cuello de botella se crea en la **salida de red de la PBX**, que es por donde pasa todo el audio (el audio directo entre teléfonos está desactivado). Allí el script `hz-qos.sh` limita la salida a 4 Mbps y, en el modo "con QoS", manda primero los paquetes marcados EF (audio) y CS3 (señalización), que Asterisk ya marca por su cuenta. Así la prueba no depende de lo que permita el firmware de cada equipo Omada y el resultado se puede medir y repetir.

La QoS de los equipos Omada (DSCP en el switch, WMM en el AP, límite a invitados en el ER605) se configura igual y se documenta con capturas, como complemento.

## Qué hay que tener instalado

| Equipo | Programa | Para qué |
|---|---|---|
| **Laptop A** (la de la llamada), en la VLAN 20 por cable o en el SSID HZ-Admin | MicroSIP y **Wireshark** (al instalarlo, aceptar **Npcap**) | Hacer la llamada y capturar el tráfico |
| **Laptop B** (la que satura), en la **VLAN 10** (gestión) | **iperf3 para Windows**: la carpeta `iperf3.22` que tiene Byron (no se instala, se usa desde PowerShell); también se descarga de https://github.com/ar51an/iperf3-win-builds/releases | Generar el tráfico de saturación |
| **Celular** en el SSID HZ-Voz (VLAN 30) | Linphone con una extensión | El otro extremo de la llamada |
| **Laptop con la VM** | Nada nuevo: la PBX ya trae `iperf3` y `tc` | Servidor de la prueba |

La laptop B va en la VLAN 10 porque esa red tiene acceso permitido a la PBX tanto en las ACL como en el firewall de FreePBX. Así no hay que abrir reglas temporales. Si no hay un puerto o SSID de gestión libre, la alternativa es la VLAN 20 con una regla temporal en el ER605 (permitir TCP/UDP 5201 hacia 192.168.30.5) y `fwconsole firewall trust <IP de la laptop B>` en la PBX, que se deshacen al terminar.

## Paso 0. Llevar el script a la PBX

Desde cualquier laptop en la VLAN 10, en PowerShell (dentro de la carpeta del repositorio):

```
scp vm-scripts\hz-qos.sh hzadmin@192.168.30.5:/tmp/
```

En la consola de la VM (usuario `hzadmin`, luego `sudo -i`):

```
cp /tmp/hz-qos.sh /root/ && bash /root/hz-qos.sh servidor
```

Debe responder "iperf3 escuchando en el puerto 5201".

## Paso 1. Línea base (sin carga)

1. Laptop A (MicroSIP) llama al celular. Contestar y dejar la llamada abierta durante toda la prueba.
2. En la VM: `bash /root/hz-qos.sh medir` (dura 60 s). **Captura** de la consola al terminar.

Esta medición sirve para el informe como referencia de una red sin congestión.

## Paso 2. Sin QoS

1. En la VM: `bash /root/hz-qos.sh sin`
2. En la laptop A abrir Wireshark, elegir la interfaz de red y empezar a capturar.
3. En la laptop B, en PowerShell dentro de la carpeta de iperf3:
   ```
   .\iperf3.exe -c 192.168.30.5 -u -b 20M -t 60 -R
   ```
   (`-R` hace que la PBX sea la que envía los 20 Mbps, de modo que su salida, limitada a 4 Mbps, queda saturada).
4. Mientras corre iperf3: en la VM `bash /root/hz-qos.sh medir`, y en la llamada hablen y anoten cómo se escucha (cortes, retraso, robótica).
5. Al terminar: detener Wireshark y guardar la captura como `qos-sin.pcapng`. **Capturas** de la consola de la VM, de la ventana de iperf3 y de lo que se escuchó (anotarlo).

## Paso 3. Con QoS

Igual que el paso 2, cambiando solo el primer comando:

1. En la VM: `bash /root/hz-qos.sh con`
2. Wireshark en la laptop A, iperf3 en la laptop B con el mismo comando, `medir` en la VM.
3. Guardar la captura como `qos-con.pcapng`.
4. En la VM: `bash /root/hz-qos.sh stats`. **Captura**: muestra cuántos paquetes pasaron por la clase prioritaria (1:10) y cuántos por la de mejor esfuerzo (1:20). Es la "estadística del dispositivo que aplica la política" que pide el enunciado.

## Paso 4. Dejar todo como estaba

En la VM: `bash /root/hz-qos.sh quitar`. Colgar la llamada.

## Cómo sacar los números

**Desde la PBX (lo más rápido):** cada bloque de `medir` muestra, por canal, los paquetes recibidos y perdidos, el **jitter** y el **RTT**. Para la tabla usen el valor típico del canal del celular y el de la laptop durante la saturación. El retardo de ida se estima como RTT ÷ 2.

**Desde Wireshark** (para la evidencia del marcado):
1. *Analyze → Enabled Protocols*, buscar `rtp_udp` y activarlo.
2. Filtro: `rtp`. Clic derecho en el encabezado de columnas → *Column Preferences* → agregar la columna `ip.dsfield.dscp`. Los paquetes que vienen de 192.168.30.5 deben mostrar **46 (EF)**. Con el filtro `sip`, los de señalización muestran **24 (CS3)**. **Captura** de ambas vistas.
3. *Telephony → RTP → RTP Streams*: muestra para cada flujo **Max Jitter, Mean Jitter y Lost**. **Captura** de esta ventana en `qos-sin` y en `qos-con`.

Con eso se llena la tabla de la sección 8.2 del informe:

| Métrica | Objetivo | Sin QoS | Con QoS |
|---|---|---|---|
| Retardo unidireccional | ≤ 150 ms | | |
| Jitter | < 30 ms | | |
| Pérdida | < 1 % | | |
| Calidad percibida | Clara | | |

Lo esperado es que sin QoS el jitter y la pérdida suban mucho (la cola única se llena con el tráfico de iperf3) y que con QoS se mantengan dentro de los objetivos, porque el audio sale primero.

## QoS en los equipos Omada (complemento, con capturas)

- **SG2210P:** activar QoS en modo DSCP (confiar en la marca del paquete) y que EF vaya a la cola de mayor prioridad. Captura de la configuración en la controladora.
- **EAP610:** WMM activado en los SSID (viene activo por defecto). Captura.
- **ER605:** límite de ancho de banda para la red de Invitados (por ejemplo 5 Mbps de bajada y 2 de subida). Captura y prueba P-28: un test de velocidad desde un celular en HZ-Invitados no debe superar el límite.

## Para explicarlo en la defensa

La voz se marca con DSCP 46 (EF) porque es el valor estándar de reenvío acelerado (RFC 3246) para tráfico sensible al retardo; la señalización con 24 (CS3), que es el valor que usan por defecto Asterisk y la mayoría de teléfonos. En la prueba, la salida de la PBX se limitó a 4 Mbps y se saturó con 20 Mbps de UDP. Sin QoS todos los paquetes esperan en la misma cola y el audio sufre retardo, jitter y pérdida. Con QoS el planificador HTB atiende primero la clase de voz, que necesita menos de 100 kbps por llamada, y el tráfico de iperf3 se queda con el resto.
