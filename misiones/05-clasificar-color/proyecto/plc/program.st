(* Misión 5 · Clasificar devoluciones

   En el muelle de entrada llegan paquetes azules (pedidos) y rojos (devoluciones), alternados.
   Las devoluciones deben salir por la cinta lateral; los pedidos siguen hasta el final.

   Objetivo:
   - Marcha y Paro con enclavamiento sobre CintaMarcha y Alimentador (como en la misión 1).
   - Cada caja roja se aparta con el Desviador hacia la cinta lateral; ninguna azul se desvía.
   - Ninguna caja debe caer al suelo.
   - Con Paro, la línea se detiene y el empujador queda recogido.

   Datos útiles: la cinta va a 1 m/s y las cajas miden 0,6 m. Cuando la fotocélula detecta el
   frente de una caja, su centro está a unos 0,67 m del centro del empujador. El empujador tarda
   0,25 s en salir del todo. *)

(* Cómo probarlo: pulsa Play (▶). Para accionar un pulsador, selecciónalo en la lista Scene
   (por ejemplo «Pulsador Marcha») y pulsa la tecla C. En la pestaña Watch ves las variables.
   Cuando creas que está, pulsa «Run tests» (junto a Play): es el juez de la misión. *)
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
  (* tus variables internas *)
END_VAR

(* ---- Tu programa ---- *)
