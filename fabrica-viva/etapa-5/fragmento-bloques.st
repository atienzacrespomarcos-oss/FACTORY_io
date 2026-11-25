(* ===== Etapa 5 · Bloque de función FB_Paletizado =====
   La secuencia del robot, como máquina de estados (CASE sobre Paso), con el intercambio de señales
   orden → ejecutar → hecho:
   - El robot tiene sus trabajos enseñados: el 1 recoge la caja del punto de recogida y el 2 + n la deja
     en el hueco n del palé (n de 0 a 7: dos capas de 2 × 2) y vuelve a reposo.
   - Para mandar un trabajo: pon su número en Trabajo y Ejecutar a TRUE. El robot arranca en el flanco
     de subida de Ejecutar; mantenlo a TRUE hasta que RobotListo caiga (así sabes que lo ha visto).
     Cuando RobotListo vuelve a TRUE, el trabajo ha terminado.
   Pasos propuestos: 0 esperar (caja lista, palé listo, robot listo y Colocadas < 8) → 1 orden de recoger
   → 2 recogiendo → 3 orden de dejar en el hueco Colocadas → 4 dejando; al terminar, Colocadas + 1 y a 0.
   Con Reiniciar, en el paso 0, Colocadas vuelve a 0 (palé nuevo). *)
FUNCTION_BLOCK FB_Paletizado
VAR_INPUT
  Habilitar : BOOL;    (* la línea está en marcha: no se empieza un trabajo si no *)
  CajaLista : BOOL;    (* hay una caja quieta en el punto de recogida *)
  PaleListo : BOOL;    (* hay un palé vacío o a medias en su sitio *)
  RobotListo : BOOL;   (* el robot está en reposo, listo para otra orden *)
  Reiniciar : BOOL;    (* palé nuevo: Colocadas a 0 *)
END_VAR
VAR_OUTPUT
  Trabajo : INT;       (* el trabajo que se manda al robot *)
  Ejecutar : BOOL;     (* la orden de ejecutar (flanco de subida) *)
  Paso : INT;          (* el paso de la secuencia *)
  Colocadas : INT;     (* cajas en el palé actual *)
  Total : INT;         (* cajas paletizadas desde el arranque *)
  PaleLleno : BOOL;    (* Colocadas = 8 *)
END_VAR
VAR
  (* tus variables internas del bloque *)
END_VAR

(* ---- tu código del bloque ---- *)
END_FUNCTION_BLOCK
