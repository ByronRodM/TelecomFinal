# 08 · Componentes extra (E1 a E4)

## E1 · Acceso desde red pública (RN-08)

**Mecanismo:** VPN de usuario con **Tailscale** (WireGuard) instalada en la VM de la PBX. El celular con datos móviles se une a la red privada de Tailscale y registra su softphone a la IP de Tailscale de la PBX (100.x.y.z). La PBX no tiene ningún puerto abierto a internet.

| Riesgo | Mitigación |
|---|---|
| Robo o pérdida del celular con la VPN activa | Acceso a Tailscale con cuenta del grupo y verificación en dos pasos; el dispositivo se elimina desde la consola |
| Uso de la extensión para llamadas fraudulentas | La extensión remota no tiene permiso de ruta de salida |
| Exposición de la PBX en internet | Ninguna: solo se alcanza por el túnel cifrado |
| Calidad variable en datos móviles | Se permite G.711; se documenta la calidad obtenida |

Si se prefiere no depender de un servicio externo, la alternativa es la VPN WireGuard del ER605 (según firmware).

| Prueba | Esperado |
|---|---|
| E1-01 | Celular con datos móviles (Wi-Fi apagado) llama a una extensión interna con audio en ambos sentidos | **Correcto**: 2201 por Tailscale (100.103.5.71, ~170 ms) llamó a 2502; capturas 24 a 26 |

## E2 · SDN con TP-Link Omada (RN-09)

La red completa se administra desde la controladora **OC200**: adopción del ER605, SG2210P y EAP610; creación de las VLAN como redes LAN; SSID por VLAN; ACL de gateway; control de ancho de banda y QoS. Los criterios de aceptación están en el Anexo A (PF-TEL-001-2026-A1).

| Prueba | Esperado |
|---|---|
| E2-01 | Los tres equipos aparecen como *Connected* en la controladora |
| E2-02 | Un cambio hecho en la controladora (por ejemplo, el límite de invitados) se aplica sin tocar el equipo |
| E2-03 | Topología y estadísticas de clientes por VLAN visibles en la controladora |

## E3 · Troncal SIP (RN-10)

Troncal PJSIP registrada en **sip2sip.info** (cuenta gratuita). Ruta de salida: prefijo `0` seguido del usuario SIP o número de destino; ruta de entrada: las llamadas que llegan a la cuenta van a la condición de horario y luego al IVR 2900. **Limitaciones encontradas:** sip2sip.info no atiende SIP en su dominio (apunta a su web); hubo que declarar el proxy `sip:proxy.sipthor.net;lr`. El servicio gratuito solo conecta con otras direcciones SIP, no con la red telefónica. La ruta de salida usa el patrón `0|X.` (solo dígitos) y no `.`, para evitar marcaciones arbitrarias.

| Prueba | Esperado |
|---|---|
| E3-01 | Una extensión marca 0 + destino externo y la llamada sale por la troncal | **Correcto**: 04444 (eco de sip2sip) contestó; captura 27 |
| E3-02 | Una llamada desde fuera a la cuenta sip2sip entra al IVR | Configurada; pendiente de probar desde otra cuenta SIP externa |

## E4 · Funciones avanzadas

| Función | Implementación |
|---|---|
| Grupo de timbrado | 2000 operadora y 2910 Consulta Externa (ringall) |
| Cola con estrategia | 2920 Enfermería y Emergencias, rrmemory |
| Música en espera personalizada | Clase "horizonte" con audio propio libre de derechos |
| Condiciones horarias | IVR diurno y nocturno según horario de atención |
