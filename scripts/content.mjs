// The words and diagrams shown in the game (and later on the site), from one source: content/.
//   node scripts/content.mjs           write game/data/content.json
//   node scripts/content.mjs --check   fail if that file is out of date, a reference is broken, a
//                                      wording rule is broken, or the About text drifted from
//                                      docs/README_ABOUT.md
import { readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const check = process.argv.includes("--check");
const out = join(root, "game/data/content.json");
const read = (p) => JSON.parse(readFileSync(join(root, p), "utf8"));

const pages = {};
for (const file of readdirSync(join(root, "content/pages")).sort()) {
  if (file.endsWith(".json")) pages[file.replace(/\.json$/, "")] = read(`content/pages/${file}`);
}
const content = {
  pages,
  cards: read("content/cards.json"),
  diagrams: read("content/diagrams.json"),
  links: read("content/links.json"),
};

const problems = [];
const bad = (where, what) => problems.push(`${where}: ${what}`);

const BLOCKS = {
  heading: ["text"],
  paragraph: ["text"],
  list: ["items"],
  steps: ["items"],
  diagram: ["id", "caption"],
  term: ["term", "text"],
  qa: ["q", "a"],
  link: ["label", "target"],
};
const ITEMS = {
  arena: ["shape"],
  line: ["from", "to", "style"],
  hole: ["at", "r"],
  marble: ["at", "side", "r"],
  arrow: ["from", "to", "style"],
  cross: ["at"],
  finger: ["at"],
  label: ["at", "text"],
};
const MODES = ["kep", "batto", "guli", "quick"];
// What a mode's own page, card or the how-to-play may not say: the history lives on the About page.
const BANNED = /\b(authentic|adapted|provisional|traditional|official)\b/i;
const EMOJI = /[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]/u;

/** Every string in a value, to check wording. */
const strings = (v) =>
  typeof v === "string"
    ? [v]
    : Array.isArray(v)
      ? v.flatMap(strings)
      : v && typeof v === "object"
        ? Object.values(v).flatMap(strings)
        : [];

function checkText(where, value, allowHistory) {
  for (const s of strings(value)) {
    if (s.includes("!")) bad(where, `exclamation mark in "${s.slice(0, 40)}"`);
    if (EMOJI.test(s)) bad(where, `emoji in "${s.slice(0, 40)}"`);
    if (!allowHistory && BANNED.test(s)) bad(where, `a history label in "${s.slice(0, 50)}"`);
  }
}

for (const [id, page] of Object.entries(pages)) {
  if (typeof page.title !== "string" || !Array.isArray(page.blocks))
    bad(`page ${id}`, "needs a title and blocks");
  checkText(`page ${id}`, page, id === "about");
  (page.blocks ?? []).forEach((b, i) => {
    const where = `page ${id} block ${i}`;
    if (!BLOCKS[b.type]) return bad(where, `unknown block type "${b.type}"`);
    for (const field of BLOCKS[b.type])
      if (b[field] === undefined) bad(where, `${b.type} needs "${field}"`);
    if (b.type === "diagram" && !content.diagrams[b.id]) bad(where, `no diagram "${b.id}"`);
    if (b.type === "link") {
      const [kind, name] = String(b.target).split(":");
      if (kind === "page" && !pages[name]) bad(where, `no page "${name}"`);
      else if (kind === "url" && !content.links[name]) bad(where, `no link "${name}"`);
      else if (kind !== "page" && kind !== "url")
        bad(where, `link target "${b.target}" is not page: or url:`);
      if (b.hide_on && !["web", "android"].includes(b.hide_on))
        bad(where, `hide_on "${b.hide_on}"`);
    }
  });
}
for (const mode of MODES) {
  if (!content.cards[mode]) bad("cards", `no card for ${mode}`);
  else if (!content.diagrams[content.cards[mode].diagram])
    bad(`card ${mode}`, "its diagram does not exist");
  if (!pages[`game_${mode}`]) bad("pages", `no page game_${mode}`);
}
checkText("cards", content.cards, false);
for (const [id, d] of Object.entries(content.diagrams)) {
  if (!Array.isArray(d.half) || !Array.isArray(d.items))
    bad(`diagram ${id}`, "needs half and items");
  checkText(`diagram ${id}`, d, false);
  (d.items ?? []).forEach((it, i) => {
    if (!ITEMS[it.kind]) return bad(`diagram ${id} item ${i}`, `unknown kind "${it.kind}"`);
    for (const f of ITEMS[it.kind])
      if (it[f] === undefined) bad(`diagram ${id} item ${i}`, `${it.kind} needs "${f}"`);
  });
}

// The About text must match docs/README_ABOUT.md: every heading, paragraph and bullet of the page.
const strip = (s) =>
  s
    .replace(/\*\*|_/g, "")
    .replace(/\s+/g, " ")
    .trim();
function aboutFromDoc() {
  const text = readFileSync(join(root, "docs/README_ABOUT.md"), "utf8");
  const body = text.slice(text.indexOf("## The page"), text.indexOf("## Where it appears"));
  const lines = [];
  for (const raw of body.split("\n")) {
    const line = raw.trim();
    if (!line || line === "## The page") continue;
    lines.push(strip(line.replace(/^###\s+/, "").replace(/^-\s+/, "")));
  }
  return lines;
}
function aboutFromContent() {
  const lines = [];
  for (const b of pages.about.blocks) {
    if (b.type === "heading" || b.type === "paragraph") lines.push(strip(b.text));
    else if (b.type === "list") b.items.forEach((x) => lines.push(strip(x)));
  }
  return lines;
}
const doc = aboutFromDoc();
const shown = aboutFromContent();
if (doc.length !== shown.length || doc.some((l, i) => l !== shown[i])) {
  const i = doc.findIndex((l, k) => l !== shown[k]);
  bad(
    "about",
    `content/pages/about.json differs from docs/README_ABOUT.md near line ${i + 1}:\n    doc:     ${doc[i] ?? "(missing)"}\n    content: ${shown[i] ?? "(missing)"}`,
  );
}

if (problems.length) {
  console.error(problems.join("\n"));
  process.exit(1);
}
const text = JSON.stringify(content, null, 1) + "\n";
if (check) {
  if (!existsSync(out) || readFileSync(out, "utf8") !== text) {
    console.error("out of date: game/data/content.json (run: node scripts/content.mjs)");
    process.exit(1);
  }
  console.log("content ok");
} else {
  writeFileSync(out, text);
  console.log(`wrote game/data/content.json (${Object.keys(pages).length} pages)`);
}
