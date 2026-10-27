# Estado del avance (27/10/2026, 14:30)

## Hecho
- VM HZ-PBX: Debian 12.15 + FreePBX 17.0.33.2 + Asterisk 22.11.0, idioma es_419, Guest Additions y carpeta compartida `C:\Telecom\vmshare` (agente: scripts en `cmd\`, salida en `out\`).
- Telefonía completa: 10 extensiones, 5 buzones, grupos 2000/2910, cola 2920, IVR diurno/nocturno con horario (2900, *271 fuerza), 2999 buzón general, música propia, códecs ulaw/alaw/g722, audio directo desactivado, TOS EF/CS3.
- Seguridad: firewall de FreePBX (trusted/local), Responsive Firewall, fail2ban activo.
- Pruebas hechas con evidencia: registro de laptop y celular, llamada laptop↔móvil, espera con música, transferencia ciega al IVR, IVR (bienvenida y opción inválida).
- Capturas 01–21 en `capturas/` y `EVIDENCIAS.md`. Credenciales en `C:\Telecom\vmshare\privado\` (fuera del repo).

## Falta (base)
1. Pruebas restantes: buzón (dejar/escuchar con *97, saludo personalizado), transferencia atendida, segunda llamada entrante, grupo 2910, cola 2920, fuera de horario, bloqueo por intentos fallidos, CDR.
2. Respaldo de FreePBX (Admin → Backup & Restore) y exportar la VM a OVA.
3. Red Omada, VLAN, ACL, QoS con iperf3/Wireshark y llamadas entre VLAN: lo hace el equipo con el hardware (`PENDIENTES-EQUIPO-RED.md`).
4. Informe PDF de 13 secciones (borradores en `informe/` y `plan/`), anexos, bitácora y presentación.

## Extras
- E1 (Tailscale) y E3 (sip2sip) requieren cuentas: Tailscale y sip2sip.info.
