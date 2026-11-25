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

| # | Ampliación | Equipos nuevos | Forma de programar que exige | Encargo en directo |
|---|---|---|---|---|
| 1 | Recepción | Camión en el muelle, cintas, fotocélula, Marcha, Paro, seta, baliza | Memoria de marcha, señales normalmente cerradas, baliza por bits | 30 cajas recibidas |
| 2 | Control de entrada | Cinta de control, lector de códigos, empujador de rechazo, Rearme | **Bloque de función** propio (`FB_Cinta`, una instancia por cinta), atasco con TON y rearme | 30 cajas etiquetadas al final, 10 rechazadas |
| 3 | Clasificación | Dos empujadores y dos cintas laterales (exprés y devoluciones) | **ARRAY y FOR**: una cola FIFO de códigos en un bloque (`FB_Cola`), orden de las instrucciones en el ciclo | 8 exprés, 8 devoluciones, 15 normales |
| 4 | Pulmón | Rodillos de acumulación, tope, cuatro fotocélulas, cinta de salida | **Máquina de estados** con CASE (`FB_Pulmon`), ritmo mínimo, histéresis de «lleno» que frena la descarga | 10 cajas entregadas al paletizado |
| 5 | Paletizado con robot | Robot de 6 ejes, dispensador de palés europeos, rodillos y tope de palés | **Intercambio de señales** (trabajo, ejecutar, listo) con el robot (`FB_Paletizado`) y una segunda secuencia para los palés | 16 cajas paletizadas, 2 palés |
| 6 | Enfardado y expedición | Enfardadora, rodillos hasta el muelle, cortina de seguridad con dos sensores de muting | **Seguridad**: muting por secuencia (`FB_Muting`), alarma enclavada con rearme, filtrar un sensor que parpadea (TOF) | 2 palés expedidos |
| 7 | Turno completo | Selector MANUAL, AVANCE, FIN TURNO | **Modos de marcha**, parada ordenada (vaciado), supervisión por tiempo (watchdog), indicadores con REAL | 1 turno terminado, 240 cajas por hora |

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

## Decisiones de diseño

- **El robot** se enseña por coordenadas con la cinemática inversa del propio proyecto (`scripts/robot-pose.mjs`, que
  usa la herramienta `solve_robot_pose` de la app). Sus trabajos ya vienen enseñados: el jugador programa el
  intercambio de señales, no las trayectorias.
- **Palé europeo** (1200 × 800 mm) con cajas de 600 × 400 mm: dos capas de 2 × 2 cajas ocupan el palé justo.
- **Muting** de dos sensores en secuencia antes de la cortina; el muting termina cuando la carga ha pasado (sensores
  libres y cortina despejada) y tiene un tiempo máximo. Es un modelo didáctico, no un diseño de seguridad certificable.
- **Disponibilidad** (etapa 7) según la idea de ISO 22400-2 (tiempo produciendo entre tiempo que se debía producir);
  aquí el tiempo que se debía producir es el de marcha más el perdido en alarma.
- **Pruebas que dependen de piezas retiradas.** Cuando una ampliación retira un sumidero que una prueba anterior
  contaba, esa prueba se adapta en la etapa nueva y se lista en `flujoAnterior` del `etapa.json`: el validador la
  exige con la solución, no con la zona nueva sin programar.
- **Orden de las piezas.** La escena de cada etapa tiene el orden de piezas que deja la ampliación en la app
  (`scripts/encadenar-fabrica-viva.mjs`; `npm run check-fabrica-viva` lo comprueba antes de validar). El orden decide
  el de los cuerpos de la física, así que el validador simula la misma planta que recibe quien juega.
- **Cinta de salida del pulmón.** Arranca 0,4 s después de bajar el tope. Además de no arrastrar la caja contra el
  tope que se retira, evita un caso del motor de física: una caja que se ha quedado quieta contra el tope sobre una
  cinta en marcha no vuelve a moverse al bajar el tope si la cinta no arranca de nuevo.
- **Ambientación** (estanterías con cargas, zona de almacén, barandilla, bolardos) va en la etapa 1 con ids `fv1-deco-*`,
  fuera de las zonas que vigilan las pruebas. Una planta guardada antes de añadirla la recibe al ampliar.
