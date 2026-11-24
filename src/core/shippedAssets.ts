// The bytes the app ships for a first-party part's models and textures, named by their SHA-256 (docs/part-sources.md,
// "Assets"). scripts/bake-part-assets.mjs optimizes each one exactly as the build does and commits it as
// public/part-assets/<sha256><ext>, append-only; core/shippedPartAssets.ts is its table.
//
// A part's asset names its bytes by hash, so a project's copy of a built-in pins them: a later app that re-exports
// the AGV ships a new file under a new hash, the previous one stays served, and the copy says "update available" instead
// of quietly drawing the new model (the fingerprint covers the hash, core/parts/partOrigin.ts).

import type { PartAsset, PartPackage } from './parts/partPackage'
import { SHIPPED_PART_ASSETS } from './shippedPartAssets'

/** where the app serves a baked part asset: content-addressed, so cacheable for good */
export const PART_ASSETS_PATH = '/part-assets/'

const byHash = new Map(Object.values(SHIPPED_PART_ASSETS).map((e) => [e.sha256, `${PART_ASSETS_PATH}${e.sha256}${e.ext}`]))

/**
 * `asset` pointed at the bytes the app ships for it: a `url` naming a first-party source file (`/models/AGV.glb`)
 * becomes `/part-assets/<sha256><ext>` with its `sha256`. Anything else - an asset with a hash already, embedded data,
 * a URL the table does not know - comes back as it is.
 */
export function pinShippedAsset(asset: PartAsset): PartAsset {
  if (asset.url === undefined || asset.sha256 !== undefined) return asset
  const e = SHIPPED_PART_ASSETS[asset.url]
  return e ? { ...asset, url: `${PART_ASSETS_PATH}${e.sha256}${e.ext}`, sha256: e.sha256 } : asset
}

/**
 * Where to fetch the bytes `url` names. A copy of a built-in made before part assets were baked names its model by
 * source path (`/models/EOATSuction.glb`); that path is fetched from its baked file instead, the bytes the app last
 * shipped for it. So a source file can leave public/ once no current part names it (the table keeps its entry for
 * good), and an old project still draws. The stored copy keeps its path: rewriting it would change its fingerprint and
 * report the part as edited. Any other url is fetched as it is.
 */
export function shippedFetchUrl(url: string): string {
  const e = SHIPPED_PART_ASSETS[url] ?? SHIPPED_PART_ASSETS[underBase(url)]
  return e ? `${PART_ASSETS_PATH}${e.sha256}${e.ext}` : underBase(url)
}

// Fábrica PLC: published under a subdirectory (GitHub Pages, /FACTORY_io/), scripts/rebase-dist.mjs rewrites the
// root-relative URLs in the code, PART_ASSETS_PATH included, but not the ones stored in a project's part packages
// (`/part-assets/<sha>.webp`). Those get the same prefix here, where every stored asset URL is fetched from.
// The prefix is Vite's own BASE_URL (vite.config.ts `base`), set at build time: a value derived from a string the
// minifier can see is folded before rebase-dist runs, and would always read as the root.
const BASE_PATH = (import.meta as { env?: { BASE_URL?: string } }).env?.BASE_URL ?? '/'

/** `url` with the published base in front when it is root-relative and lacks it; unchanged at the root. */
function underBase(url: string): string {
  return BASE_PATH !== '/' && url.startsWith('/') && !url.startsWith('//') && !url.startsWith(BASE_PATH) ? BASE_PATH + url.slice(1) : url
}

/** The URL this app serves the bytes of `sha256` at, when they are a part asset it ships. */
export function shippedAssetUrl(sha256: string): string | undefined {
  return byHash.get(sha256)
}

/**
 * `pkg` with every asset whose bytes this app ships held as a reference (`url`) instead of the bytes: what a project
 * folder's `assets/<sha256>.*` file reads back as, kept light in memory and in the browser autosave. The same asset
 * either way (its fingerprint is its hash), so nothing about the part changes. Returns `pkg` itself when nothing does.
 */
export function referenceShippedAssets(pkg: PartPackage): PartPackage {
  if (!pkg.assets?.some((a) => a.data !== undefined && a.sha256 !== undefined && byHash.has(a.sha256))) return pkg
  return {
    ...pkg,
    assets: pkg.assets.map((a) => {
      const url = a.data !== undefined && a.sha256 !== undefined ? byHash.get(a.sha256) : undefined
      if (url === undefined) return a
      const { data: _bytes, ...rest } = a
      return { ...rest, url }
    }),
  }
}
