(* ===== Etapa 3 · Clasificación =====
   Encargo: separar los pedidos exprés (código 103, cajas naranjas) y las devoluciones (código 104, cajas
   rojas) hacia sus cintas laterales. Los pedidos normales (101, 102) siguen hacia el final.
   - Entre el lector de códigos y los empujadores viajan varias cajas a la vez: una variable no basta.
     Usa ColaA y ColaB (tu FB_Cola): mete el código al leer cada caja con etiqueta, y sácalo cuando la caja
     llega a cada fotocélula. Las cajas sin etiqueta ya salen por el rechazo antes, así que no las metas.
   - Cada empujador, como en el rechazo: está 0,37 m después de su fotocélula y tarda 0,25 s en salir.
   - La cinta de clasificación va con el resto de la línea (se para con Paro, la seta y los atascos), y
     las colas no se pierden al parar: al rearrancar, cada caja sigue a su destino. *)

(* ---- tu código de la etapa 3 ---- *)
