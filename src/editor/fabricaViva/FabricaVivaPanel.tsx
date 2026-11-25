// El panel de encargos de la Fábrica viva, sobre la vista 3D (fabrica-viva/DISENO.md). Lee en directo los objetivos
// del encargo (variables del PLC) mientras la planta funciona, lleva el estado de la etapa (objetivos, juez) y ofrece
// la ampliación cuando la etapa está certificada.

import { useEffect, useState } from 'react'
import type { ReactElement } from 'react'
import { defineMessages, t } from '../../core/i18n'
import { runCommand } from '../commands'
import type { EditorController } from '../controller'
import type { EditorState, EditorStore } from '../store/store'
import {
  ampliarFabrica,
  anotarObjetivos,
  cargarEtapas,
  certificada,
  etapaDePlanta,
  EVENTO_PROGRESO,
  leerProgreso,
  objetivosCumplidos,
  tomarCamaraPendiente,
} from './fabricaViva'
import type { Etapa, Progreso } from './fabricaViva'
import './fabricaViva.css'

const M = defineMessages('fabricaViva', {
  titulo: 'Fábrica viva · Etapa {n}',
  encargo: 'Encargo',
  objetivos: 'Objetivos en directo',
  aprenderas: 'Aprenderás',
  ponEnMarcha: 'Pon la planta en marcha (Play) y cumple los objetivos.',
  cumplidos: '¡Objetivos cumplidos! Ahora el juez comprueba la planta entera, también lo de etapas anteriores.',
  pasarJuez: 'Pasar el juez',
  juezFallo: 'El juez encontró fallos: revisa la ventana de pruebas, corrige y vuelve a intentarlo.',
  certificadaTxt: 'Etapa certificada.',
  ampliar: 'Ampliar la fábrica: etapa {n} · {titulo}',
  ultima: 'Has completado todas las ampliaciones publicadas por ahora.',
  confirmar:
    'La fábrica se ampliará con «{titulo}». Tus piezas y tu programa se conservan; se añaden la zona nueva, sus señales y sus pruebas. ¿Seguir?',
  ampliando: 'Ampliando…',
  errorAmpliar: 'No se pudo ampliar la fábrica: {motivo}',
  pista: 'Ver una pista',
  ocultar: 'Ocultar',
  mostrar: 'Encargo',
  sinEtapas: 'No se pudieron cargar los encargos.',
})

interface Props {
  store: EditorStore
  state: EditorState
  controller: EditorController | null
}

