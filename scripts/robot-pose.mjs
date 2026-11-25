// La fila de articulaciones que pone el punto de agarre de un robot en un punto de la nave, por cinemática inversa:
// la misma herramienta solve_robot_pose de la app (src/editor/agent/robotAgentTools.ts), sin la app abierta. Sirve para
// enseñar las posiciones de un robot por coordenadas (fabrica-viva, etapa de paletizado).
//
//   node scripts/robot-pose.mjs <carpeta-proyecto> <id-robot> <x,y,z> [--yaw <grados>] [--from <fila>] [--free] [--any]
//
//   --yaw   hacia dónde mira la herramienta (su eje X), en grados antihorarios desde +X vista desde arriba
//   --from  la fila de waypoints de la que parte la búsqueda (por defecto, la pose de reposo)
//   --free  no obliga a la herramienta a mirar hacia abajo
//   --any   permite otra configuración del brazo si la de partida no llega
//
// Imprime la respuesta de la herramienta en JSON (row, reached, missMm, …). No cambia nada.

import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { createServer } from 'vite'
import { openProjectForEdit } from './lib/projectLibrary.mjs'

const repo = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const argv = process.argv.slice(2)
const flag = (n) => {
  const i = argv.indexOf(n)
  return i >= 0 ? argv[i + 1] : undefined
}
const [folder, id, xyz] = argv.filter((a, i) => !a.startsWith('--') && !['--yaw', '--from'].includes(argv[i - 1]))
if (!folder || !id || !xyz) {
  console.error('uso: node scripts/robot-pose.mjs <carpeta-proyecto> <id-robot> <x,y,z> [--yaw g] [--from fila] [--free] [--any]')
  process.exit(2)
}
const target = xyz.split(',').map(Number)
const args = { id, target }
if (flag('--yaw') !== undefined) args.yawDeg = Number(flag('--yaw'))
if (flag('--from') !== undefined) args.from = Number(flag('--from'))
if (argv.includes('--free')) args.down = false
if (argv.includes('--any')) args.anyConfiguration = true

const vite = await createServer({ configFile: false, root: repo, logLevel: 'error', server: { middlewareMode: true, hmr: false, ws: false }, appType: 'custom', optimizeDeps: { noDiscovery: true } })
let code = 0
try {
  const lib = await openProjectForEdit(vite, folder, { log: () => {} })
  const { solveRobotPose } = await vite.ssrLoadModule('/src/editor/agent/robotAgentTools.ts')
  const ctx = { store: { getState: () => ({ scene: lib.scene }) } }
  console.log(JSON.stringify(solveRobotPose.run(ctx, args)))
} catch (e) {
  console.error(`✗ ${e.message}`)
  code = 1
} finally {
  await vite.close()
}
process.exit(code)
