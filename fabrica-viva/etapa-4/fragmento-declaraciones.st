(* ===== Etapa 4 · Pulmón: señales nuevas ===== *)
VAR_INPUT
  FotocelulaEntradaPulmon : BOOL;  (* entrada de los rodillos *)
  FotocelulaLleno : BOOL;          (* a 2,8 m del tope: si la cola llega aquí, el pulmón está lleno *)
  FotocelulaTope : BOOL;           (* una caja esperando en el tope *)
  FotocelulaSalidaPulmon : BOOL;   (* en la cinta de salida *)
  CajasAPaletizar : INT;           (* cajas entregadas al final (el futuro paletizado) *)
END_VAR
VAR_OUTPUT
  RodillosPulmon : BOOL;           (* rodillos de acumulación: giran aunque haya cajas paradas encima *)
  TopePulmon : BOOL;               (* TRUE: tope arriba *)
  CintaSalidaPulmon : BOOL;        (* cinta de salida (el doble de rápida) *)
  PulmonLleno : BOOL;              (* el pulmón está lleno: se para la descarga del camión *)
END_VAR
VAR
  Pulmon : FB_Pulmon;              (* tu máquina de estados del tope *)
END_VAR