export function FabricaVivaPanel({ store, state, controller }: Props): ReactElement | null {
  const [etapas, setEtapas] = useState<Etapa[] | null>(null)
  const [error, setError] = useState(false)
  const [progreso, setProgreso] = useState<Progreso>(() => leerProgreso())
  const [abierto, setAbierto] = useState(true)
  const [pistas, setPistas] = useState(0)
  const [ampliando, setAmpliando] = useState(false)
  const [valores, setValores] = useState<Record<string, number>>({})

  const n = etapaDePlanta(state.scene.parts)
  const etapa = etapas?.find((e) => e.orden === n)
  const siguiente = etapas?.find((e) => e.orden === n + 1)

  // tras ampliar, la página se recarga: la cámara va a la zona nueva que dejó apuntada ampliarFabrica
  useEffect(() => {
    if (!controller) return
    const pose = tomarCamaraPendiente()
    if (!pose) return
    const id = window.setTimeout(() => controller.view.setCameraPose(pose), 1000)
    return () => window.clearTimeout(id)
  }, [controller])

  useEffect(() => {
    let vivo = true
    cargarEtapas().then(
      (e) => vivo && setEtapas(e),
      () => vivo && setError(true),
    )
    return () => {
      vivo = false
    }
  }, [])

  useEffect(() => {
    const leer = (): void => setProgreso(leerProgreso())
    window.addEventListener(EVENTO_PROGRESO, leer)
    window.addEventListener('storage', leer)
    return () => {
      window.removeEventListener(EVENTO_PROGRESO, leer)
      window.removeEventListener('storage', leer)
    }
  }, [])

  // en directo: los objetivos se leen de las variables del PLC mientras la planta funciona
  useEffect(() => {
    if (!etapa || !state.running || !controller) return
    const id = window.setInterval(() => {
      const w = controller.plcWatch
      if (!w) return
      const v: Record<string, number> = {}
      for (const o of etapa.objetivos) {
        const x = Number(w[o.tag])
        if (Number.isFinite(x)) v[o.tag] = x
      }
      setValores(v)
      anotarObjetivos(etapa.orden, v)
    }, 400)
    return () => window.clearInterval(id)
  }, [etapa, state.running, controller])

  if (error) return <div className="fv-panel">{t(M.sinEtapas)}</div>
  if (!etapa) return null

  if (!abierto) {
    return (
      <button type="button" className="fv-panel-boton-abrir" onClick={() => setAbierto(true)}>
        {t(M.mostrar)}
      </button>
    )
  }

  const mejores = progreso.mejores[etapa.orden] ?? {}
  const cumplidos = objetivosCumplidos(etapa, progreso)
  const hecha = certificada(etapa, progreso)

  const ampliar = async (): Promise<void> => {
    if (!siguiente || !confirm(t(M.confirmar, { titulo: siguiente.titulo }))) return
    setAmpliando(true)
    try {
      const motivo = await ampliarFabrica(store, siguiente)
      if (motivo) alert(t(M.errorAmpliar, { motivo }))

    } catch (e) {
      alert(t(M.errorAmpliar, { motivo: e instanceof Error ? e.message : String(e) }))
    } finally {
      setAmpliando(false)
    }
  }

  return (
    // .fv-panel está en la lista de capas que la vista 3D no captura al pulsar (controller/pointer.ts)
    <div className="fv-panel" data-fabrica-viva>
      <div className="fv-cabecera">
        <span className="fv-etapa">{t(M.titulo, { n: etapa.orden })}</span>
        <button type="button" className="fv-ocultar" onClick={() => setAbierto(false)}>
          {t(M.ocultar)}
        </button>
      </div>
      <h3 className="fv-titulo">{etapa.titulo}</h3>
      <p className="fv-encargo">{etapa.encargo}</p>

      <div className="fv-seccion">{t(M.objetivos)}</div>
      {etapa.objetivos.map((o) => {
        const ahora = state.running ? (valores[o.tag] ?? 0) : 0
        const mejor = Math.max(mejores[o.tag] ?? 0, ahora)
        const pct = Math.min(100, Math.round((mejor / o.meta) * 100))
        return (
          <div className="fv-objetivo" key={o.tag} data-objetivo={o.tag}>
            <div className="fv-objetivo-fila">
              <span>{o.etiqueta}</span>
              <span className="fv-cifra">
                {Math.min(mejor, o.meta)} / {o.meta}
              </span>
            </div>
            <div className="fv-barra">
              <div className={`fv-barra-relleno${pct >= 100 ? ' completa' : ''}`} style={{ width: `${pct}%` }} />
            </div>
          </div>
        )
      })}

      <div className="fv-estado" data-estado={hecha ? 'certificada' : cumplidos ? 'juez' : 'objetivos'}>
        {!cumplidos && <p>{t(M.ponEnMarcha)}</p>}
        {cumplidos && !hecha && (
          <>
            <p>{progreso.juez[etapa.orden] === false ? t(M.juezFallo) : t(M.cumplidos)}</p>
            <button type="button" className="fv-boton" onClick={() => runCommand('sim.runTests')}>
              {t(M.pasarJuez)}
            </button>
          </>
        )}
        {hecha && (
          <>
            <p className="fv-ok">{t(M.certificadaTxt)}</p>
            {siguiente ? (
              <button type="button" className="fv-boton" disabled={ampliando || state.running} data-ampliar onClick={() => void ampliar()}>
                {ampliando ? t(M.ampliando) : t(M.ampliar, { n: siguiente.orden, titulo: siguiente.titulo })}
              </button>
            ) : (
              <p>{t(M.ultima)}</p>
            )}
          </>
        )}
      </div>

      {etapa.aprenderas.length > 0 && (
        <>
          <div className="fv-seccion">{t(M.aprenderas)}</div>
          <div className="fv-chips">
            {etapa.aprenderas.map((a) => (
              <span className="fv-chip" key={a}>
                {a}
              </span>
            ))}
          </div>
        </>
      )}
      {etapa.pistas.slice(0, pistas).map((p) => (
        <p className="fv-pista" key={p}>
          {p}
        </p>
      ))}
      {pistas < etapa.pistas.length && (
        <button type="button" className="fv-enlace" onClick={() => setPistas(pistas + 1)}>
          {t(M.pista)}
        </button>
      )}
    </div>
  )
}
