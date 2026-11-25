// Comprueba cada etapa de la fábrica viva (fabrica-viva/DISENO.md, «Cómo se valida cada etapa»):
//   1. con la solución de referencia de la etapa, todas sus pruebas pasan;
//   2. el punto de partida de quien juega:
//      - etapa 1: el programa inicial compila y no supera las pruebas;
//      - etapa N > 1: la solución de la etapa N-1 unida con el fragmento de la etapa N (con unirPrograma, la misma
//        función que usa la app al ampliar) compila, pasa las pruebas de etapas anteriores y falla alguna nueva.
//
//   node scripts/check-fabrica-viva.mjs [N...]

import { spawnSync } from 'node:child_process'
import { cpSync, existsSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { createServer } from 'vite'

const ROOT = resolve(fileURLToPath(import.meta.url), '../..')
const DIR = join(ROOT, 'fabrica-viva')
const only = process.argv.slice(2).map(Number)
const etapas = readdirSync(DIR)
  .map((n) => /^etapa-(\d+)$/.exec(n))
  .filter(Boolean)
  .map((m) => Number(m[1]))
  .filter((n) => only.length === 0 || only.includes(n))
  .sort((a, b) => a - b)

const npm = process.platform === 'win32' ? 'npm.cmd' : 'npm'
const run = (script, folder) => spawnSync(npm, ['run', '-s', script, '--', folder], { cwd: ROOT, encoding: 'utf8' })
/** el resultado de cada prueba, leído de la salida de test-project: { fichero: true|false } */
function porPrueba(out) {
  const r = {}
  for (const l of out.split('\n')) {
    const m = /^([✓✗]) (\S+\.test\.json)/.exec(l)
    if (m) r[m[2]] = m[1] === '✓'
  }
  return r
}
const leer = (p) => (existsSync(p) ? readFileSync(p, 'utf8') : '')

const vite = await createServer({ configFile: false, root: ROOT, logLevel: 'error', server: { middlewareMode: true, hmr: false, ws: false }, appType: 'custom', optimizeDeps: { noDiscovery: true } })
const { unirPrograma, ampliarProyecto } = await vite.ssrLoadModule('/src/editor/fabricaViva/ampliar.ts')
await vite.close()

let fallos = 0
for (const n of etapas) {
  const dir = join(DIR, `etapa-${n}`)
  const tmp = mkdtempSync(join(tmpdir(), `fv-${n}-`))
  const problemas = []
  try {
    const proyecto = join(tmp, 'proyecto')
    cpSync(join(dir, 'proyecto'), proyecto, { recursive: true })
    const manifest = JSON.parse(readFileSync(join(proyecto, 'project.json'), 'utf8'))
    const programa = join(proyecto, manifest.program[0])

    // 1. la solución
    writeFileSync(programa, readFileSync(join(dir, 'solucion.st'), 'utf8'))
    const sol = run('test-project', proyecto)
    if (sol.status !== 0) problemas.push(`la solución no pasa todas las pruebas:\n${sol.stdout.slice(-2500)}`)

    // 2. el punto de partida
    let inicio
    if (n === 1) inicio = readFileSync(join(dir, 'proyecto', manifest.program[0]), 'utf8')
    else {
      inicio = unirPrograma(readFileSync(join(DIR, `etapa-${n - 1}`, 'solucion.st'), 'utf8'), {
        bloques: leer(join(dir, 'fragmento-bloques.st')),
        declaraciones: leer(join(dir, 'fragmento-declaraciones.st')),
        codigo: leer(join(dir, 'fragmento-codigo.st')),
      })
    }
    writeFileSync(programa, inicio)
    const compila = run('check-st', proyecto)
    if (compila.status !== 0) problemas.push(`el punto de partida no compila:\n${compila.stdout}${compila.stderr}`)
    const ini = porPrueba(run('test-project', proyecto).stdout)
    const nuevas = Object.keys(ini).filter((f) => f.startsWith(`e${n}-`))
    const antiguas = Object.keys(ini).filter((f) => !f.startsWith(`e${n}-`))
    if (nuevas.length === 0) problemas.push('la etapa no tiene pruebas propias (e' + n + '-*)')
    if (nuevas.every((f) => ini[f])) problemas.push('el punto de partida ya pasa las pruebas nuevas: no exigen trabajo')
    // las pruebas de flujo anteriores que necesitan la zona nueva funcionando para llegar a su cifra (etapa.json
    // `flujoAnterior`): se exigen con la solución, no con la zona nueva sin programar
    const metaEtapa = JSON.parse(readFileSync(join(dir, 'etapa.json'), 'utf8'))
    const flujo = new Set(metaEtapa.flujoAnterior ?? [])
    const rotas = antiguas.filter((f) => !ini[f] && !flujo.has(f))
    if (rotas.length) problemas.push(`la ampliación rompe pruebas anteriores con la solución previa: ${rotas.join(', ')}`)

    // 3. ampliar la planta de la etapa anterior da exactamente la planta validada de esta etapa
    if (n > 1) {
      const meta = JSON.parse(readFileSync(join(dir, 'etapa.json'), 'utf8'))
      const escena = (k) => JSON.parse(readFileSync(join(DIR, `etapa-${k}`, 'proyecto', 'scene.json'), 'utf8'))
      const ampliada = ampliarProyecto({ name: 'x', scene: escena(n - 1), stProgram: '' }, { scene: escena(n) }, { retira: meta.retira, ajustes: meta.ajustes, fragmento: {} })
      const clave = (ps) => JSON.stringify([...ps].sort((a, b) => a.id.localeCompare(b.id)).map((p) => ({ ...p, params: Object.fromEntries(Object.entries(p.params ?? {}).sort()) })))
      if (clave(ampliada.scene.parts) !== clave(escena(n).parts)) problemas.push('ampliar la planta anterior (retira + ajustes + piezas nuevas) no da la planta de esta etapa: faltan ajustes en etapa.json')
    }

    if (problemas.length === 0) console.log(`✓ etapa ${n}: solución ✓ (${Object.keys(ini).length} pruebas); partida: compila, anteriores ✓ (${antiguas.length}), nuevas ✗ (${nuevas.filter((f) => !ini[f]).length}/${nuevas.length})`)
    else {
      fallos++
      console.log(`✗ etapa ${n}\n  - ${problemas.join('\n  - ')}`)
    }
  } finally {
    rmSync(tmp, { recursive: true, force: true })
  }
}
process.exit(fallos === 0 ? 0 : 1)
