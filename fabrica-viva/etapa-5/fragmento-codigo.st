(* ===== Etapa 5 · Paletizado =====
   Encargo: un robot coge cada caja al final de la cinta de salida y la apila en un palé europeo
   (1200 × 800): dos capas de 2 × 2 cajas. El palé lleno sale por los rodillos y entra uno vacío.
   - Cinta de salida: ahora para cuando hay una caja en el punto de recogida (FotocelulaPicking).
     Cambia su línea de la etapa 4.
   - Pulmón: conviene que el Permiso de la etapa 4 incluya que el punto de recogida está libre. Así el
     tope no baja mientras la cinta de salida está parada, y los rodillos del pulmón no se quedan
     parados esperando a que la caja salga.
   - Robot: la instancia Paletizado (tu FB_Paletizado) da RobotTrabajo y RobotEjecutar.
     RobotHabilitado := EnMarcha: con Paro o emergencia el brazo se frena y solo sigue con Marcha.
   - Palés, con tu secuencia PasoPale (CASE): pedir un palé (DarPale, flanco), esperar a que el
     dispensador termine (DispensadorOcupado a FALSE), llevarlo hasta el tope con los rodillos (que
     PalePresente lleve 2 s a TRUE para que llegue hasta el tope), cargarlo con el robot, y con 8 cajas
     y el robot en reposo, bajar el tope y sacarlo (cuando PalePresente lleve 3 s libre, tope arriba y
     PalesCompletos + 1). *)

(* ---- tu código de la etapa 5 ---- *)
