(* ===== Etapa 6 · Enfardado y expedición =====
   Encargo: cada palé lleno se enfarda con film y sale por el muelle de expedición hasta el camión.
   El muelle tiene una cortina de seguridad: los palés pasan gracias al muting; una persona no.
   - Enfardado, con tu secuencia PasoEnf (CASE): recibir el palé con los rodillos hasta que
     PaleEnEnfardadora, parar y dar la orden Enfardar (flanco; mantenla hasta que EnfardadoraOcupada
     suba), esperar EnfardadoHecho y soltar el palé hacia el muelle (vuelve a recibir cuando
     PaleEnEnfardadora lleve unos segundos libre). EnfardadoraHabilitada := EnMarcha.
   - Expedición: los rodillos de expedición, en marcha con la línea.
   - Cortina: la instancia Muting (tu FB_Muting). Si Muting.ZonaSegura cae, AlarmaCortina se queda a
     TRUE hasta que se pulse Rearme con la zona segura. La alarma para la línea: añádela a la memoria
     de marcha de la etapa 1, como el atasco. Con la alarma, baliza en rojo (4). LamparaMuting
     muestra el muting.
   - PalesExpedidos: cuenta cada palé que pasa por la fotocélula del muelle, una sola vez aunque la
     fotocélula parpadee con los huecos entre los tacos del palé. *)

(* ---- tu código de la etapa 6 ---- *)
