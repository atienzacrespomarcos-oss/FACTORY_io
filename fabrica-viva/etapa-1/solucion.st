(* Fábrica viva · Etapa 1 · Solución de referencia *)
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
  EnMarcha : BOOL;
END_VAR

(* La seta corta la marcha (y la memoria de marcha), así que al soltarla no se rearranca sola. *)
EnMarcha := (Marcha OR EnMarcha) AND NOT Paro AND Seta;
CintaRecepcion := EnMarcha;
Alimentador := EnMarcha;

IF NOT Seta THEN
  Baliza := 4;
ELSIF EnMarcha THEN
  Baliza := 1;
ELSE
  Baliza := 2;
END_IF;
