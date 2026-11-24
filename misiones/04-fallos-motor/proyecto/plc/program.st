(* Misión 4 · Motor con vigilancia de fallos

   Objetivo:
   - Marcha y Paro con enclavamiento, como en la misión 1, sobre OrdenMarcha.
   - Si se ordena marcha y el motor no confirma Realimentacion en 500 ms, activa FalloMotor
     y quita OrdenMarcha.
   - Si se pierde la comunicación (FalloComunicacion), activa FalloMotor al instante.
   - FalloMotor se queda activo hasta Rearme, y Rearme no puede borrarlo mientras el fallo
     siga presente. Un motor que vuelve solo nunca debe rearrancar la línea sin aviso. *)
VAR_INPUT
  Marcha : BOOL;             (* pulsador de marcha: TRUE solo mientras se pulsa *)
  Paro : BOOL;               (* pulsador de paro: TRUE solo mientras se pulsa *)
  Rearme : BOOL;             (* pulsador de rearme: TRUE solo mientras se pulsa *)
  Realimentacion : BOOL;     (* el motor informa de que está girando *)
  FalloComunicacion : BOOL;  (* TRUE: se ha perdido la comunicación con la E/S del motor *)
END_VAR
VAR_OUTPUT
  OrdenMarcha : BOOL;        (* TRUE: se ordena al motor que gire *)
  FalloMotor : BOOL;         (* TRUE: fallo; se queda activo hasta Rearme *)
END_VAR
VAR
  (* tus variables internas *)
END_VAR

(* ---- Tu programa ---- *)
