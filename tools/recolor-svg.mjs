#!/usr/bin/env node
/* Recolor the SVG/XML artwork to the exact ayu palette colours.
 *
 *   node tools/recolor-svg.mjs [--dry]
 *
 * The mapping lives in tools/asset-map.json ("svg" section) and points at the
 * official ayu colours (https://github.com/ayu-theme/ayu-colors). Source
 * artwork is recolored so that a fresh render (see render-assets.sh) produces
 * the same exact colours as the checked-in PNGs.
 *
 * Files that are shared between the light and the dark flavour keep the light
 * accent in the source; tools/recolor-assets.mjs swaps it for the dark accent
 * when it renders the dark assets.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const MAP = JSON.parse(fs.readFileSync(path.join(ROOT, "tools/asset-map.json"), "utf8"));

const dry = process.argv.includes("--dry");
let changed = 0;

function recolorFile(file, mapping) {
  const text = fs.readFileSync(file, "utf8");
  const seen = new Map();
  const out = text.replace(/#[0-9a-fA-F]{6}\b/g, (m) => {
    const key = m.toLowerCase();
    if (!seen.has(key)) seen.set(key, mapping[key] || m);
    const target = seen.get(key);
    return target === m ? m : target;
  });
  const n = [...seen.entries()].filter(([k, v]) => v !== k).length;
  if (out !== text) {
    if (!dry) fs.writeFileSync(file, out);
    changed += n;
    console.log(`${path.relative(ROOT, file)}: ${n} colours${dry ? " (dry)" : ""}`);
  }
}

function walk(dir, mapping) {
  const abs = path.join(ROOT, dir);
  if (!fs.existsSync(abs)) return;
  for (const entry of fs.readdirSync(abs, { withFileTypes: true })) {
    const p = path.join(abs, entry.name);
    if (entry.isDirectory()) walk(path.join(dir, entry.name), mapping);
    else if (/\.(svg|xml)$/.test(entry.name)) recolorFile(p, mapping);
  }
}

for (const [rel, mapping] of Object.entries(MAP.svg || {})) {
  if (rel.endsWith("/")) {
    walk(rel, mapping);
    continue;
  }
  const file = path.join(ROOT, rel);
  if (!fs.existsSync(file)) {
    console.error(`missing file: ${rel}`);
    process.exitCode = 1;
    continue;
  }
  recolorFile(file, mapping);
}

console.log(`svg recolored${dry ? " (dry run)" : ""}`);
