# Descripción general del proyecto

## Objetivo

Diseñar, implementar y validar la telefonía IP del Centro Médico Horizonte sobre una red segmentada en VLAN con prioridad para la voz, de modo que el personal pueda comunicarse desde laptops y celulares con extensiones de cuatro dígitos, menú de voz y buzón.

## Alcance realizado

La muestra representa las cinco áreas del cliente con diez extensiones, dos por área, sobre un plan de numeración que admite hasta cien por área. Se implementaron todas las funciones obligatorias de telefonía (espera, segunda llamada, transferencia ciega y atendida, buzón con saludo personalizado, IVR con manejo de errores) y cuatro funciones avanzadas: grupo de timbrado, cola con reparto por turnos, música en espera propia y condiciones de horario. La red usa hardware real TP-Link Omada administrado desde su controladora, lo que además cubre el extra de SDN.

## Modalidad elegida

Local (stand-alone): la PBX corre en una máquina virtual dentro de la red del cliente, en la VLAN de Voz. La justificación completa está en la sección de investigación.

## Herramientas y versiones

| Herramienta | Versión | Uso |
|---|---|---|
| Debian GNU/Linux | 12.15 | Sistema operativo de la PBX |
| FreePBX / Asterisk | 17.0.33.2 / 22.11.0 | Central telefónica |
| Oracle VirtualBox | 7.2 | Virtualización |
| TP-Link Omada: ER605, SG2210P, EAP610, OC200 | [PENDIENTE: versiones de firmware] | Router, switch, AP y controladora |
| MicroSIP | 3.21 o superior | Softphone en Windows |
| Linphone | 5.x | Softphone en celulares |
| Wireshark | 4.x | Captura y análisis de tráfico |
| iperf3 | 3.17+ | Generación de tráfico para la prueba de congestión |
