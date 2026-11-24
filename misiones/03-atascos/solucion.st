(* Misión 3 · Solución de referencia: vigilancia de atasco con temporizador a la conexión (TON).
   Adaptada del ejemplo jam-detect de Open Industry Project (licencia MIT). *)
VAR_INPUT
  Marcha : BOOL;        (* pulsador de marcha: TRUE solo mientras se pulsa *)
  Paro : BOOL;          (* pulsador de paro: TRUE solo mientras se pulsa *)
  Rearme : BOOL;        (* pulsador de rearme: TRUE solo mientras se pulsa *)
  Fotocelula : BOOL;    (* fotocélula a 2,5 m: TRUE con una caja delante *)
END_VAR
VAR_OUTPUT
  CintaMarcha : BOOL;   (* TRUE: la cinta se mueve *)
  Alimentador : BOOL;   (* TRUE: entran cajas en la cinta *)
  AlarmaAtasco : BOOL;  (* TRUE: hay un atasco; se queda activa hasta Rearme *)
END_VAR
VAR
  Tapada : TON;   (* cuenta el tiempo que la fotocélula lleva tapada con la cinta en marcha *)
END_VAR

(* Solo cuenta con la cinta en marcha: una caja parada delante de la fotocélula con la cinta parada
   no es un atasco. TON pone Q a TRUE cuando IN lleva PT seguido a TRUE, y se reinicia si IN cae. *)
Tapada(IN := Fotocelula AND CintaMarcha, PT := T#2s);

(* El rearme va antes que la detección: si el atasco sigue presente, la alarma no se puede borrar. *)
IF Rearme THEN
  AlarmaAtasco := FALSE;
END_IF;
IF Tapada.Q THEN
  AlarmaAtasco := TRUE;
END_IF;

CintaMarcha := (CintaMarcha OR Marcha) AND NOT Paro AND NOT AlarmaAtasco;
Alimentador := CintaMarcha;
