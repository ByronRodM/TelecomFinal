
# 2. Resumen ejecutivo para el cliente
Hasta ahora, el personal del Centro Médico Horizonte se comunicaba entre áreas con sus celulares personales y dos líneas tradicionales. Las llamadas se perdían, los pacientes no tenían un número único al cual llamar y la red del edificio era una sola, compartida por el personal, las computadoras administrativas y las visitas.

Instalamos una central telefónica propia que funciona dentro del edificio. Cada colaborador tiene un número interno de cuatro dígitos que se reconoce por el área: los que empiezan con 21 son de Recepción, con 22 de Consulta Externa, con 23 de Enfermería y Emergencias, con 24 de Administración y con 25 de Gerencia. Se puede llamar desde la computadora o desde el celular, conectado al Wi-Fi del centro, sin costo por llamada.

Cuando un paciente llama, una grabación en español le da la bienvenida y le ofrece elegir el área. Si no marca nada, lo atiende la operadora. Fuera del horario de atención escucha un mensaje distinto que le permite llegar a Emergencias. Si la persona buscada no contesta, el llamante puede dejarle un mensaje de voz que luego se escucha marcando \*97.

Las llamadas se pueden poner en espera con música, transferir a otra área avisando antes o directamente, y atender una segunda llamada mientras se habla. Las llamadas a Consulta Externa suenan en todas las clínicas a la vez, y las de Enfermería se reparten por turnos para que ninguna enfermera quede saturada.

La red quedó dividida en cuatro partes independientes: una para administrar los equipos, una para las computadoras del personal, una exclusiva para la telefonía y una para visitas. Las visitas tienen internet con velocidad limitada y no pueden ver nada interno. La telefonía tiene prioridad sobre el resto del tráfico, así que las llamadas se siguen escuchando bien aunque alguien esté descargando archivos grandes.

Solo el personal de TI puede entrar a la configuración de la central, todas las extensiones tienen contraseñas largas y la central bloquea por sí misma a quien intente adivinarlas. La configuración se respalda para poder recuperarla si algo falla.

Para empezar a usarla, cada colaborador recibe su número, su contraseña y la guía rápida de una página que acompaña este informe.

# 3. Descripción general del proyecto
## 3.1 Objetivo

Diseñar, implementar y validar la telefonía IP del Centro Médico Horizonte sobre una red segmentada en VLAN con prioridad para la voz, de modo que el personal pueda comunicarse desde laptops y celulares con extensiones de cuatro dígitos, menú de voz y buzón.

## 3.2 Alcance realizado

La muestra representa las cinco áreas del cliente con diez extensiones, dos por área, sobre un plan de numeración que admite hasta cien por área. Se implementaron todas las funciones obligatorias de telefonía (espera, segunda llamada, transferencia ciega y atendida, buzón con saludo personalizado, IVR con manejo de errores) y cuatro funciones avanzadas: grupo de timbrado, cola con reparto por turnos, música en espera propia y condiciones de horario. La red usa hardware real TP-Link Omada administrado desde su controladora, lo que además cubre el extra de SDN.

## 3.3 Modalidad elegida

Local (stand-alone): la PBX corre en una máquina virtual dentro de la red del cliente, en la VLAN de Voz. La justificación completa está en la sección de investigación.

## 3.4 Herramientas y versiones

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

# 4. Investigación y análisis de alternativas
## 4.1 Modalidades de despliegue

| Criterio | A. Local (stand-alone) | B. Nube pública | C. Híbrida | D. Servicio hospedado (solo análisis) |
|---|---|---|---|---|
| Latencia interna | Mínima, el audio no sale del edificio | El audio interno viaja a internet y regresa | Interna baja, externa depende del enlace | Depende del operador |
| Integración con VLAN y QoS | Total: la PBX vive en la VLAN de Voz y la QoS del ER605 la cubre | La QoS local solo controla la salida; en internet no hay garantías | Parcial | Ninguna sobre la plataforma |
| Exposición a ataques | Baja si no se publica a internet | Alta: IP pública escaneada en minutos | Media (troncal o VPN expuesta) | La asume el proveedor |
| Dependencia de internet | Las llamadas internas funcionan sin internet | Si cae internet, no hay telefonía | Solo las externas dependen de internet | Total |
| Costo inicial | Hardware existente (laptop/servidor) | Bajo | Bajo | Bajo |
| Costo recurrente | Energía y mantenimiento | Instancia mensual (≈ US$5 a 20 en un VPS pequeño) más transferencia | Troncal SIP por minuto | Cuota por usuario (≈ US$15 a 30 por usuario al mes) |
| Control y personalización | Total | Total | Total | Limitado al panel del proveedor |

