// Reescribe un build (dist/) para servirlo bajo un subdirectorio, p. ej. GitHub Pages de un repositorio
// de proyecto (https://<usuario>.github.io/<repo>/).
//
//   node scripts/rebase-dist.mjs <dist> <base>      p. ej.  node scripts/rebase-dist.mjs dist /FACTORY_io
//
// La app escribe sus URLs desde la raíz ('/models/...', '/app/', '/sw.js'...). En vez de tocar cada sitio
// del código, este paso antepone <base> a toda URL de raíz que apunte a algo que existe en la raíz de dist/.
// Solo cambia texto entre comillas, comillas invertidas, paréntesis o url(...), y solo para nombres de primer
// nivel reales de dist/, así que una expresión regular escapada (/\/models\//) o una ruta ajena no se tocan.
// Una <base> vacía o "/" no cambia nada.

import { readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs'
import { extname, join } from 'node:path'

const [dist, rawBase] = process.argv.slice(2)
if (!dist || rawBase === undefined) {
  console.error('uso: node scripts/rebase-dist.mjs <dist> <base>')
  process.exit(2)
}
const base = rawBase.replace(/\/+$/, '')
if (base === '') {
  console.log('rebase-dist: base vacía, nada que hacer')
  process.exit(0)
}
if (!/^\/[A-Za-z0-9._-]+(\/[A-Za-z0-9._-]+)*$/.test(base)) {
  console.error(`rebase-dist: base no válida: ${rawBase}`)
  process.exit(2)
}

const TEXT = new Set(['.html', '.js', '.mjs', '.css', '.json', '.webmanifest'])
const escape = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
const roots = readdirSync(dist).filter((n) => !n.startsWith('.') && !n.startsWith('_'))
// delante: una comilla, una comilla invertida, un paréntesis o "url("; detrás: fin de nombre
const rootUrl = new RegExp(`(["'\`(])\\/(${roots.map(escape).join('|')})(?=[\\/"'\`?#)\\s]|$)`, 'g')
// el ámbito del service worker y del manifiesto es la raíz misma, que no tiene nombre que buscar
const swScope = /scope:`\/`/g
const manifestScope = /"scope":"\/"/g

function* files(dir) {
  for (const name of readdirSync(dir)) {
    const path = join(dir, name)
    if (statSync(path).isDirectory()) yield* files(path)
    else if (TEXT.has(extname(name))) yield path
  }
}

let changedFiles = 0
let changedUrls = 0
for (const path of files(dist)) {
  const before = readFileSync(path, 'utf8')
  let count = 0
  const after = before
    .replace(rootUrl, (_m, lead, name) => {
      count++
      return `${lead}${base}/${name}`
    })
    .replace(swScope, () => {
      count++
      return `scope:\`${base}/\``
    })
    .replace(manifestScope, () => {
      count++
      return `"scope":"${base}/"`
    })
  if (count > 0) {
    writeFileSync(path, after)
    changedFiles++
    changedUrls += count
  }
}
console.log(`rebase-dist: ${changedUrls} URL(s) en ${changedFiles} fichero(s) con base ${base}/`)
