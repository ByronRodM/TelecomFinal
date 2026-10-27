# Riesgos, limitaciones y lecciones aprendidas

| Problema | Impacto | Cómo se resolvió | Qué haríamos distinto |
|---|---|---|---|
| La instalación desatendida de VirtualBox para Debian incluyó entorno gráfico | Instalación mucho más lenta y una VM más pesada de lo necesario para un servidor | Se dejó el sistema en modo texto (`multi-user.target`) y se eliminaron los paquetes de escritorio antes de instalar FreePBX | Instalar Debian a mano marcando solo "servidor SSH" y "utilidades estándar" |
| Windows mantenía activo su hipervisor (Hyper-V, plataforma de VM y seguridad basada en virtualización) | VirtualBox trabajó en modo de compatibilidad (NEM), varias veces más lento | Se desactivaron las características y la VBS; aun así el hipervisor siguió presente, por lo que la preparación se completó en modo compatible | Revisar desde el inicio `HypervisorPresent` en cada laptop y elegir para la PBX la que no tenga Hyper-V |
| La laptop de preparación no tiene puerto Ethernet | No se puede conectar la PBX al switch en su VLAN | La VM se exporta como OVA y se importa en una laptop con Ethernet; el adaptador puente se cambia al puerto cableado | Definir desde el diseño qué equipo será el servidor de la demo |
| El paquete de sonidos en español latinoamericano traía 34 archivos vacíos, entre ellos el tono del buzón | El buzón grababa sin avisar y colgaba por silencio | Se reemplazaron por la versión en español general y se fijó es_419 como idioma por defecto | Escuchar todas las locuciones del sistema antes de dar por buena la configuración |
| sip2sip.info no atiende SIP en su propio dominio | La troncal no se registraba | Se declaró el proxy `proxy.sipthor.net` | Revisar la documentación del proveedor sobre registros SRV y proxies |
| El panel mostraba el registro de llamadas en hora UTC | Evidencias con hora confusa | Se configuró la zona America/Guatemala en FreePBX | Fijar la zona horaria en todos los componentes desde la instalación |
| Equipos Omada prestados y no disponibles todo el tiempo | La red se configuró en una ventana corta | Se dejó la configuración documentada paso a paso en `PENDIENTES-EQUIPO-RED.md` para aplicarla sin improvisar | Reservar los equipos con más anticipación |

## Riesgos que quedan para el cliente

La PBX corre en una sola máquina virtual, así que una falla de la laptop o del disco deja al centro sin telefonía interna hasta restaurar el respaldo. Para producción recomendamos un equipo dedicado (mini PC) con respaldo diario automático y una UPS. Las grabaciones del IVR de esta versión se generaron con voz sintética y conviene reemplazarlas por una voz real del centro.