**Decisión:** modalidad **A (local)**. El centro médico necesita, ante todo, que las llamadas entre áreas no fallen y se escuchen bien aunque la red esté cargada, y eso solo se garantiza si la PBX está dentro de la red que controlamos con VLAN y QoS. Las llamadas internas siguen funcionando si se cae el proveedor de internet, algo importante en Emergencias. El acceso desde fuera (RN-08) se resuelve con una VPN de usuario, sin publicar la PBX en internet. A futuro el cliente puede pasar a un esquema híbrido contratando una troncal SIP comercial.

## 4.2 Tecnologías de PBX

| Plataforma | Licencia | Interfaz | Ventajas | Limitaciones |
|---|---|---|---|---|
| **FreePBX 17 + Asterisk** | GPL, gratuita | Web completa | Comunidad grande, módulos de IVR, colas, horarios, firewall y respaldos incluidos; instalador oficial para Debian 12 | Algunos módulos comerciales son de pago |
| Issabel | GPL | Web | Derivado de Elastix, incluye correo y fax | Comunidad más pequeña, ciclo de versiones lento |
| FreeSWITCH + FusionPBX | MPL/BSD | Web | Muy escalable, multiempresa | Curva de aprendizaje alta |
| Wazo Platform | GPL | API, web limitada | Orientado a integraciones | Documentación pensada para desarrolladores |
| 3CX | Comercial (edición gratuita limitada) | Web muy pulida | Fácil de usar, apps móviles | Restricciones de licencia y de usuarios; hoy exige registro y despliegues específicos |

**Decisión:** **FreePBX 17 sobre Asterisk y Debian 12**. Cubre con módulos gratuitos todo lo que pide el enunciado (IVR, buzón, colas, grupos, horarios, firewall con bloqueo de intentos, respaldos y registros de llamadas), tiene instalador oficial y es la plataforma con más documentación pública, lo que reduce el riesgo con el poco tiempo disponible.

## 4.3 Virtualización

Se eligió VirtualBox porque es gratuito, ya estaba instalado en las laptops del grupo y permite exportar la VM completa en un archivo OVA para moverla a la laptop que se conecta a los equipos de red. Hyper-V queda descartado porque obliga a Windows Pro y complica el puente de red.

## 4.4 Costos referenciales

| Concepto | Solución elegida | Alternativa nube |
|---|---|---|
| Licencia PBX | US$0 | US$0 |
| Servidor | Equipo existente o mini PC (≈ Q2,500 una vez) | VPS ≈ US$10/mes |
| Red | TP-Link Omada ER605 + SG2210P + EAP610 + OC200 (≈ Q5,500 una vez) | Se necesita igual para la red interna |
| Softphones | Gratuitos (MicroSIP, Linphone) | Gratuitos |
| Troncal externa | Opcional, por minuto | Igual |

# 5. Diseño de la solución
## 5.1 VLAN y direccionamiento

| VLAN | Nombre | Red | Puerta de enlace | DHCP | Reservas / fijas |
|---|---|---|---|---|---|
| 10 | Gestión | 192.168.10.0/24 | 192.168.10.1 | .100 a .150 | .2 OC200 · .3 SG2210P · .4 EAP610 · .20 laptop de TI |
| 20 | Administrativa | 192.168.20.0/24 | 192.168.20.1 | .100 a .200 | .2 a .49 para equipos fijos |
| 30 | Voz | 192.168.30.0/24 | 192.168.30.1 | .100 a .200 | **.5 PBX** · .2 a .49 teléfonos fijos |
| 40 | Invitados | 192.168.40.0/24 | 192.168.40.1 | .100 a .250 | Ninguna |

Máscara /24 en todas (254 hosts), suficiente para los 31 colaboradores y sus dispositivos con espacio para crecer. El ER605 hace el enrutamiento entre VLAN (router con interfaces lógicas por VLAN) y el DHCP de cada segmento; el SG2210P lleva las VLAN etiquetadas (802.1Q) hacia el router y el punto de acceso.

## 5.2 Diagrama lógico

@@DIAGRAMA@@

El diagrama físico con puertos exactos lo completa el responsable de red al cablear (ver `PENDIENTES-EQUIPO-RED.md`).

## 5.3 Matriz de comunicación entre VLAN

