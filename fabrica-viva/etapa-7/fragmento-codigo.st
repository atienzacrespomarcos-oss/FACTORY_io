(* ===== Etapa 7 · Turno completo =====
   Encargo: la planta tiene que aguantar un turno entero. Añade:
   - Modo manual (selector MANUAL): la línea no arranca ni sigue en marcha, la baliza parpadea en ámbar
     (2 y 0 cada medio segundo) y cada pulsación de AVANCE mueve 2 s los rodillos de palés, de la
     enfardadora y de expedición, solo con la zona del muelle segura (Muting.ZonaSegura).
   - Fin de turno (FIN TURNO): deja de entrar mercancía y la línea sigue hasta vaciarse. Se para sola
     cuando lleva 30 s vacía: sin cajas en el pulmón ni en la recogida, el robot en reposo, el último
     palé lleno ya expedido y un palé en el robot (el palé a medias se queda para el turno siguiente).
     Suma 1 a TurnosTerminados.
   - Supervisión del transporte: un palé que sale de la enfardadora tiene que llegar al muelle en 25 s
     de rodillos en marcha. Si no, AlarmaTransporte, enclavada hasta Rearme; para la línea y pone la
     baliza en ámbar y rojo (6), como el atasco.
   - EstadoLinea: 4 manual, 3 en alarma (o emergencia), 2 vaciando, 1 en marcha, 0 parada.
   - Indicadores: TiempoMarcha y TiempoAlarma en segundos (un pulso cada segundo),
     Disponibilidad = 100 × marcha / (marcha + alarma) y CajasPorHora = CajasPaletizadas × 3600 / marcha.
   Muchas de estas cosas cambian código de etapas anteriores: la memoria de marcha, el Alimentador,
   la baliza. *)

(* ---- tu código de la etapa 7 ---- *)
