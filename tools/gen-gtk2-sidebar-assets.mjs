import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { PNG } from "pngjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const width = 256;
const height = 36;
const stripeWidth = 2;
const variants = [
  {
    directory: "common/gtk-2.0/assets",
    hoverColor: [0, 0, 0],
    hoverOpacity: 0.05,
    selectedColor: [242, 151, 24],
    accentColor: [242, 151, 24],
  },
  {
    directory: "common/gtk-2.0/assets-dark",
    hoverColor: [255, 255, 255],
    hoverOpacity: 0.03,
    selectedColor: [230, 180, 80],
    accentColor: [230, 180, 80],
  },
  {
    directory: "common/gtk-2.0/assets-mirage",
    hoverColor: [255, 255, 255],
    hoverOpacity: 0.03,
    selectedColor: [255, 204, 102],
    accentColor: [255, 204, 102],
  },
];

function writeRowImage(directory, name, color, opacity, accentColor) {
  const image = new PNG({ width, height });

  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const offset = (y * width + x) * 4;
      const fade = Math.min(1, x / (width / 2));
      const isAccent = x >= width - stripeWidth;
      const alpha = isAccent ? 255 : Math.round(255 * opacity * fade);
      const rgb = isAccent ? accentColor : color;

      image.data[offset] = rgb[0];
      image.data[offset + 1] = rgb[1];
      image.data[offset + 2] = rgb[2];
      image.data[offset + 3] = alpha;
    }
  }

  const output = resolve(root, directory, name);
  mkdirSync(dirname(output), { recursive: true });
  writeFileSync(output, PNG.sync.write(image));
}

for (const variant of variants) {
  writeRowImage(variant.directory, "sidebar-row-hover.png", variant.hoverColor, variant.hoverOpacity, variant.accentColor);
  writeRowImage(variant.directory, "sidebar-row-selected.png", variant.selectedColor, 0.25, variant.accentColor);
}
