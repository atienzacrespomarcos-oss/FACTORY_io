(* ===== Etapa 3 · Clasificación: señales nuevas ===== *)
VAR_INPUT
  FotocelulaExpres : BOOL;    (* fotocélula antes del empujador exprés (código 103) *)
  FotocelulaDevol : BOOL;     (* fotocélula antes del empujador de devoluciones (código 104) *)
  CajasExpres : INT;          (* cajas retiradas en la cinta de exprés *)
  CajasDevueltas : INT;       (* cajas retiradas en la cinta de devoluciones *)
  CajasPedidos : INT;         (* cajas de pedido normal (101, 102) al final de la clasificación *)
END_VAR
VAR_OUTPUT
  CintaClasificacion : BOOL;  (* la cinta de clasificación y sus dos laterales *)
  DesvioExpres : BOOL;
  DesvioDevol : BOOL;
END_VAR
VAR
  ColaA : FB_Cola;            (* las cajas entre el lector y el empujador exprés *)
  ColaB : FB_Cola;            (* las cajas entre el empujador exprés y el de devoluciones *)
END_VAR
