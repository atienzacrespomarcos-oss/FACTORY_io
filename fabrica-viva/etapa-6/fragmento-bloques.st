(* ===== Etapa 6 · Bloque de función FB_Muting =====
   La cortina del muelle protege a las personas: si algo la corta, la línea se para. Pero los palés
   tienen que pasar por ella. El muting la anula solo mientras pasa un palé:
   - Empieza si los dos sensores de muting se tapan en orden: primero A y después B (el flanco de
     subida de B con A tapado). Una persona que cruza la cortina no los tapa así.
   - Acaba cuando la carga ha pasado: A y B libres y la cortina despejada.
   - Por seguridad, como mucho 30 s seguidos.
   ZonaSegura := la cortina libre, o el muting activo. *)
FUNCTION_BLOCK FB_Muting
VAR_INPUT
  SensorA : BOOL;       (* sensor de muting antes de la cortina *)
  SensorB : BOOL;       (* sensor de muting, más cerca de la cortina *)
  CortinaLibre : BOOL;  (* salida de seguridad de la cortina: TRUE = nada la corta *)
END_VAR
VAR_OUTPUT
  Activo : BOOL;        (* el muting está anulando la cortina *)
  ZonaSegura : BOOL;    (* se puede trabajar *)
END_VAR
VAR
  (* tus variables internas del bloque *)
END_VAR

(* ---- tu código del bloque ---- *)
END_FUNCTION_BLOCK
