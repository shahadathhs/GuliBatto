// Concept-render tokens, read from the single colour source design/tokens.json.
// Concept renders are design targets, not the game: the real arena is 3D.
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");
const data = JSON.parse(readFileSync(join(root, "design/tokens.json"), "utf8"));
const camel = (n) => n.replace(/-(\w)/g, (_, c) => c.toUpperCase());
// An 8-digit hex (#RRGGBBAA) becomes an rgba() string so SVG renders the alpha.
const css = (h) => {
  if (h.length !== 9) return h;
  const a = (parseInt(h.slice(7, 9), 16) / 255).toFixed(2);
  const [r, g, b] = [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16));
  return `rgba(${r},${g},${b},${a})`;
};
const build = (theme) =>
  Object.fromEntries(
    [...data.tokens, ...data.arena, ...data.sheet].map((t) => [camel(t.name), css(t[theme])]),
  );

export const THEMES = { light: build("light"), dark: build("dark") };
