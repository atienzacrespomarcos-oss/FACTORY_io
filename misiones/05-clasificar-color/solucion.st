(* Misión 5 · Solución de referencia: memoria de color, retardo (TON) y pulso de empuje (TP). *)
VAR_INPUT
  Marcha : BOOL;            (* pulsador de marcha: TRUE solo mientras se pulsa *)
  Paro : BOOL;              (* pulsador de paro: TRUE solo mientras se pulsa *)
  ColorCaja : INT;          (* sensor de color a 5,9 m: 0 = nada delante, 1 = rojo, 3 = azul *)
  FotocelulaDesvio : BOOL;  (* fotocélula a 6,2 m, justo antes del empujador: TRUE con caja delante *)
  CajasAzules : INT;        (* paquetes retirados al final de la cinta principal *)
  CajasRojas : INT;         (* devoluciones retiradas al final de la cinta lateral *)
END_VAR
VAR_OUTPUT
  CintaMarcha : BOOL;       (* TRUE: se mueven la cinta principal y la lateral *)
  Alimentador : BOOL;       (* TRUE: entran paquetes *)
  Desviador : BOOL;         (* TRUE: el empujador sale y aparta la caja hacia la cinta lateral *)
END_VAR
VAR
  EnMarcha : BOOL;
  EsRoja : BOOL;      (* el color de la última caja que ha leído el sensor *)
  Pendiente : BOOL;   (* hay una caja roja de camino al empujador *)
  Llega : R_TRIG;     (* una caja llega a la fotocélula *)
  Retardo : TON;      (* espera a que la caja esté delante del empujador *)
  Empuje : TP;        (* mantiene el empujador fuera el tiempo justo *)
END_VAR

EnMarcha := (Marcha OR EnMarcha) AND NOT Paro;
CintaMarcha := EnMarcha;
Alimentador := EnMarcha;

(* El sensor solo da un color mientras la caja está delante; se guarda el último leído.
   0 significa "nada delante", así que no borra la memoria. *)
IF ColorCaja = 1 THEN
  EsRoja := TRUE;
ELSIF ColorCaja <> 0 THEN
  EsRoja := FALSE;
END_IF;

(* La fotocélula ve la caja 0,67 m antes del empujador. Si se empuja en ese momento, la pala sale
   antes de que llegue la caja y la caja choca contra su costado. Se espera 0,45 s con un TON. *)
Llega(CLK := FotocelulaDesvio);
IF Llega.Q AND EsRoja AND EnMarcha THEN
  Pendiente := TRUE;
END_IF;
Retardo(IN := Pendiente, PT := T#450ms);
IF Retardo.Q OR NOT EnMarcha THEN
  Pendiente := FALSE;
END_IF;

(* TP da un pulso de duración fija al detectar el flanco de su entrada: 1 s de empuje basta para
   sacar la caja de la cinta y recoger la pala antes de que llegue la siguiente. *)
Empuje(IN := Retardo.Q, PT := T#1s);
Desviador := Empuje.Q AND EnMarcha;
