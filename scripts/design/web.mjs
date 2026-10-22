// Concept renders of the website: Home, a game page and Download, drawn from the same tokens and
// marble marks as the app screens. They show the layout, not the exact text of every page.
import { FONT, text, marble, hole, jalla, arena } from "./parts.mjs";
import { THEMES } from "./tokens.mjs";

export const WEB_W = 1440;
const X = 180;
const COL = 1080;

const wrap = (c, rows, x, y, o = {}) =>
  rows
    .map((t, i) =>
      text(t, x, y + i * (o.gap ?? 28), {
        fill: o.fill ?? c.ink,
        size: o.size ?? 17,
        weight: o.weight ?? 500,
      }),
    )
    .join("");

const pill = (c, label, x, y, w) =>
  `<rect x="${x}" y="${y}" width="${w}" height="60" rx="30" fill="${c.glaze}"/>${text(label, x + w / 2, y + 37, { fill: c.onGlaze, size: 16, weight: 800, anchor: "middle", ls: 1.5 })}`;
const words = (t, n) => {
  const out = [""];
  for (const w of t.split(" ")) {
    if ((out.at(-1) + " " + w).trim().length > n) out.push(w);
    else out[out.length - 1] = (out.at(-1) + " " + w).trim();
  }
  return out;
};
const h2 = (c, label, y) => text(label, X, y, { fill: c.ink, size: 32, weight: 800 });

function header(c) {
  const items = ["Games", "How to play", "Play", "Download", "About"];
  const xs = [700, 782, 902, 970, 1070];
  const nav = items.map((t, i) => text(t, xs[i], 44, { fill: c.ink, size: 16 })).join("");
  return `<text x="${X}" y="44" font-family="${FONT}" font-size="18" font-weight="800" letter-spacing="2" fill="${c.ink}">GULI<tspan fill="${c.mute}" font-weight="500" letter-spacing="0"> &amp; </tspan>BATTO</text>${nav}
<rect x="1160" y="22" width="100" height="32" rx="16" fill="none" stroke="${c.ink}" stroke-width="2"/>${text("SYSTEM", 1210, 43, { fill: c.ink, size: 12, weight: 800, anchor: "middle", ls: 1.5 })}`;
}

function footer(c, y) {
  return `<line x1="${X}" y1="${y}" x2="${X + COL}" y2="${y}" stroke="${c.line}"/>
${text("GULI &amp; BATTO", X, y + 36, { fill: c.mute, size: 12, weight: 800, ls: 1.5 })}${text("Inspired by the traditional marble games of Bangladesh.", X, y + 62, { fill: c.mute, size: 14 })}
${text("GAMES", 900, y + 36, { fill: c.mute, size: 12, weight: 800, ls: 1.5 })}${wrap(c, ["Kep", "Batto", "Guli Khela", "Quick Dan"], 900, y + 62, { size: 14, fill: c.mute, gap: 22 })}
${text("MORE", 1100, y + 36, { fill: c.mute, size: 12, weight: 800, ls: 1.5 })}${wrap(c, ["How to play", "Download", "Contact", "Privacy"], 1100, y + 62, { size: 14, fill: c.mute, gap: 22 })}`;
}

const frame = (c, h, body) =>
  `<svg xmlns="http://www.w3.org/2000/svg" width="${WEB_W}" height="${h}" viewBox="0 0 ${WEB_W} ${h}"><rect width="${WEB_W}" height="${h}" fill="${c.ground}"/>${header(c)}${body}${footer(c, h - 150)}</svg>`;

