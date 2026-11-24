(* Misión 4 · Motor con vigilancia de fallos

   Objetivo:
   - Marcha y Paro con enclavamiento, como en la misión 1, sobre OrdenMarcha.
   - Si se ordena marcha y el motor no confirma Realimentacion en 500 ms, activa FalloMotor
     y quita OrdenMarcha.
   - Si se pierde la comunicación (FalloComunicacion), activa FalloMotor al instante.
   - FalloMotor se queda activo hasta Rearme, y Rearme no puede borrarlo mientras el fallo
     siga presente. Un motor que vuelve solo nunca debe rearrancar la línea sin aviso. *)

(* Cómo probarlo: pulsa Play (▶). Para accionar un pulsador, selecciónalo en la lista Scene
   (por ejemplo «Pulsador Marcha») y pulsa la tecla C. En la pestaña Watch ves las variables.
   Cuando creas que está, pulsa «Run tests» (junto a Play): es el juez de la misión.
   En Play la cinta siempre confirma la marcha y la comunicación no falla: esas averías solo las provoca
   el juez, así que usa «Run tests» para comprobar tu vigilancia. *)
VAR_INPUT
  Marcha : BOOL;             (* pulsador de marcha: TRUE solo mientras se pulsa *)
  Paro : BOOL;               (* pulsador de paro: TRUE solo mientras se pulsa *)
  Rearme : BOOL;             (* pulsador de rearme: TRUE solo mientras se pulsa *)
  Realimentacion : BOOL;     (* la cinta informa de que está girando *)
  FalloComunicacion : BOOL;  (* TRUE: se ha perdido la comunicación con la E/S del motor *)
  CajasSalida : INT;         (* cajas retiradas al final de la cinta *)
END_VAR
VAR_OUTPUT
  OrdenMarcha : BOOL;        (* TRUE: se ordena al motor de la cinta que gire (y al alimentador que suelte cajas) *)
  FalloMotor : BOOL;         (* TRUE: fallo; se queda activo hasta Rearme *)
END_VAR
VAR
  (* tus variables internas *)
END_VAR

(* ---- Tu programa ---- *)
