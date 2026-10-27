# Conclusiones y recomendaciones

Una PBX local sobre FreePBX cubre todas las necesidades de comunicación interna del Centro Médico Horizonte sin costo de licencias, y al estar dentro de la VLAN de Voz se beneficia directamente de la segmentación y de la prioridad configuradas en la red.

La segmentación en cuatro VLAN con una matriz de comunicación explícita reduce la superficie de ataque: las visitas no ven ningún equipo interno y la administración de la central solo es posible desde la red de gestión. Desactivar el audio directo entre teléfonos simplificó las reglas de acceso y la QoS, porque todo el audio pasa por una sola dirección conocida.

El plan de numeración por bloques de cien deja espacio de sobra para crecer y hace que el número de cada extensión diga a qué área pertenece, lo que facilita el uso para personal no técnico.

**Recomendaciones al cliente:** mover la PBX a un equipo dedicado con UPS; programar respaldos automáticos diarios y guardar una copia fuera del servidor; grabar las locuciones del IVR con una voz del personal; contratar una troncal SIP comercial cuando quiera recibir llamadas desde la red telefónica pública, manteniendo el prefijo 0 y restringiendo los destinos internacionales; y revisar cada mes el registro de intentos bloqueados del firewall.
