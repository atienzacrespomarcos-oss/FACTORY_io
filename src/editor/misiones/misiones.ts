// Misiones de Fábrica PLC: abrir una misión desde la URL (/app/?mision=<id>) y guardar el resultado de sus tests.
//
// Una misión es un proyecto publicado como /misiones/<id>.oip, con sus tests de juez dentro. La lista está en
// /misiones/index.json (scripts/build-misiones.mjs). La página /misiones/ lee el progreso que se guarda aquí, en
// localStorage, bajo PROGRESS_KEY: mismo origen, así que no hace falta servidor.
//
// Una misión cuenta como superada solo si los tests que pasaron son los oficiales: al terminar una ejecución se
// descarga la misión, se valida con el mismo códec que la app usa al importar y se comparan los tests ya
// normalizados. Así editar o borrar un test en la app no supera la misión.

import { defineMessages, t } from '../../core/i18n'
import { oipBytesToProject } from '../../core/project/projectArchive'
import type { ProjectJSON } from '../../core/project/project'
import { bakePart } from '../parts/bakePart'
import { fileOutgoingDocument, listDocuments, openDocument } from '../project/documentStore'
import { importProjectData } from '../project/projectFile'
import type { ProjectTestRun } from '../project/projectTestsRun'
import type { EditorStore } from '../store/store'

const M = defineMessages('misiones', {
  unknown: 'There is no mission called “{id}”.',
  loadFailed: 'The mission could not be loaded: {reason}',
})

/** Una fila de /misiones/index.json. */
export interface MisionIndice {
  id: string
  orden: number
  titulo: string
  /** el nombre del proyecto de la misión (project.json "name"): así se reconoce en la app */
  proyecto: string
  nivel: string
  objetivo: string
  aprenderas: string[]
  pistas: string[]
  tests: number
}

/** Lo que la página de misiones lee de localStorage, por id de misión. */
export interface ProgresoMision {
  superada: boolean
  /** el mayor número de tests oficiales superados en una ejecución */
  mejor: number
  total: number
  ultima: { fecha: string; pasados: number; total: number; oficiales: boolean }
}

export const PROGRESS_KEY = 'fabrica-plc/misiones/progreso'
const ID = /^[a-z0-9-]{1,64}$/

async function cargarIndice(): Promise<MisionIndice[]> {
  const res = await fetch('/misiones/index.json', { cache: 'no-cache' })
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  const data = (await res.json()) as { misiones?: MisionIndice[] }
  return Array.isArray(data.misiones) ? data.misiones : []
}

async function descargarMision(id: string): Promise<Uint8Array> {
  const res = await fetch(`/misiones/${id}.oip`, { cache: 'no-cache' })
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return new Uint8Array(await res.arrayBuffer())
}

function leerProgreso(): Record<string, ProgresoMision> {
  try {
    const raw = localStorage.getItem(PROGRESS_KEY)
    const parsed: unknown = raw ? JSON.parse(raw) : {}
    return parsed && typeof parsed === 'object' ? (parsed as Record<string, ProgresoMision>) : {}
  } catch {
    return {}
  }
}

/**
 * Si la URL pide una misión (?mision=<id>), la abre: el proyecto de esa misión que ya está en este navegador, o una
 * copia nueva importada de /misiones/<id>.oip (también con ?nueva). Quita los parámetros antes de nada, porque abrir
 * o importar recarga la página y no debe volver a entrar aquí.
 */
export async function abrirMisionPedida(store: EditorStore): Promise<void> {
  const url = new URL(location.href)
  const id = url.searchParams.get('mision')
  if (id === null) return
  const nueva = url.searchParams.has('nueva')
  url.searchParams.delete('mision')
  url.searchParams.delete('nueva')
  history.replaceState(history.state, '', url.pathname + url.search + url.hash)

  try {
    const entrada = ID.test(id) ? (await cargarIndice()).find((m) => m.id === id) : undefined
    if (!entrada) {
      alert(t(M.unknown, { id }))
      return
    }
    if (!nueva) {
      if (store.getState().projectName === entrada.proyecto && !store.getState().demoSession) return
      const doc = (await listDocuments()).find((d) => d.name === entrada.proyecto)
      if (doc) {
        const error = await openDocument(doc.id, store.outgoingProject())
        if (error) alert(t(M.loadFailed, { reason: error }))
        return
      }
    }
    const bytes = await descargarMision(id)
    const error = await importProjectData(store, bytes, {
      beforeAdopt: () => fileOutgoingDocument(store.outgoingProject()),
    })
    if (error) alert(t(M.loadFailed, { reason: error }))
  } catch (e) {
    alert(t(M.loadFailed, { reason: e instanceof Error ? e.message : String(e) }))
  }
}

/**
 * Guarda el resultado de una ejecución de los tests si el proyecto es una misión. Silencioso: un fallo de red o de
 * almacenamiento no debe molestar a quien solo estaba probando su programa.
 */
export async function registrarResultadoMision(project: ProjectJSON, runs: readonly ProjectTestRun[]): Promise<void> {
  try {
    const entrada = (await cargarIndice()).find((m) => m.proyecto === project.name)
    if (!entrada) return
    const oficial = await oipBytesToProject(await descargarMision(entrada.id), { bakePart })
    const oficiales = oficial.ok && JSON.stringify(oficial.project.tests ?? []) === JSON.stringify(project.tests ?? [])
    const total = entrada.tests
    const pasados = oficiales ? runs.filter((r) => r.ok).length : 0
    const progreso = leerProgreso()
    const antes = progreso[entrada.id]
    progreso[entrada.id] = {
      superada: (antes?.superada ?? false) || (oficiales && runs.length === total && pasados === total),
      mejor: Math.max(antes?.mejor ?? 0, pasados),
      total,
      ultima: { fecha: new Date().toISOString(), pasados: runs.filter((r) => r.ok).length, total: runs.length, oficiales },
    }
    localStorage.setItem(PROGRESS_KEY, JSON.stringify(progreso))
  } catch {
    // sin red o sin almacenamiento: no hay progreso que guardar
  }
}
