// Fails if a colour is written by hand outside the token source and the generated files.
// Rule (AGENTS.md, docs/README_VISUAL_DESIGN.md): colours come only from design/tokens.json.
//   node scripts/check-colors.mjs
import { readdirSync, readFileSync } from "node:fs";
import { dirname, join, relative, sep } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");

const SCAN_DIRS = ["game/scripts", "game/tests", "game/scenes", "web/src", "scripts"];
const EXTENSIONS = new Set([
  ".gd",
  ".tscn",
  ".tres",
  ".ts",
  ".tsx",
  ".js",
  ".mjs",
  ".css",
  ".html",
]);
const SKIP_DIRS = new Set(["node_modules", ".next", ".godot", "build", "addons"]);

// Files allowed to hold colour literals, with the reason.
const ALLOWED = new Map([
  ["game/scripts/generated/palette.gd", "generated from the tokens"],
  ["web/src/app/tokens.css", "generated from the tokens"],
  ["scripts/tokens.mjs", "the generator and contrast check; it writes Color(...) and reads hex"],
  ["scripts/design/tokens.mjs", "converts 8-digit tokens to rgba() for SVG"],
  ["scripts/check-colors.mjs", "this file describes the patterns"],
]);

const HEX = /#(?:[0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3})\b/;
const FUNCTIONS = /\b(?:Color|Color8|rgba?|hsla?|oklch|oklab)\s*\(/;
const NAMED = /\bColor\.[A-Z_]+\b/;

/** @param {string} dir @returns {string[]} */
function walk(dir) {
  const out = [];
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    if (e.isDirectory()) {
      if (!SKIP_DIRS.has(e.name)) out.push(...walk(join(dir, e.name)));
    } else if (EXTENSIONS.has(e.name.slice(e.name.lastIndexOf(".")))) out.push(join(dir, e.name));
  }
  return out;
}

const found = [];
for (const dir of SCAN_DIRS) {
  let files = [];
  try {
    files = walk(join(root, dir));
  } catch {
    continue;
  }
  for (const file of files) {
    const rel = relative(root, file).split(sep).join("/");
    if (ALLOWED.has(rel)) continue;
    readFileSync(file, "utf8")
      .split("\n")
      .forEach((line, i) => {
        if (HEX.test(line) || FUNCTIONS.test(line) || NAMED.test(line))
          found.push(`${rel}:${i + 1}: ${line.trim().slice(0, 100)}`);
      });
  }
}

if (found.length) {
  console.error(
    "Hand-written colours (use design/tokens.json):\n" + found.map((f) => `  ${f}`).join("\n"),
  );
  process.exit(1);
}
console.log("colours ok");