| Origen ↓ / Destino → | Gestión 10 | Administrativa 20 | Voz 30 | Invitados 40 | Internet |
|---|---|---|---|---|---|
| **Gestión 10** | ✔ | ✔ | ✔ (incluye web de la PBX) | ✔ (diagnóstico) | ✔ |
| **Administrativa 20** | ✖ | ✔ | Solo hacia 192.168.30.5: SIP UDP 5060 y RTP UDP 10000-20000 | ✖ | ✔ |
| **Voz 30** | ✖ | Solo respuestas de la PBX (conexiones establecidas) | ✔ | ✖ | Solo la PBX (actualizaciones y troncal SIP) |
| **Invitados 40** | ✖ | ✖ | ✖ | ✖ (aislamiento de clientes) | ✔ con límite de ancho de banda |

En la PBX se desactiva el audio directo entre teléfonos (*direct media*), así que todo el RTP pasa por 192.168.30.5. Gracias a eso las reglas solo tienen que abrir el tráfico hacia una IP y la QoS se aplica en un punto conocido.

## 5.4 ACL a implementar en el ER605 (Gateway ACL en Omada)

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

## 5.5 NAT y voz

El ER605 hace NAT de salida (masquerade) para todas las VLAN. Para la voz importan tres cosas:

**SIP ALG.** Muchos routers reescriben los mensajes SIP al pasar por el NAT y suelen dañarlos (direcciones mal reescritas, audio en un solo sentido). En este diseño los teléfonos internos hablan con la PBX sin pasar por NAT, y la única salida SIP es la troncal de la PBX, que ya sabe cuál es su IP externa. Por eso se recomienda **desactivar SIP ALG** en el ER605 (Settings → Transmission → NAT → ALG en Omada) y dejar que Asterisk lo maneje.

**Rango RTP.** Asterisk usa UDP 10000 a 20000 para audio. Ese rango es el que se abre en las ACL y el que se marca con EF.

**NAT traversal.** Para la troncal SIP, en FreePBX se configuran la IP externa y las redes locales (Settings → Asterisk SIP Settings → NAT) y las opciones `rtp_symmetric`, `force_rport` y `rewrite_contact` en la troncal. No se abre ningún puerto en la WAN porque la troncal se registra desde adentro; el acceso remoto de usuarios (E1) va por VPN.

## 5.6 DHCP

Cada VLAN tiene su propio servidor DHCP en el ER605 con DNS 1.1.1.1 y 8.8.8.8. La PBX usa IP fija fuera del rango dinámico. No se usa la opción 66 (aprovisionamiento) porque los softphones se configuran a mano.
## 5.7 Plan de numeración (4 dígitos)

El primer dígito 2 identifica la sede; el segundo, el área. Cada área tiene un bloque de 100 números, así que ninguna se queda corta aunque el centro crezca más allá de los 31 colaboradores actuales.

| Rango | Uso | Personal actual |
|---|---|---|
| 2000 | Operadora (recepción) | - |
| 2100 a 2199 | Recepción y Admisión | 4 |
| 2200 a 2299 | Consulta Externa | 10 |
| 2300 a 2399 | Enfermería y Emergencias | 8 |
| 2400 a 2499 | Administración y Contabilidad | 6 |
| 2500 a 2599 | Gerencia y TI | 3 |
| 2900 a 2999 | Servicios (IVR, grupos, colas, buzón) | - |
| 0 + número | Llamadas externas por la troncal | - |
| `*` + código | Funciones del sistema (buzón, desvíos) | - |

El prefijo 0 para salir no choca con ninguna extensión porque todas empiezan con 2.

## 5.8 Extensiones de la muestra

| Ext. | Nombre en pantalla | Área | Buzón | Asignada a (pruebas) | Terminal previsto |
|---|---|---|---|---|---|
| 2101 | Recepción Principal | Recepción y Admisión | Sí | Juan Pablo Méndez | Laptop (MicroSIP) |
| 2102 | Admisión | Recepción y Admisión | No | Jairo Castillo | Celular (Linphone) |
| 2201 | Clínica 1 | Consulta Externa | Sí | Brandon Borrayo | Celular |
| 2202 | Clínica 2 | Consulta Externa | No | Jefferson Abac | Laptop |
| 2301 | Estación de Enfermería | Enfermería y Emergencias | Sí | Brandon Florián | Celular |
| 2302 | Emergencias | Enfermería y Emergencias | No | Joaquín Garrido | Celular |
| 2401 | Administración | Administración y Contabilidad | Sí | José Benjamín Hernández | Laptop |
| 2402 | Contabilidad | Administración y Contabilidad | No | Libre (pruebas) | - |
| 2501 | Gerencia | Gerencia y TI | Sí | Libre (pruebas) | - |
| 2502 | Soporte TI | Gerencia y TI | No | Byron Rodríguez | Laptop |

