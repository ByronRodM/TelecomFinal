# 03 · Plataforma de telefonía (criterio C)

## Entorno

| Elemento | Valor |
|---|---|
| Virtualización | Oracle VirtualBox 7.x en Windows 11 |
| VM | `HZ-PBX`, 2 vCPU, 3 GB RAM, disco 30 GB |
| Sistema operativo | Debian GNU/Linux 12.15 "bookworm" amd64 (instalación desatendida) |
| PBX | FreePBX 17 con Asterisk (versiones exactas en `CONFIG.md`, sección Versiones) |
| Red de la VM | Adaptador 1 en puente (producción: VLAN 30, IP 192.168.30.5); adaptador 2 solo-anfitrión 192.168.56.10 para administrar desde la laptop durante la preparación |

La instalación se hizo con los scripts de `vm-scripts/`: `hz-base.sh` deja el sistema actualizado con zona horaria de Guatemala y herramientas de diagnóstico (sngrep, tcpdump, iperf3), y `hz-freepbx.sh` ejecuta el instalador oficial de Sangoma para Debian 12.

## Administración protegida

La interfaz web de FreePBX solo acepta conexiones desde la VLAN 10 (Gestión). Se aplica en dos capas: la ACL 7 del ER605 y el firewall de FreePBX, donde la red 192.168.10.0/24 se declara como **Trusted** y las VLAN 20 y 30 como **Local** (pueden registrar teléfonos, pero no ven la administración). Mientras la VM está en la laptop de preparación, la red solo-anfitrión 192.168.56.0/24 también es Trusted; al pasar a producción se retira.

## Códecs y ancho de banda

| Códec | Uso | Tasa del códec |
|---|---|---|
| G.711 µ-law | Principal; compatible con todos los softphones y troncales | 64 kbps |
| G.711 A-law | Respaldo para troncales que lo exijan | 64 kbps |
| G.722 | Banda ancha entre softphones internos (mejor voz con el mismo ancho de banda) | 64 kbps |

No se habilitan códecs comprimidos (G.729, Opus) en la red interna: el ancho de banda sobra en la LAN y los códecs sin compresión evitan transcodificación en la PBX, que consumiría CPU de la VM.

**Cálculo por llamada (G.711, paquetes cada 20 ms, 50 paquetes por segundo):**

| Capa | Bytes por paquete |
|---|---|
| Voz (64 kbps × 20 ms) | 160 |
| RTP | 12 |
| UDP | 8 |
| IPv4 | 20 |
| **Subtotal IP** | **200 B → 200 × 8 × 50 = 80 kbps** |
| Ethernet (cabecera 14 + FCS 4) | 18 |
| **Total en el cable** | **218 B → 87.2 kbps por sentido** |
| Con etiqueta 802.1Q (+4) | 222 B → 88.8 kbps |

**Dimensionamiento para el cliente:** con 31 colaboradores y una simultaneidad estimada de 25 % (8 llamadas a la vez), el tráfico de voz máximo es 8 × 88.8 ≈ **710 kbps por sentido**. Como todo el audio pasa por la PBX, su enlace soporta el doble (dos tramos por llamada), unos 1.4 Mbps, muy por debajo de un puerto de 1 Gbps. Hacia internet (troncal SIP) se reservan 2 llamadas externas, unos 180 kbps por sentido.

## Extensiones

Cada extensión tiene una contraseña SIP aleatoria de 24 caracteres generada por FreePBX, guardada fuera del repositorio. Lista completa en `04-telefonia.md`.

## Registros para auditoría

| Registro | Dónde | Para qué |
|---|---|---|
| CDR (detalle de llamadas) | Reports → CDR Reports (base `asteriskcdrdb`) | Quién llamó a quién, duración, transferencias |
| Eventos de llamada (CEL) | Reports → CEL | Pasos internos de cada llamada |
| Log de Asterisk | `/var/log/asterisk/full` | Registros SIP, errores, intentos fallidos |
| Log de seguridad | `/var/log/asterisk/security` y `fail2ban` | Intentos de registro con contraseña errónea |
| Log del sistema | `journalctl` | Arranques, servicios |

## Seguridad aplicada

| Medida | Cómo |
|---|---|
| Sin credenciales por defecto | Usuario administrador propio creado en el primer acceso; root sin acceso por SSH con contraseña |
| Contraseñas robustas | Secretos SIP de 24 caracteres; buzones con PIN de 6 dígitos distinto de la extensión |
| Firewall en la PBX | Módulo Firewall de FreePBX: zonas Trusted (gestión), Local (voz y administrativa), Internet bloqueado |
| Bloqueo de intentos | Responsive Firewall + fail2ban (bloqueo tras varios intentos fallidos) |
| Servicios mínimos | Solo SIP (PJSIP 5060/UDP), RTP, HTTP(S) para gestión y SSH desde gestión |
| Actualizaciones | `apt full-upgrade` y `fwconsole ma updateall` al instalar; actualizaciones automáticas de seguridad de Debian |
| Respaldos | Módulo Backup & Restore de FreePBX y exportación de la configuración de Omada |
| Llamadas externas | Ruta de salida solo con prefijo 0 y solo hacia la troncal de prueba (sin costo) |
