# 06 · Terminales y experiencia de usuario (criterio E)

| Tipo | Software | Dónde se usa |
|---|---|---|
| Laptop Windows | MicroSIP (gratuito, ligero) | Personal administrativo y recepción |
| Celular Android/iOS | Linphone (gratuito) | Personal que se mueve: clínicas, enfermería |

## Configuración de un softphone

| Campo | Valor |
|---|---|
| Servidor / dominio | 192.168.30.5 |
| Usuario y extensión | El número de 4 dígitos (por ejemplo 2201) |
| Contraseña | La entrega TI por un canal privado |
| Transporte | UDP |
| Puerto | 5060 |

Los celulares se conectan al SSID **HZ-Voz** (VLAN 30) y las laptops al SSID **HZ-Admin** o por cable a la VLAN 20. Así quedan terminales en VLAN distintas y se prueba la llamada entre VLAN.

Durante la preparación, sin los equipos Omada, la VM está en puente al Wi-Fi de la casa y las extensiones se pueden probar registrando los softphones a la IP que muestre la VM en ese momento.

## Matriz de llamadas entre terminales

| Prueba | Origen | Destino | VLAN | Resultado |
|---|---|---|---|---|
| Laptop ↔ móvil | 2101 MicroSIP | 2201 Linphone | 20 → 30 | pendiente |
| Laptop ↔ laptop | 2101 | 2202 | 20 → 20 | pendiente |
| Móvil ↔ móvil | 2301 | 2302 | 30 → 30 | pendiente |
| Cuatro registradas a la vez | 2101, 2201, 2301, 2401 | Captura de Reports → Asterisk Info → Peers | - | pendiente |

La guía para el personal está en `GUIA-USUARIO.md`.