const tile = (c, x, y, kind) => {
  if (kind === "batto")
    return `<polygon points="${x + 80},${y} ${x + 150},${y} ${x + 170},${y + 190} ${x + 60},${y + 190}" fill="${c.earthRim}"/><polygon points="${x + 84},${y + 4} ${x + 146},${y + 4} ${x + 164},${y + 186} ${x + 66},${y + 186}" fill="${c.earth}"/>${[30, 90, 150].map((d, i) => hole(c, x + 115, y + d, "", { rx: 14 + i * 2, ry: 7 })).join("")}${marble(c, x + 115, y + 176, "p1", { r: 7 })}`;
  const stake =
    kind === "guli" || kind === "quick"
      ? [0, 1, 2, 3, 4, 5, 6, 7]
          .map((i) =>
            marble(
              c,
              x + 115 + Math.cos(i * 0.785) * 52,
              y + 90 + Math.sin(i * 0.785) * 52,
              "pot",
              { r: 8 },
            ),
          )
          .join("")
      : marble(c, x + 85, y + 92, "p3", { r: 9 }) + marble(c, x + 148, y + 92, "p2", { r: 9 });
  return `<circle cx="${x + 115}" cy="${y + 95}" r="98" fill="${c.earthRim}"/><circle cx="${x + 115}" cy="${y + 95}" r="93" fill="${c.earth}"/>${hole(c, x + 115, y + 90, "", { rx: 15, ry: 15 })}${stake}<path d="M${x + 60} ${y + 150} H${x + 170}" stroke="${c.ink}" stroke-width="3" stroke-dasharray="10 10"/>${marble(c, x + 115, y + 176, "p1", { r: 9 })}`;
};

export function homeSvg(theme) {
  const c = THEMES[theme];
  const games = [
    ["Kep", "Toss from behind the line at the hole.", "kep"],
    ["Batto", "Everyone tosses at hole 1. The closest goes first.", "batto"],
    ["Guli Khela", "Everyone pays a stake and tosses.", "guli"],
    ["Quick Dan", "One dan of Guli Khela.", "quick"],
  ];
  const facts = [
    ["Offline", "Plays without a connection."],
    ["Real physics", "So every shot can be learned."],
    ["Computers or friends", "Against the computer, or pass the phone."],
    ["Light and dark", "Both themes, drawn for small screens."],
    ["Nothing to sign up for", "No accounts, ads or purchases."],
    ["By one person", "Made from memory, as a child."],
  ];
  const body = `
${text("Line up the shot.", X, 150, { fill: c.ink, size: 56, weight: 800 })}${text("Let the marbles roll.", X, 210, { fill: c.ink, size: 56, weight: 800 })}
${wrap(c, ["A small 3D marble game for your phone and your browser,", "made from the traditional marble games of Bangladesh.", "Four games, no accounts, no ads."], X, 276, { size: 20, fill: c.mute, gap: 30 })}
${pill(c, "DOWNLOAD FOR ANDROID", X, 396, 300)}${text("Play in your browser", X + 332, 433, { fill: c.ink, size: 16, deco: "underline" })}
${arena(c, { cx: 1080, cy: 270, rx: 200, ry: 135 })}${hole(c, 1080, 195, "H3", { rx: 20, ry: 9 })}${hole(c, 1080, 240, "H2", { rx: 20, ry: 9 })}${hole(c, 1080, 285, "H1", { rx: 20, ry: 9 })}${jalla(c, 1080, 360, 105)}${marble(c, 1000, 250, "p2", { r: 13 })}${marble(c, 1170, 225, "p3", { r: 13 })}${marble(c, 1150, 305, "pot", { r: 13 })}${marble(c, 1080, 335, "p1", { r: 15, active: true })}
${h2(c, "How it works", 590)}
${[
  "Aim|Press your marble and pull back, like a slingshot.",
  "Release|A longer pull means more power. Let go and watch.",
  "Read the result|Points are judged once everything has stopped.",
]
  .map((s, i) => {
    const [t, d] = s.split("|");
    return `<circle cx="${X + 18}" cy="${670 + i * 100}" r="18" fill="none" stroke="${c.ink}" stroke-width="2"/>${text(String(i + 1), X + 18, 676 + i * 100, { fill: c.ink, size: 16, weight: 800, anchor: "middle" })}${text(t, X + 56, 668 + i * 100, { fill: c.ink, size: 18, weight: 800 })}${text(d, X + 56, 696 + i * 100, { fill: c.mute, size: 17 })}`;
  })
  .join("")}
<rect x="820" y="620" width="300" height="320" fill="${c.earth}"/><path d="M970 760 V690" stroke="${c.glaze}" stroke-width="3"/><path d="M962 704 L970 688 L978 704 Z" fill="${c.glaze}"/><path d="M970 800 V880" stroke="${c.ink}" stroke-width="2" stroke-dasharray="6 6"/><circle cx="970" cy="880" r="9" fill="${c.mute}"/>${marble(c, 970, 780, "p1", { r: 13 })}${text("pull back", 990, 850, { fill: c.ink, size: 13, weight: 800 })}
${text("Pull back from the marble. It goes the other way.", 820, 966, { fill: c.mute, size: 14 })}
${h2(c, "The four games", 1080)}
${games.map(([n, d, k], i) => `${tile(c, X + i * 275, 1110, k)}${text(n, X + i * 275, 1340, { fill: c.ink, size: 20, weight: 800 })}${wrap(c, words(d, 30), X + i * 275, 1366, { size: 14, fill: c.mute, gap: 19 })}${text("Rules for " + n, X + i * 275, 1416, { fill: c.ink, size: 15, deco: "underline" })}`).join("")}
${h2(c, "The short list", 1500)}
${facts.map(([t, d], i) => `<line x1="${X + (i % 3) * 370}" y1="${1530 + Math.floor(i / 3) * 90}" x2="${X + (i % 3) * 370 + 330}" y2="${1530 + Math.floor(i / 3) * 90}" stroke="${c.ink}" stroke-width="2"/>${text(t, X + (i % 3) * 370, 1560 + Math.floor(i / 3) * 90, { fill: c.ink, size: 17, weight: 800 })}${text(d, X + (i % 3) * 370, 1584 + Math.floor(i / 3) * 90, { fill: c.mute, size: 15 })}`).join("")}`;
  return frame(c, 1900, body);
}

