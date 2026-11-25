(* Fábrica viva · Etapa 2 · Solución de referencia: FB_Cinta reutilizable, atasco que para toda la
   línea y rechazo de cajas sin etiqueta. *)
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

(* Solo cuenta con el motor en marcha: una caja delante de la fotocélula con la cinta parada no es un atasco. *)
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

(* Etapa 1, retocada: el atasco también corta la marcha de toda la línea. *)
EnMarcha := (Marcha OR EnMarcha) AND NOT Paro AND Seta AND NOT AlarmaAtasco;
CintaRecepcion := EnMarcha;
Alimentador := EnMarcha;

(* Etapa 2: la cinta de control con su vigilancia. *)
Control(Habilitar := EnMarcha, Presencia := FotocelulaAtasco, Rearme := Rearme);
CintaControl := Control.Motor;
AlarmaAtasco := Control.Atasco;

(* Baliza: emergencia, atasco, marcha o parada. *)
IF NOT Seta THEN
  Baliza := 4;
ELSIF AlarmaAtasco THEN
  Baliza := 6;
ELSIF EnMarcha THEN
  Baliza := 1;
ELSE
  Baliza := 2;
END_IF;

(* Rechazo: el lector dice si la caja que entra lleva etiqueta; se aparta al llegar al desvío. *)
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
