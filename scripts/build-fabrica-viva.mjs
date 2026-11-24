// Empaqueta la fábrica viva para la web (fabrica-viva/DISENO.md):
//   public/fabrica-viva/etapa-<N>.oip   la planta acumulada de cada etapa (la 1 es el punto de partida)
//   public/fabrica-viva/index.json      las etapas: encargo, objetivos, pistas, y lo que cada ampliación retira,
//                                       ajusta y añade al programa (src/editor/fabricaViva/)
//
//   node scripts/build-fabrica-viva.mjs
//
// Salida generada (.gitignore); la fuente es fabrica-viva/etapa-<N>/.

import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs'
import { join, relative, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { zipSync } from 'fflate'

const ROOT = resolve(fileURLToPath(import.meta.url), '../..')
const SRC = join(ROOT, 'fabrica-viva')
const OUT = join(ROOT, 'public', 'fabrica-viva')
const MTIME = new Date(2000, 0, 1)
const files = (dir) => readdirSync(dir).flatMap((n) => (statSync(join(dir, n)).isDirectory() ? files(join(dir, n)) : [join(dir, n)]))
const leer = (p) => (existsSync(p) ? readFileSync(p, 'utf8') : '')

rmSync(OUT, { recursive: true, force: true })
mkdirSync(OUT, { recursive: true })

const etapas = []
for (const n of readdirSync(SRC).map((d) => /^etapa-(\d+)$/.exec(d)?.[1]).filter(Boolean).map(Number).sort((a, b) => a - b)) {
  const dir = join(SRC, `etapa-${n}`)
  const meta = JSON.parse(readFileSync(join(dir, 'etapa.json'), 'utf8'))
  const proyecto = join(dir, 'proyecto')
  const manifest = JSON.parse(readFileSync(join(proyecto, 'project.json'), 'utf8'))
  const tree = {}
  for (const p of files(proyecto).sort()) tree[relative(proyecto, p).replaceAll('\\', '/')] = [readFileSync(p), { level: 6, mtime: MTIME }]
  writeFileSync(join(OUT, `etapa-${n}.oip`), zipSync(tree))
  etapas.push({
    ...meta,
    orden: n,
    pruebas: (manifest.tests ?? []).length,
    fragmento: {
      bloques: leer(join(dir, 'fragmento-bloques.st')),
      declaraciones: leer(join(dir, 'fragmento-declaraciones.st')),
      codigo: leer(join(dir, 'fragmento-codigo.st')),
    },
  })
}
writeFileSync(join(OUT, 'index.json'), JSON.stringify({ proyecto: 'Fábrica viva', etapas }, null, 2) + '\n')
console.log(`build-fabrica-viva: ${etapas.length} etapa(s) en public/fabrica-viva/`)
