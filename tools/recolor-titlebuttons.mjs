#!/usr/bin/env node
/* Recolor the GTK titlebutton raster assets to match the xfwm4 decorations.
 *
 *   node tools/recolor-titlebuttons.mjs [--dry]
 *
 * The source PNGs carry their color in RGB with coverage in alpha, so each
 * pixel can be matched against a small per-state palette and replaced while
 * preserving alpha. This keeps the Arc/Ayu artwork and its antialiasing.
 */
import { PNG } from "pngjs";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const DIRS = ["common/gtk-3.0/3.22/assets", "common/gtk-4.0/assets"];

const hex = s => [
  parseInt(s.slice(1, 3), 16),
  parseInt(s.slice(3, 5), 16),
  parseInt(s.slice(5, 7), 16),
];

// White details are shared by every state.
const DETAIL = [
  ["#F8F8F9", "#FCFCFC"],
  ["#FFFFFF", "#FFFFFF"],
];

function rulesFor(file) {
  let base = path.basename(file, ".png").replace(/@2$/, "");
  const dark = base.endsWith("-dark");
  if (dark) base = base.slice(0, -"-dark".length);
  const state = ["hover", "active", "backdrop"].find(s => base.endsWith(`-${s}`)) || "normal";
  const kind = base.split("-")[1];

  if (!dark) {
    if (kind === "close") {
      if (state === "normal") return [...DETAIL, ["#F46067", "#F07171"]];
      if (state === "hover") return [...DETAIL, ["#F68086", "#F38E8E"]];
      if (state === "active") return [...DETAIL, ["#F13039", "#EB4242"]];
    }
    if ((kind === "maximize" || kind === "minimize") && state === "active") {
      return [...DETAIL, ["#005FD9", "#035BD6"]];
    }
    if ((kind === "maximize" || kind === "minimize") && state === "hover") {
      return [...DETAIL, ["#7A7F8B", "#5C6773"]];
    }
    return DETAIL;
  }

  if (kind === "close") {
    if (state === "normal") return [...DETAIL, ["#CC575D", "#F07178"]];
    if (state === "hover") return [...DETAIL, ["#D7787D", "#F38E94"]];
    if (state === "active") return [...DETAIL, ["#BE3841", "#EB424C"]];
    if (state === "backdrop") return [...DETAIL, ["#B9BCC3", "#5A6673"]];
  }
  if (kind === "maximize" || kind === "minimize") {
    if (state === "normal") return [...DETAIL, ["#B9BCC2", "#8A8A87"]];
    if (state === "backdrop") return [...DETAIL, ["#B9BCC3", "#5A6673"]];
    if (state === "hover") {
      return [
        ...DETAIL,
        ["#C4C7CC", "#BFBDB6"],
        ["#5F687E", "#1F2738"],
        ["#15171C", "#0D1017"],
        ["#171A20", "#0D1017"],
      ];
    }
    if (state === "active") return [...DETAIL, ["#E8AF4B", "#E6B450"]];
  }
  return DETAIL;
}

function recolor(file, dry) {
  const png = PNG.sync.read(fs.readFileSync(file));
  const d = png.data;
  const rules = rulesFor(file).map(([from, to]) => [hex(from), hex(to)]);
  const targets = new Set(rules.map(([, to]) => to.join(",")));
  let changed = 0;

  for (let i = 0; i < d.length; i += 4) {
    if (d[i + 3] === 0) continue;
    // Keep repeated runs idempotent: a flat target fill is never a source.
    if (targets.has(`${d[i]},${d[i + 1]},${d[i + 2]}`)) continue;
    let best = null;
    let bestDistance = Infinity;
    for (const [from, to] of rules) {
      const dr = d[i] - from[0], dg = d[i + 1] - from[1], db = d[i + 2] - from[2];
      const distance = dr * dr + dg * dg + db * db;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = to;
      }
    }
    // Stay close to a known state colour; stray/mask pixels are left alone.
    if (!best || bestDistance > 70 * 70) continue;
    if (d[i] !== best[0] || d[i + 1] !== best[1] || d[i + 2] !== best[2]) {
      d[i] = best[0];
      d[i + 1] = best[1];
      d[i + 2] = best[2];
      changed++;
    }
  }

  if (changed && !dry) fs.writeFileSync(file, PNG.sync.write(png));
  return changed;
}

const dry = process.argv.includes("--dry");
for (const dir of DIRS) {
  const abs = path.join(ROOT, dir);
  if (!fs.existsSync(abs)) continue;
  for (const f of fs.readdirSync(abs).filter(x => /^titlebutton-.*\.png$/.test(x))) {
    const n = recolor(path.join(abs, f), dry);
    if (n) console.log(`${dir}/${f}: ${n} px${dry ? " (dry)" : ""}`);
  }
}
console.log("titlebuttons recolored" + (dry ? " (dry run)" : ""));