## 5.9 Números de servicio

| Número | Función | Destino |
|---|---|---|
| 2000 | Operadora | Grupo de timbrado: 2101 y 2102 a la vez; si nadie contesta en 20 s, buzón de 2101 |
| 2900 | Menú de voz (IVR) | Condición de horario: IVR diurno o nocturno |
| 2910 | Grupo Consulta Externa | 2201 y 2202 timbran a la vez (ringall) |
| 2920 | Cola Enfermería y Emergencias | 2301 y 2302, estrategia *rrmemory* (reparte por turnos), música mientras espera |
| 2999 | Buzón de voz general | Pide extensión y PIN para escuchar mensajes desde cualquier teléfono |
| `*97` | Mi buzón | Entra directo al buzón de la extensión propia (pide PIN) |
| `*98` | Buzón de otra extensión | Igual que 2999 |

## 5.10 IVR (2900)

Mensaje de bienvenida (diurno):

> «Gracias por llamar al Centro Médico Horizonte. Para Recepción y citas, marque 1. Para Consulta Externa, marque 2. Para Enfermería y Emergencias, marque 3. Para Administración y Contabilidad, marque 4. Si desea hablar con la operadora, marque 0 o espere en la línea.»

| Tecla | Destino |
|---|---|
| 1 | 2000 (Recepción) |
| 2 | 2910 (grupo Consulta Externa) |
| 3 | 2920 (cola Enfermería y Emergencias) |
| 4 | 2401 (Administración) |
| 0 | 2000 (operadora) |
| Opción inválida | «La opción marcada no es válida» y repite el menú; al tercer error pasa a la operadora |
| Sin respuesta (7 s) | Repite el menú una vez; si sigue sin marcar, pasa a la operadora |

Fuera de horario (lunes a viernes 07:00 a 19:00, sábado 07:00 a 12:00), la condición de horario envía al IVR nocturno:

> «Gracias por llamar al Centro Médico Horizonte. En este momento estamos fuera del horario de atención, que es de lunes a viernes de siete de la mañana a siete de la noche y sábados de siete a doce. Si se trata de una emergencia, marque 3. Para dejar un mensaje a Recepción, marque 1.»

Las grabaciones se cargaron en Admin → System Recordings. Se generaron en español con voz sintética para las pruebas y conviene regrabarlas con la voz de un integrante antes de la demo.
## 5.11 Clases de tráfico

| Clase | Qué incluye | Identificación | DSCP | Tratamiento |
|---|---|---|---|---|
| 1. Medios de voz | Audio RTP de llamadas | UDP 10000-20000 desde/hacia 192.168.30.5 | **EF (46)** | Cola de prioridad estricta |
| 2. Señalización | SIP de teléfonos y troncal | UDP 5060 (extensiones), 5160 (troncal) | **CS3 (24)** | Prioridad alta, después de EF |
| 3. Datos críticos y gestión | Administración de equipos, controladora Omada, web de la PBX | Tráfico de la VLAN 10 | AF21 (18) | Prioridad media |
| 4. Mejor esfuerzo | Navegación y datos del personal administrativo | VLAN 20, resto del tráfico | DF (0) | Cola normal |
| 5. Invitados | Internet para visitas | VLAN 40 | CS1 (8) | Prioridad mínima y límite fijo de ancho de banda |

**Por qué CS3 para la señalización.** RFC 4594 sugiere CS5 para señalización, pero la práctica más extendida en telefonía IP (y el valor por defecto de Asterisk y de la mayoría de teléfonos) es CS3. Elegimos CS3 para que la PBX, los softphones y la red usen el mismo valor sin reescribir marcas, y porque la señalización ocupa muy poco ancho de banda: lo importante es que no compita con el audio (EF) y que quede por encima de los datos.

## 5.12 Dónde se marca y dónde se prioriza

Asterisk marca sus propios paquetes: en FreePBX (Settings → Asterisk SIP Settings) el audio sale con `tos_audio = ef` y la señalización con `tos_sip = cs3`. Como todo el audio pasa por la PBX (*direct media* desactivado), la mitad de cada llamada (PBX → teléfono) siempre llega bien marcada. En el sentido teléfono → PBX, los softphones de Windows no siempre pueden marcar DSCP, así que el SG2210P y el ER605 clasifican por puertos y por destino 192.168.30.5 y aplican la prioridad aunque el paquete llegue con DSCP 0.

