(* ===== Etapa 5 · Paletizado: señales nuevas ===== *)
VAR_INPUT
  FotocelulaPicking : BOOL;   (* caja en el punto de recogida, al final de la cinta de salida *)
  RobotListo : BOOL;          (* el robot está listo para otra orden *)
  DispensadorOcupado : BOOL;  (* el dispensador está dejando un palé: no muevas los rodillos de palés *)
  PaleEnDispensador : BOOL;   (* hay un palé bajo el dispensador *)
  PalePresente : BOOL;        (* hay un palé llegando o parado en el tope de palés *)
  SalidaPales : INT;          (* lo que sale por el final de los rodillos de palés: cada palé y cada caja cuentan 1 *)
END_VAR
VAR_OUTPUT
  RobotTrabajo : INT;         (* número de trabajo *)
  RobotEjecutar : BOOL;       (* ejecutar (flanco de subida) *)
  RobotHabilitado : BOOL;     (* el robot solo se mueve con esto a TRUE; si cae, se frena donde esté *)
  DarPale : BOOL;             (* pedir un palé al dispensador (flanco de subida) *)
  RodillosPale : BOOL;        (* rodillos de palés *)
  TopePale : BOOL;            (* TRUE: tope de palés arriba *)
  CajasPaletizadas : INT;     (* objetivo en directo *)
  PalesCompletos : INT;       (* objetivo en directo: palés llenos que has sacado *)
END_VAR
VAR
  Paletizado : FB_Paletizado; (* tu secuencia del robot *)
  PasoPale : INT;             (* tu secuencia de palés *)
END_VAR
