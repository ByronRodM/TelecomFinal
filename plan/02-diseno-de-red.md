# 02 · Diseño de red y segmentación (criterio B)

## VLAN y direccionamiento

| VLAN | Nombre | Red | Puerta de enlace | DHCP | Reservas / fijas |
|---|---|---|---|---|---|
| 10 | Gestión | 192.168.10.0/24 | 192.168.10.1 | .100 a .150 | .2 OC200 · .3 SG2210P · .4 EAP610 · .20 laptop de TI |
| 20 | Administrativa | 192.168.20.0/24 | 192.168.20.1 | .100 a .200 | .2 a .49 para equipos fijos |
| 30 | Voz | 192.168.30.0/24 | 192.168.30.1 | .100 a .200 | **.5 PBX** · .2 a .49 teléfonos fijos |
| 40 | Invitados | 192.168.40.0/24 | 192.168.40.1 | .100 a .250 | Ninguna |

Máscara /24 en todas (254 hosts), suficiente para los 31 colaboradores y sus dispositivos con espacio para crecer. El ER605 hace el enrutamiento entre VLAN (router con interfaces lógicas por VLAN) y el DHCP de cada segmento; el SG2210P lleva las VLAN etiquetadas (802.1Q) hacia el router y el punto de acceso.

## Diagrama lógico

```
                 Internet
                    │ WAN (NAT)
              ┌─────┴─────┐
              │   ER605   │  gateway .1 de cada VLAN, DHCP, ACL, límite de ancho de banda
              └─────┬─────┘
                    │ troncal 802.1Q (10,20,30,40)
              ┌─────┴─────┐
              │  SG2210P  │  PoE, QoS por DSCP
              └┬────┬────┬┘
   acceso V30  │    │    │ troncal 802.1Q
   ┌───────────┘    │    └──────────────┐
┌──┴──────────┐  ┌──┴───┐         ┌─────┴─────┐  SSID HZ-Voz → V30
│ Laptop PBX  │  │OC200 │ V10     │  EAP610   │  SSID HZ-Admin → V20
│ VM FreePBX  │  └──────┘         └───────────┘  SSID HZ-Invitados → V40
│ 192.168.30.5│
└─────────────┘
```

El diagrama físico con puertos exactos lo completa el responsable de red al cablear (ver `PENDIENTES-EQUIPO-RED.md`).

## Matriz de comunicación entre VLAN

| Origen ↓ / Destino → | Gestión 10 | Administrativa 20 | Voz 30 | Invitados 40 | Internet |
|---|---|---|---|---|---|
| **Gestión 10** | ✔ | ✔ | ✔ (incluye web de la PBX) | ✔ (diagnóstico) | ✔ |
| **Administrativa 20** | ✖ | ✔ | Solo hacia 192.168.30.5: SIP UDP 5060 y RTP UDP 10000-20000 | ✖ | ✔ |
| **Voz 30** | ✖ | Solo respuestas de la PBX (conexiones establecidas) | ✔ | ✖ | Solo la PBX (actualizaciones y troncal SIP) |
| **Invitados 40** | ✖ | ✖ | ✖ | ✖ (aislamiento de clientes) | ✔ con límite de ancho de banda |

En la PBX se desactiva el audio directo entre teléfonos (*direct media*), así que todo el RTP pasa por 192.168.30.5. Gracias a eso las reglas solo tienen que abrir el tráfico hacia una IP y la QoS se aplica en un punto conocido.

## ACL a implementar en el ER605 (Gateway ACL en Omada)

Se evalúan en orden; la primera coincidencia gana.

| # | Nombre | Acción | Origen | Destino | Protocolo / puertos |
|---|---|---|---|---|---|
| 1 | GEST-a-todo | Permitir | Red VLAN 10 | Cualquiera | Todos |
| 2 | ADMIN-a-PBX-SIP | Permitir | Red VLAN 20 | IP 192.168.30.5 | UDP 5060 |
| 3 | ADMIN-a-PBX-RTP | Permitir | Red VLAN 20 | IP 192.168.30.5 | UDP 10000-20000 |
| 4 | ADMIN-bloq-internas | Denegar | Red VLAN 20 | VLAN 10, 30, 40 | Todos |
| 5 | VOZ-bloq-gest-inv | Denegar | Red VLAN 30 | VLAN 10, 40 | Todos |
| 6 | INV-bloq-internas | Denegar | Red VLAN 40 | VLAN 10, 20, 30 | Todos |
| 7 | WEB-PBX-solo-gestion | Denegar | VLAN 20, 30, 40 | IP 192.168.30.5 | TCP 80, 443, 22 |

El ER605 es stateful, por lo que las respuestas a conexiones permitidas regresan sin regla adicional. La regla 7 duplica lo que ya hace el firewall de FreePBX (defensa en profundidad).

## NAT y voz

El ER605 hace NAT de salida (masquerade) para todas las VLAN. Para la voz importan tres cosas:

**SIP ALG.** Muchos routers reescriben los mensajes SIP al pasar por el NAT y suelen dañarlos (direcciones mal reescritas, audio en un solo sentido). En este diseño los teléfonos internos hablan con la PBX sin pasar por NAT, y la única salida SIP es la troncal de la PBX, que ya sabe cuál es su IP externa. Por eso se recomienda **desactivar SIP ALG** en el ER605 (Settings → Transmission → NAT → ALG en Omada) y dejar que Asterisk lo maneje.

**Rango RTP.** Asterisk usa UDP 10000 a 20000 para audio. Ese rango es el que se abre en las ACL y el que se marca con EF.

**NAT traversal.** Para la troncal SIP, en FreePBX se configuran la IP externa y las redes locales (Settings → Asterisk SIP Settings → NAT) y las opciones `rtp_symmetric`, `force_rport` y `rewrite_contact` en la troncal. No se abre ningún puerto en la WAN porque la troncal se registra desde adentro; el acceso remoto de usuarios (E1) va por VPN.

## DHCP

Cada VLAN tiene su propio servidor DHCP en el ER605 con DNS 1.1.1.1 y 8.8.8.8. La PBX usa IP fija fuera del rango dinámico. No se usa la opción 66 (aprovisionamiento) porque los softphones se configuran a mano.
