(* ===== Etapa 2 · Control de entrada: señales nuevas ===== *)
VAR_INPUT
  Rearme : BOOL;              (* pulsador de rearme de la zona de control *)
  FotocelulaAtasco : BOOL;    (* vigilancia de atasco al principio de la cinta de control *)
  LecturaOk : BOOL;           (* el lector de códigos: pulso al leer una caja *)
  CodigoCaja : DINT;          (* el código leído; 0 = caja sin etiqueta *)
  FotocelulaRechazo : BOOL;   (* fotocélula justo antes del desvío de rechazo *)
  CajasRechazadas : INT;      (* cajas retiradas en la cinta de rechazo *)
  CajasFinLinea : INT;        (* cajas que llegan al final de la línea *)
END_VAR
VAR_OUTPUT
  CintaControl : BOOL;        (* la cinta de control y la de rechazo *)
  Desvio : BOOL;              (* el empujador de rechazo *)
  AlarmaAtasco : BOOL;        (* hay un atasco en la zona de control *)
END_VAR
VAR
  Control : FB_Cinta;         (* la cinta de control, vigilada por tu bloque *)
END_VAR
