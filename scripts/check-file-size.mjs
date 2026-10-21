// Fails if a hand-written source file is over the hard ceiling; lists files over the soft limit.
// Rule (AGENTS.md, docs/README_CODE_STANDARDS.md): 300 lines soft, 450 lines hard.
//   node scripts/check-file-size.mjs
import { readdirSync, readFileSync } from "node:fs";
import { dirname, join, relative, sep } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const SOFT = 300;
const HARD = 450;
const SCAN_DIRS = ["game/scripts", "web/src", "scripts"];
const EXTENSIONS = new Set([".gd", ".ts", ".tsx", ".mjs"]);
const SKIP_DIRS = new Set(["node_modules", ".next", ".godot", "build", "addons", "generated"]);
// Files allowed over the ceiling, with the reason.
const EXEMPT = new Map();

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

const over = [];
const soft = [];
for (const dir of SCAN_DIRS) {
  let files = [];
  try {
    files = walk(join(root, dir));
  } catch {
    continue;
  }
  for (const file of files) {
    const rel = relative(root, file).split(sep).join("/");
    const lines = readFileSync(file, "utf8").split("\n").length;
    if (lines > HARD && !EXEMPT.has(rel)) over.push(`${rel}: ${lines} lines`);
    else if (lines > SOFT) soft.push(`${rel}: ${lines} lines`);
  }
}

if (soft.length)
  console.log(
    `Over ${SOFT} lines (split when next touched):\n${soft.map((s) => `  ${s}`).join("\n")}`,
  );
if (over.length) {
  console.error(`Over the ${HARD}-line ceiling:\n${over.map((s) => `  ${s}`).join("\n")}`);
  process.exit(1);
}
console.log(`file sizes ok (ceiling ${HARD})`);
