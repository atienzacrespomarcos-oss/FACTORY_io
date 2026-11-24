// Empaqueta las misiones de misiones/ para la web:
//   public/misiones/<id>.oip   la carpeta proyecto/ comprimida (un .oip es la carpeta del proyecto en zip,
//                              core/project/projectArchive.ts), sin la solución
//   public/misiones/index.json la lista que leen la página /misiones/ y la app (src/editor/misiones/misiones.ts)
//
//   node scripts/build-misiones.mjs
//
// Los dos son salida generada (.gitignore); la fuente es misiones/<id>/{mision.json, proyecto/}.

import { mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs'
import { join, relative, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { zipSync } from 'fflate'

const ROOT = resolve(fileURLToPath(import.meta.url), '../..')
const SRC = join(ROOT, 'misiones')
const OUT = join(ROOT, 'public', 'misiones')
// fecha fija, como projectArchive.ts: la misma carpeta da el mismo .oip byte a byte
const MTIME = new Date(2000, 0, 1)

function files(dir) {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name)
    return statSync(path).isDirectory() ? files(path) : [path]
  })
}

for (const name of readdirSync(OUT, { withFileTypes: true })) {
  if (name.isFile() && (name.name.endsWith('.oip') || name.name === 'index.json')) rmSync(join(OUT, name.name))
}
mkdirSync(OUT, { recursive: true })

const misiones = []
for (const id of readdirSync(SRC).sort()) {
  const dir = join(SRC, id)
  let meta
  try {
    meta = JSON.parse(readFileSync(join(dir, 'mision.json'), 'utf8'))
  } catch {
    continue
  }
  const project = join(dir, 'proyecto')
  const manifest = JSON.parse(readFileSync(join(project, 'project.json'), 'utf8'))
  const tree = {}
  for (const path of files(project).sort()) {
    tree[relative(project, path).replaceAll('\\', '/')] = [readFileSync(path), { level: 6, mtime: MTIME }]
  }
  writeFileSync(join(OUT, `${id}.oip`), zipSync(tree))
  misiones.push({
    id,
    orden: meta.orden,
    titulo: meta.titulo,
    proyecto: manifest.name,
    nivel: meta.nivel,
    objetivo: meta.objetivo,
    aprenderas: meta.aprenderas ?? [],
    pistas: meta.pistas ?? [],
    origen: meta.origen ?? null,
    tests: (manifest.tests ?? []).length,
  })
}
misiones.sort((a, b) => a.orden - b.orden)
writeFileSync(join(OUT, 'index.json'), JSON.stringify({ misiones }, null, 2) + '\n')
console.log(`build-misiones: ${misiones.length} misión(es) en public/misiones/`)
