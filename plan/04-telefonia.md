# 04 · Plan de numeración y funcionalidades (criterio D)

## Plan de numeración (4 dígitos)

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

## Extensiones de la muestra

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

## Números de servicio

| Número | Función | Destino |
|---|---|---|
| 2000 | Operadora | Grupo de timbrado: 2101 y 2102 a la vez; si nadie contesta en 20 s, buzón de 2101 |
| 2900 | Menú de voz (IVR) | Condición de horario: IVR diurno o nocturno |
| 2910 | Grupo Consulta Externa | 2201 y 2202 timbran a la vez (ringall) |
| 2920 | Cola Enfermería y Emergencias | 2301 y 2302, estrategia *rrmemory* (reparte por turnos), música mientras espera |
| 2999 | Buzón de voz general | Pide extensión y PIN para escuchar mensajes desde cualquier teléfono |
| `*97` | Mi buzón | Entra directo al buzón de la extensión propia (pide PIN) |
| `*98` | Buzón de otra extensión | Igual que 2999 |

## Funcionalidades obligatorias

**Llamada en espera.** El botón *Hold* del softphone pone la llamada en espera y la otra parte escucha la música en espera del centro médico (clase de música propia, no la de fábrica). Call Waiting está habilitado en todas las extensiones, así que una segunda llamada entrante suena con un tono suave y se puede contestar dejando la primera en espera.

**Transferencias.** Se pueden hacer con los botones del softphone (*Transfer* para ciega, *Attended/Consultar* para atendida) o con los códigos de Asterisk durante la llamada: `##` + extensión para la ciega y `*2` + extensión para la atendida. La transferencia entre una laptop y un celular se prueba en la matriz de pruebas.

**Buzón de voz.** Habilitado en 2101, 2201, 2301, 2401 y 2501. Si la extensión está ocupada o no contesta en 20 segundos, la llamada pasa al buzón. Cada buzón tiene su saludo personalizado grabado con `*97` → opción 0. El PIN es de 6 dígitos y distinto del número de extensión.

## IVR (2900)

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

Las grabaciones están en `audios/` de la VM (no en el repositorio). Se generaron en español con voz sintética de prueba y deben reemplazarse por la voz de un integrante antes de la demo (Admin → System Recordings).
