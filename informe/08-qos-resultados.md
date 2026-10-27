## Resultados de QoS

[PENDIENTE: el responsable de QoS llena esta tabla con la prueba de congestión con iperf3 descrita en la sección 5, y agrega las figuras de Wireshark con el DSCP visible (EF en RTP, CS3 en SIP) y las estadísticas del ER605/SG2210P.]

| Métrica | Objetivo | Sin QoS | Con QoS |
|---|---|---|---|
| Retardo unidireccional | ≤ 150 ms | [PENDIENTE] | [PENDIENTE] |
| Jitter | < 30 ms | [PENDIENTE] | [PENDIENTE] |
| Pérdida | < 1 % | [PENDIENTE] | [PENDIENTE] |
| Calidad percibida | Clara | [PENDIENTE] | [PENDIENTE] |

Como referencia sin congestión, en la red de preparación el celular registrado por Wi-Fi mostró un RTT de 37 ms hacia la PBX y la laptop de 1 a 2 ms (figura 17); por Tailscale desde datos móviles el RTT fue de unos 170 ms (figura 25), lo que da un retardo de ida de alrededor de 85 ms, dentro del límite de 150 ms de ITU-T G.114.

## Pruebas de seguridad

| Prueba | Resultado |
|---|---|
| Acceso al panel solo desde redes de confianza | Configurado en el firewall de FreePBX (figura 15); [PENDIENTE: verificar desde la VLAN 20 en la red Omada] |
| Bloqueo por intentos fallidos | Responsive Firewall y fail2ban activos (figura 16); [PENDIENTE: prueba P-29] |
| Peticiones a la administración desde enlaces externos | Bloqueadas por la verificación de origen de FreePBX ("Potential Security Breach") |
| Respaldo y restauración | Respaldo completo generado (base de datos, configuración y audios) y respaldo diario programado |
