# Implementación

## Plataforma

La central se instaló en una máquina virtual de VirtualBox (2 vCPU, 3 GB de RAM y 30 GB de disco) con Debian 12.15. El sistema se dejó en modo texto, porque una PBX no necesita entorno gráfico y así libera memoria para Asterisk. Sobre esa base se ejecutó el instalador oficial de Sangoma para Debian 12, que dejó en operación FreePBX 17.0.33.2 con Asterisk 22.11.0. Los scripts usados están en la carpeta `vm-scripts` del repositorio, de modo que la instalación se puede repetir en otro equipo.

La VM tiene dos adaptadores de red. El primero trabaja en modo puente y, en producción, queda conectado a un puerto de acceso del SG2210P en la VLAN 30 con la dirección fija 192.168.30.5; el script `hz-produccion.sh` hace ese cambio y ajusta las zonas del firewall. El segundo adaptador es de tipo solo-anfitrión y se usó para administrar la PBX desde la laptop durante la preparación.

## Telefonía

Las diez extensiones de la muestra se crearon por importación masiva (Bulk Handler) con contraseñas SIP aleatorias de 24 caracteres. Cada extensión usa el controlador PJSIP, tiene la llamada en espera habilitada y el audio directo desactivado, de manera que todo el RTP pasa por la PBX. Esa decisión simplifica las reglas entre VLAN y concentra la priorización de la voz en una sola dirección.

Las cinco extensiones con buzón tienen PIN de seis dígitos distinto del número de extensión. El idioma del sistema es español latinoamericano (es_419), con lo cual el buzón, los tonos y los mensajes del sistema se escuchan en español. Durante las pruebas se detectó que el paquete de sonidos es_419 traía 34 archivos vacíos, entre ellos el tono que avisa el inicio de la grabación; se reemplazaron por su versión en español general.

El IVR se construyó con dos menús. El diurno ofrece cuatro áreas y la operadora; ante una opción inválida repite el menú dos veces con un mensaje propio y luego pasa a la operadora, y si el llamante no marca nada repite una vez y también lo pasa a la operadora. El nocturno ofrece Emergencias o dejar un mensaje a Recepción. Una condición de horario (lunes a viernes de 7:00 a 19:00 y sábado de 7:00 a 12:00, zona America/Guatemala) decide cuál se reproduce, y el número interno 2900 entra a esa condición. Las locuciones se generaron en español con voz sintética para la prueba y se recomienda regrabarlas con una voz del centro.

Para la atención por áreas se configuraron la operadora 2000 y el grupo 2910 de Consulta Externa, ambos con timbrado simultáneo, y la cola 2920 de Enfermería y Emergencias con estrategia *rrmemory*, que reparte las llamadas por turnos. La música en espera es una pieza propia sin derechos de autor y reemplaza a la de fábrica en la clase por defecto.

## Códecs

Se dejaron habilitados únicamente G.711 µ-law, G.711 A-law y G.722, en ese orden. Así se evita la transcodificación en la PBX, y el ancho de banda de G.711 (unos 88 kbps por sentido con etiqueta 802.1Q) es irrelevante frente a la capacidad de la LAN.

## Seguridad

El firewall de FreePBX quedó activo con la red de gestión como zona de confianza y las VLAN administrativa y de voz como zona local, que solo da acceso a la telefonía. El Responsive Firewall limita los intentos de registro SIP y bloquea por 24 horas a quien insiste con credenciales falsas, y fail2ban protege además SSH y la interfaz web. La protección contra peticiones que no provienen del propio panel se dejó activa. El sistema se actualizó por completo al instalarse, las actualizaciones automáticas de seguridad de Debian están habilitadas, y se programó un respaldo diario de la base de datos de la PBX a las 23:00, además del respaldo completo entregado en los anexos.

## Red

[PENDIENTE: el equipo de red describe aquí la configuración real en la controladora OC200: adopción de equipos, redes LAN y VLAN, perfiles de puerto del SG2210P, SSID del EAP610, ACL del ER605, desactivación de SIP ALG y control de ancho de banda. Referencia de diseño en la sección 5.]