En el SG2210P se activa QoS en modo DSCP (confiar en la marca) y se mapea EF a la cola más alta. En el EAP610 se deja WMM activo, que traduce EF a la categoría de acceso de voz del Wi-Fi. En el ER605 se configura el control de ancho de banda: un límite por VLAN para invitados (por ejemplo 5 Mbps bajada / 2 Mbps subida) y, durante la prueba, un límite artificial al enlace.

## 5.13 Prueba bajo congestión

1. Llamada activa entre una extensión en la VLAN 20 (laptop) y otra en la VLAN 30 (celular en HZ-Voz).
2. Se limita el enlace del ER605 (por ejemplo a 10 Mbps) para que se pueda saturar.
3. En la PBX corre `iperf3 -s`; desde otra laptop en la VLAN 20 o 40 se envía `iperf3 -c <servidor> -u -b 50M -t 60` (UDP por encima del límite).
4. **Sin QoS:** se mide durante 60 s con Wireshark en la laptop (Telephony → RTP → RTP Streams: jitter, pérdida, delta máximo) y se anota la calidad percibida.
5. **Con QoS:** se activa la política y se repite igual.
6. Se toman capturas de Wireshark con el campo DSCP visible (filtro `rtp`, columna `ip.dsfield.dscp`).

## 5.14 Códecs y ancho de banda

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


# 6. Implementación
## 6.1 Plataforma

La central se instaló en una máquina virtual de VirtualBox (2 vCPU, 3 GB de RAM y 30 GB de disco) con Debian 12.15. El sistema se dejó en modo texto, porque una PBX no necesita entorno gráfico y así libera memoria para Asterisk. Sobre esa base se ejecutó el instalador oficial de Sangoma para Debian 12, que dejó en operación FreePBX 17.0.33.2 con Asterisk 22.11.0. Los scripts usados están en la carpeta `vm-scripts` del repositorio, de modo que la instalación se puede repetir en otro equipo.

La VM tiene dos adaptadores de red. El primero trabaja en modo puente y, en producción, queda conectado a un puerto de acceso del SG2210P en la VLAN 30 con la dirección fija 192.168.30.5; el script `hz-produccion.sh` hace ese cambio y ajusta las zonas del firewall. El segundo adaptador es de tipo solo-anfitrión y se usó para administrar la PBX desde la laptop durante la preparación.

## 6.2 Telefonía

Las diez extensiones de la muestra se crearon por importación masiva (Bulk Handler) con contraseñas SIP aleatorias de 24 caracteres. Cada extensión usa el controlador PJSIP, tiene la llamada en espera habilitada y el audio directo desactivado, de manera que todo el RTP pasa por la PBX. Esa decisión simplifica las reglas entre VLAN y concentra la priorización de la voz en una sola dirección.

Las cinco extensiones con buzón tienen PIN de seis dígitos distinto del número de extensión. El idioma del sistema es español latinoamericano (es_419), con lo cual el buzón, los tonos y los mensajes del sistema se escuchan en español. Durante las pruebas se detectó que el paquete de sonidos es_419 traía 34 archivos vacíos, entre ellos el tono que avisa el inicio de la grabación; se reemplazaron por su versión en español general.

El IVR se construyó con dos menús. El diurno ofrece cuatro áreas y la operadora; ante una opción inválida repite el menú dos veces con un mensaje propio y luego pasa a la operadora, y si el llamante no marca nada repite una vez y también lo pasa a la operadora. El nocturno ofrece Emergencias o dejar un mensaje a Recepción. Una condición de horario (lunes a viernes de 7:00 a 19:00 y sábado de 7:00 a 12:00, zona America/Guatemala) decide cuál se reproduce, y el número interno 2900 entra a esa condición. Las locuciones se generaron en español con voz sintética para la prueba y se recomienda regrabarlas con una voz del centro.

Para la atención por áreas se configuraron la operadora 2000 y el grupo 2910 de Consulta Externa, ambos con timbrado simultáneo, y la cola 2920 de Enfermería y Emergencias con estrategia *rrmemory*, que reparte las llamadas por turnos. La música en espera es una pieza propia sin derechos de autor y reemplaza a la de fábrica en la clase por defecto.

## 6.3 Códecs

Se dejaron habilitados únicamente G.711 µ-law, G.711 A-law y G.722, en ese orden. Así se evita la transcodificación en la PBX, y el ancho de banda de G.711 (unos 88 kbps por sentido con etiqueta 802.1Q) es irrelevante frente a la capacidad de la LAN.

## 6.4 Seguridad

