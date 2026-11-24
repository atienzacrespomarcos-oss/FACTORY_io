(* Misión 7 · Lotes de 3 para el muelle

   El muelle de carga recibe las cajas en lotes de exactamente 3. La cinta de rodillos acumula:
   el tope retiene las cajas y los rodillos siguen girando por debajo sin empujarlas.

   Objetivo:
   - Marcha y Paro con enclavamiento.
   - Fase 0 (acumulando): tope arriba; entran cajas hasta tener 3 en los rodillos.
   - Fase 1 (liberando): baja el tope y salen esas 3, ni una más. Después vuelve a la fase 0.
   - Cuenta en Lotes los lotes entregados.
   - Con Paro todo se detiene, el tope queda arriba y no sale ninguna caja. Al volver a dar Marcha,
     los lotes siguen siendo de 3.

   Las cajas llegan a ritmo irregular: no vale soltar el tope cada cierto tiempo, hay que contar.
   Nunca debe haber más de 3 cajas en los rodillos.

   Datos útiles: los rodillos van a 1 m/s y la cinta de salida a 2 m/s, así que al salir las cajas
   se separan y la fotocélula de salida las ve de una en una. Las cajas acumuladas contra el tope
   quedan pegadas: la fotocélula del tope no las distingue. *)
VAR_INPUT
  Marcha : BOOL;              (* pulsador de marcha: TRUE solo mientras se pulsa *)
  Paro : BOOL;                (* pulsador de paro: TRUE solo mientras se pulsa *)
  FotocelulaEntrada : BOOL;   (* a la entrada de la cinta de rodillos (3,5 m) *)
  FotocelulaTope : BOOL;      (* justo antes del tope (6,55 m): TRUE con una caja esperando *)
  FotocelulaSalida : BOOL;    (* en la cinta de salida (8,2 m) *)
  CajasCargadas : INT;        (* cajas retiradas al final, en el muelle *)
END_VAR
VAR_OUTPUT
  CintaEntrada : BOOL;        (* cinta de entrada (con ella se para también el alimentador) *)
  Alimentador : BOOL;         (* TRUE: entran cajas *)
  Rodillos : BOOL;            (* cinta de rodillos de acumulación: puede girar con cajas paradas encima *)
  CintaSalida : BOOL;         (* cinta de salida, el doble de rápida *)
  Tope : BOOL;                (* TRUE: el tope sube y retiene las cajas *)
  Fase : INT;                 (* tu máquina de estados: 0 = acumulando, 1 = liberando *)
  Lotes : INT;                (* lotes de 3 entregados *)
END_VAR
VAR
  (* tus variables internas *)
END_VAR

(* ---- Tu programa ---- *)
