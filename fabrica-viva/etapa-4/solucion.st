(* Fábrica viva · Etapa 4 · Solución de referencia: pulmón con máquina de estados (FB_Pulmon) y retención. *)
FUNCTION_BLOCK FB_Cola
VAR_INPUT
  Meter : BOOL;
  Valor : DINT;
  Sacar : BOOL;
END_VAR
VAR_OUTPUT
  Primero : DINT;
  Cantidad : INT;
END_VAR
VAR
  Datos : ARRAY[0..15] OF DINT;
  i : INT;
END_VAR

(* Sacar desplaza todo un puesto hacia la cabeza; meter escribe detrás del último. *)
IF Sacar AND Cantidad > 0 THEN
  FOR i := 0 TO 14 DO
    Datos[i] := Datos[i + 1];
  END_FOR;
  Cantidad := Cantidad - 1;
END_IF;
IF Meter AND Cantidad < 16 THEN
  Datos[Cantidad] := Valor;
  Cantidad := Cantidad + 1;
END_IF;
IF Cantidad > 0 THEN
  Primero := Datos[0];
ELSE
  Primero := 0;
END_IF;
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Pulmon
VAR_INPUT
  Habilitar : BOOL;
  CajaEnTope : BOOL;
  Permiso : BOOL;
END_VAR
VAR_OUTPUT
  Tope : BOOL;
  Avance : BOOL;
  Salida : BOOL;
  Estado : INT;
  Liberadas : INT;
END_VAR
VAR
  Cerrando : TON;
  Bajando : TON;
END_VAR

CASE Estado OF
  0: (* esperando *)
    IF Habilitar AND CajaEnTope AND Permiso THEN
      Estado := 1;
    END_IF;
  1: (* liberando: rodillos parados (la caja siguiente se queda) y tope abajo hasta que la caja se va *)
    IF NOT CajaEnTope THEN
      Liberadas := Liberadas + 1;
      Estado := 2;
    END_IF;
  2: (* cerrando: tope arriba; los rodillos arrancan cuando ha subido *)
    IF Cerrando.Q THEN
      Estado := 0;
    END_IF;
