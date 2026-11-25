(* ===== Etapa 4 · Pulmón =====
   Encargo: el paletizado que vendrá será más lento que lo que llega. El pulmón acumula los pedidos
   normales y los suelta de uno en uno, como mucho uno cada 10 s (el ritmo del paletizador).
   - Los rodillos, el tope y la cinta de salida los gobierna la instancia Pulmon (tu FB_Pulmon):
     RodillosPulmon := Pulmon.Avance, TopePulmon := Pulmon.Tope y CintaSalidaPulmon := Pulmon.Salida.
   - El Permiso impone el ritmo: al menos 10 s en espera (Estado 0) entre una caja y la siguiente.
   - PulmonLleno: si la fotocélula de lleno está tapada 2 s seguidos. Mientras esté lleno, se para la
     descarga del camión (Alimentador); lo que ya viene en camino cabe. Deja de estar lleno cuando esa
     fotocélula lleva 3 s libre.
   - Baliza: con el pulmón lleno (y sin emergencia ni atasco), verde y ámbar a la vez (3). *)

(* ---- tu código de la etapa 4 ---- *)