El firewall de FreePBX quedó activo con la red de gestión como zona de confianza y las VLAN administrativa y de voz como zona local, que solo da acceso a la telefonía. El Responsive Firewall limita los intentos de registro SIP y bloquea por 24 horas a quien insiste con credenciales falsas, y fail2ban protege además SSH y la interfaz web. La protección contra peticiones que no provienen del propio panel se dejó activa. El sistema se actualizó por completo al instalarse, las actualizaciones automáticas de seguridad de Debian están habilitadas, y se programó un respaldo diario de la base de datos de la PBX a las 23:00, además del respaldo completo entregado en los anexos.

## 6.5 Red

[PENDIENTE: el equipo de red describe aquí la configuración real en la controladora OC200: adopción de equipos, redes LAN y VLAN, perfiles de puerto del SG2210P, SSID del EAP610, ACL del ER605, desactivación de SIP ALG y control de ancho de banda. Referencia de diseño en la sección 5.]

# 7. Evidencias gráficas
Todas las capturas muestran la fecha y la hora de Windows y ninguna contiene contraseñas. Se dejan a pantalla completa; pueden recortarse en la versión final.

@@FIGURAS@@

# 8. Pruebas y verificación
La matriz siguiente registra cada prueba con su resultado esperado y el obtenido. La columna *Evidencia* indica el número de figura de la sección 7. Las pruebas marcadas como pendientes requieren la red Omada o tres o más terminales simultáneas y se completan en la sesión de integración.
## 8.1 Matriz de pruebas

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

## 8.2 Resultados de QoS

[PENDIENTE: el responsable de QoS llena esta tabla con la prueba de congestión con iperf3 descrita en la sección 5, y agrega las figuras de Wireshark con el DSCP visible (EF en RTP, CS3 en SIP) y las estadísticas del ER605/SG2210P.]

| Métrica | Objetivo | Sin QoS | Con QoS |
|---|---|---|---|
| Retardo unidireccional | ≤ 150 ms | [PENDIENTE] | [PENDIENTE] |
| Jitter | < 30 ms | [PENDIENTE] | [PENDIENTE] |
| Pérdida | < 1 % | [PENDIENTE] | [PENDIENTE] |
| Calidad percibida | Clara | [PENDIENTE] | [PENDIENTE] |

Como referencia sin congestión, en la red de preparación el celular registrado por Wi-Fi mostró un RTT de 37 ms hacia la PBX y la laptop de 1 a 2 ms (figura 17); por Tailscale desde datos móviles el RTT fue de unos 170 ms (figura 25), lo que da un retardo de ida de alrededor de 85 ms, dentro del límite de 150 ms de ITU-T G.114.

## 8.3 Pruebas de seguridad

| Prueba | Resultado |
|---|---|
| Acceso al panel solo desde redes de confianza | Configurado en el firewall de FreePBX (figura 15); [PENDIENTE: verificar desde la VLAN 20 en la red Omada] |
| Bloqueo por intentos fallidos | Responsive Firewall y fail2ban activos (figura 16); [PENDIENTE: prueba P-29] |
| Peticiones a la administración desde enlaces externos | Bloqueadas por la verificación de origen de FreePBX ("Potential Security Breach") |
| Respaldo y restauración | Respaldo completo generado (base de datos, configuración y audios) y respaldo diario programado |

# 9. Componentes extra
## 9.1 E1 · Acceso desde red pública (RN-08)

**Mecanismo:** VPN de usuario con **Tailscale** (WireGuard) instalada en la VM de la PBX. El celular con datos móviles se une a la red privada de Tailscale y registra su softphone a la IP de Tailscale de la PBX (100.x.y.z). La PBX no tiene ningún puerto abierto a internet.

| Riesgo | Mitigación |
|---|---|
| Robo o pérdida del celular con la VPN activa | Acceso a Tailscale con cuenta del grupo y verificación en dos pasos; el dispositivo se elimina desde la consola |
| Uso de la extensión para llamadas fraudulentas | La extensión remota no tiene permiso de ruta de salida |
| Exposición de la PBX en internet | Ninguna: solo se alcanza por el túnel cifrado |
| Calidad variable en datos móviles | Se permite G.711; se documenta la calidad obtenida |

Si se prefiere no depender de un servicio externo, la alternativa es la VPN WireGuard del ER605 (según firmware).

| Prueba | Esperado | Resultado |
|---|---|---|
| E1-01 | Celular con datos móviles (Wi-Fi apagado) llama a una extensión interna con audio en ambos sentidos | **Correcto**: 2201 por Tailscale (100.103.5.71, ~170 ms) llamó a 2502; capturas 24 a 26 |

## 9.2 E2 · SDN con TP-Link Omada (RN-09)

