# Fábrica viva: diseño

Un único proyecto, **«Fábrica viva»**, que es tu centro logístico. No hay capítulos que se cierran: la planta está
siempre ahí, la pones en marcha con Play y produce. Te llegan **encargos**; al cumplir uno, la planta se **amplía**
con una zona nueva que se suma a lo que ya construiste y programaste.

## Reglas del juego

1. **Una planta, que crece.** Cada ampliación añade piezas en una zona libre de la nave y las conecta con la anterior.
   Nada de lo tuyo se borra: tus piezas, tu programa y tus cambios se conservan.
2. **Encargos en directo.** Cada encargo tiene objetivos medibles (cajas entregadas, rechazos, paradas…) que se ven
   avanzar en un panel mientras la fábrica funciona en Play.
3. **El juez certifica.** Al llegar al objetivo en directo, el juez (las pruebas de la planta) comprueba la zona nueva
   **y todas las anteriores**. Si una ampliación rompe algo que ya funcionaba, no se certifica.
4. **El programa evoluciona.** Cada ampliación exige una forma de programar más elaborada; lo que escribiste antes se
   reorganiza, no se tira.

## Progresión

| # | Ampliación | Equipos nuevos | Forma de programar que exige | Encargo en directo (ejemplo) |
|---|---|---|---|---|
| 1 | Recepción desde el muelle | Camión en muelle, cintas, seta de emergencia, baliza | Un programa: enclavamientos, señales normalmente cerradas, salida de baliza por bits | Descargar 30 cajas; la seta lo para todo y la baliza lo indica |
| 2 | Control de entrada | Lector de códigos, fotocélula, desvío de rechazo | **Bloque de función** propio (una cinta = una instancia) y atascos con TON | 40 cajas controladas sin rechazos erróneos |
| 3 | Clasificación | Desvíos a dos líneas (pedidos y devoluciones) | **Arrays**: el registro de desplazamiento pasa a una cola de códigos | Clasificar 60 cajas sin errores de destino |
| 4 | Pulmón y lotes | Rodillos de acumulación, topes | **Máquina de estados** con CASE y **tipos propios** (STRUCT) para alarmas | Entregar 10 lotes completos |
| 5 | Paletizado | Robot de 6 ejes, dispensador de palés | **Intercambio de señales** con otra máquina (orden, ejecutar, terminado) y secuencias | Montar 3 palés completos |
| 6 | Enfardado y expedición | Enfardadora, transferencia, AGV, barrera de seguridad | **Varios programas y tareas** (CONFIGURATION) y enclavamientos de seguridad | Expedir 2 palés al muelle sin incidentes |
| 7 | Turno completo | Toda la planta | Modos manual/automático, recuperación de averías, indicadores de producción | Un turno con averías aleatorias y un ritmo mínimo |

Las zonas se reparten por la nave siguiendo el flujo: muelle de recepción → control → clasificación → pulmón →
paletizado → enfardado → muelle de expedición.

## Cómo funciona por dentro

- **Etapas en el repositorio:** `fabrica-viva/etapa-N/` contiene la planta acumulada hasta esa etapa (montada con las
  herramientas del proyecto, nunca editando la escena a mano), la solución de referencia, el fragmento de programa
  que se te añade y los objetivos del encargo.
- **Ampliar:** la app une tu proyecto actual con lo nuevo de la etapa siguiente (piezas, paquetes, pruebas y el
  fragmento de programa) y lo carga. Tus piezas y tu código no se tocan.
- **Panel de encargos:** lee en directo las variables del PLC durante Play.

## Cómo se valida cada etapa antes de publicarla

1. Con la solución de referencia, **todas** las pruebas acumuladas pasan.
2. Con la solución de la etapa anterior más el fragmento nuevo sin programar, las pruebas antiguas siguen pasando y
   las nuevas fallan: la ampliación no rompe nada y exige trabajo real.
3. El juez rechaza las soluciones erróneas típicas de esa etapa.
4. Se juega entera desde la interfaz (ampliar, programar, Play, encargo en directo, juez), sin atajos internos.
5. Se revisa a ojo la escena (encuadre, piezas bien montadas, sin elementos flotando).

## Riesgos conocidos

- **Robot (etapa 5):** sus trayectorias se calcularán con la cinemática inversa del propio proyecto
  (`src/core/robot/robotIk.ts`). Si no resultan fiables, se sustituirá por el pórtico de pick & place, y se dirá.
- **Rendimiento:** una planta grande tiene muchas piezas. Se medirá en cada etapa.
