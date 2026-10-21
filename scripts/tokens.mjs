// Single source of colours: design/tokens.json.
//   node scripts/tokens.mjs           regenerate the Godot palette and the web CSS
//   node scripts/tokens.mjs --check   fail if a generated file is out of date or a contrast pair fails
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const data = JSON.parse(readFileSync(join(root, "design/tokens.json"), "utf8"));
const check = process.argv.includes("--check");

const byName = (name) => {
  const t = [...data.tokens, ...data.arena, ...data.sheet].find((x) => x.name === name);
  if (!t) throw new Error(`unknown token: ${name}`);
  return t;
};

// ── contrast ──────────────────────────────────────────────────────────
const channel = (h, i) => parseInt(h.slice(1 + i * 2, 3 + i * 2), 16) / 255;
const lin = (c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
const luminance = (h) =>
  0.2126 * lin(channel(h, 0)) + 0.7152 * lin(channel(h, 1)) + 0.0722 * lin(channel(h, 2));
const ratio = (a, b) => {
  const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
};

const problems = [];
for (const { text, on, min } of data.contrast) {
  for (const theme of ["light", "dark"]) {
    const r = ratio(byName(text)[theme], byName(on)[theme]);
    if (r < min) problems.push(`${text} on ${on} (${theme}) is ${r.toFixed(1)}, needs ${min}`);
  }
}

// ── generators ────────────────────────────────────────────────────────
const snake = (n) => n.replaceAll("-", "_");
const gdColor = (h) => {
  const f = (i) => channel(h, i).toFixed(4);
  const a = h.length === 9 ? (parseInt(h.slice(7, 9), 16) / 255).toFixed(4) : null;
  return a ? `Color(${f(0)}, ${f(1)}, ${f(2)}, ${a})` : `Color(${f(0)}, ${f(1)}, ${f(2)})`;
};
const all = [...data.tokens, ...data.arena];

function palette() {
  const dict = (theme) => all.map((t) => `\t"${snake(t.name)}": ${gdColor(t[theme])},`).join("\n");
  return `# Generated from design/tokens.json by scripts/tokens.mjs. Do not edit.
class_name Palette
extends RefCounted
## Light and dark colour tokens. Names use snake_case (on_glaze, earth_rim).

enum Scheme { LIGHT, DARK }

const LIGHT := {
${dict("light")}
}

const DARK := {
${dict("dark")}
}


static func get_color(token: StringName, scheme: Scheme) -> Color:
	var table: Dictionary = LIGHT if scheme == Scheme.LIGHT else DARK
	assert(table.has(token), "unknown colour token: %s" % token)
	return table[token]
`;
}

function css() {
  const vars = (theme) => data.tokens.map((t) => `  --${t.name}: ${t[theme]};`).join("\n");
  return `/* Generated from design/tokens.json by scripts/tokens.mjs. Do not edit. */
:root {
${vars("light")}
  color-scheme: light dark;
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
${vars("dark").replaceAll("  --", "    --")}
  }
}

:root[data-theme="dark"] {
${vars("dark")}
}
`;
}

const outputs = [
  ["game/scripts/generated/palette.gd", palette()],
  ["web/src/app/tokens.css", css()],
];

for (const [file, content] of outputs) {
  const path = join(root, file);
  if (check) {
    if (!existsSync(path) || readFileSync(path, "utf8") !== content)
      problems.push(`${file} is out of date: run node scripts/tokens.mjs`);
  } else {
    writeFileSync(path, content);
    console.log(`wrote ${file}`);
  }
}

if (problems.length) {
  console.error(problems.map((p) => `- ${p}`).join("\n"));
  process.exit(1);
}
if (check) console.log("tokens ok");
