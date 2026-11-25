// Deja la escena de cada etapa de la Fábrica viva en el orden de piezas que tiene la planta de quien juega:
// la de la etapa 1 ampliada una vez por etapa con la misma función que la app (src/editor/fabricaViva/ampliar.ts).
//
//   node scripts/encadenar-fabrica-viva.mjs [--check]
//
// Por qué: el contenido de la escena de la etapa N ya es el de la ampliación (check-fabrica-viva lo comprueba), pero
// el orden de las piezas decide el orden en que se crean los cuerpos de la física, y con él pequeñas diferencias en
// una simulación que no es lineal. Con el mismo orden, el validador simula exactamente la planta que recibe quien
// juega. Solo cambia el orden: si el contenido no coincide, se detiene y no escribe nada.
// Con --check no escribe: sale con 1 si alguna escena no está en ese orden.

import { readFileSync, readdirSync, writeFileSync } from 'node:fs'
import { dirname, join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { createServer } from 'vite'

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const DIR = join(ROOT, 'fabrica-viva')
const soloComprobar = process.argv.includes('--check')
const etapas = readdirSync(DIR)
  .map((d) => /^etapa-(\d+)$/.exec(d)?.[1])
  .filter(Boolean)
  .map(Number)
  .sort((a, b) => a - b)

const vite = await createServer({ configFile: false, root: ROOT, logLevel: 'error', server: { middlewareMode: true, hmr: false, ws: false }, appType: 'custom', optimizeDeps: { noDiscovery: true } })
let fuera = 0
try {
  const { ampliarProyecto } = await vite.ssrLoadModule('/src/editor/fabricaViva/ampliar.ts')
  const ruta = (n) => join(DIR, `etapa-${n}`, 'proyecto', 'scene.json')
  const clave = (ps) => JSON.stringify([...ps].sort((a, b) => a.id.localeCompare(b.id)).map((p) => ({ ...p, params: Object.fromEntries(Object.entries(p.params ?? {}).sort()) })))
  let planta = JSON.parse(readFileSync(ruta(etapas[0]), 'utf8'))
  for (const n of etapas.slice(1)) {
    const escena = JSON.parse(readFileSync(ruta(n), 'utf8'))
    const meta = JSON.parse(readFileSync(join(DIR, `etapa-${n}`, 'etapa.json'), 'utf8'))
    planta = ampliarProyecto({ name: 'x', scene: planta, stProgram: '' }, { scene: escena }, { retira: meta.retira, ajustes: meta.ajustes, fragmento: {} }).scene
    if (clave(planta.parts) !== clave(escena.parts)) {
      console.error(`✗ etapa ${n}: la ampliación no da la escena de la etapa (faltan ajustes en etapa.json); no se escribe nada`)
      process.exit(1)
    }
    const enOrden = planta.parts.map((p) => p.id).join() === escena.parts.map((p) => p.id).join()
    if (enOrden) console.log(`✓ etapa ${n}: ya en el orden de la ampliación`)
    else if (soloComprobar) {
      fuera++
      console.log(`✗ etapa ${n}: no está en el orden de la ampliación (node scripts/encadenar-fabrica-viva.mjs)`)
    } else {
      writeFileSync(ruta(n), JSON.stringify({ ...escena, parts: planta.parts }, null, 2) + '\n')
      console.log(`✓ etapa ${n}: reordenada`)
    }
  }
} finally {
  await vite.close()
}
process.exit(fuera ? 1 : 0)
