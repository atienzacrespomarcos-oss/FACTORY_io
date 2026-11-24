// Fábrica viva: unir la planta de quien juega con la ampliación siguiente (fabrica-viva/DISENO.md).
//
// Puro (sin DOM ni red): lo usan la app al pulsar «Ampliar la fábrica» y scripts/check-fabrica-viva.mjs, que
// comprueba cada etapa con esta misma función antes de publicarla.
//
// El programa no se puede unir pegando texto al final: el motor exige que todas las declaraciones (bloques de
// función, bloques VAR) vayan antes de la primera instrucción del código de nivel superior. Así que el fragmento de
// una ampliación trae tres trozos, y cada uno va a su sitio:
//   - `bloques`: FUNCTION_BLOCK / FUNCTION / TYPE nuevos, al principio del programa;
//   - `declaraciones`: los bloques VAR de las señales nuevas, justo después de las últimas declaraciones de nivel
//     superior (antes de la primera instrucción);
//   - `codigo`: las llamadas a la zona nueva, al final.

import type { ProjectJSON } from '../../core/project/project'

/** Lo que una ampliación añade al programa. */
export interface FragmentoPrograma {
  bloques?: string
  declaraciones?: string
  codigo?: string
}

/** Lo que una ampliación cambia en la planta, además de añadir lo que trae su proyecto. */
export interface CambiosAmpliacion {
  /** piezas de etapas anteriores que la ampliación sustituye (p. ej. un sumidero provisional al final de la línea) */
  retira?: readonly string[]
  /** parámetros que la ampliación fija en piezas que ya estaban (p. ej. qué códigos trae el camión) */
  ajustes?: readonly { id: string; params: Record<string, unknown> }[]
  fragmento: FragmentoPrograma
}

const POU_ABRE = /^(FUNCTION_BLOCK|FUNCTION|PROGRAM|TYPE|CONFIGURATION|INTERFACE|CLASS)$/i
const VAR_ABRE = /^VAR(_INPUT|_OUTPUT|_IN_OUT|_GLOBAL|_EXTERNAL|_TEMP)?$/i

interface Palabra {
  texto: string
  inicio: number
  fin: number
}

/** Las palabras del texto ST que no están dentro de comentarios ni de cadenas, con su posición. */
function palabras(st: string): Palabra[] {
  const out: Palabra[] = []
  let i = 0
  while (i < st.length) {
    const c = st[i]!
    if (c === '(' && st[i + 1] === '*') {
      const fin = st.indexOf('*)', i + 2)
      i = fin < 0 ? st.length : fin + 2
    } else if (c === '/' && st[i + 1] === '/') {
      const fin = st.indexOf('\n', i)
      i = fin < 0 ? st.length : fin + 1
    } else if (c === "'" || c === '"') {
      const fin = st.indexOf(c, i + 1)
      out.push({ texto: c, inicio: i, fin: fin < 0 ? st.length : fin + 1 })
      i = fin < 0 ? st.length : fin + 1
    } else if (/[A-Za-z_]/.test(c)) {
      let j = i + 1
      while (j < st.length && /[A-Za-z0-9_]/.test(st[j]!)) j++
      out.push({ texto: st.slice(i, j), inicio: i, fin: j })
      i = j
    } else if (/\s/.test(c)) {
      i++
    } else {
      out.push({ texto: c, inicio: i, fin: i + 1 })
      i++
    }
  }
  return out
}

/**
 * Dónde termina la zona de declaraciones de nivel superior: justo después del último END_VAR que no está dentro de
 * un POU y que va antes de la primera instrucción. Si no hay ninguna declaración, el inicio de la primera instrucción
 * (o el final del texto si no hay código).
 */
export function finDeclaraciones(st: string): number {
  const ps = palabras(st)
  let dentroPou: string | null = null
  let finUltimoVar = -1
  for (let k = 0; k < ps.length; k++) {
    const p = ps[k]!
    const t = p.texto.toUpperCase()
    if (dentroPou) {
      if (t === `END_${dentroPou}`) dentroPou = null
      continue
    }
    if (POU_ABRE.test(t)) {
      dentroPou = t
      continue
    }
    if (VAR_ABRE.test(t)) {
      let j = k + 1
      while (j < ps.length && ps[j]!.texto.toUpperCase() !== 'END_VAR') j++
      if (j >= ps.length) return st.length
      finUltimoVar = ps[j]!.fin
      k = j
      continue
    }
    // la primera palabra de nivel superior que no es una declaración: empieza el código
    return finUltimoVar >= 0 ? finUltimoVar : p.inicio
  }
  return finUltimoVar >= 0 ? finUltimoVar : st.length
}

/** El programa de quien juega con el fragmento de una ampliación, cada trozo en su sitio. */
export function unirPrograma(actual: string, f: FragmentoPrograma): string {
  let st = actual.replace(/\s+$/, '')
  if (f.declaraciones?.trim()) {
    const at = finDeclaraciones(st)
    st = `${st.slice(0, at)}\n\n${f.declaraciones.trim()}\n${st.slice(at)}`
  }
  if (f.bloques?.trim()) st = `${f.bloques.trim()}\n\n${st}`
  if (f.codigo?.trim()) st = `${st}\n\n${f.codigo.trim()}`
  return `${st}\n`
}

/**
 * La planta de quien juega (`actual`) ampliada con la etapa siguiente (`etapa`: el proyecto acumulado de esa etapa).
 * Se conserva todo lo suyo (piezas, posiciones, parámetros, código); se retiran solo las piezas provisionales que la
 * etapa sustituye; se añaden las piezas y paquetes nuevos; las pruebas pasan a ser las oficiales acumuladas.
 */
export function ampliarProyecto(actual: ProjectJSON, etapa: ProjectJSON, cambios: CambiosAmpliacion): ProjectJSON {
  const retira = new Set(cambios.retira ?? [])
  const ajustes = new Map((cambios.ajustes ?? []).map((a) => [a.id, a.params]))
  const propias = actual.scene.parts
    .filter((p) => !retira.has(p.id))
    .map((p) => (ajustes.has(p.id) ? ({ ...p, params: { ...p.params, ...ajustes.get(p.id) } } as typeof p) : p))
  const ids = new Set(propias.map((p) => p.id))
  const nuevas = etapa.scene.parts.filter((p) => !ids.has(p.id) && !retira.has(p.id))
  const paquetes = actual.packages ?? []
  const idsPaquete = new Set(paquetes.map((p) => p.id))
  return {
    ...actual,
    scene: { ...actual.scene, parts: [...propias, ...nuevas] },
    packages: [...paquetes, ...(etapa.packages ?? []).filter((p) => !idsPaquete.has(p.id))],
    tests: etapa.tests ?? [],
    stProgram: unirPrograma(actual.stProgram ?? '', cambios.fragmento),
  }
}
