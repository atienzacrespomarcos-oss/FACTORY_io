(* Misión 6 · Enrutar por código de barras

   Cada caja lleva una etiqueta con su muelle de destino. El lector la lee al pasar y da el código en
   CodigoDestino con un pulso en LecturaOk. Código 1: muelle A (cinta lateral A). Código 2: muelle B
   (cinta lateral B). Código 3: sigue recto hasta el final.

   Objetivo:
   - Marcha y Paro con enclavamiento sobre CintaMarcha y Alimentador.
   - Cada caja sale por su muelle; ninguna cae al suelo.

   Datos útiles: la cinta va a 1 m/s. Cada empujador está 0,37 m después de su fotocélula y tarda
   0,25 s en salir (como en la misión 5). Las cajas viajan separadas unos 3 m, y entre el lector y
   el último empujador puede haber varias a la vez: el programa tiene que saber qué código lleva
   cada una. Ojo: las fotocélulas A y B también están a 3 m entre sí. *)

(* Cómo probarlo: pulsa Play (▶). Para accionar un pulsador, selecciónalo en la lista Scene
   (por ejemplo «Pulsador Marcha») y pulsa la tecla C. En la pestaña Watch ves las variables.
   Cuando creas que está, pulsa «Run tests» (junto a Play): es el juez de la misión. *)
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
  (* tus variables internas *)
END_VAR

(* ---- Tu programa ---- *)
