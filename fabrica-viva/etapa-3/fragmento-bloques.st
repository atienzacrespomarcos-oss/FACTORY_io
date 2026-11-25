(* ===== Etapa 3 · Bloque de función FB_Cola =====
   Una cola FIFO de códigos: lo primero que entra es lo primero que sale. Complétalo con un ARRAY.
   - Meter (un pulso): añade Valor al final de la cola.
   - Sacar (un pulso): quita el primero de la cola.
   - Si llegan los dos en el mismo ciclo, primero se saca y después se mete.
   - Primero: el valor que está a la cabeza (0 si la cola está vacía). Cantidad: cuántos hay. *)
FUNCTION_BLOCK FB_Cola
VAR_INPUT
  Meter : BOOL;
  Valor : DINT;
  Sacar : BOOL;
END_VAR
VAR_OUTPUT
  Primero : DINT;
  Cantidad : INT;
END_VAR
VAR
  Datos : ARRAY[0..15] OF DINT;   (* hasta 16 cajas en cola *)
  (* tus variables internas del bloque *)
END_VAR

(* ---- tu código del bloque ---- *)
END_FUNCTION_BLOCK
