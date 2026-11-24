(* Misión 7 · Solución de referencia: máquina de estados con CASE, contadores de entrada y salida. *)
VAR_INPUT
  Marcha : BOOL;              (* pulsador de marcha: TRUE solo mientras se pulsa *)
  Paro : BOOL;                (* pulsador de paro: TRUE solo mientras se pulsa *)
  FotocelulaEntrada : BOOL;   (* a la entrada de la cinta de rodillos (3,5 m) *)
  FotocelulaTope : BOOL;      (* justo antes del tope (6,55 m): TRUE con una caja esperando *)
  FotocelulaSalida : BOOL;    (* en la cinta de salida (8,2 m) *)
  CajasCargadas : INT;        (* cajas retiradas al final, en el muelle *)
END_VAR
VAR_OUTPUT
  CintaEntrada : BOOL;        (* cinta de entrada (con ella se para también el alimentador) *)
  Alimentador : BOOL;         (* TRUE: entran cajas *)
  Rodillos : BOOL;            (* cinta de rodillos de acumulación: puede girar con cajas paradas encima *)
  CintaSalida : BOOL;         (* cinta de salida, el doble de rápida *)
  Tope : BOOL;                (* TRUE: el tope sube y retiene las cajas *)
  Fase : INT;                 (* tu máquina de estados: 0 = acumulando, 1 = liberando *)
  Lotes : INT;                (* lotes de 3 entregados *)
END_VAR
VAR
  EnMarcha : BOOL;
  Entra : R_TRIG;     (* una caja entra en los rodillos *)
  Sale : R_TRIG;      (* una caja sale por la cinta de salida *)
  Entradas : INT;     (* cajas en los rodillos *)
  Salidas : INT;      (* cajas que han salido en la liberación actual *)
  Asentado : TON;     (* da tiempo a la tercera caja a llegar al tope *)
END_VAR

EnMarcha := (Marcha OR EnMarcha) AND NOT Paro;

(* Los flancos y los temporizadores se llaman fuera del CASE: un bloque que no se llama en un ciclo
   no ve los cambios de su entrada, y un flanco perdido es una caja sin contar. *)
Entra(CLK := FotocelulaEntrada);
Sale(CLK := FotocelulaSalida);
IF Entra.Q THEN
  Entradas := Entradas + 1;
END_IF;
Asentado(IN := Fase = 0 AND Entradas >= 3 AND FotocelulaTope AND EnMarcha, PT := T#3s);

CASE Fase OF
  0: (* acumulando *)
    IF Asentado.Q THEN
      Fase := 1;
      Salidas := 0;
    END_IF;
  1: (* liberando *)
    IF Sale.Q THEN
      Salidas := Salidas + 1;
    END_IF;
    IF Salidas >= 3 THEN
      Fase := 0;
      Entradas := Entradas - 3;
      Lotes := Lotes + 1;
    END_IF;
END_CASE;

(* El tope solo baja liberando y con la línea en marcha. *)
Tope := NOT (Fase = 1 AND EnMarcha);
(* La entrada se para en cuanto hay 3 cajas dentro: si siguiera, una cuarta se colaría con el lote. *)
CintaEntrada := EnMarcha AND Fase = 0 AND Entradas < 3;
Alimentador := CintaEntrada;
Rodillos := EnMarcha;
CintaSalida := EnMarcha;
