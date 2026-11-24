# Fábrica PLC

Simulador web de fábrica con PLC virtual. Montas una línea (cintas, sensores, desviadores, robots…),
la programas en **Structured Text** o **Ladder** (subconjunto de IEC 61131-3) y la pones en marcha,
todo en el navegador y sin hardware.

**Jugar:** <https://atienzacrespomarcos-oss.github.io/FACTORY_io/app/>
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
| F2 | Capa de juego: misiones con juez automático, puntuación y progresión | pendiente |
| F3 | Temática de la fábrica | pendiente |
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
