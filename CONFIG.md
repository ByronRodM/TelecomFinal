# Operación de la PBX (HZ-PBX)

## Encender y entrar

| Qué | Cómo |
|---|---|
| Encender | VirtualBox → `HZ-PBX` → Iniciar (o *Inicio sin interfaz* para que corra en segundo plano) |
| Consola | Usuario `root` (contraseña en el archivo de credenciales, fuera del repo) |
| Panel web durante la preparación | http://192.168.55.10/admin (red solo-anfitrión, desde la laptop que corre la VM) |
| Panel web en producción | http://192.168.30.5/admin, **solo desde la VLAN 10** |
| Servidor SIP para softphones | 192.168.30.5, UDP 5060 (en preparación: la IP del adaptador puente, la muestra `ip -br addr`) |
| SSH | `ssh hzadmin@192.168.30.5` desde la VLAN 10 y luego `su -` |

## Versiones

| Componente | Versión |
|---|---|
| Debian | 12.15 (bookworm) |
| FreePBX | se completa tras la instalación (`fwconsole -V`) |
| Asterisk | se completa tras la instalación (`asterisk -V`) |
| VirtualBox | 7.x |

## Comandos útiles (consola de la VM)

| Para qué | Comando |
|---|---|
| Ver extensiones registradas | `asterisk -rx "pjsip show contacts"` |
| Ver llamadas activas | `asterisk -rx "core show channels"` |
| Ver tráfico SIP en vivo | `sngrep` |
| Aplicar cambios | `fwconsole reload` |
| Reiniciar FreePBX | `fwconsole restart` |
| Estado del firewall | `fwconsole firewall list trusted` |
| IP bloqueadas por intentos | `fail2ban-client status` |
| Respaldo manual | Admin → Backup & Restore → ejecutar el respaldo "HZ-diario" |
| Pasar a IP de producción | `bash /root/hz-produccion.sh` |
| Servidor iperf3 para la prueba de QoS | `iperf3 -s` |

## Estado frente a la rúbrica

| Criterio | Estado | Falta |
|---|---|---|
| A Investigación | Documentado en `plan/01` | Revisar costos con precios locales |
| B Red | Diseño completo en `plan/02` | Implementar en Omada (ver `PENDIENTES-EQUIPO-RED.md`) |
| C PBX | En instalación | Versiones, capturas, firewall en producción |
| D Funcionalidades | Diseño en `plan/04` | Configurar y probar |
| E Terminales | Guía lista | Registrar terminales en la red real |
| F QoS | Diseño en `plan/05` | Medir con el equipo |
| G Documentación | Estructura lista | Informe PDF, resultados de pruebas |
| H Presentación | - | Preparar diapositivas y ensayo |
