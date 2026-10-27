# Índice de evidencias

Todas las capturas muestran el reloj de Windows (fecha y hora) y ocultan contraseñas.

| Archivo | Muestra | Criterio |
|---|---|---|
| `capturas/01-debian-instalacion-apt.jpg` | Instalación desatendida de Debian 12 en la VM HZ-PBX (primer intento; se repitió en versión mínima por el modo de compatibilidad de Windows) | C |
| `capturas/02-debian-base-guest-additions.jpg` | Consola de la VM: sistema en modo texto (multi-user), Guest Additions y carpeta compartida activas | C |
| `capturas/03-resumen-pbx-consola.jpg` | Consola: versiones (Debian 12.15, FreePBX 17.0.33.2, Asterisk 22.11.0), 10 extensiones PJSIP, 5 buzones, grupos 2000/2910, cola 2920, servicios 2900/2999, IVR diurno y nocturno, horario, idioma español latinoamericano (es_419), audio directo desactivado y TOS de audio 184 (EF) | C, D, F |
| `capturas/04-virtualbox-vm-hz-pbx.jpg` | VirtualBox: VM HZ-PBX (Debian 12, 3 GB RAM, 2 CPU, disco 30 GB, adaptador puente + solo-anfitrión, carpeta compartida) | C |
| `capturas/05-freepbx-extensiones.jpg` | FreePBX: las 10 extensiones PJSIP de 4 dígitos con nombres por área y llamada en espera (CW) activa | C, D |
| `capturas/06-freepbx-ivr-opciones.jpg` | IVR Menu Diurno: opciones 0 y 1 (operadora 2000), 2 (grupo 2910), 3 (cola 2920), 4 (extensión 2401); sin respuesta va a la operadora con aviso | D |
| `capturas/07-freepbx-ivr-invalido-timeout.jpg` | IVR Menu Diurno: bienvenida hz-bienvenida, marcación directa, espera de 7 s, 2 reintentos ante opción inválida con mensaje propio y paso a la operadora, 1 reintento sin respuesta | D |
| `capturas/08-freepbx-codecs.jpg` | Asterisk SIP Settings: solo G.711 µ-law, G.711 A-law y G.722 habilitados, en ese orden de preferencia | C |
| `capturas/09-freepbx-ring-groups.jpg` | Grupos de timbrado: 2000 Operadora - Recepción y 2910 Consulta Externa | D, E4 |
| `capturas/10-freepbx-cola-agentes.jpg` | Cola 2920: agentes estáticos 2301 y 2302; la cola es destino de la opción 3 de ambos IVR | D, E4 |
| `capturas/11-freepbx-cola-estrategia.jpg` | Cola 2920: estrategia rrmemory, música en espera propia (clase horizonte) y destino de respaldo al buzón de 2301 | D, E4 |
| `capturas/12-freepbx-condicion-horario.jpg` | Condición de horario (zona America/Guatemala): en horario va al Menu Diurno y fuera de horario al Menu Nocturno; se marca desde 2900 y se fuerza con *271 | D, E4 |
| `capturas/13-freepbx-grabaciones.jpg` | System Recordings: las 5 locuciones propias del IVR en español (bienvenida, fuera de horario, opción inválida, sin respuesta, transferencia) | D |
| `capturas/14-freepbx-musica-espera.jpg` | Música en espera: clase default con la pieza propia del centro, clase horizonte (cola) y original (música de fábrica conservada) | D, E4 |
| `capturas/15-freepbx-firewall-redes.jpg` | Firewall de FreePBX: redes de confianza (gestión VLAN 10 y redes de preparación) y locales (VLAN 20 y 30, solo telefonía) | C, B |
| `capturas/16-freepbx-responsive-firewall.jpg` | Responsive Firewall activo para SIP (pjsip): limita intentos de registro y bloquea 24 h al atacante; umbrales por niveles | C |
| `capturas/17-terminales-registradas.jpg` | Consola: 2101 (celular con Linphone, 192.168.1.99) y 2502 (MicroSIP en la laptop, 192.168.1.101) registrados y disponibles; rango RTP 10000-20000 | C, E |
| `capturas/18-llamada-laptop-movil.jpg` | Llamada en curso de 2502 (MicroSIP, laptop) a 2101 (Linphone, celular): ambos canales Up, códec G.711 µ-law; prueba P-04 laptop ↔ móvil | D, E |
| `capturas/19-llamada-en-espera.jpg` | Llamada en espera desde MicroSIP ("Poner en espera"): el celular escucha la música propia (clase default en /var/lib/asterisk/moh); prueba P-08 | D |
| `capturas/20-transferencia-ciega.jpg` | Transferencia ciega (Transf. Directa) en MicroSIP: la llamada del celular 2101 se envía al IVR 2900 sin consulta; prueba P-10 | D |
| `capturas/21-transferencia-al-ivr.jpg` | Resultado de la transferencia ciega: el celular 2101 queda en el IVR (contexto ivr-1, reproduciendo la bienvenida) y MicroSIP queda libre | D |
| `capturas/22-buzon-y-cdr-consola.jpg` | Consola: 5 buzones, 3 mensajes dejados por 2101 en el buzón 2501 (ya escuchados) y CDR con llamadas a buzón, consulta con *97/*98 (VoiceMailMain), llamadas atendidas, no contestadas y ocupadas; pruebas P-13 a P-16 y P-31 | D, C |
| `capturas/23-freepbx-cdr.jpg` | Reports → CDR: 25 llamadas de prueba con hora local (llamadas, ocupado, no contestada, buzón, consulta *97/*98, grupo 2000, IVR 2900) | C, D |
| `capturas/24-e1-microsip-llamada-remota.jpg` | Extra E1: MicroSIP (2502) conectado con Clínica 1 (2201), un celular en datos móviles fuera de la red local | E1 |
| `capturas/25-e1-consola-tailscale.jpg` | Extra E1: Tailscale con la PBX (100.114.1.2) y el celular (100.103.5.71) conectados en directo desde la IP pública del operador móvil; 2201 registrado por el túnel (RTT ≈170 ms); llamada estableciéndose | E1 |
| `capturas/26-e1-trafico-tailscale.jpg` | Extra E1: después de la llamada, el túnel registra unos 400 KB enviados y recibidos (audio bidireccional) | E1 |
| `capturas/27-e3-troncal-sip2sip.jpg` | Extra E3: troncal sip2sip registrada (vía proxy.sipthor.net), ruta de salida 0 + X., ruta de entrada hacia la condición de horario/IVR, y llamada de salida al eco 4444 por la troncal (ANSWERED) | E3 |
