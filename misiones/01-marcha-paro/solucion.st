(* Misión 1 · Solución de referencia: marcha y paro con enclavamiento (autorretención). *)
VAR_INPUT
  FotocelulaSalida : BOOL;
  Marcha : BOOL;
  Paro : BOOL;
  CajasSalida : INT;
END_VAR
VAR_OUTPUT
  CintaMarcha : BOOL;
  Alimentador : BOOL;
END_VAR
VAR
  EnMarcha : BOOL;
END_VAR

(* Marcha es un pulsador: solo está a TRUE mientras se pulsa. El término "OR EnMarcha" mantiene la orden
   cuando se suelta (enclavamiento). "AND NOT Paro" va al final para que Paro gane si se pulsan los dos. *)
EnMarcha := (Marcha OR EnMarcha) AND NOT Paro;
CintaMarcha := EnMarcha;
Alimentador := EnMarcha;
