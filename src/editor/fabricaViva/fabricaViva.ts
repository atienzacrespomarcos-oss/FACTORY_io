// Fábrica viva (fabrica-viva/DISENO.md): abrir la planta de quien juega, saber en qué etapa está, llevar su progreso
// y ampliarla. La unión de la ampliación es pura y está en ampliar.ts; aquí va lo que toca la red, el navegador y el
// documento abierto.
//
// El progreso vive en localStorage (PROGRESO_KEY), en este navegador, como el de la Academia:
//   - `mejores[etapa][tag]`: el mayor valor que ha alcanzado cada objetivo en directo (Play);
//   - `juez[etapa]`: las pruebas oficiales de esa etapa han pasado todas.
// Una etapa está certificada cuando se cumplen las dos cosas.

import { oipBytesToProject } from '../../core/project/projectArchive'
import type { ProjectJSON } from '../../core/project/project'
import { viewOfParts } from '../controller/camera'
import { bakePart } from '../parts/bakePart'
import { currentDocumentId, fileOutgoingDocument, listDocuments, openDocument } from '../project/documentStore'
import { adoptImportedProject, importProjectData } from '../project/projectFile'
import type { ProjectTestRun } from '../project/projectTestsRun'
import type { EditorStore } from '../store/store'
import { ampliarProyecto } from './ampliar'
import type { FragmentoPrograma } from './ampliar'

export const NOMBRE_PROYECTO = 'Fábrica viva'
export const PROGRESO_KEY = 'fabrica-plc/fabrica-viva'
/** se lanza en `window` cuando cambia el progreso, para que el panel se actualice */
export const EVENTO_PROGRESO = 'fabrica-viva-progreso'

export interface Objetivo {
  etiqueta: string
  tag: string
  meta: number
}

export interface Etapa {
  orden: number
  titulo: string
  encargo: string
  objetivos: Objetivo[]
  aprenderas: string[]
  pistas: string[]
  pruebas: number
  retira?: string[]
  ajustes?: { id: string; params: Record<string, unknown> }[]
  fragmento: FragmentoPrograma
}

export interface Progreso {
  mejores: Record<string, Record<string, number>>
  juez: Record<string, boolean>
}

let indice: Promise<Etapa[]> | null = null

/** Las etapas publicadas, en orden. */
export function cargarEtapas(): Promise<Etapa[]> {
  indice ??= fetch('/fabrica-viva/index.json', { cache: 'no-cache' })
    .then((r) => {
      if (!r.ok) throw new Error(`HTTP ${r.status}`)
      return r.json() as Promise<{ etapas?: Etapa[] }>
    })
    .then((d) => (Array.isArray(d.etapas) ? [...d.etapas].sort((a, b) => a.orden - b.orden) : []))
  indice.catch(() => {
    indice = null
  })
  return indice
}

async function proyectoDeEtapa(orden: number): Promise<ProjectJSON> {
  const res = await fetch(`/fabrica-viva/etapa-${orden}.oip`, { cache: 'no-cache' })
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  const r = await oipBytesToProject(new Uint8Array(await res.arrayBuffer()), { bakePart })
  if (!r.ok) throw new Error(r.errors.join('; '))
  return r.project
}

/** La etapa en la que está una planta: la mayor N con alguna pieza `fvN-…` (las de cada ampliación llevan su número). */
export function etapaDePlanta(parts: readonly { id: string }[]): number {
  let n = 0
  for (const p of parts) {
    const m = /^fv(\d+)-/.exec(p.id)
    if (m) n = Math.max(n, Number(m[1]))
  }
  return n
}

export function leerProgreso(): Progreso {
  try {
    const raw = localStorage.getItem(PROGRESO_KEY)
    const p = raw ? (JSON.parse(raw) as Partial<Progreso>) : {}
    return { mejores: p.mejores ?? {}, juez: p.juez ?? {} }
  } catch {
    return { mejores: {}, juez: {} }
  }
}

function guardarProgreso(p: Progreso): void {
  try {
    localStorage.setItem(PROGRESO_KEY, JSON.stringify(p))
  } catch {
    // sin almacenamiento: el progreso no se recuerda, pero el juego sigue
  }
  window.dispatchEvent(new Event(EVENTO_PROGRESO))
}

/** Anota los valores en directo de los objetivos de una etapa, quedándose con el mejor de cada uno. */
export function anotarObjetivos(etapa: number, valores: Record<string, number>): void {
  const p = leerProgreso()
  const antes = p.mejores[etapa] ?? {}
  let cambia = false
  const ahora = { ...antes }
  for (const [tag, v] of Object.entries(valores)) {
    if (Number.isFinite(v) && v > (antes[tag] ?? 0)) {
      ahora[tag] = v
      cambia = true
    }
  }
  if (!cambia) return
  p.mejores[etapa] = ahora
  guardarProgreso(p)
}

