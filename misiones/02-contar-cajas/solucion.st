(* Misión 2 · Solución de referencia: contador por flanco con parada a lote completo. *)
VAR_INPUT
  FotocelulaSalida : BOOL;  (* fotocélula al final de la cinta: TRUE con caja delante *)
  Marcha : BOOL;            (* pulsador verde: TRUE solo mientras se pulsa *)
  Paro : BOOL;              (* pulsador rojo: TRUE solo mientras se pulsa *)
  Rearme : BOOL;            (* pulsador de rearme: TRUE solo mientras se pulsa *)
  CajasSalida : INT;        (* cajas retiradas por el sumidero *)
END_VAR
VAR_OUTPUT
  CintaMarcha : BOOL;       (* TRUE: la cinta se mueve *)
  Alimentador : BOOL;       (* TRUE: el alimentador suelta cajas *)
  Cajas : INT;              (* cajas del lote que han pasado por la fotocélula *)
  LoteCompleto : BOOL;      (* TRUE al llegar a 5 cajas, hasta el rearme *)
END_VAR
VAR
  EnMarcha : BOOL;
  Flanco : R_TRIG;   (* detecta el paso de FALSE a TRUE: una caja que llega a la fotocélula *)
END_VAR

(* La fotocélula está a TRUE todo el tiempo que la caja tarda en pasar (muchos ciclos de scan).
   Contar "mientras está a TRUE" sumaría una vez por ciclo; R_TRIG da un solo pulso por caja. *)
Flanco(CLK := FotocelulaSalida);

(* El rearme va antes que la cuenta, para que un rearme y un flanco en el mismo ciclo dejen el lote a cero. *)
IF Rearme THEN
  Cajas := 0;
  LoteCompleto := FALSE;
END_IF;
IF Flanco.Q THEN
  Cajas := Cajas + 1;
END_IF;
IF Cajas >= 5 THEN
  LoteCompleto := TRUE;
END_IF;

EnMarcha := (Marcha OR EnMarcha) AND NOT Paro AND NOT LoteCompleto;
CintaMarcha := EnMarcha;
Alimentador := EnMarcha;
