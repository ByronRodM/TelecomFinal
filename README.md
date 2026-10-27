# Centro Médico Horizonte · Telefonía IP con VLAN y QoS

Proyecto final de Telecomunicaciones I (PF-TEL-001-2026), **Grupo 2**, Universidad Mariano Gálvez, Campus Jutiapa. Catedrático: Ing. Juan Daniel Ramos Martínez.

La solución instala una central telefónica IP (FreePBX sobre Asterisk) en una máquina virtual y la conecta a una red segmentada en cuatro VLAN, administrada con equipos TP-Link Omada (router ER605, switch SG2210P, punto de acceso EAP610 y controladora OC200). Los teléfonos son softphones en las laptops y celulares de los integrantes.

> Aquí solo está la documentación y los scripts. Las contraseñas, la máquina virtual exportada y los respaldos con secretos se manejan fuera del repositorio.

**Entrega en Canvas:** miércoles 28 de octubre de 2026, 23:30, la sube el coordinador.

## Integrantes y roles

| Integrante | Carné | Rol |
|---|---|---|
| Juan Pablo Méndez Martínez | pendiente | Coordinador del proyecto |
| Jefferson Francisco Abac Lemus | pendiente | Red y VLAN |
| Brandon Obdulio Estiven Borrayo López | pendiente | Telefonía (PBX) |
| Jairo Ardani Castillo Girón | pendiente | Terminales y experiencia de usuario |
| Brandon Baldemar Florián López | pendiente | QoS y mediciones |
| Joaquín Emanuel Garrido y Garrido | pendiente | Seguridad |
| José Benjamín Hernández Martínez | pendiente | Infraestructura y componentes extra |
| Byron Daniel Rodríguez Mazariegos | pendiente | Documentación y calidad |

## Cómo está organizado

| Archivo | Para qué sirve |
|---|---|
| [`PENDIENTES-EQUIPO-RED.md`](PENDIENTES-EQUIPO-RED.md) | **Lo que falta hacer con los equipos Omada**, paso a paso, para quien tenga el hardware |
| [`CONFIG.md`](CONFIG.md) | Operación de la PBX: encenderla, direcciones, comandos y estado frente a la rúbrica |
| [`GUIA-USUARIO.md`](GUIA-USUARIO.md) | Guía rápida de una página para el personal del centro médico (anexo) |
| [`EVIDENCIAS.md`](EVIDENCIAS.md) | Índice de capturas con lo que muestra cada una |
| [`BITACORA.md`](BITACORA.md) | Aportes de cada integrante por hito (anexo) |
| `plan/01` a `plan/08` | Investigación, diseño, implementación, pruebas y extras |
| `vm-scripts/` | Scripts con los que se instaló la VM |
| `capturas/` | Evidencias con fecha y hora visibles |

## Resumen técnico

| Elemento | Decisión |
|---|---|
| Modalidad | Local (stand-alone) en VirtualBox, con acceso remoto por VPN como extra |
| PBX | FreePBX 17 sobre Asterisk, Debian 12 |
| VLAN | 10 Gestión · 20 Administrativa · 30 Voz · 40 Invitados (redes 192.168.X.0/24) |
| PBX en producción | 192.168.30.5 (VLAN 30) |
| Numeración | 4 dígitos, un bloque de 100 por área (2100 a 2599), prefijo externo 0 |
| Servicios | 2000 operadora · 2900 IVR · 2999 buzón · 2910 grupo Consulta Externa · 2920 cola Enfermería |
| Códecs | G.711 µ-law y A-law (principal), G.722 (banda ancha interna) |
| QoS | EF para audio, CS3 para señalización, invitados limitados |