export function objetivosCumplidos(etapa: Etapa, p: Progreso): boolean {
  const m = p.mejores[etapa.orden] ?? {}
  return etapa.objetivos.every((o) => (m[o.tag] ?? 0) >= o.meta)
}

export function certificada(etapa: Etapa, p: Progreso): boolean {
  return objetivosCumplidos(etapa, p) && p.juez[etapa.orden] === true
}

/**
 * Tras ejecutar las pruebas en la Fábrica viva: si son las oficiales de su etapa (comparadas ya validadas con las del
 * .oip publicado, como en la Academia) y pasan todas, el juez da por buena la etapa. Silencioso ante errores.
 */
export async function registrarJuezFabrica(project: ProjectJSON, runs: readonly ProjectTestRun[]): Promise<void> {
  if (project.name !== NOMBRE_PROYECTO) return
  try {
    const n = etapaDePlanta(project.scene.parts)
    if (n === 0) return
    const oficial = await proyectoDeEtapa(n)
    const oficiales = JSON.stringify(oficial.tests ?? []) === JSON.stringify(project.tests ?? [])
    const ok = oficiales && runs.length === (oficial.tests ?? []).length && runs.every((r) => r.ok)
    const p = leerProgreso()
    p.juez[n] = ok
    guardarProgreso(p)
  } catch {
    // sin red: no se registra
  }
}

/**
 * Abre la Fábrica viva de quien juega: su documento si ya existe en este navegador, o la etapa 1 si es la primera vez.
 * Devuelve un mensaje de error, o null (abrir o importar recargan la página).
 */
export async function abrirFabricaViva(store: EditorStore): Promise<string | null> {
  if (store.getState().projectName === NOMBRE_PROYECTO && !store.getState().demoSession) return null
  const doc = (await listDocuments()).find((d) => d.name === NOMBRE_PROYECTO)
  if (doc) return openDocument(doc.id, store.outgoingProject())
  const res = await fetch('/fabrica-viva/etapa-1.oip', { cache: 'no-cache' })
  if (!res.ok) return `HTTP ${res.status}`
  return importProjectData(store, new Uint8Array(await res.arrayBuffer()), {
    beforeAdopt: () => fileOutgoingDocument(store.outgoingProject()),
  })
}

/**
 * Amplía la planta abierta con la etapa siguiente: une el proyecto actual con el de esa etapa (ampliar.ts) y lo
 * guarda sobre el mismo documento, que se recarga. Devuelve un mensaje de error, o null.
 */
export async function ampliarFabrica(store: EditorStore, siguiente: Etapa): Promise<string | null> {
  const actual = store.snapshotProject()
  if (etapaDePlanta(actual.scene.parts) !== siguiente.orden - 1) return 'Esta planta no está en la etapa anterior a la ampliación.'
  const etapa = await proyectoDeEtapa(siguiente.orden)
  const ampliada = ampliarProyecto(actual, etapa, { retira: siguiente.retira, ajustes: siguiente.ajustes, fragmento: siguiente.fragmento })
  const doc = currentDocumentId()
  // la planta ampliada se abre mirando a la zona nueva (sin decoración ni piezas ocultas): FabricaVivaPanel la aplica
  const propias = new Set(actual.scene.parts.map((p) => p.id))
  apuntarCamara(viewOfParts(etapa.scene.parts.filter((p) => !propias.has(p.id))))
  const r = await adoptImportedProject({ project: ampliada }, doc ? { docId: doc } : undefined)
  return r.ok ? null : r.message
}

const CAMARA_KEY = 'fabrica-plc/fabrica-viva-camara'
type Pose = NonNullable<ReturnType<typeof viewOfParts>>

function apuntarCamara(pose: Pose | null): void {
  try {
    if (pose) sessionStorage.setItem(CAMARA_KEY, JSON.stringify(pose))
  } catch {
    // sin almacenamiento de sesión la planta se abre con su cámara de siempre
  }
}

/** La vista de la zona nueva que dejó apuntada la última ampliación, una sola vez (null si no hay). */
export function tomarCamaraPendiente(): Pose | null {
  try {
    const raw = sessionStorage.getItem(CAMARA_KEY)
    sessionStorage.removeItem(CAMARA_KEY)
    return raw ? (JSON.parse(raw) as Pose) : null
  } catch {
    return null
  }
}
