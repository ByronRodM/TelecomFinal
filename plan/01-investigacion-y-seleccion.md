# 01 · Investigación y selección tecnológica (criterio A)

## Modalidades de despliegue

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

## Tecnologías de PBX

| Plataforma | Licencia | Interfaz | Ventajas | Limitaciones |
|---|---|---|---|---|
| **FreePBX 17 + Asterisk** | GPL, gratuita | Web completa | Comunidad grande, módulos de IVR, colas, horarios, firewall y respaldos incluidos; instalador oficial para Debian 12 | Algunos módulos comerciales son de pago |
| Issabel | GPL | Web | Derivado de Elastix, incluye correo y fax | Comunidad más pequeña, ciclo de versiones lento |
| FreeSWITCH + FusionPBX | MPL/BSD | Web | Muy escalable, multiempresa | Curva de aprendizaje alta |
| Wazo Platform | GPL | API, web limitada | Orientado a integraciones | Documentación pensada para desarrolladores |
| 3CX | Comercial (edición gratuita limitada) | Web muy pulida | Fácil de usar, apps móviles | Restricciones de licencia y de usuarios; hoy exige registro y despliegues específicos |

**Decisión:** **FreePBX 17 sobre Asterisk y Debian 12**. Cubre con módulos gratuitos todo lo que pide el enunciado (IVR, buzón, colas, grupos, horarios, firewall con bloqueo de intentos, respaldos y registros de llamadas), tiene instalador oficial y es la plataforma con más documentación pública, lo que reduce el riesgo con el poco tiempo disponible.

## Virtualización

Se eligió VirtualBox porque es gratuito, ya estaba instalado en las laptops del grupo y permite exportar la VM completa en un archivo OVA para moverla a la laptop que se conecta a los equipos de red. Hyper-V queda descartado porque obliga a Windows Pro y complica el puente de red.

## Costos referenciales

| Concepto | Solución elegida | Alternativa nube |
|---|---|---|
| Licencia PBX | US$0 | US$0 |
| Servidor | Equipo existente o mini PC (≈ Q2,500 una vez) | VPS ≈ US$10/mes |
| Red | TP-Link Omada ER605 + SG2210P + EAP610 + OC200 (≈ Q5,500 una vez) | Se necesita igual para la red interna |
| Softphones | Gratuitos (MicroSIP, Linphone) | Gratuitos |
| Troncal externa | Opcional, por minuto | Igual |
