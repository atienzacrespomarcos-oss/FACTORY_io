(* Misión 6 · Solución de referencia: registro de desplazamiento de códigos y dos desvíos temporizados. *)
VAR_INPUT
  Marcha : BOOL;            (* pulsador de marcha: TRUE solo mientras se pulsa *)
  Paro : BOOL;              (* pulsador de paro: TRUE solo mientras se pulsa *)
  LecturaOk : BOOL;         (* lector de código a 2,5 m: pulso de un ciclo al leer una etiqueta *)
  CodigoDestino : DINT;     (* el código de la última etiqueta leída: 1 = muelle A, 2 = muelle B, 3 = recto *)
  FotocelulaA : BOOL;       (* fotocélula a 4,63 m, antes del empujador A *)
  FotocelulaB : BOOL;       (* fotocélula a 7,63 m, antes del empujador B *)
  CajasA : INT;             (* cajas retiradas en el muelle A *)
  CajasB : INT;             (* cajas retiradas en el muelle B *)
  CajasRecto : INT;         (* cajas retiradas al final de la cinta principal *)
END_VAR
VAR_OUTPUT
  CintaMarcha : BOOL;       (* TRUE: se mueven la cinta principal y las dos laterales *)
  Alimentador : BOOL;       (* TRUE: entran cajas *)
  DesviadorA : BOOL;        (* TRUE: el empujador A aparta la caja hacia el muelle A *)
  DesviadorB : BOOL;        (* TRUE: el empujador B aparta la caja hacia el muelle B *)
END_VAR
VAR
  EnMarcha : BOOL;
  Leido : R_TRIG;
  LlegaA : R_TRIG;
  LlegaB : R_TRIG;
  CodigoEntrada : DINT;
  CodigoTramo : DINT;
  PendienteA : BOOL;
  PendienteB : BOOL;
  RetardoA : TON;
  RetardoB : TON;
  EmpujeA : TP;
  EmpujeB : TP;
END_VAR
(* Un registro de desplazamiento: el código de cada caja viaja con ella de sensor en sensor.
   CodigoEntrada: la caja entre el lector y la fotocélula A. CodigoTramo: la caja entre A y B. *)

EnMarcha := (Marcha OR EnMarcha) AND NOT Paro;
CintaMarcha := EnMarcha;
Alimentador := EnMarcha;
(* El lector da un pulso al leer; se guarda el código de la caja que acaba de entrar. *)
Leido(CLK := LecturaOk);
IF Leido.Q THEN CodigoEntrada := CodigoDestino; END_IF;
(* Primero el tramo de aguas abajo (B) y después el de aguas arriba (A). Las fotocélulas están a 3 m,
   igual que la separación entre cajas, así que a menudo ven una caja cada una en el mismo ciclo.
   Si se tratara A primero, el código de la caja nueva pisaría al de la caja que está llegando a B. *)
LlegaB(CLK := FotocelulaB);
IF LlegaB.Q THEN
  IF CodigoTramo = 2 THEN PendienteB := TRUE; END_IF;
  CodigoTramo := 0;
END_IF;
LlegaA(CLK := FotocelulaA);
IF LlegaA.Q THEN
  IF CodigoEntrada = 1 THEN PendienteA := TRUE; CodigoTramo := 0; ELSE CodigoTramo := CodigoEntrada; END_IF;
  CodigoEntrada := 0;
END_IF;
(* Retardo y empuje de cada muelle, como en la misión 5. *)
RetardoA(IN := PendienteA, PT := T#450ms);
IF RetardoA.Q OR NOT EnMarcha THEN PendienteA := FALSE; END_IF;
RetardoB(IN := PendienteB, PT := T#450ms);
IF RetardoB.Q OR NOT EnMarcha THEN PendienteB := FALSE; END_IF;
EmpujeA(IN := RetardoA.Q, PT := T#1s);
EmpujeB(IN := RetardoB.Q, PT := T#1s);
DesviadorA := EmpujeA.Q AND EnMarcha;
DesviadorB := EmpujeB.Q AND EnMarcha;
