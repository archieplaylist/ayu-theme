#!/usr/bin/env node
/* Recolor the Arc accent blues in SVG/XML sources to the ayu palette.
 *
 *   node tools/recolor-svg.mjs [--dry]
 *
 * Files whose name contains "-dark" (and directories listed as dark) get the
 * ayu dark accent (yellow), everything else gets the ayu light accent (blue).
 * Neutral blue-grays (Arc UI grays such as #383c4a) are left untouched: the
 * classifier requires both a blue-band hue and a minimum chroma, which
 * separates real accents from the slightly blue-tinted neutrals.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.dirname(path.dirname(fileURLToPath(import.meta.url)));

const LIGHT = { hue: 213.6, satMul: 0.971 / 0.695, lightMul: 0.426 / 0.602 };
const DARK  = { hue: 38.4,  satMul: 0.757 / 0.695, lightMul: 1.0 };

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
const hex2 = v => Math.round(Math.min(255, Math.max(0, v))).toString(16).padStart(2, "0");

function mapHex(hex, target) {
  const r = parseInt(hex.slice(1, 3), 16), g = parseInt(hex.slice(3, 5), 16), b = parseInt(hex.slice(5, 7), 16);
  const chroma = (Math.max(r, g, b) - Math.min(r, g, b)) / 255;
  const [h, s, l] = rgb2hsl(r, g, b);
  if (chroma < 0.18 || h < 195 || h > 250) return null;
  // Idempotency: skip colors already sitting in the ayu accent family, so
  // repeated runs (or symlinked duplicates) never darken the palette again.
  let hueDiff = Math.abs(h - target.hue);
  if (hueDiff > 180) hueDiff = 360 - hueDiff;
  if (target === LIGHT && hueDiff < 6 && s > 0.90 && l < 0.55) return null;
  if (target === DARK && hueDiff < 6 && s > 0.60) return null;
  const [nr, ng, nb] = hsl2rgb(target.hue, Math.min(1, s * target.satMul), Math.max(0, Math.min(1, l * target.lightMul)));
  return `#${hex2(nr)}${hex2(ng)}${hex2(nb)}`;
}

function recolorFile(file, forceDark, dry) {
  const text = fs.readFileSync(file, "utf8");
  const target = forceDark || /-dark/.test(path.basename(file)) ? DARK : LIGHT;
  const seen = new Map();
  const out = text.replace(/#[0-9a-fA-F]{6}\b/g, m => {
    if (seen.has(m.toLowerCase())) return seen.get(m.toLowerCase());
    const mapped = mapHex(m.toLowerCase(), target);
    const result = mapped ? (m === m.toUpperCase() ? mapped.toUpperCase() : mapped) : m;
    seen.set(m.toLowerCase(), result);
    return result;
  });
  if (out !== text) {
    if (!dry) fs.writeFileSync(file, out);
    return seen.size;
  }
  return 0;
}

const processed = new Set();

function walk(dir, forceDark, dry) {
  const abs = path.join(ROOT, dir);
  if (!fs.existsSync(abs)) return;
  for (const entry of fs.readdirSync(abs, { withFileTypes: true })) {
    const p = path.join(abs, entry.name);
    if (entry.isDirectory()) walk(path.join(dir, entry.name), forceDark, dry);
    else if (/\.(svg|xml)$/.test(entry.name)) {
      const real = fs.realpathSync(p);
      if (processed.has(real)) continue;
      processed.add(real);
      const changed = recolorFile(p, forceDark, dry);
      if (changed) console.log(`${path.relative(ROOT, p)}: ${changed} colors${dry ? " (dry)" : ""}`);
    }
  }
}

const dry = process.argv.includes("--dry");
const dirs = [
  ["common/cinnamon/common-assets", false],
  ["common/cinnamon/light-assets", false],
  ["common/cinnamon/dark-assets", true],
  ["common/gnome-shell/3.22/common-assets", false],
  ["common/gnome-shell/3.22/light-assets", false],
  ["common/gnome-shell/3.22/dark-assets", true],
  ["common/metacity-1", false],
  ["common/unity", false],
  ["common/gtk-2.0", false],
  ["common/gtk-3.0/3.22", false],
  ["common/gtk-4.0/assets", false],
  ["common/xfwm4", false],
];
for (const [dir, forceDark] of dirs) walk(dir, forceDark, dry);
console.log("svg/xml recolored" + (dry ? " (dry run)" : ""));
