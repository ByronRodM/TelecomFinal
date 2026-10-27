# Pendientes para quienes tienen los equipos Omada

La PBX se preparó en la laptop de Byron, que no tiene puerto Ethernet. Este archivo dice qué falta para integrarla con la red real. Sigue el orden: cada paso depende del anterior.

**Antes de empezar:** los equipos son prestados. No restablezcan a fábrica ni actualicen firmware sin permiso del dueño. Exporten la configuración actual de la controladora (Settings → Maintenance → Backup) antes de cambiar nada.

## 1. Mover la VM a la laptop con Ethernet

1. Byron comparte `HZ-PBX.ova` (la VM exportada) por un canal privado, junto con el archivo de credenciales.
2. En la laptop destino: VirtualBox → **Archivo → Importar servicio virtualizado** → `HZ-PBX.ova`.
3. En **Configuración → Red → Adaptador 1**: *Adaptador puente* al **puerto Ethernet** (no al Wi-Fi). El adaptador 2 (solo-anfitrión) se puede dejar; sirve para entrar a la PBX desde esa misma laptop.
4. Necesita al menos 8 GB de RAM en la laptop. Si va lenta, desactiven *Integridad de memoria* en Seguridad de Windows y reinicien.

## 2. Red en la controladora OC200 (criterio B y extra E2)

1. Adoptar ER605, SG2210P y EAP610 en la OC200. **Captura** de los tres en *Connected*.
2. Settings → Wired Networks → LAN: crear las cuatro redes.

| Nombre | VLAN | Gateway/Máscara | DHCP |
|---|---|---|---|
| Gestion | 10 | 192.168.10.1/24 | .100 a .150 |
| Administrativa | 20 | 192.168.20.1/24 | .100 a .200 |
| Voz | 30 | 192.168.30.1/24 | .100 a .200 |
| Invitados | 40 | 192.168.40.1/24 | .100 a .250 |

3. Perfiles de puerto en el SG2210P:
   - Puerto hacia el ER605: troncal con todas las VLAN.
   - Puerto hacia el EAP610: troncal (PoE).
   - Puerto de la OC200 y de la laptop de TI: acceso VLAN 10.
   - **Puerto de la laptop con la PBX: acceso VLAN 30 (sin etiqueta).**
   - Un puerto de acceso VLAN 20 para pruebas con laptop por cable.
4. Wi-Fi (EAP610): SSID `HZ-Voz` → VLAN 30, `HZ-Admin` → VLAN 20, `HZ-Invitados` → VLAN 40 con *Guest Network* (aislamiento) y límite de velocidad (por ejemplo 5/2 Mbps).
5. Gateway ACL en el ER605: las 7 reglas de `plan/02-diseno-de-red.md`, en ese orden. **Captura** de la lista.
6. Desactivar SIP ALG en el ER605 (Settings → Transmission → NAT → ALG).
7. Exportar la configuración (respaldo para anexos).

## 3. Cambiar la PBX a su IP de producción

En la consola de la VM, como root:

```
bash /root/hz-produccion.sh
```

El script pone la interfaz 1 en 192.168.30.5/24, gateway 192.168.30.1, y ajusta el firewall de FreePBX para que la red 192.168.10.0/24 sea de confianza (administración) y 192.168.20.0/24 y 192.168.30.0/24 sean locales (registro de teléfonos). Luego verifiquen:

- Desde una laptop en VLAN 10: abrir `http://192.168.30.5` → carga el panel. **Captura.**
- Desde una laptop en VLAN 20: el panel **no** carga, pero el softphone sí registra. **Captura.**

## 4. Registrar terminales y probar (criterios D y E)

Cada integrante configura su extensión según `plan/04-telefonia.md` y `GUIA-USUARIO.md`, con servidor `192.168.30.5`. Celulares en `HZ-Voz`, laptops en `HZ-Admin` o cable VLAN 20. Ejecutar las pruebas P-01 a P-23 de `plan/07-pruebas-y-trazabilidad.md` y llenar la columna *Obtenido*. Cada prueba lleva captura con el reloj de Windows visible.

## 5. QoS y mediciones (criterio F)

1. SG2210P: QoS en modo DSCP, EF a la cola más alta.
2. ER605: control de ancho de banda (Settings → Transmission → Bandwidth Control) limitando invitados; para la prueba, limitar también el enlace.
3. Seguir el procedimiento de `plan/05-qos.md` con iperf3 (`C:\Telecom\iperf3.22\iperf3.exe` funciona en cualquier Windows sin instalar; la PBX ya tiene `iperf3`).
4. Wireshark en la laptop durante una llamada: filtro `rtp || sip`, agregar columna DSCP, Telephony → RTP → RTP Streams. Capturas con y sin QoS.

## 6. Extras

- **E1:** instalar Tailscale en la VM (`curl -fsSL https://tailscale.com/install.sh | sh && tailscale up`) y en un celular; probar con datos móviles. Ver riesgos en `plan/08-extras.md`.
- **E2:** capturas de la controladora (topología, dispositivos, redes, ACL, estadísticas). Revisar el Anexo A.
- **E3:** crear cuenta en sip2sip.info y configurar la troncal (ver `CONFIG.md`).

## 7. Cierre

- Respaldo final de FreePBX (Admin → Backup & Restore) y de Omada. Quitar contraseñas de los archivos antes de meterlos en el comprimido de anexos.
- Llenar `BITACORA.md` con lo que hizo cada quien.
