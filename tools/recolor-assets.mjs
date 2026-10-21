#!/usr/bin/env node
/* Recolor the rendered PNG assets to the exact ayu palette colours.
 *
 *   node tools/recolor-assets.mjs          # recolor in place
 *   node tools/recolor-assets.mjs --dry    # list what would change
 *
 * The mapping lives in tools/asset-map.json and points at the official ayu
 * colours (https://github.com/ayu-theme/ayu-colors). Base colours are written
 * exactly; antialiased edge pixels keep their original tone so the artwork is
 * not distorted. The tool is idempotent: running it twice changes nothing.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { PNG } from "pngjs";

const ROOT = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const MAP = JSON.parse(fs.readFileSync(path.join(ROOT, "tools/asset-map.json"), "utf8"));

function hex2rgb(hex) {
  const h = hex.replace("#", "");
  return [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16)];
}
function rgb2hex(r, g, b) {
  return (
    "#" +
    [r, g, b]
      .map((v) => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, "0"))
      .join("")
  ).toUpperCase();
}

/* Build the lookup table for one file: exact colour -> target colour. */
function buildLut(mapping) {
  const lut = [];
  for (const [source, target] of Object.entries(mapping)) {
    if (source.toLowerCase() === target.toLowerCase()) continue; // already exact
    lut.push({ source, target, s: hex2rgb(source), t: hex2rgb(target) });
  }
  return lut;
}

function recolor(file, lut, dry) {
  const png = PNG.sync.read(fs.readFileSync(file));
  const d = png.data;
  let changed = 0;
  for (let i = 0; i < d.length; i += 4) {
    if (d[i + 3] === 0) continue;
    const r = d[i], g = d[i + 1], b = d[i + 2];
    for (const entry of lut) {
      if (r !== entry.s[0] || g !== entry.s[1] || b !== entry.s[2]) continue;
      d[i] = entry.t[0]; d[i + 1] = entry.t[1]; d[i + 2] = entry.t[2];
      changed++;
      break;
    }
  }
  if (!dry && changed) fs.writeFileSync(file, PNG.sync.write(png));
  return changed;
}

const dry = process.argv.includes("--dry");
let total = 0;

for (const [dir, variants] of Object.entries(MAP.png)) {
  const abs = path.join(ROOT, dir);
  if (!fs.existsSync(abs)) {
    console.error(`missing directory: ${dir}`);
    process.exitCode = 1;
    continue;
  }
  for (const file of fs.readdirSync(abs).filter((x) => x.endsWith(".png"))) {
    const isDark = /-dark/.test(file);
    const mapping = isDark ? variants.dark || variants.all : variants.light || variants.all;
    if (!mapping) continue;
    const lut = buildLut(mapping);
    const n = recolor(path.join(abs, file), lut, dry);
    total += n;
    if (n && dry) console.log(`${dir}/${file}: ${n} px`);
  }
}

// The GTK4 tree reuses the GTK3 artwork.
const gtk4 = path.join(ROOT, "common/gtk-4.0/assets");
const gtk3 = path.join(ROOT, "common/gtk-3.0/3.22/assets");
if (fs.existsSync(gtk4) && fs.existsSync(gtk3)) {
  for (const file of fs.readdirSync(gtk3).filter((x) => x.endsWith(".png"))) {
    const target = path.join(gtk4, file);
    if (!fs.existsSync(target)) continue;
    const isDark = /-dark/.test(file);
    const mapping = isDark ? MAP.png["common/gtk-3.0/3.22/assets"].dark : MAP.png["common/gtk-3.0/3.22/assets"].light;
    const lut = buildLut(mapping);
    const n = recolor(target, lut, dry);
    total += n;
    if (n && dry) console.log(`common/gtk-4.0/assets/${file}: ${n} px`);
  }
}

console.log(`assets recolored${dry ? " (dry run)" : ""}`);
