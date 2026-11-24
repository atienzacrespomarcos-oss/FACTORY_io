(* ===== Etapa 2 · Control de entrada =====
   Encargo: el camión trae cajas sin etiqueta (código 0). Hay que apartarlas antes de que sigan, y
   la nueva cinta de control tiene que vigilarse contra atascos.
   - Usa la instancia Control (tu FB_Cinta) para la cinta de control: CintaControl := Control.Motor.
   - Un atasco (AlarmaAtasco) para TODA la línea: recepción, descarga del camión y control. La baliza
     lo indica con ámbar y rojo a la vez (6). Rearme lo borra; después hace falta Marcha.
   - Las cajas sin etiqueta se apartan con Desvio hacia la cinta de rechazo. El empujador está 0,37 m
     después de su fotocélula y tarda 0,25 s en salir (como en la Academia, misión 5).
   Para integrar el atasco tendrás que retocar también tu código de la etapa 1. *)

(* ---- tu código de la etapa 2 ---- *)
