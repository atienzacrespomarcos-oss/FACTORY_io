(* ===== Etapa 2 · Bloque de función FB_Cinta =====
   Una cinta con vigilancia de atasco, para usar una instancia por cinta. Complétalo:
   - Motor sigue a Habilitar, salvo cuando hay Atasco.
   - Atasco se activa si Presencia lleva 3 s seguidos a TRUE con el motor en marcha (una caja parada
     delante de la fotocélula) y se queda activo hasta Rearme. *)
FUNCTION_BLOCK FB_Cinta
VAR_INPUT
  Habilitar : BOOL;   (* la cinta debe moverse *)
  Presencia : BOOL;   (* la fotocélula de vigilancia de esta cinta *)
  Rearme : BOOL;      (* borra el atasco *)
END_VAR
VAR_OUTPUT
  Motor : BOOL;       (* orden al motor de la cinta *)
  Atasco : BOOL;      (* atasco detectado, con memoria hasta Rearme *)
END_VAR
VAR
  (* tus variables internas del bloque *)
END_VAR

(* ---- tu código del bloque ---- *)
END_FUNCTION_BLOCK
