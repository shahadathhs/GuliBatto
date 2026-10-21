// Smoke test of the built site: every page answers with real content in the HTML (so it works
// without JavaScript), sets no cookies, and loads nothing from other sites.
//   pnpm --filter web build && pnpm --filter web smoke
import { spawn } from "node:child_process";
import { createRequire } from "node:module";
import { setTimeout as sleep } from "node:timers/promises";

const PORT = process.env.SMOKE_PORT ?? "3101";
const BASE = `http://127.0.0.1:${PORT}`;

// Each page: the heading it must contain, plus text that proves the body rendered.
const PAGES = [
  ["/", "Line up the shot", "Kep"],
  ["/how-to-play", "How to play", "baad"],
  ["/about", "About these games", "Nothing here is invented from nothing"],
  ["/download", "Download", "direct download"],
  ["/privacy", "Privacy", "collects nothing"],
];
// Links out are allowed (a visitor chooses to follow them); resources the page loads are not.
const LOADS = /(?:src|srcset|data-href)="(https?:\/\/[^"]+)"|<link[^>]+href="(https?:\/\/[^"]+)"/g;

// Run next directly (not through pnpm) so stopping the server really stops it.
const nextBin = createRequire(import.meta.url).resolve("next/dist/bin/next");
const server = spawn(process.execPath, [nextBin, "start", "-p", PORT], { stdio: "ignore" });
const stop = () => server.kill();
process.on("exit", stop);

let failed = false;
const fail = (msg) => {
  failed = true;
  console.error(`FAIL  ${msg}`);
};

try {
  for (let i = 0; ; i++) {
    try {
      if ((await fetch(BASE)).ok) break;
    } catch {}
    if (i > 60) throw new Error("server did not start");
    await sleep(500);
  }

  for (const [path, heading, text] of PAGES) {
    const res = await fetch(BASE + path);
    const html = await res.text();
    if (res.status !== 200) fail(`${path} answered ${res.status}`);
    if (!html.includes(heading)) fail(`${path} lacks "${heading}"`);
    if (!html.includes(text)) fail(`${path} lacks "${text}" in the HTML`);
    if (res.headers.get("set-cookie")) fail(`${path} sets a cookie`);
    for (const m of html.matchAll(LOADS)) fail(`${path} loads ${m[1] ?? m[2]} from another site`);
    if (!failed) console.log(`ok    ${path}`);
  }

  for (const path of ["/robots.txt", "/sitemap.xml"]) {
    const res = await fetch(BASE + path);
    if (res.status !== 200) fail(`${path} answered ${res.status}`);
    else console.log(`ok    ${path}`);
  }
  if ((await fetch(BASE + "/no-such-page")).status !== 404) fail("an unknown page is not a 404");
} catch (e) {
  fail(String(e));
} finally {
  stop();
}
process.exit(failed ? 1 : 0);
