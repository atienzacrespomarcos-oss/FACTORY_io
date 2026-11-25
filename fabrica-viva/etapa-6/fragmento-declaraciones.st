(* ===== Etapa 6 · Enfardado y expedición: señales nuevas ===== *)
VAR_INPUT
  PaleEnEnfardadora : BOOL;    (* el palé está centrado bajo el brazo de la enfardadora *)
  EnfardadoraOcupada : BOOL;   (* la enfardadora está trabajando: no muevas sus rodillos *)
  EnfardadoHecho : BOOL;       (* palé enfardado y brazo recogido *)
  CortinaLibre : BOOL;         (* cortina de seguridad del muelle: TRUE = nada la corta *)
  MutingA : BOOL;              (* sensor de muting A *)
  MutingB : BOOL;              (* sensor de muting B *)
  PaleEnMuelle : BOOL;         (* fotocélula del muelle, justo antes del camión *)
  SalidaExpedicion : INT;      (* lo que entra en el camión: cada palé y cada caja cuentan 1 *)
END_VAR
VAR_OUTPUT
  RodillosEnfardado : BOOL;    (* rodillos de la enfardadora *)
  Enfardar : BOOL;             (* orden de enfardar (flanco de subida) *)
  EnfardadoraHabilitada : BOOL;(* la enfardadora solo se mueve con esto a TRUE *)
  RodillosExpedicion : BOOL;   (* rodillos de expedición, hasta el camión *)
  LamparaMuting : BOOL;        (* lámpara de muting de la cortina *)
  AlarmaCortina : BOOL;        (* alguien ha cortado la cortina sin muting *)
  PalesExpedidos : INT;        (* objetivo en directo *)
END_VAR
VAR
  Muting : FB_Muting;          (* tu muting de la cortina *)
  PasoEnf : INT;               (* tu secuencia de enfardado *)
END_VAR
