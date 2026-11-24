(* Misión 3 · Detección de atascos

   Una caja de 0,6 m a 1 m/s tapa la fotocélula unos 0,6 s. Si la fotocélula sigue tapada 2 s
   MIENTRAS LA CINTA SE MUEVE, la caja se ha quedado parada: es un atasco.

   Objetivo:
   - Marcha arranca la cinta y el alimentador; Paro los detiene (como en la misión 1).
   - Con un atasco, activa AlarmaAtasco y para la cinta y el alimentador.
   - AlarmaAtasco se queda activa hasta pulsar Rearme. Después, Marcha vuelve a arrancar.
   - Si se rearma y arranca con la caja todavía atascada, la alarma debe volver a saltar.
   - El tráfico normal no debe disparar nunca la alarma. *)

(* Cómo probarlo: pulsa Play (▶). Para accionar un pulsador, selecciónalo en la lista Scene
   (por ejemplo «Pulsador Marcha») y pulsa la tecla C. En la pestaña Watch ves las variables.
   Cuando creas que está, pulsa «Run tests» (junto a Play): es el juez de la misión. *)
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
  (* tus variables internas *)
END_VAR

(* ---- Tu programa ---- *)
