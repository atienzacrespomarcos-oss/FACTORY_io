# Fábrica PLC

Simulador web de fábrica con PLC virtual. Montas una línea (cintas, sensores, desviadores, robots…),
la programas en **Structured Text** o **Ladder** (subconjunto de IEC 61131-3) y la pones en marcha,
todo en el navegador y sin hardware.

**Jugar:** <https://atienzacrespomarcos-oss.github.io/FACTORY_io/> (inicio: Fábrica viva, Academia y modo libre)
(Chrome o Edge recomendados; en Chrome la interfaz se traduce sola al español con el traductor del navegador).

## Origen y licencia

Este proyecto parte de [Open Industry Project](https://github.com/Open-Industry-Project/Open-Industry-Project)
(commit `01a9127`, licencia MIT, © 2024-present Automation Standard LLC and Contributors).
El primer commit de este repositorio es ese código sin modificar; los cambios propios van en commits posteriores.

- La licencia MIT original se conserva en [LICENSE](LICENSE) y los avisos de terceros en
  [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
- Proyecto independiente, **sin afiliación** con Open Industry Project ni con sus autores.
  Su nombre y logotipos no se usan como marca de este proyecto (la licencia MIT no cubre marcas).

## Hoja de ruta

| Fase | Contenido | Estado |
|---|---|---|
| F0 | Fork, marca propia, publicación automática en GitHub Pages | hecho |
| F1 | Tutor con Claude Code (pista / explicar / hacer), sin API de pago: ver [tutor/LEEME.md](tutor/LEEME.md) | hecho |
| F2 | Misiones con juez automático y progreso: ver [misiones/](misiones/) y la página `/misiones/` | hecho |
| F3 | Temática: centro logístico. Fábrica viva (planta que crece en 7 etapas, de la recepción al turno completo) + Academia (7 ejercicios sueltos) | hecho |
| F4 | Pulido | pendiente |

## Desarrollo local

Requiere Node 24 o superior.

```sh
npm ci
npm run dev     # portada en /, simulador en /app/
npm test
npm run build   # salida en dist/
```

La documentación técnica heredada del proyecto original está en [docs/](docs/README.md) (en inglés).

## Publicación

`.github/workflows/publicar.yml` compila y publica en GitHub Pages en cada push a `main`. La app escribe sus URLs
desde la raíz (`/models`, `/app/`…); como este repositorio se sirve en `/FACTORY_io/`,
[scripts/rebase-dist.mjs](scripts/rebase-dist.mjs) antepone ese prefijo a las rutas del build antes de publicarlo.
Con un repositorio `<usuario>.github.io` el prefijo es vacío y el paso no cambia nada.

GitHub Pages no permite las cabeceras COOP/COEP, así que la física y el PLC funcionan en un solo hilo
(la app lo detecta y cae a ese modo sola).

## Fábrica viva

El modo principal: una única planta, la tuya, que crece. Diseño y progresión en
[fabrica-viva/DISENO.md](fabrica-viva/DISENO.md).

- `fabrica-viva/etapa-<N>/`: la planta acumulada hasta esa etapa (`proyecto/`), la solución de referencia,
  el fragmento de programa que se añade al ampliar (`fragmento-*.st`) y la ficha (`etapa.json`: encargo,
  objetivos en directo, pistas, piezas que retira y parámetros que ajusta).
- `npm run check-fabrica-viva` comprueba que cada escena tiene el orden de piezas de la ampliación
  (`scripts/encadenar-fabrica-viva.mjs` lo arregla) y después cada etapa: la solución pasa todo; la solución de la etapa anterior
  más el fragmento nuevo (unidos con la misma función que la app) compila, mantiene las pruebas anteriores y
  falla las nuevas; y ampliar la planta anterior da exactamente la planta de la etapa.
- En la app: `/app/?fabrica=viva` abre tu fábrica; el panel de encargos lee los objetivos en directo, el juez
  certifica la etapa y «Ampliar la fábrica» une la etapa siguiente con tu planta (`src/editor/fabricaViva/`).

## Academia (misiones)

Cada misión es una carpeta `misiones/<id>/`:

- `proyecto/`: el proyecto que se abre en la app (escena, `plc/program.st` inicial y `tests/`, que son el juez);
- `solucion.st`: una solución de referencia (no se publica en el `.oip`);
- `mision.json`: título, nivel, objetivo, qué se aprende y pistas.

`npm run check-misiones` comprueba en cada una que el programa inicial compila y no supera el juez, y que la
solución lo supera. `npm run build` empaqueta las misiones en `public/misiones/` (`scripts/build-misiones.mjs`).
En la app, `/app/?mision=<id>` abre la misión, y al ejecutar **Run Project Tests** el resultado se guarda en el
navegador (`src/editor/misiones/misiones.ts`). Solo cuenta si los tests son los oficiales de la misión.
