#!/usr/bin/env node
/* Recolor Arc accent pixels in rendered PNG assets to the ayu palette.
 *
 * Run from anywhere after `npm i pngjs` is available (node resolves it from
 * the repo root or your global modules):
 *
 *   node tools/recolor-assets.mjs          # recolor in place
 *   node tools/recolor-assets.mjs --dry    # list what would change
 *
 *  - light files (no "-dark" suffix): Arc blue -> ayu light blue (#035BD6 model)
 *  - "-dark" files (and the assets-dark dir): Arc blue -> ayu yellow (#E6B450 model)
 * Only saturated blue-band pixels are touched; partial alpha is preserved.
 */
import { PNG } from "pngjs";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.dirname(path.dirname(fileURLToPath(import.meta.url)));

function rgb2hsl(r, g, b) {
  r /= 255; g /= 255; b /= 255;
  const max = Math.max(r, g, b), min = Math.min(r, g, b), d = max - min;
  let h = 0;
  if (d) {
    switch (max) {
      case r: h = ((g - b) / d + 6) % 6; break;
      case g: h = (b - r) / d + 2; break;
      default: h = (r - g) / d + 4;
    }
    h *= 60;
  }
  const l = (max + min) / 2;
  const s = d === 0 ? 0 : d / (1 - Math.abs(2 * l - 1));
  return [h, s, l];
}
function hsl2rgb(h, s, l) {
  h = ((h % 360) + 360) % 360;
  const c = (1 - Math.abs(2 * l - 1)) * s, x = c * (1 - Math.abs(((h / 60) % 2) - 1)), m = l - c / 2;
  let r, g, b;
  if (h < 60) { r = c; g = x; b = 0; } else if (h < 120) { r = x; g = c; b = 0; } else if (h < 180) { r = 0; g = c; b = x; }
  else if (h < 240) { r = 0; g = x; b = c; } else if (h < 300) { r = x; g = 0; b = c; } else { r = c; g = 0; b = x; }
  return [(r + m) * 255, (g + m) * 255, (b + m) * 255];
}

// target models derived from Arc accent #5294e2 (h=213.3°, s=0.695, l=0.602)
//  light goal #035BD6: h=213.6°, s=0.971, l=0.426
//  dark  goal #E6B450: h=38.4°,  s=0.757, l=0.607
const LIGHT = { hue: 213.6, satMul: 0.971 / 0.695, lightMul: 0.426 / 0.602 };
const DARK  = { hue: 38.4,  satMul: 0.757 / 0.695, lightMul: 1.0 };

function recolor(file, forceDark, dry) {
  const png = PNG.sync.read(fs.readFileSync(file));
  const d = png.data;
  const target = forceDark || /-dark/.test(path.basename(file)) ? DARK : LIGHT;
  let changed = 0;
  for (let i = 0; i < d.length; i += 4) {
    if (d[i + 3] === 0) continue;
    const h = rgb2hsl(d[i], d[i + 1], d[i + 2]);
    // Accent pixels only: neutral blue-grays (Arc uses s ~0.15) must stay
    // untouched, so discriminate on chroma instead of HSL saturation.
    // Arc accent #5294e2 has chroma 0.565; its antialiased blends >= 0.2.
    const chroma = (Math.max(d[i], d[i + 1], d[i + 2]) - Math.min(d[i], d[i + 1], d[i + 2])) / 255;
    if (chroma < 0.18 || h[0] < 195 || h[0] > 250) continue;
    const ns = Math.min(1, h[1] * target.satMul);
    const nl = Math.max(0, Math.min(1, h[2] * target.lightMul));
    const [nr, ng, nb] = hsl2rgb(target.hue, ns, nl);
    d[i] = nr; d[i + 1] = ng; d[i + 2] = nb;
    changed++;
  }
  if (!dry) fs.writeFileSync(file, PNG.sync.write(png));
  return changed;
}

const dry = process.argv.includes("--dry");
const dirs = [
  ["common/gtk-2.0/assets", false],
  ["common/gtk-2.0/assets-dark", true],
  ["common/gtk-2.0/menubar-toolbar", false],
  ["common/gtk-3.0/3.22/assets", false],
  ["common/gtk-4.0/assets", false],
  ["common/xfwm4/assets", false],
  ["common/xfwm4/assets-dark", true],
];
for (const [dir, forceDark] of dirs) {
  const abs = path.join(ROOT, dir);
  if (!fs.existsSync(abs)) continue;
  for (const f of fs.readdirSync(abs).filter(x => x.endsWith(".png"))) {
    const n = recolor(path.join(abs, f), forceDark, dry);
    if (dry && n > 0) console.log(`${dir}/${f}: ${n} px`);
  }
}
console.log("assets recolored" + (dry ? " (dry run)" : ""));
