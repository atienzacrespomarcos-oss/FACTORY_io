// Comprueba que cada misión de misiones/ es justa y resoluble:
//   1. el programa inicial compila (check-st);
//   2. con el programa inicial, el juez (los tests del proyecto) NO se supera: algún test falla;
//   3. con la solución de referencia (solucion.st), el juez se supera: todos los tests pasan.
//
//   node scripts/check-misiones.mjs [id...]
//
// Cada misión es misiones/<id>/ con proyecto/ (carpeta de proyecto), solucion.st y mision.json.

import { spawnSync } from 'node:child_process'
import { cpSync, existsSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const ROOT = resolve(fileURLToPath(import.meta.url), '../..')
const DIR = join(ROOT, 'misiones')
const only = process.argv.slice(2)
const ids = readdirSync(DIR)
  .filter((n) => existsSync(join(DIR, n, 'mision.json')))
  .filter((n) => only.length === 0 || only.includes(n))
  .sort()

const npm = process.platform === 'win32' ? 'npm.cmd' : 'npm'
const run = (script, folder) => spawnSync(npm, ['run', '-s', script, '--', folder], { cwd: ROOT, encoding: 'utf8' })

let failures = 0
for (const id of ids) {
  const mission = join(DIR, id)
  const tmp = mkdtempSync(join(tmpdir(), `mision-${id}-`))
  try {
    const project = join(tmp, 'proyecto')
    cpSync(join(mission, 'proyecto'), project, { recursive: true })
    const manifest = JSON.parse(readFileSync(join(project, 'project.json'), 'utf8'))
    const programFile = join(project, manifest.program[0])
    const problems = []

    const compile = run('check-st', project)
    if (compile.status !== 0) problems.push(`el programa inicial no compila:\n${compile.stdout}${compile.stderr}`)

    const starter = run('test-project', project)
    if (starter.status === 0) problems.push('el programa inicial ya supera el juez (los tests no exigen nada)')

    writeFileSync(programFile, readFileSync(join(mission, 'solucion.st'), 'utf8'))
    const solved = run('test-project', project)
    if (solved.status !== 0) problems.push(`la solución no supera el juez:\n${solved.stdout}${solved.stderr}`)

    if (problems.length === 0) console.log(`✓ ${id}: el inicio no pasa, la solución pasa los ${manifest.tests.length} tests`)
    else {
      failures++
      console.log(`✗ ${id}\n  - ${problems.join('\n  - ')}`)
    }
  } finally {
    rmSync(tmp, { recursive: true, force: true })
  }
}
if (ids.length === 0) console.log('no hay misiones')
process.exit(failures === 0 ? 0 : 1)
