# 07 · Matriz de pruebas y trazabilidad (criterio G)

Columna **Obtenido**: se llena al ejecutar cada prueba, con la captura correspondiente en `capturas/` (reloj de Windows visible).

## Matriz de pruebas

| ID | Prueba | Pasos | Resultado esperado | Obtenido | Evidencia |
|---|---|---|---|---|---|
| P-01 | PBX operativa | Entrar al panel de FreePBX | Panel accesible, versiones visibles | Correcto (en red de preparación) | 03, 05 |
| P-02 | Admin bloqueada fuera de gestión | Abrir http://192.168.30.5 desde la VLAN 20 | No carga (bloqueo) | pendiente | |
| P-03 | Extensiones registradas | Registrar 2101, 2201, 2301, 2401 a la vez | Las 4 aparecen como *Avail* | Parcial: 2101 y 2502 registradas; faltan dos terminales más (equipo) | 17 |
| P-04 | Marcación 4 dígitos entre áreas | 2502 (TI) marca 2101 (Recepción) | Timbra y hay audio en ambos sentidos | Correcto, G.711 µ-law | 18 |
| P-05 | Llamada entre VLAN | Laptop VLAN 20 llama a celular VLAN 30 | Audio bidireccional | pendiente | |
| P-06 | Laptop ↔ laptop | 2101 llama a 2202 | Audio bidireccional | pendiente | |
| P-07 | Móvil ↔ móvil | 2301 llama a 2302 | Audio bidireccional | pendiente | |
| P-08 | Espera con música | En llamada, 2502 pulsa Hold en MicroSIP | El otro escucha la música del centro; al reanudar sigue la llamada | Correcto | 19 |
| P-09 | Segunda llamada entrante | 2201 en llamada recibe otra de 2301 | Tono de llamada en espera; atiende la segunda y vuelve a la primera | pendiente | |
| P-10 | Transferencia ciega | 2502 transfiere sin consultar la llamada de 2101 al IVR 2900 | 2101 queda en el IVR | Correcto | 20, 21 |
| P-11 | Transferencia atendida | 2101 consulta a 2301 y luego transfiere | 2301 habla primero con 2101 y luego queda con el llamante | pendiente | |
| P-12 | Transferencia entre tipos de terminal | Laptop transfiere la llamada del celular | Funciona igual que entre iguales | Correcto (laptop → celular al IVR) | 20, 21 |
| P-13 | Buzón por no respuesta | Llamar a 2501 (sin terminal) desde 2101 | Mensaje de no disponible en español, bip y grabación | Correcto tras reponer el bip de es_419 | 22 |
| P-14 | Buzón por ocupado | 2502 llama a 2101 y el celular rechaza la llamada | Pasa al buzón de 2101 con mensaje de ocupado | Correcto | 22 (CDR 14:48:08) |
| P-15 | Consulta de buzón | Marcar 2999, buzón 2501 y PIN | Escucha los mensajes de P-13 | Correcto | 22 |
| P-16 | Número de servicio buzón | Marcar 2999 | Pide buzón y PIN | Correcto | 22 |
| P-17 | Operadora | Marcar 2000 | Timbran 2101 y 2102 | pendiente | |
| P-18 | IVR, recorrido | Marcar 2900 y probar 1, 2, 3, 4 y 0 | Cada opción llega a su destino | Parcial: bienvenida y opción 1 verificadas | 21 |
| P-19 | IVR, opción inválida | Marcar 2900 y luego 8 | Mensaje de opción inválida y repite | Correcto | 07 |
| P-20 | IVR, sin respuesta | Marcar 2900 y no marcar nada | Repite y luego pasa a la operadora | pendiente | |
| P-21 | IVR fuera de horario | Marcar *271 (cambia el estado de la condición de horario) y luego 2900 | Se escucha el mensaje nocturno | pendiente | |
| P-22 | Grupo de timbrado | Marcar 2910 | Timbran 2201 y 2202 | pendiente | |
| P-23 | Cola | Marcar 2920 | Música de espera y reparto entre 2301 y 2302 | pendiente | |
| P-24 | Marcado DSCP | Captura Wireshark de una llamada | RTP con DSCP 46 (EF), SIP con 24 (CS3) | pendiente | |
| P-25 | QoS sin política | iperf3 saturando + llamada | Jitter y pérdida altos | pendiente | |
| P-26 | QoS con política | Igual con política activa | Jitter < 30 ms, pérdida < 1 % | pendiente | |
| P-27 | Invitados aislados | Desde VLAN 40, ping a 192.168.30.5 y 192.168.20.1 | Sin respuesta; internet sí funciona | pendiente | |
| P-28 | Límite a invitados | Test de velocidad en VLAN 40 | No supera el límite configurado | pendiente | |
| P-29 | Bloqueo por intentos fallidos | Registrar con contraseña errónea varias veces | La IP queda bloqueada (fail2ban/Responsive Firewall) | pendiente | |
| P-30 | Respaldo | Ejecutar respaldo de FreePBX y exportar config Omada | Archivos generados | pendiente | |
| P-31 | Registros de llamadas | Revisar CDR tras las pruebas | Aparecen llamadas, transferencias y buzones | Correcto | 22 |

## Matriz de trazabilidad

| Requerimiento | Descripción | Pruebas | Evidencia principal |
|---|---|---|---|
| RN-01 | Extensiones de 4 dígitos, espera y transferencia | P-04, P-08 a P-12 | Capturas de llamadas, CDR |
| RN-02 | Escritorio, laptop y móvil | P-03, P-05 a P-07 | Peers registrados, llamadas entre tipos |
| RN-03 | Separación de tráfico | P-02, P-05, P-27 | VLAN y ACL en Omada, pruebas de bloqueo |
| RN-04 | Calidad con tráfico intenso | P-24 a P-26 | Wireshark con DSCP, tabla con y sin QoS |
| RN-05 | Seguridad | P-02, P-29, P-30 | Firewall, fail2ban, respaldos |
| RN-06 | Facilidad de uso | Guía de usuario, P-15 | `GUIA-USUARIO.md` |
| RN-07 | IVR y buzón | P-13 a P-21 | Configuración IVR, recorrido grabado |
| RN-08 | Acceso desde red pública (extra E1) | E1-01 | Llamada por datos móviles con VPN |
| RN-09 | Administración centralizada SDN (extra E2) | E2-01 a E2-03 | Capturas de la controladora OC200 |
| RN-10 | Troncal SIP y funciones avanzadas (extras E3, E4) | E3-01, E3-02, P-21 a P-23 | Troncal registrada, CDR de llamadas externas |