export function gameSvg(theme) {
  const c = THEMES[theme];
  const stake = [0, 1, 2, 3, 4, 5, 6, 7]
    .map((i) =>
      marble(
        c,
        1000 + Math.cos(i * 0.785 + 0.4) * 110,
        270 + Math.sin(i * 0.785 + 0.4) * 110,
        "pot",
        { r: 14, baad: i === 5 },
      ),
    )
    .join("");
  const body = `
${text("THE GAMES", X, 100, { fill: c.mute, size: 12, weight: 800, ls: 1.5 })}${text("Guli Khela", X, 170, { fill: c.ink, size: 62, weight: 800 })}
${wrap(c, ["Every side pays a stake of marbles. The stake is", "scattered round a hole, and everyone but the side", "that scattered it tries to touch exactly one marble,", "and never the one they named as baad."], X, 230, { size: 20, fill: c.mute, gap: 30 })}
${pill(c, "PLAY IN YOUR BROWSER", X, 380, 300)}
<circle cx="1000" cy="270" r="190" fill="${c.earthRim}"/><circle cx="1000" cy="270" r="184" fill="${c.earth}"/>${hole(c, 1000, 270, "", { rx: 30, ry: 30 })}${stake}<path d="M900 400 H1100" stroke="${c.ink}" stroke-width="3" stroke-dasharray="12 12"/>${marble(c, 1000, 440, "p1", { r: 14, active: true })}
${text("A dan", X, 560, { fill: c.ink, size: 32, weight: 800 })}
${[
  "Each side pays the stake, and every side tosses once.",
  "The closest toss is the scatterer. The stake is set down.",
  "Every other side names a baad, then throws once.",
  "When the throw has stopped, it is judged.",
]
  .map(
    (t, i) =>
      `<circle cx="${X + 16}" cy="${612 + i * 52}" r="15" fill="none" stroke="${c.ink}" stroke-width="2"/>${text(String(i + 1), X + 16, 618 + i * 52, { fill: c.ink, size: 14, weight: 800, anchor: "middle" })}${text(t, X + 48, 618 + i * 52, { fill: c.ink, size: 17 })}`,
  )
  .join("")}
${text("What an attempt can do", X, 860, { fill: c.ink, size: 32, weight: 800 })}
${wrap(c, ["• It touches one marble, not the baad: you win the dan.", "• It touches the baad or two marbles: you pay a fine.", "• It touches nothing: the attempt is over."], X, 906, { size: 17, gap: 32 })}
<line x1="880" y1="580" x2="880" y2="1000" stroke="${c.line}" stroke-width="2"/>
${text("AT A GLANCE", 910, 600, { fill: c.mute, size: 12, weight: 800, ls: 1.5 })}${wrap(c, ["• Everyone pays a stake and tosses.", "• Tap the baad, then throw.", "• Touch exactly one other marble", "  to win the ground.", "• Touch the baad: a fine."], 910, 636, { size: 16, gap: 28 })}
${text("THE OTHER GAMES", 910, 820, { fill: c.mute, size: 12, weight: 800, ls: 1.5 })}${wrap(c, ["Kep", "Batto", "Quick Dan"], 910, 852, { size: 16, gap: 28 })}`;
  return frame(c, 1230, body);
}

