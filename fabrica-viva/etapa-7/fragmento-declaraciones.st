(* ===== Etapa 7 · Turno completo: señales nuevas ===== *)
VAR_INPUT
  ModoManual : BOOL;      (* selector MANUAL (se queda pulsado): TRUE = manual *)
  AvanceManual : BOOL;    (* pulsador AVANCE: en manual, mueve los rodillos de palés *)
  FinTurno : BOOL;        (* pulsador FIN TURNO: vaciar la línea y parar *)
END_VAR
VAR_OUTPUT
  EstadoLinea : INT;      (* 0 parada, 1 en marcha, 2 vaciando, 3 en alarma, 4 manual *)
  AlarmaTransporte : BOOL;(* un palé no ha llegado al muelle a tiempo *)
  TurnosTerminados : INT; (* objetivo en directo: vaciados completos *)
  TiempoMarcha : DINT;    (* segundos en marcha *)
  TiempoAlarma : DINT;    (* segundos parada por alarma *)
  Disponibilidad : REAL;  (* % *)
  CajasPorHora : REAL;    (* objetivo en directo *)
END_VAR
VAR
  Vaciando : BOOL;        (* fin de turno pedido: la línea se está vaciando *)
  PaleEnCamino : BOOL;    (* un palé ha salido de la enfardadora y no ha llegado al muelle *)
END_VAR
