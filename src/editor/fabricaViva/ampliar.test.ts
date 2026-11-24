import { describe, expect, it } from 'vitest'
import { ampliarProyecto, finDeclaraciones, unirPrograma } from './ampliar'
import type { ProjectJSON } from '../../core/project/project'

const BASE = `(* Etapa 1: comentario que menciona VAR_INPUT y END_VAR sin serlo *)
VAR_INPUT
  Marcha : BOOL;
END_VAR
VAR_OUTPUT
  Cinta : BOOL;
END_VAR
VAR
  EnMarcha : BOOL; (* END_VAR en un comentario *)
END_VAR

(* ---- Tu programa ---- *)
EnMarcha := Marcha OR EnMarcha;
Cinta := EnMarcha;
`

describe('finDeclaraciones', () => {
  it('se para tras el último END_VAR de nivel superior, ignorando comentarios', () => {
    const at = finDeclaraciones(BASE)
    expect(BASE.slice(0, at).trimEnd().endsWith('END_VAR')).toBe(true)
    expect(BASE.slice(at)).toContain('EnMarcha := Marcha')
    expect(BASE.slice(at)).not.toContain('VAR\n')
  })

  it('salta los POU (sus END_VAR no cuentan como nivel superior)', () => {
    const st = `FUNCTION_BLOCK FB
VAR_INPUT a : BOOL; END_VAR
VAR_OUTPUT b : BOOL; END_VAR
b := a;
END_FUNCTION_BLOCK
${BASE}`
    const at = finDeclaraciones(st)
    expect(st.slice(at)).toMatch(/^\s*\(\* ---- Tu programa/)
  })

  it('sin declaraciones: el inicio del código', () => {
    expect(finDeclaraciones('X := 1;')).toBe(0)
  })

  it('sin código: el final de las declaraciones', () => {
    const st = 'VAR a : BOOL; END_VAR\n'
    expect(st.slice(0, finDeclaraciones(st))).toBe('VAR a : BOOL; END_VAR')
  })
})

describe('unirPrograma', () => {
  it('pone cada trozo en su sitio y conserva el código de quien juega', () => {
    const out = unirPrograma(BASE, {
      bloques: 'FUNCTION_BLOCK FB_Cinta\nVAR_INPUT h : BOOL; END_VAR\nEND_FUNCTION_BLOCK',
      declaraciones: 'VAR_INPUT\n  Fotocelula : BOOL;\nEND_VAR',
      codigo: 'Control(h := Cinta);',
    })
    expect(out.startsWith('FUNCTION_BLOCK FB_Cinta')).toBe(true)
    const iDecl = out.indexOf('Fotocelula : BOOL')
    const iCodigo = out.indexOf('EnMarcha := Marcha')
    expect(iDecl).toBeGreaterThan(out.indexOf('EnMarcha : BOOL'))
    expect(iDecl).toBeLessThan(iCodigo)
    expect(out.trimEnd().endsWith('Control(h := Cinta);')).toBe(true)
    expect(out).toContain(BASE.slice(BASE.indexOf('(* ---- Tu programa')).trimEnd())
  })
})

describe('ampliarProyecto', () => {
  const parte = (id: string, params: Record<string, unknown> = {}) => ({ id, type: 'part', packageId: 'oip.x', position: [0, 0, 0], rotationY: 0, params })
  const proyecto = (parts: unknown[], extra: Partial<ProjectJSON> = {}) =>
    ({ version: 7, name: 'Fábrica viva', scene: { version: 1, parts }, stProgram: BASE, ...extra }) as unknown as ProjectJSON

  it('conserva lo de quien juega, retira lo provisional, ajusta y añade lo nuevo', () => {
    const mia = proyecto([parte('fv1-cinta', { speed: 1.5 }), parte('fv1-sumidero'), parte('fv1-alimentador', { a: 1 }), parte('mi-pieza')], {
      packages: [{ id: 'oip.x' }] as never,
    })
    const etapa = proyecto([parte('fv1-cinta', { speed: 1 }), parte('fv1-sumidero'), parte('fv1-alimentador'), parte('fv2-lector')], {
      packages: [{ id: 'oip.x' }, { id: 'oip.scanner' }] as never,
      tests: [{ name: 'E1' }, { name: 'E2' }] as never,
    })
    const out = ampliarProyecto(mia, etapa, {
      retira: ['fv1-sumidero'],
      ajustes: [{ id: 'fv1-alimentador', params: { b: 2 } }],
      fragmento: { codigo: 'X := 1;' },
    })
    const ids = out.scene.parts.map((p) => p.id)
    expect(ids).toEqual(['fv1-cinta', 'fv1-alimentador', 'mi-pieza', 'fv2-lector'])
    expect(out.scene.parts[0]!.params).toEqual({ speed: 1.5 })
    expect(out.scene.parts[1]!.params).toEqual({ a: 1, b: 2 })
    expect(out.packages?.map((p) => p.id)).toEqual(['oip.x', 'oip.scanner'])
    expect(out.tests?.length).toBe(2)
    expect(out.stProgram?.trimEnd().endsWith('X := 1;')).toBe(true)
    expect(out.name).toBe('Fábrica viva')
  })
})
