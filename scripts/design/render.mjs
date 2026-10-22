// Writes the concept renders in docs/design: SVG sources to a temp dir, PNGs through headless Chrome.
//   node scripts/design/render.mjs          (needs Google Chrome)
import { mkdirSync, writeFileSync, rmSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { tmpdir } from "node:os";
import { screenSvg, screenList, screenBody, viewsSvg, W, H } from "./screens.mjs";
import { THEMES } from "./tokens.mjs";
import { homeSvg, gameSvg, downloadSvg, WEB_W } from "./web.mjs";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");
const out = join(root, "docs/design");
const tmp = join(tmpdir(), "gulibatto-design");
rmSync(tmp, { recursive: true, force: true });
mkdirSync(tmp, { recursive: true });
const CHROME = process.env.CHROME ?? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";

function png(svgText, name, w, h, dest) {
  const file = join(tmp, `${name}.svg`);
  writeFileSync(file, svgText);
  mkdirSync(dirname(dest), { recursive: true });
  execFileSync(
    CHROME,
    [
      "--headless=new",
      "--disable-gpu",
      "--hide-scrollbars",
      `--screenshot=${dest}`,
      `--window-size=${w},${h}`,
      "--force-device-scale-factor=2",
      `file://${file}`,
    ],
    { stdio: "ignore" },
  );
}

for (const theme of Object.keys(THEMES)) {
  for (const { id } of screenList)
    png(screenSvg(id, theme), `${theme}-${id}`, W, H, join(out, "screens", theme, `${id}.png`));
  png(
    viewsSvg(theme),
    `${theme}-views`,
    1170,
    520,
    join(out, "screens", theme, "16-camera-views.png"),
  );
  // Overview sheet: all screens in a grid.
  const cols = 4,
    gap = 24,
    s = 0.5,
    cw = W * s,
    ch = H * s;
  const rows = Math.ceil(screenList.length / cols);
  const sheet = screenList
    .map(({ id }, i) => {
      const x = gap + (i % cols) * (cw + gap),
        y = gap + Math.floor(i / cols) * (ch + gap);
      return `<g transform="translate(${x},${y}) scale(${s})"><rect width="${W}" height="${H}" fill="${THEMES[theme].ground}"/><clipPath id="c${i}"><rect width="${W}" height="${H}"/></clipPath><g clip-path="url(#c${i})">${screenBody(id, theme)}</g></g>`;
    })
    .join("");
  const sw = gap + cols * (cw + gap),
    sh = gap + rows * (ch + gap);
  // The README strip: six screens in a row.
  const pick = [
    "01-menu",
    "02-modes",
    "17-who-plays",
    "05-kep-ready",
    "07-batto-ready",
    "10-guli-baad",
  ];
  const strip = pick
    .map((id, i) => {
      const x = gap + i * (cw + gap);
      return `<g transform="translate(${x},${gap}) scale(${s})"><rect width="${W}" height="${H}" fill="${THEMES[theme].ground}"/><clipPath id="s${i}"><rect width="${W}" height="${H}"/></clipPath><g clip-path="url(#s${i})">${screenBody(id, theme)}</g></g>`;
    })
    .join("");
  const stw = gap + pick.length * (cw + gap);
  png(
    `<svg xmlns="http://www.w3.org/2000/svg" width="${stw}" height="${ch + gap * 2}"><rect width="100%" height="100%" fill="${THEMES[theme].sheet}"/>${strip}</svg>`,
    `${theme}-strip`,
    stw,
    ch + gap * 2,
    join(out, `app-strip-${theme}.png`),
  );
  png(
    `<svg xmlns="http://www.w3.org/2000/svg" width="${sw}" height="${sh}"><rect width="100%" height="100%" fill="${THEMES[theme].sheet}"/>${sheet}</svg>`,
    `${theme}-overview`,
    sw,
    sh,
    join(out, `overview-${theme}.png`),
  );
}
for (const theme of Object.keys(THEMES)) {
  for (const [name, svg, h] of [
    ["home", homeSvg(theme), 1900],
    ["game-guli", gameSvg(theme), 1230],
    ["download", downloadSvg(theme), 1030],
  ])
    png(svg, `${theme}-web-${name}`, WEB_W, h, join(out, "web", theme, `${name}.png`));
}
console.log("done");
