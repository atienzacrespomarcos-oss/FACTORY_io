(* FÁBRICA VIVA · Etapa 1 · Recepción

   Encargo: el camión del muelle de recepción trae cajas. Ponlas en la línea y llévalas hasta el
   final de la recepción. Objetivo en directo: 30 cajas recibidas.

   Requisitos:
   - Marcha arranca la recepción (cintas y descarga del camión) y sigue al soltarla; Paro la detiene.
   - La seta de emergencia es normalmente cerrada: Seta = TRUE mientras está libre. Al pulsarla todo
     se para al instante, y al soltarla la línea NO arranca sola: hace falta Marcha.
   - Baliza: verde (1) en marcha, ámbar (2) parada, rojo (4) con la seta pulsada.

   Cómo probarlo: Play (▶); para accionar un pulsador, selecciónalo en la lista Scene y pulsa C.
   El panel de encargos muestra tu progreso en directo. Cuando llegues al objetivo, el juez
   («Run tests») certifica la etapa y se desbloquea la ampliación de la fábrica. *)
VAR_INPUT
  Marcha : BOOL;               (* pulsador de marcha de la recepción *)
  Paro : BOOL;                 (* pulsador de paro *)
  Seta : BOOL;                 (* seta de emergencia, normalmente cerrada: TRUE = libre, FALSE = pulsada *)
  FotocelulaRecepcion : BOOL;  (* fotocélula al final de la recepción *)
  CajasRecibidas : INT;        (* cajas que han llegado al final de la recepción *)
END_VAR
VAR_OUTPUT
  CintaRecepcion : BOOL;       (* las dos cintas de recepción *)
  Alimentador : BOOL;          (* la descarga del camión: TRUE = salen cajas del muelle *)
  Baliza : INT;                (* bits de la baliza: 1 = verde, 2 = ámbar, 4 = rojo *)
END_VAR
VAR
  (* tus variables internas *)
END_VAR

(* ---- Tu programa ---- *)
