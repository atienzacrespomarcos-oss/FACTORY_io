(* Misión 1 · Marcha y paro

   Objetivo: que el pulsador Marcha ponga en marcha la cinta y el alimentador de cajas, que sigan
   funcionando al soltarlo, y que Paro los detenga. Si se pulsan los dos a la vez, gana Paro.

   Las señales ya están declaradas con los nombres que usan las piezas de la escena.
   Escribe tu lógica debajo de la línea "Tu programa". *)
VAR_INPUT
  FotocelulaSalida : BOOL;  (* fotocélula al final de la cinta: TRUE con caja delante *)
  Marcha : BOOL;            (* pulsador verde: TRUE solo mientras se pulsa *)
  Paro : BOOL;              (* pulsador rojo: TRUE solo mientras se pulsa *)
  CajasSalida : INT;        (* cajas retiradas por el sumidero *)
END_VAR
VAR_OUTPUT
  CintaMarcha : BOOL;       (* TRUE: la cinta se mueve *)
  Alimentador : BOOL;       (* TRUE: el alimentador suelta cajas *)
END_VAR
VAR
  (* tus variables internas *)
END_VAR

(* ---- Tu programa ---- *)
