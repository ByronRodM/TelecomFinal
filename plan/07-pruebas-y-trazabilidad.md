# 07 · Matriz de pruebas y trazabilidad (criterio G)

Columna **Obtenido**: se llena al ejecutar cada prueba, con la captura correspondiente en `capturas/` (reloj de Windows visible).

## Matriz de pruebas

| ID | Prueba | Pasos | Resultado esperado | Obtenido | Evidencia |
|---|---|---|---|---|---|
| P-01 | PBX operativa | Entrar al panel de FreePBX desde la VLAN 10 | Dashboard con servicios en verde y versiones visibles | pendiente | |
| P-02 | Admin bloqueada fuera de gestión | Abrir http://192.168.30.5 desde la VLAN 20 | No carga (bloqueo) | pendiente | |
| P-03 | Extensiones registradas | Registrar 2101, 2201, 2301, 2401 a la vez | Las 4 aparecen como *Avail* | pendiente | |
| P-04 | Marcación 4 dígitos entre áreas | 2101 marca 2301 | Timbra y hay audio en ambos sentidos | pendiente | |
| P-05 | Llamada entre VLAN | Laptop VLAN 20 llama a celular VLAN 30 | Audio bidireccional | pendiente | |
| P-06 | Laptop ↔ laptop | 2101 llama a 2202 | Audio bidireccional | pendiente | |
| P-07 | Móvil ↔ móvil | 2301 llama a 2302 | Audio bidireccional | pendiente | |
| P-08 | Espera con música | En llamada, 2101 pulsa Hold | El otro escucha la música del centro; al reanudar sigue la llamada | pendiente | |
| P-09 | Segunda llamada entrante | 2201 en llamada recibe otra de 2301 | Tono de llamada en espera; atiende la segunda y vuelve a la primera | pendiente | |
| P-10 | Transferencia ciega | 2101 atiende y transfiere sin consultar a 2201 | 2201 recibe la llamada; CDR la muestra | pendiente | |
| P-11 | Transferencia atendida | 2101 consulta a 2301 y luego transfiere | 2301 habla primero con 2101 y luego queda con el llamante | pendiente | |
| P-12 | Transferencia entre tipos de terminal | Laptop transfiere a celular | Funciona igual que entre iguales | pendiente | |
| P-13 | Buzón por no respuesta | Llamar a 2201 y no contestar 20 s | Se escucha el saludo personalizado; se deja mensaje | pendiente | |
| P-14 | Buzón por ocupado | Llamar a 2101 mientras está en llamada (sin call waiting) | Pasa al buzón | pendiente | |
| P-15 | Consulta de buzón | 2201 marca *97 e ingresa PIN | Escucha el mensaje de P-13 | pendiente | |
| P-16 | Número de servicio buzón | Marcar 2999 desde 2402 | Pide extensión y PIN | pendiente | |
| P-17 | Operadora | Marcar 2000 | Timbran 2101 y 2102 | pendiente | |
| P-18 | IVR, recorrido | Marcar 2900 y probar 1, 2, 3, 4 y 0 | Cada opción llega a su destino | pendiente | |
| P-19 | IVR, opción inválida | Marcar 2900 y luego 8 | Mensaje de opción inválida y repite | pendiente | |
| P-20 | IVR, sin respuesta | Marcar 2900 y no marcar nada | Repite y luego pasa a la operadora | pendiente | |
| P-21 | IVR fuera de horario | Forzar la condición de horario a "fuera" | Se escucha el mensaje nocturno | pendiente | |
| P-22 | Grupo de timbrado | Marcar 2910 | Timbran 2201 y 2202 | pendiente | |
| P-23 | Cola | Marcar 2920 | Música de espera y reparto entre 2301 y 2302 | pendiente | |
| P-24 | Marcado DSCP | Captura Wireshark de una llamada | RTP con DSCP 46 (EF), SIP con 24 (CS3) | pendiente | |
| P-25 | QoS sin política | iperf3 saturando + llamada | Jitter y pérdida altos | pendiente | |
| P-26 | QoS con política | Igual con política activa | Jitter < 30 ms, pérdida < 1 % | pendiente | |
| P-27 | Invitados aislados | Desde VLAN 40, ping a 192.168.30.5 y 192.168.20.1 | Sin respuesta; internet sí funciona | pendiente | |
| P-28 | Límite a invitados | Test de velocidad en VLAN 40 | No supera el límite configurado | pendiente | |
| P-29 | Bloqueo por intentos fallidos | Registrar con contraseña errónea varias veces | La IP queda bloqueada (fail2ban/Responsive Firewall) | pendiente | |
| P-30 | Respaldo | Ejecutar respaldo de FreePBX y exportar config Omada | Archivos generados | pendiente | |
| P-31 | Registros de llamadas | Revisar CDR tras las pruebas | Aparecen llamadas, transferencias y buzones | pendiente | |

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
