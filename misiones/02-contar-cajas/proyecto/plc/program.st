(* Misión 2 · Lote de 5 cajas

   Objetivo: cuenta en Cajas las cajas que pasan por FotocelulaSalida (cada caja una sola vez).
   Al llegar a 5, activa LoteCompleto y para la cinta y el alimentador.
   Rearme pone Cajas a 0 y quita LoteCompleto; después, Marcha empieza otro lote.
   Mientras el lote esté completo, Marcha no debe arrancar nada.
   Marcha y Paro funcionan como en la misión 1. *)

(* Cómo probarlo: pulsa Play (▶). Para accionar un pulsador, selecciónalo en la lista Scene
   (por ejemplo «Pulsador Marcha») y pulsa la tecla C. En la pestaña Watch ves las variables.
   Cuando creas que está, pulsa «Run tests» (junto a Play): es el juez de la misión. *)
VAR_INPUT
  FotocelulaSalida : BOOL;  (* fotocélula al final de la cinta: TRUE con caja delante *)
  Marcha : BOOL;            (* pulsador verde: TRUE solo mientras se pulsa *)
  Paro : BOOL;              (* pulsador rojo: TRUE solo mientras se pulsa *)
  Rearme : BOOL;            (* pulsador de rearme: TRUE solo mientras se pulsa *)
  CajasSalida : INT;        (* cajas retiradas por el sumidero *)
END_VAR
VAR_OUTPUT
  CintaMarcha : BOOL;       (* TRUE: la cinta se mueve *)
  Alimentador : BOOL;       (* TRUE: el alimentador suelta cajas *)
  Cajas : INT;              (* cajas del lote que han pasado por la fotocélula *)
  LoteCompleto : BOOL;      (* TRUE al llegar a 5 cajas, hasta el rearme *)
END_VAR
VAR
  (* tus variables internas *)
END_VAR

(* ---- Tu programa ---- *)
