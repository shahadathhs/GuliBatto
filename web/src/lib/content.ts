// The pages, cards and diagrams the game also shows, from the one source in content/ (copied to
// content.generated.json by `make content`). The site renders them; it holds no copy of the text.
import data from "./content.generated.json";

export type Block =
  | { type: "heading"; text: string }
  | { type: "paragraph"; text: string }
  | { type: "list"; items: string[] }
  | { type: "steps"; items: string[] }
  | { type: "diagram"; id: string; caption: string }
  | { type: "term"; term: string; text: string }
  | { type: "qa"; q: string; a: string }
  | { type: "link"; label: string; target: string; hide_on?: string };

export type Page = { title: string; blocks: Block[] };
export type Card = { title: string; diagram: string; lines: string[] };

export type DiagramItem = {
  kind: "arena" | "line" | "hole" | "marble" | "arrow" | "cross" | "finger" | "label";
  shape?: string;
  half?: [number, number];
  r?: number;
  at?: [number, number];
  from?: [number, number];
  to?: [number, number];
  side?: number;
  style?: string;
  text?: string;
  label?: string;
};
export type DiagramData = { half: [number, number]; items: DiagramItem[] };

const pages = data.pages as unknown as Record<string, Page>;
const cards = data.cards as unknown as Record<string, Card>;
const diagrams = data.diagrams as unknown as Record<string, DiagramData>;
const links = data.links as Record<string, string>;

/** The four games, in menu order: the site path, the content page and the card. */
export const GAMES = [
  { slug: "kep", page: "game_kep", card: "kep" },
  { slug: "batto", page: "game_batto", card: "batto" },
  { slug: "guli-khela", page: "game_guli", card: "guli" },
  { slug: "quick-dan", page: "game_quick", card: "quick" },
] as const;

/** Where each content page lives on the site. */
const ROUTES: Record<string, string> = {
  how_to_play: "/how-to-play",
  about: "/about",
  contact: "/contact",
  privacy: "/privacy",
  ...Object.fromEntries(GAMES.map((g) => [g.page, `/games/${g.slug}`])),
};

export const page = (id: string): Page => {
  const found = pages[id];
  if (!found) throw new Error(`no content page "${id}"`);
  return found;
};
export const card = (id: string): Card => cards[id] as Card;
export const diagram = (id: string): DiagramData => diagrams[id] as DiagramData;
export const game = (slug: string) => GAMES.find((g) => g.slug === slug);

/** The path or address a link block points to, or null when it is hidden on the web. */
export function hrefFor(block: Extract<Block, { type: "link" }>): string | null {
  if (block.hide_on === "web") return null;
  const [kind, name] = block.target.split(":");
  if (kind === "page") return ROUTES[name] ?? null;
  const url = links[name ?? ""];
  if (!url) return null;
  // The site's own pages are relative, so the link works on a preview and on localhost.
  const site = links.site ?? "";
  return site && url.startsWith(site) ? url.slice(site.length) || "/" : url;
}

export type Section = { title: string | null; id: string; blocks: Block[] };

export const slugify = (text: string): string =>
  text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");

/** A page's blocks cut at its headings. Blocks before the first heading have no title. */
export function sections(blocks: Block[]): Section[] {
  const out: Section[] = [];
  for (const b of blocks) {
    if (b.type === "heading") out.push({ title: b.text, id: slugify(b.text), blocks: [] });
    else {
      if (out.length === 0) out.push({ title: null, id: "intro", blocks: [] });
      out[out.length - 1]!.blocks.push(b);
    }
  }
  return out;
}