La red completa se administra desde la controladora **OC200**: adopción del ER605, SG2210P y EAP610; creación de las VLAN como redes LAN; SSID por VLAN; ACL de gateway; control de ancho de banda y QoS. Los criterios de aceptación están en el Anexo A (PF-TEL-001-2026-A1).

| Prueba | Esperado | Resultado |
|---|---|---|
| E2-01 | Los tres equipos aparecen como *Connected* en la controladora | [PENDIENTE] |
| E2-02 | Un cambio hecho en la controladora (por ejemplo, el límite de invitados) se aplica sin tocar el equipo | [PENDIENTE] |
| E2-03 | Topología y estadísticas de clientes por VLAN visibles en la controladora | [PENDIENTE] |

## 9.3 E3 · Troncal SIP (RN-10)

Troncal PJSIP registrada en **sip2sip.info** (cuenta gratuita). Ruta de salida: prefijo `0` seguido del usuario SIP o número de destino; ruta de entrada: las llamadas que llegan a la cuenta van a la condición de horario y luego al IVR 2900. **Limitaciones encontradas:** sip2sip.info no atiende SIP en su dominio (apunta a su web); hubo que declarar el proxy `sip:proxy.sipthor.net;lr`. El servicio gratuito solo conecta con otras direcciones SIP, no con la red telefónica. La ruta de salida usa el patrón `0|X.` (solo dígitos) y no `.`, para evitar marcaciones arbitrarias.

| Prueba | Esperado | Resultado |
|---|---|---|
| E3-01 | Una extensión marca 0 + destino externo y la llamada sale por la troncal | **Correcto**: 04444 (eco de sip2sip) contestó; captura 27 |
| E3-02 | Una llamada desde fuera a la cuenta sip2sip entra al IVR | Configurada; pendiente de probar desde otra cuenta SIP externa |

## 9.4 E4 · Funciones avanzadas

| Función | Implementación |
|---|---|
| Grupo de timbrado | 2000 operadora y 2910 Consulta Externa (ringall) |
| Cola con estrategia | 2920 Enfermería y Emergencias, rrmemory |
| Música en espera personalizada | Clase "horizonte" con audio propio libre de derechos |
| Condiciones horarias | IVR diurno y nocturno según horario de atención |

# 10. Matriz de trazabilidad


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

# 11. Riesgos, limitaciones y lecciones aprendidas
| Problema | Impacto | Cómo se resolvió | Qué haríamos distinto |
|---|---|---|---|
| La instalación desatendida de VirtualBox para Debian incluyó entorno gráfico | Instalación mucho más lenta y una VM más pesada de lo necesario para un servidor | Se dejó el sistema en modo texto (`multi-user.target`) y se eliminaron los paquetes de escritorio antes de instalar FreePBX | Instalar Debian a mano marcando solo "servidor SSH" y "utilidades estándar" |
| Windows mantenía activo su hipervisor (Hyper-V, plataforma de VM y seguridad basada en virtualización) | VirtualBox trabajó en modo de compatibilidad (NEM), varias veces más lento | Se desactivaron las características y la VBS; aun así el hipervisor siguió presente, por lo que la preparación se completó en modo compatible | Revisar desde el inicio `HypervisorPresent` en cada laptop y elegir para la PBX la que no tenga Hyper-V |
| La laptop de preparación no tiene puerto Ethernet | No se puede conectar la PBX al switch en su VLAN | La VM se exporta como OVA y se importa en una laptop con Ethernet; el adaptador puente se cambia al puerto cableado | Definir desde el diseño qué equipo será el servidor de la demo |
| El paquete de sonidos en español latinoamericano traía 34 archivos vacíos, entre ellos el tono del buzón | El buzón grababa sin avisar y colgaba por silencio | Se reemplazaron por la versión en español general y se fijó es_419 como idioma por defecto | Escuchar todas las locuciones del sistema antes de dar por buena la configuración |
| sip2sip.info no atiende SIP en su propio dominio | La troncal no se registraba | Se declaró el proxy `proxy.sipthor.net` | Revisar la documentación del proveedor sobre registros SRV y proxies |
| El panel mostraba el registro de llamadas en hora UTC | Evidencias con hora confusa | Se configuró la zona America/Guatemala en FreePBX | Fijar la zona horaria en todos los componentes desde la instalación |
| Equipos Omada prestados y no disponibles todo el tiempo | La red se configuró en una ventana corta | Se dejó la configuración documentada paso a paso en `PENDIENTES-EQUIPO-RED.md` para aplicarla sin improvisar | Reservar los equipos con más anticipación |

## 11.1 Riesgos que quedan para el cliente

