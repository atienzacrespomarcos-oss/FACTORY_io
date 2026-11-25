(* ===== Etapa 4 · Bloque de función FB_Pulmon =====
   El tope del pulmón como máquina de estados (CASE sobre Estado). Complétalo:
   - Estado 0, esperando: tope arriba y rodillos en marcha. Si hay una caja en el tope, Habilitar y
     Permiso, pasa a 1.
   - Estado 1, liberando: tope abajo y rodillos PARADOS, hasta que la caja deja la fotocélula del tope;
     entonces suma 1 a Liberadas y pasa a 2. La caja del tope ya está en la cinta de salida y se va;
     la siguiente, sobre los rodillos parados, se queda: así sale una sola.
   - Estado 2, cerrando: tope arriba y rodillos parados durante 0,5 s; luego vuelve a 0. *)
FUNCTION_BLOCK FB_Pulmon
VAR_INPUT
  Habilitar : BOOL;    (* la línea está en marcha *)
  CajaEnTope : BOOL;   (* la fotocélula del tope *)
  Permiso : BOOL;      (* se puede soltar una caja (lo decide quien recibe las cajas) *)
END_VAR
VAR_OUTPUT
  Tope : BOOL;         (* TRUE: tope arriba, retiene *)
  Avance : BOOL;       (* TRUE: rodillos del pulmón en marcha *)
  Estado : INT;        (* 0 esperando, 1 liberando, 2 cerrando *)
  Liberadas : INT;     (* cajas soltadas *)
END_VAR
VAR
  (* tus variables internas del bloque *)
END_VAR

(* ---- tu código del bloque ---- *)
END_FUNCTION_BLOCK
