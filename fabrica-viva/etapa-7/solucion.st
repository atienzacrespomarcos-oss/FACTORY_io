(* Fábrica viva · Etapa 7 · Solución de referencia: modos manual y automático, fin de turno, supervisión de transporte e indicadores. *)
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

FUNCTION_BLOCK FB_Muting
VAR_INPUT
  SensorA : BOOL;
  SensorB : BOOL;
  CortinaLibre : BOOL;
END_VAR
VAR_OUTPUT
  Activo : BOOL;
  ZonaSegura : BOOL;
END_VAR
VAR
  SubeB : R_TRIG;
  Limite : TON;
END_VAR

(* El muting empieza solo si los dos sensores se tapan en orden, A y luego B, como hace un palé al
   llegar; una persona que cruza la cortina no los tapa así. Acaba cuando la carga ha pasado: los dos
   sensores libres y la cortina despejada. Con un tiempo máximo, por si se queda algo a medias. *)
SubeB(CLK := SensorB);
IF SubeB.Q AND SensorA THEN
  Activo := TRUE;
END_IF;
IF Activo AND NOT SensorA AND NOT SensorB AND CortinaLibre THEN
  Activo := FALSE;
END_IF;
Limite(IN := Activo, PT := T#30s);
IF Limite.Q THEN
  Activo := FALSE;
END_IF;
ZonaSegura := CortinaLibre OR Activo;
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Paletizado
VAR_INPUT
  Habilitar : BOOL;
  CajaLista : BOOL;
  PaleListo : BOOL;
  RobotListo : BOOL;
  Reiniciar : BOOL;
END_VAR
VAR_OUTPUT
  Trabajo : INT;
  Ejecutar : BOOL;
  Paso : INT;
  Colocadas : INT;
  Total : INT;
  PaleLleno : BOOL;
END_VAR

(* Intercambio de señales con el robot: se fija el trabajo, se mantiene Ejecutar hasta que el robot
   avisa de que lo ha empezado (cae RobotListo) y se espera a que vuelva a estar listo. *)
Ejecutar := FALSE;
CASE Paso OF
  0: (* esperando caja y palé *)
    IF Reiniciar THEN
      Colocadas := 0;
    END_IF;
    IF Habilitar AND CajaLista AND PaleListo AND RobotListo AND Colocadas < 8 THEN
      Trabajo := 1;
      Paso := 1;
    END_IF;
  1: (* recoger: orden dada *)
    Ejecutar := TRUE;
    IF NOT RobotListo THEN
      Paso := 2;
    END_IF;
  2: (* recogiendo *)
    IF RobotListo AND Habilitar THEN
      Trabajo := 2 + Colocadas;
      Paso := 3;
    END_IF;
  3: (* dejar en su hueco: orden dada *)
    Ejecutar := TRUE;
    IF NOT RobotListo THEN
      Paso := 4;
    END_IF;
  4: (* dejando y volviendo a reposo *)
    IF RobotListo THEN
      Colocadas := Colocadas + 1;
      Total := Total + 1;
      Paso := 0;
    END_IF;
END_CASE;
PaleLleno := Colocadas >= 8;
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

VAR_INPUT
  FotocelulaPicking : BOOL;
  PalePresente : BOOL;
  PaleEnDispensador : BOOL;
  DispensadorOcupado : BOOL;
  RobotListo : BOOL;
  SalidaPales : INT;
END_VAR
VAR_OUTPUT
  RodillosPale : BOOL;
  TopePale : BOOL;
  DarPale : BOOL;
  RobotTrabajo : INT;
  RobotEjecutar : BOOL;
  RobotHabilitado : BOOL;
  CajasPaletizadas : INT;
  PalesCompletos : INT;
END_VAR
VAR
  Paletizado : FB_Paletizado;
  PasoPale : INT;
  CajaQuieta : TON;
  Asentado : TON;
  Fuera : TON;
END_VAR

VAR_INPUT
  PaleEnEnfardadora : BOOL;
  EnfardadoraOcupada : BOOL;
  EnfardadoHecho : BOOL;
  CortinaLibre : BOOL;
  MutingA : BOOL;
  MutingB : BOOL;
  PaleEnMuelle : BOOL;
  SalidaExpedicion : INT;
END_VAR
VAR_OUTPUT
  RodillosEnfardado : BOOL;
  Enfardar : BOOL;
  EnfardadoraHabilitada : BOOL;
  RodillosExpedicion : BOOL;
  LamparaMuting : BOOL;
  AlarmaCortina : BOOL;
  PalesExpedidos : INT;
END_VAR
VAR
  Muting : FB_Muting;
  PasoEnf : INT;
  Salido : TON;
  MuelleOcupado : TOF;
  LlegaMuelle : F_TRIG;
END_VAR

VAR_INPUT
  ModoManual : BOOL;
  AvanceManual : BOOL;
  FinTurno : BOOL;
END_VAR
VAR_OUTPUT
  EstadoLinea : INT;
  AlarmaTransporte : BOOL;
  TurnosTerminados : INT;
  TiempoMarcha : DINT;
  TiempoAlarma : DINT;
  Disponibilidad : REAL;
  CajasPorHora : REAL;
END_VAR
VAR
  Vaciando : BOOL;
  FinVaciado : BOOL;
  Vacia : TON;
  PaleEnCamino : BOOL;
  Supervision : TON;
  Parpadeo : TON;
  Luz : BOOL;
  Avance : TP;
  Segundo : TON;
  HayAlarma : BOOL;
END_VAR

(* Etapas 1 y 2 *)
HayAlarma := AlarmaAtasco OR AlarmaCortina OR AlarmaTransporte;
EnMarcha := (Marcha OR EnMarcha) AND NOT Paro AND Seta AND NOT HayAlarma AND NOT ModoManual AND NOT FinVaciado;
CintaRecepcion := EnMarcha;
Alimentador := EnMarcha AND NOT PulmonLleno AND NOT Vaciando;
Control(Habilitar := EnMarcha, Presencia := FotocelulaAtasco, Rearme := Rearme);
CintaControl := Control.Motor;
AlarmaAtasco := Control.Atasco;
IF NOT Seta OR AlarmaCortina THEN
  Baliza := 4;
ELSIF AlarmaAtasco OR AlarmaTransporte THEN
  Baliza := 6;
ELSIF ModoManual THEN
  (* manual: ámbar intermitente *)
  IF Luz THEN
    Baliza := 2;
  ELSE
    Baliza := 0;
  END_IF;
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
Ritmo(IN := Pulmon.Estado = 0, PT := T#10s);
(* etapa 5: además, solo con el punto de recogida libre, para no bajar el tope con la cinta de salida parada *)
Pulmon(Habilitar := EnMarcha, CajaEnTope := FotocelulaTope, Permiso := Ritmo.Q AND NOT FotocelulaPicking);
TopePulmon := Pulmon.Tope;
RodillosPulmon := Pulmon.Avance;
LlenoTapada(IN := FotocelulaLleno, PT := T#2s);
LlenoLibre(IN := NOT FotocelulaLleno, PT := T#3s);
IF LlenoTapada.Q THEN
  PulmonLleno := TRUE;
ELSIF LlenoLibre.Q THEN
  PulmonLleno := FALSE;
END_IF;

(* Etapa 5: la cinta de salida lleva cada caja al punto de recogida y espera allí a que el robot la coja. *)
CintaSalidaPulmon := Pulmon.Salida AND NOT FotocelulaPicking;
CajaQuieta(IN := FotocelulaPicking, PT := T#300ms);
RobotHabilitado := EnMarcha;

(* Palés: pedir uno al dispensador, llevarlo al tope, cargarlo y sacarlo lleno. *)
DarPale := FALSE;
RodillosPale := FALSE;
TopePale := TRUE;
CASE PasoPale OF
  0: (* pedir un palé (el dispensador actúa en el flanco de subida) *)
    IF EnMarcha AND NOT DispensadorOcupado THEN
      PasoPale := 1;
    END_IF;
  1:
    DarPale := TRUE;
    IF DispensadorOcupado THEN
      PasoPale := 2;
    END_IF;
  2: (* el dispensador lo deja sobre los rodillos: no se mueven hasta que termina *)
    IF NOT DispensadorOcupado THEN
      PasoPale := 3;
    END_IF;
  3: (* llevarlo hasta el tope *)
    RodillosPale := EnMarcha;
    IF Asentado.Q THEN
      PasoPale := 4;
    END_IF;
  4: (* cargando: lo hace el robot *)
    IF Paletizado.PaleLleno AND Paletizado.Paso = 0 THEN
      PasoPale := 5;
    END_IF;
  5: (* sacar el palé lleno *)
    TopePale := FALSE;
    RodillosPale := EnMarcha;
    IF Fuera.Q THEN
      PalesCompletos := PalesCompletos + 1;
      PasoPale := 0;
    END_IF;
END_CASE;
Asentado(IN := PasoPale = 3 AND PalePresente, PT := T#2s);
Fuera(IN := PasoPale = 5 AND NOT PalePresente, PT := T#3s);

Paletizado(Habilitar := EnMarcha, CajaLista := CajaQuieta.Q, PaleListo := PasoPale = 4, RobotListo := RobotListo,
  Reiniciar := PasoPale <> 4);
RobotTrabajo := Paletizado.Trabajo;
RobotEjecutar := Paletizado.Ejecutar;
CajasPaletizadas := Paletizado.Total;

(* Etapa 6: la cortina del muelle. Si se corta sin muting, alarma: se para la línea y hace falta
   Rearme (con la cortina despejada) y luego Marcha. *)
Muting(SensorA := MutingA, SensorB := MutingB, CortinaLibre := CortinaLibre);
LamparaMuting := Muting.Activo;
IF NOT Muting.ZonaSegura THEN
  AlarmaCortina := TRUE;
ELSIF Rearme THEN
  AlarmaCortina := FALSE;
END_IF;

(* Enfardado: recibir el palé, pararlo bajo el brazo, enfardar y soltarlo. *)
Enfardar := FALSE;
RodillosEnfardado := FALSE;
EnfardadoraHabilitada := EnMarcha;
CASE PasoEnf OF
  0: (* recibir *)
    RodillosEnfardado := EnMarcha;
    IF PaleEnEnfardadora THEN
      PasoEnf := 1;
    END_IF;
  1: (* orden de enfardar (flanco) *)
    Enfardar := TRUE;
    IF EnfardadoraOcupada THEN
      PasoEnf := 2;
    END_IF;
  2: (* enfardando *)
    IF EnfardadoHecho THEN
      PasoEnf := 3;
    END_IF;
  3: (* soltar hacia el muelle *)
    RodillosEnfardado := EnMarcha;
    IF Salido.Q THEN
      PasoEnf := 0;
    END_IF;
END_CASE;
Salido(IN := PasoEnf = 3 AND NOT PaleEnEnfardadora, PT := T#4s);
RodillosExpedicion := EnMarcha;
(* un palé tiene huecos entre sus tacos: la fotocélula parpadea al pasar. Con el TOF, el palé cuenta
   una vez, cuando la fotocélula lleva 1 s libre. *)
MuelleOcupado(IN := PaleEnMuelle, PT := T#1s);
LlegaMuelle(CLK := MuelleOcupado.Q);
IF LlegaMuelle.Q THEN
  PalesExpedidos := PalesExpedidos + 1;
END_IF;

(* Etapa 7 · Supervisión del transporte: un palé que sale de la enfardadora tiene que llegar al muelle
   en 25 s de rodillos en marcha. Si no (un motor disparado, un palé enganchado), alarma enclavada. *)
IF PasoEnf = 3 THEN
  PaleEnCamino := TRUE;
END_IF;
IF LlegaMuelle.Q THEN
  PaleEnCamino := FALSE;
END_IF;
Supervision(IN := PaleEnCamino AND RodillosExpedicion, PT := T#25s);
IF Supervision.Q THEN
  AlarmaTransporte := TRUE;
ELSIF Rearme THEN
  AlarmaTransporte := FALSE;
END_IF;

(* Fin de turno: no entran más cajas y la línea sigue hasta vaciarse. Se para sola cuando lleva 30 s
   vacía: sin cajas en el pulmón ni en la recogida, el robot en reposo, el último palé lleno ya
   expedido (enfardadora libre y ningún palé en camino) y un palé en el robot. El palé a medias se queda
   en el robot para el turno siguiente. *)
IF FinTurno AND EnMarcha THEN
  Vaciando := TRUE;
END_IF;
Vacia(IN := Vaciando AND NOT FotocelulaEntradaPulmon AND NOT FotocelulaTope AND NOT FotocelulaPicking
  AND Paletizado.Paso = 0 AND PasoPale = 4 AND PasoEnf = 0 AND NOT PaleEnCamino, PT := T#30s);
FinVaciado := Vacia.Q;
IF FinVaciado AND Vaciando THEN
  TurnosTerminados := TurnosTerminados + 1;
  Vaciando := FALSE;
END_IF;
IF NOT EnMarcha THEN
  Vaciando := FALSE;
END_IF;

(* Manual: las secuencias se quedan quietas y cada pulsación de AVANCE mueve 2 s los rodillos de palés,
   de la enfardadora y de expedición, solo con la zona del muelle segura. Para sacar un palé a mano. *)
Parpadeo(IN := NOT Parpadeo.Q, PT := T#500ms);
IF Parpadeo.Q THEN
  Luz := NOT Luz;
END_IF;
Avance(IN := AvanceManual AND ModoManual, PT := T#2s);
IF ModoManual THEN
  RodillosPale := Avance.Q AND Muting.ZonaSegura;
  RodillosEnfardado := Avance.Q AND Muting.ZonaSegura;
  RodillosExpedicion := Avance.Q AND Muting.ZonaSegura;
END_IF;

(* Estado de la línea, para el panel: 0 parada, 1 en marcha, 2 vaciando, 3 en alarma, 4 manual *)
IF ModoManual THEN
  EstadoLinea := 4;
ELSIF HayAlarma OR NOT Seta THEN
  EstadoLinea := 3;
ELSIF Vaciando THEN
  EstadoLinea := 2;
ELSIF EnMarcha THEN
  EstadoLinea := 1;
ELSE
  EstadoLinea := 0;
END_IF;

(* Indicadores (ISO 22400-2: disponibilidad = tiempo produciendo / tiempo que debía producir). Aquí, el
   tiempo que debía producir es el de marcha más el perdido en alarma. Un pulso cada segundo cuenta. *)
Segundo(IN := NOT Segundo.Q, PT := T#1s);
IF Segundo.Q THEN
  IF EnMarcha THEN
    TiempoMarcha := TiempoMarcha + 1;
  ELSIF HayAlarma THEN
    TiempoAlarma := TiempoAlarma + 1;
  END_IF;
END_IF;
IF TiempoMarcha + TiempoAlarma > 0 THEN
  Disponibilidad := 100.0 * DINT_TO_REAL(TiempoMarcha) / DINT_TO_REAL(TiempoMarcha + TiempoAlarma);
END_IF;
IF TiempoMarcha > 0 THEN
  CajasPorHora := INT_TO_REAL(CajasPaletizadas) * 3600.0 / DINT_TO_REAL(TiempoMarcha);
END_IF;
