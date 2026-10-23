#!/usr/bin/env node
/* Check that every colour used by the theme comes from the official ayu
 * palette (https://github.com/ayu-theme/ayu-colors).
 *
 *   node tools/check-palette.mjs          # report and exit non-zero on drift
 *   node tools/check-palette.mjs --quiet  # only print problems
 *
 * Rules:
 *   - a colour must be an exact ayu token, an ayu token with the official
 *     alpha, a documented derived colour, or a neutral mask (black/white);
 *   - the generated palette blocks in the Sass sources must match
 *     tools/palette.json (run tools/gen-palette.mjs to update them);
 *   - the rendered PNG assets must not contain the old Arc accent colours.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { PNG } from "pngjs";

const ROOT = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const palette = JSON.parse(fs.readFileSync(path.join(ROOT, "tools/palette.json"), "utf8"));
const quiet = process.argv.includes("--quiet");

/* ------------------------------------------------------------------ tokens */
const official = new Set(); // 6-digit hex, lower case
const officialAlpha = new Set(); // 8-digit hex, lower case
function collect(node) {
  for (const value of Object.values(node)) {
    if (value && typeof value === "object") collect(value);
    else {
      const h = value.replace("#", "").toLowerCase();
      if (h.length === 8) {
        officialAlpha.add(h);
        official.add(h.slice(0, 6));
      } else official.add(h);
    }
  }
}
for (const flavor of Object.values(palette.flavors)) collect(flavor);

/* Colours that are derived from ayu tokens (hover/active/backdrop states) or
 * that are pure masks. Keep this list in sync with PALETTE.md. */
const derived = new Set([
  // neutral masks and shadows
  "#000000", "#ffffff", "#00000000",
  // headerbar backdrop: lighten(surface.base, 1.5%) in mirage and dark,
  // see PALETTE.md; the light value is #ffffff above
  "#222735", "#10131c",
  // legacy Arc artwork that is only used as an alpha mask in the sprite sheets
  "#ff00ff",
]);
/* Colours that are still Arc artwork in the GNOME Shell's Adwaita palette
 * (common/gnome-shell/3.22/sass/_palette.scss). The shell keeps Adwaita's
 * ramps for widget internals; the ayu surfaces, text and accents override
 * them. See PALETTE.md. */
const shellAdwaita = new Set([
  "#99c1f1", "#62a0ea", "#3584e4", "#1c71d8", "#1a5fb4",
  "#8ff0a4", "#57e389", "#33d17a", "#2ec27e", "#26a269",
  "#f9f06b", "#f8e45c", "#f6d32d", "#f5c211", "#e5a50a",
  "#ffbe6f", "#ffa348", "#ff7800", "#e66100", "#c64600",
  "#f66151", "#ed333b", "#e01b24", "#c01c28", "#a51d2d",
  "#dc8add", "#c061cb", "#9141ac", "#813d9c", "#613583",
  "#cdab8f", "#b5835a", "#986a44", "#865e3c", "#63452c",
  "#f6f5f4", "#deddda", "#9a9996", "#77767b", "#5e5c64",
  "#3d3846", "#241f31", "#c0bfbc",
]);

const problems = [];
function report(kind, file, detail) {
  problems.push(`${kind}: ${file}: ${detail}`);
}

/* ------------------------------------------------------------ source files */
const SOURCE_GLOBS = [
  "common/gtk-3.0/3.22/sass/*.scss",
  "common/gtk-4.0/sass/*.scss",
  "common/cinnamon/sass/*.scss",
  "common/gnome-shell/3.22/sass/*.scss",
  "common/gnome-shell/3.22/sass/widgets/*.scss",
  "common/gtk-2.0/gtkrc*",
  "common/gtk-2.0/*.rc",
  "common/xfwm4/themerc*",
  "common/metacity-1/*.xml",
  "extra/libadwaita/gtk.css.*",
];

function* walkFiles(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) yield* walkFiles(p);
    else yield p;
  }
}

for (const glob of SOURCE_GLOBS) {
  const dir = path.join(ROOT, path.dirname(glob));
  if (!fs.existsSync(dir)) continue;
  const pattern = path.basename(glob);
  for (const file of walkFiles(dir)) {
    if (path.basename(file) !== pattern && !pattern.includes("*")) continue;
    if (pattern.includes("*") && !new RegExp("^" + pattern.replace(/\*/g, ".*") + "$").test(path.basename(file))) continue;
    const text = fs.readFileSync(file, "utf8");
    // ignore comments: bug numbers such as "#786613" are not colours
    const code = text.replace(/\/\*[\s\S]*?\*\//g, "").replace(/^\s*\/\/.*$/gm, "");
    const rel = path.relative(ROOT, file);
    for (const m of code.matchAll(/#[0-9a-fA-F]{6,8}\b/g)) {
      const hex = m[0].toLowerCase().replace("#", "");
      const base = hex.slice(0, 6);
      if (official.has(base)) continue;
      if (officialAlpha.has(hex)) continue;
      if (derived.has(hex) || derived.has("#" + hex) ||
          derived.has(base) || derived.has("#" + base)) continue;
      if (rel.includes("gnome-shell") && shellAdwaita.has(base)) continue;
      report("colour", rel, `#${hex} is not an ayu palette colour`);
    }
  }
}

/* ------------------------------------------------------- generated palette */
const gen = fs.existsSync(path.join(ROOT, "tools/gen-palette.mjs"))
  ? fs.readFileSync(path.join(ROOT, "tools/gen-palette.mjs"), "utf8")
  : "";
if (gen) {
  const { execFileSync } = await import("node:child_process");
  try {
    execFileSync(process.execPath, [path.join(ROOT, "tools/gen-palette.mjs"), "--check"], {
      cwd: ROOT,
      stdio: "pipe",
    });
  } catch (err) {
    report("palette", "tools/palette.json", (err.stderr || "").toString().trim());
  }
}

/* --------------------------------------------------------------- PNG assets */
const legacy = ["005fd9", "e8af4b", "0062e0", "0060da", "f38e8e", "f38e94", "eb4242", "eb424c", "2b303b", "cfd6e6"];
const assetDirs = [
  "common/gtk-3.0/3.22/assets",
  "common/gtk-4.0/assets",
  "common/gtk-2.0/assets",
  "common/gtk-2.0/assets-dark",
  "common/gtk-2.0/menubar-toolbar",
  "common/xfwm4/assets",
  "common/xfwm4/assets-dark",
  "common/xfwm4/assets-mirage",
  "common/xfwm4/assets-hdpi",
  "common/xfwm4/assets-dark-hdpi",
  "common/xfwm4/assets-mirage-hdpi",
];
for (const dir of assetDirs) {
  const abs = path.join(ROOT, dir);
  if (!fs.existsSync(abs)) continue;
  for (const file of fs.readdirSync(abs).filter((x) => x.endsWith(".png"))) {
    const png = PNG.sync.read(fs.readFileSync(path.join(abs, file)));
    const d = png.data;
    const found = new Set();
    for (let i = 0; i < d.length; i += 4) {
      if (d[i + 3] < 200) continue;
      const hex = ((d[i] << 16) | (d[i + 1] << 8) | d[i + 2]).toString(16).padStart(6, "0");
      if (legacy.includes(hex)) found.add(hex);
    }
    if (found.size) report("asset", `${dir}/${file}`, `legacy colours: ${[...found].join(", ")}`);
  }
}

/* ------------------------------------------------------------------ report */
if (problems.length) {
  for (const p of problems) console.error(p);
  console.error(`\n${problems.length} palette problem(s) found`);
  process.exit(1);
}
if (!quiet) console.log("palette check passed");