const qr = (c, x, y, s) => {
  let o = `<rect x="${x}" y="${y}" width="${s}" height="${s}" rx="8" fill="${c.bone}"/>`;
  const n = 21,
    m = (s - 24) / n;
  const finder = (fx, fy) =>
    `<rect x="${x + 12 + fx * m}" y="${y + 12 + fy * m}" width="${7 * m}" height="${7 * m}" fill="${c.hole}"/><rect x="${x + 12 + (fx + 1) * m}" y="${y + 12 + (fy + 1) * m}" width="${5 * m}" height="${5 * m}" fill="${c.bone}"/><rect x="${x + 12 + (fx + 2) * m}" y="${y + 12 + (fy + 2) * m}" width="${3 * m}" height="${3 * m}" fill="${c.hole}"/>`;
  o += finder(0, 0) + finder(14, 0) + finder(0, 14);
  for (let i = 0; i < n; i++)
    for (let j = 0; j < n; j++) {
      const inFinder = (i < 8 && j < 8) || (i > 12 && j < 8) || (i < 8 && j > 12);
      if (!inFinder && (i * 7 + j * 13 + i * j) % 3 === 0)
        o += `<rect x="${x + 12 + i * m}" y="${y + 12 + j * m}" width="${m}" height="${m}" fill="${c.hole}"/>`;
    }
  return o;
};

export function downloadSvg(theme) {
  const c = THEMES[theme];
  const row = (k, v, y) =>
    `${text(k, X + 28, y, { fill: c.mute, size: 14 })}${text(v, X + 120, y, { fill: c.ink, size: 16 })}`;
  const body = `
${text("Download", X, 150, { fill: c.ink, size: 62, weight: 800 })}${text("Version 0.0.1 for Android (29 MB).", X, 196, { fill: c.mute, size: 20 })}
${pill(c, "DOWNLOAD APK", X, 226, 240)}${text("Release notes", X + 270, 263, { fill: c.ink, size: 16, deco: "underline" })}
${text("64-bit ARM. A direct download, not a store build.", X, 322, { fill: c.mute, size: 14 })}
${text("On another device", X, 372, { fill: c.ink, size: 22, weight: 800 })}${qr(c, X, 392, 168)}${wrap(c, ["Scan this with a phone camera to open", "this page on it, then download the app."], X + 190, 470, { size: 14, fill: c.mute, gap: 22 })}
<rect x="${X}" y="590" width="510" height="260" rx="18" fill="none" stroke="${c.ink}" stroke-width="2"/>${text("About this APK", X + 26, 630, { fill: c.ink, size: 18, weight: 800 })}${row("File", "gulibatto-0.0.1.apk", 668)}${row("Version", "0.0.1", 700)}${row("Size", "29 MB", 732)}${row("SHA-256", "f07be7d39824eef00724d8a5ce61d29e…", 764)}${text("shasum -a 256 gulibatto-0.0.1.apk", X + 26, 818, { fill: c.ink, size: 13 })}
<line x1="780" y1="170" x2="780" y2="860" stroke="${c.line}" stroke-width="2"/>
${text("Install", 810, 210, { fill: c.ink, size: 32, weight: 800 })}
${[
  "Download the file|Do it on your phone, from this page.",
  "Open it|Android asks once to allow installs from your browser.",
  "Open Guli &amp; Batto|Press Play, choose a game, and drag back.",
]
  .map((s, i) => {
    const [t, d] = s.split("|");
    return `<circle cx="828" cy="${262 + i * 84}" r="18" fill="none" stroke="${c.ink}" stroke-width="2"/>${text(String(i + 1), 828, 268 + i * 84, { fill: c.ink, size: 15, weight: 800, anchor: "middle" })}${text(t, 864, 262 + i * 84, { fill: c.ink, size: 18, weight: 800 })}${text(d, 864, 288 + i * 84, { fill: c.mute, size: 15 })}`;
  })
  .join("")}
${text("Good to know", 810, 540, { fill: c.ink, size: 32, weight: 800 })}${wrap(c, ["• It is not on Google Play and not available for iPhone.", "• Every build is signed with the same key.", "• It collects nothing."], 810, 590, { size: 16, gap: 30 })}`;
  return frame(c, 1030, body);
}
