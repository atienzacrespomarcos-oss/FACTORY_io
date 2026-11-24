(* Misión 4 · Solución de referencia: marcha/paro con vigilancia de realimentación y de comunicación.
   Adaptada del ejemplo start-stop-motor de Open Industry Project (licencia MIT). *)
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
  SinRealimentacion : TON;  (* tiempo con orden de marcha y sin confirmación del motor *)
END_VAR

SinRealimentacion(IN := OrdenMarcha AND NOT Realimentacion, PT := T#500ms);

(* Rearme antes que las condiciones de fallo: si el fallo sigue presente, se vuelve a activar
   en el mismo ciclo y el rearme no tiene efecto. *)
IF Rearme THEN
  FalloMotor := FALSE;
END_IF;
IF SinRealimentacion.Q OR FalloComunicacion THEN
  FalloMotor := TRUE;
END_IF;

OrdenMarcha := (OrdenMarcha OR Marcha) AND NOT Paro AND NOT FalloMotor;