END_CASE;
(* el temporizador se llama fuera del CASE: así ve siempre su entrada *)
Cerrando(IN := Estado = 2, PT := T#500ms);
Bajando(IN := Estado = 1, PT := T#400ms);
Tope := Estado <> 1;
Avance := Habilitar AND Estado = 0;
(* la cinta de salida espera a que el tope haya bajado del todo antes de llevarse la caja *)
Salida := Habilitar AND NOT (Estado = 1 AND NOT Bajando.Q);
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Cinta
VAR_INPUT
  Habilitar : BOOL;
  Presencia : BOOL;
  Rearme : BOOL;
END_VAR
VAR_OUTPUT
  Motor : BOOL;
  Atasco : BOOL;
END_VAR
VAR
  Tapada : TON;
END_VAR

Tapada(IN := Presencia AND Motor, PT := T#3s);
IF Rearme THEN
  Atasco := FALSE;
END_IF;
IF Tapada.Q THEN
  Atasco := TRUE;
END_IF;
Motor := Habilitar AND NOT Atasco;
END_FUNCTION_BLOCK

VAR_INPUT
  Marcha : BOOL;
  Paro : BOOL;
  Seta : BOOL;
  FotocelulaRecepcion : BOOL;
  CajasRecibidas : INT;
END_VAR
VAR_OUTPUT
  CintaRecepcion : BOOL;
  Alimentador : BOOL;
  Baliza : INT;
END_VAR
VAR
  EnMarcha : BOOL;
END_VAR

VAR_INPUT
  Rearme : BOOL;
  FotocelulaAtasco : BOOL;
  LecturaOk : BOOL;
  CodigoCaja : DINT;
  FotocelulaRechazo : BOOL;
  CajasRechazadas : INT;
  CajasFinLinea : INT;
END_VAR
VAR_OUTPUT
  CintaControl : BOOL;
  Desvio : BOOL;
  AlarmaAtasco : BOOL;
END_VAR
VAR
  Control : FB_Cinta;
  Leida : R_TRIG;
  Llega : R_TRIG;
  SinEtiqueta : BOOL;
  Pendiente : BOOL;
  Retardo : TON;
  Empuje : TP;
END_VAR

VAR_INPUT
  FotocelulaExpres : BOOL;
  FotocelulaDevol : BOOL;
  CajasExpres : INT;
  CajasDevueltas : INT;
  CajasPedidos : INT;
END_VAR
VAR_OUTPUT
  CintaClasificacion : BOOL;
  DesvioExpres : BOOL;
  DesvioDevol : BOOL;
END_VAR
VAR
  ColaA : FB_Cola;
  ColaB : FB_Cola;
  CodigoEnA : DINT;
  LlegaA : R_TRIG;
  LlegaB : R_TRIG;
  PendienteA : BOOL;
  PendienteB : BOOL;
  RetardoA : TON;
  RetardoB : TON;
  EmpujeA : TP;
  EmpujeB : TP;
END_VAR

VAR_INPUT
  FotocelulaEntradaPulmon : BOOL;
  FotocelulaLleno : BOOL;
  FotocelulaTope : BOOL;
  FotocelulaSalidaPulmon : BOOL;
  CajasAPaletizar : INT;
END_VAR
VAR_OUTPUT
  RodillosPulmon : BOOL;
  TopePulmon : BOOL;
  CintaSalidaPulmon : BOOL;
  PulmonLleno : BOOL;
END_VAR
VAR
  Pulmon : FB_Pulmon;
  Ritmo : TON;
  LlenoTapada : TON;
  LlenoLibre : TON;
END_VAR

(* Etapas 1 y 2 *)
EnMarcha := (Marcha OR EnMarcha) AND NOT Paro AND Seta AND NOT AlarmaAtasco;
CintaRecepcion := EnMarcha;
Alimentador := EnMarcha AND NOT PulmonLleno;
Control(Habilitar := EnMarcha, Presencia := FotocelulaAtasco, Rearme := Rearme);
CintaControl := Control.Motor;
AlarmaAtasco := Control.Atasco;
IF NOT Seta THEN
  Baliza := 4;
ELSIF AlarmaAtasco THEN
  Baliza := 6;
ELSIF EnMarcha AND PulmonLleno THEN
  Baliza := 3;
ELSIF EnMarcha THEN
  Baliza := 1;
ELSE
  Baliza := 2;
END_IF;
Leida(CLK := LecturaOk);
IF Leida.Q THEN
  SinEtiqueta := CodigoCaja = 0;
END_IF;
Llega(CLK := FotocelulaRechazo);
IF Llega.Q AND SinEtiqueta AND EnMarcha THEN
  Pendiente := TRUE;
END_IF;
Retardo(IN := Pendiente, PT := T#450ms);
IF Retardo.Q OR NOT EnMarcha THEN
  Pendiente := FALSE;
END_IF;
Empuje(IN := Retardo.Q, PT := T#600ms);
Desvio := Empuje.Q AND EnMarcha;

(* Etapa 3. Primero se detectan las llegadas; después se decide con la cabeza de cada cola (el código de la
   caja que acaba de llegar) y por último se actualizan las colas, cada una con una sola llamada por ciclo. *)
CintaClasificacion := EnMarcha;
LlegaB(CLK := FotocelulaDevol);
LlegaA(CLK := FotocelulaExpres);
IF LlegaB.Q AND ColaB.Primero = 104 THEN
  PendienteB := TRUE;
END_IF;
CodigoEnA := ColaA.Primero;
IF LlegaA.Q AND CodigoEnA = 103 THEN
  PendienteA := TRUE;
END_IF;
(* la caja que pasa el empujador exprés sin desviarse entra en la cola del tramo siguiente *)
ColaB(Meter := LlegaA.Q AND ColaA.Cantidad > 0 AND CodigoEnA <> 103, Valor := CodigoEnA, Sacar := LlegaB.Q);
ColaA(Meter := Leida.Q AND CodigoCaja <> 0, Valor := CodigoCaja, Sacar := LlegaA.Q);

RetardoA(IN := PendienteA, PT := T#450ms);
IF RetardoA.Q OR NOT EnMarcha THEN
  PendienteA := FALSE;
END_IF;
EmpujeA(IN := RetardoA.Q, PT := T#600ms);
DesvioExpres := EmpujeA.Q AND EnMarcha;
RetardoB(IN := PendienteB, PT := T#450ms);
IF RetardoB.Q OR NOT EnMarcha THEN
  PendienteB := FALSE;
END_IF;
EmpujeB(IN := RetardoB.Q, PT := T#600ms);
DesvioDevol := EmpujeB.Q AND EnMarcha;

(* Etapa 4: el pulmón suelta una caja cada 10 s como mucho, y retiene la descarga si se llena. *)
CintaSalidaPulmon := Pulmon.Salida;
Ritmo(IN := Pulmon.Estado = 0, PT := T#10s);
Pulmon(Habilitar := EnMarcha, CajaEnTope := FotocelulaTope, Permiso := Ritmo.Q);
TopePulmon := Pulmon.Tope;
RodillosPulmon := Pulmon.Avance;
LlenoTapada(IN := FotocelulaLleno, PT := T#2s);
LlenoLibre(IN := NOT FotocelulaLleno, PT := T#3s);
IF LlenoTapada.Q THEN
  PulmonLleno := TRUE;
ELSIF LlenoLibre.Q THEN
  PulmonLleno := FALSE;
END_IF;