La PBX corre en una sola máquina virtual, así que una falla de la laptop o del disco deja al centro sin telefonía interna hasta restaurar el respaldo. Para producción recomendamos un equipo dedicado (mini PC) con respaldo diario automático y una UPS. Las grabaciones del IVR de esta versión se generaron con voz sintética y conviene reemplazarlas por una voz real del centro.

# 12. Conclusiones y recomendaciones
Una PBX local sobre FreePBX cubre todas las necesidades de comunicación interna del Centro Médico Horizonte sin costo de licencias, y al estar dentro de la VLAN de Voz se beneficia directamente de la segmentación y de la prioridad configuradas en la red.

La segmentación en cuatro VLAN con una matriz de comunicación explícita reduce la superficie de ataque: las visitas no ven ningún equipo interno y la administración de la central solo es posible desde la red de gestión. Desactivar el audio directo entre teléfonos simplificó las reglas de acceso y la QoS, porque todo el audio pasa por una sola dirección conocida.

El plan de numeración por bloques de cien deja espacio de sobra para crecer y hace que el número de cada extensión diga a qué área pertenece, lo que facilita el uso para personal no técnico.

**Recomendaciones al cliente:** mover la PBX a un equipo dedicado con UPS; programar respaldos automáticos diarios y guardar una copia fuera del servidor; grabar las locuciones del IVR con una voz del personal; contratar una troncal SIP comercial cuando quiera recibir llamadas desde la red telefónica pública, manteniendo el prefijo 0 y restringiendo los destinos internacionales; y revisar cada mes el registro de intentos bloqueados del firewall.

# 13. Referencias
Babiarz, J., Chan, K., & Baker, F. (2006). *Configuration guidelines for DiffServ service classes* (RFC 4594). Internet Engineering Task Force. https://www.rfc-editor.org/rfc/rfc4594

Davie, B., Charny, A., Bennett, J. C. R., Benson, K., Le Boudec, J. Y., Courtney, W., Davari, S., Firoiu, V., & Stiliadis, D. (2002). *An expedited forwarding PHB (per-hop behavior)* (RFC 3246). Internet Engineering Task Force. https://www.rfc-editor.org/rfc/rfc3246

IEEE. (2022). *IEEE standard for local and metropolitan area networks: Bridges and bridged networks* (IEEE Std 802.1Q-2022).

International Telecommunication Union. (1988). *Pulse code modulation (PCM) of voice frequencies* (ITU-T Recommendation G.711).

International Telecommunication Union. (2003). *One-way transmission time* (ITU-T Recommendation G.114).

Nichols, K., Blake, S., Baker, F., & Black, D. (1998). *Definition of the differentiated services field (DS field) in the IPv4 and IPv6 headers* (RFC 2474). Internet Engineering Task Force. https://www.rfc-editor.org/rfc/rfc2474

Rosenberg, J., Schulzrinne, H., Camarillo, G., Johnston, A., Peterson, J., Sparks, R., Handley, M., & Schooler, E. (2002). *SIP: Session initiation protocol* (RFC 3261). Internet Engineering Task Force. https://www.rfc-editor.org/rfc/rfc3261

Sangoma Technologies. (2024). *FreePBX 17 documentation*. https://sangomakb.atlassian.net/wiki/spaces/FP/overview

Sangoma Technologies. (2024). *sng_freepbx_debian_install* [Software]. GitHub. https://github.com/FreePBX/sng_freepbx_debian_install

Schulzrinne, H., Casner, S., Frederick, R., & Jacobson, V. (2003). *RTP: A transport protocol for real-time applications* (RFC 3550). Internet Engineering Task Force. https://www.rfc-editor.org/rfc/rfc3550

TP-Link. (2024). *Omada SDN controller user guide*. https://www.omadanetworks.com/

Universidad Mariano Gálvez de Guatemala. (2026). *Proyecto final de curso: Diseño e implementación de una central telefónica virtual (PBX IP) con segmentación por VLAN, calidad de servicio y acceso seguro* (PF-TEL-001-2026, v1.2).

Valin, J. M., Vos, K., & Terriberry, T. (2012). *Definition of the Opus audio codec* (RFC 6716). Internet Engineering Task Force. https://www.rfc-editor.org/rfc/rfc6716

# Anexos

Se entregan en el archivo comprimido junto con este informe:

- **Anexo A.** Guía rápida de usuario final (una página).
- **Anexo B.** Respaldo de configuración de la PBX y exportación de la controladora Omada, con contraseñas y claves retiradas.
- **Anexo C.** Bitácora de trabajo con los aportes de cada integrante por hito.
