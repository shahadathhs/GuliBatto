import { THEMES } from "./tokens.mjs";
import { MORE } from "./screens_more.mjs";
import {
  text,
  marble,
  arena,
  hole,
  jalla,
  routeChips,
  iconButton,
  primaryDisc,
  outlineButton,
  textAction,
  hud,
  cameraBar,
  wordmark,
  FONT,
} from "./parts.mjs";

export const W = 390,
  H = 844;

const ground = (c, o = {}) => arena(c, { cy: 420, rx: 178, ry: 140, ...o });
const banner = (c, label, y = 590, w = 310) =>
  `<rect x="${(W - w) / 2}" y="${y}" width="${w}" height="62" rx="16" fill="${c.ink}"/>${text(label, 195, y + 38, { fill: c.ground, size: label.length > 24 ? 14 : 16, weight: 800, anchor: "middle", ls: 1 })}`;
const mini = (c, kind) => {
  const base = `<ellipse cx="320" cy="${kind.y}" rx="40" ry="26" fill="${c.earth}" stroke="${c.ink}" stroke-width="1.5"/>`;
  const holes = {
    kep:
      hole(c, 320, kind.y - 6, "", { rx: 9, ry: 5 }) + marble(c, 304, kind.y + 8, "p1", { r: 6 }),
    batto: [kind.y - 12, kind.y - 2, kind.y + 8]
      .map((y) => hole(c, 320, y, "", { rx: 8, ry: 4 }))
      .join(""),
    guli:
      hole(c, 320, kind.y - 4, "", { rx: 9, ry: 5 }) +
      [
        [304, kind.y - 8],
        [336, kind.y - 6],
        [310, kind.y + 10],
        [330, kind.y + 10],
      ]
        .map(([x, y]) => marble(c, x, y, "pot", { r: 5 }))
        .join(""),
  };
  return base + holes[kind.type];
};

// Batto's board: long and narrow, seen from behind the line, with three deep holes four marbles wide.
const battoBoard = (
  c,
) => `<polygon points="120,236 270,236 346,574 44,574" fill="${c.earthRim}"/><polygon points="126,240 264,240 336,566 54,566" fill="${c.earth}"/>
${hole(c, 195, 290, "H3", { rx: 22, ry: 8 })}${hole(c, 195, 392, "H2", { rx: 26, ry: 10 })}${hole(c, 195, 494, "H1", { rx: 30, ry: 12 })}${jalla(c, 195, 556, 90)}`;

const SCREENS = [
  [
    "01-menu",
    "Menu",
    (c) => `${wordmark(c, 195, 150, 38)}
${text("MARBLE GAMES FROM CHILDHOOD", 195, 184, { fill: c.mute, size: 11, weight: 700, anchor: "middle", ls: 2.5 })}
${ground(c)}${hole(c, 195, 360, "")}${jalla(c, 195, 500)}${marble(c, 150, 400, "pot")}${marble(c, 240, 390, "pot")}${marble(c, 195, 470, "p1", { r: 14, active: true })}
${primaryDisc(c, "PLAY", 195, 690, 52)}
${textAction(c, "How to play", 75, 800)}${textAction(c, "About", 195, 800)}${textAction(c, "Settings", 315, 800)}`,
  ],
  [
    "02-modes",
    "Mode select",
    (c) => {
      const row = (
        y,
        name,
        line,
        kind,
        sel,
      ) => `<rect x="24" y="${y}" width="342" height="112" rx="18" fill="${c.ground}" stroke="${sel ? c.ink : c.line}" stroke-width="${sel ? 4 : 2}"/>
${text(name, 44, y + 40, { fill: c.ink, size: 21, weight: 800, ls: 1 })}${text(line, 44, y + 70, { fill: c.mute, size: 14 })}
${mini(c, { ...kind, y: y + 56 })}${textAction(c, "Rules", 330, y + 100)}${sel ? `<circle cx="344" cy="${y + 22}" r="14" fill="${c.ink}"/><path d="M337 ${y + 22} L342 ${y + 28} L352 ${y + 16}" fill="none" stroke="${c.ground}" stroke-width="3"/>` : ""}`;
      return `${iconButton(c, "back", 40, 88)}${text("CHOOSE A MODE", 80, 94, { fill: c.ink, size: 20, weight: 800, ls: 1.5 })}
${row(130, "KEP", "Toss at the hole. Closest scores.", { type: "kep" }, false)}
${row(254, "BATTO", "Race three holes and back.", { type: "batto" }, false)}
${row(378, "GULI KHELA", "Name the baad. Touch one marble.", { type: "guli" }, true)}
${row(502, "QUICK DAN", "One round of Guli Khela.", { type: "guli" }, false)}
${textAction(c, "About these games", 195, 660)}
${primaryDisc(c, "START", 195, 735, 48)}`;
    },
  ],
  [
    "03-about",
    "About these games",
    (
      c,
    ) => `${iconButton(c, "back", 40, 88)}${text("ABOUT THESE GAMES", 80, 94, { fill: c.ink, size: 20, weight: 800, ls: 1.5 })}
<foreignObject x="24" y="130" width="342" height="660"><div xmlns="http://www.w3.org/1999/xhtml" style="font-family:${FONT};color:${c.ink};font-size:15px;line-height:1.5">
<p style="margin:0 0 4px;font-weight:800;letter-spacing:1px;font-size:12px;color:${c.mute}">CHILDHOOD GAMES</p>
<p style="margin:0 0 14px">I grew up playing marble games on bare ground: a line, a small hole, a handful of marbles, and no rulebook. I made this game to bring those afternoons back.</p>
<p style="margin:0 0 4px;font-weight:800;letter-spacing:1px;font-size:12px;color:${c.mute}">WHERE THE RULES COME FROM</p>
<p style="margin:0 0 14px">Nothing here is invented from nothing. Each mode starts with a game people played: the toss at the hole, the three-hole race, and the game of the line, the hole and the marble you must not touch.</p>
<p style="margin:0 0 4px;font-weight:800;letter-spacing:1px;font-size:12px;color:${c.mute}">WHAT I CHANGED</p>
<p style="margin:0 0 14px">I changed some rules to work on a phone. Those are my decisions, not the tradition's.</p>
<p style="margin:0 0 4px;font-weight:800;letter-spacing:1px;font-size:12px;color:${c.mute}">WHAT THIS IS NOT</p>
<p style="margin:0">It is not an official rulebook. If you remember it differently, you are not wrong.</p>
</div></foreignObject>
${textAction(c, "Tell me how you played", 195, 800)}`,
  ],
  [
    "04-first-use",
    "First-use prompt",
    (c) => `${hud(c, "Kep · round 1 of 5", "Your turn", "p1", [
      ["p1", "YOU", 0],
      ["p2", "", 0],
      ["p3", "", 0],
    ])}
${ground(c)}${hole(c, 195, 345, "")}${jalla(c, 195, 500)}${marble(c, 195, 470, "p1", { r: 14, active: true })}
<path d="M195 495 L195 565" stroke="${c.ink}" stroke-width="3" stroke-dasharray="3 8" stroke-linecap="round"/>
<rect x="40" y="600" width="310" height="116" rx="16" fill="${c.ink}"/>
${text("PULL BACK, THEN RELEASE", 195, 636, { fill: c.ground, size: 15, weight: 800, anchor: "middle", ls: 1.5 })}
${text("Drag away from where you want", 195, 664, { fill: c.ground, size: 14, anchor: "middle" })}${text("the marble to go. Longer pull, more power.", 195, 684, { fill: c.ground, size: 14, anchor: "middle" })}
${textAction(c, "Got it", 195, 800)}`,
  ],
  [
    "05-kep-ready",
    "Kep, your toss",
    (c) => `${hud(c, "Kep · round 2 of 5", "Your toss", "p1", [
      ["p1", "YOU", 3],
      ["p2", "", 5],
      ["p3", "", 1],
    ])}
${ground(c)}${hole(c, 195, 345, "")}${jalla(c, 195, 500)}
${marble(c, 160, 372, "p2")}${marble(c, 238, 395, "p3")}${marble(c, 195, 470, "p1", { r: 14, active: true })}
${text("Toss from behind the line", 195, 600, { fill: c.mute, size: 14, anchor: "middle" })}
${cameraBar(c, "angled")}`,
  ],
  [
    "06-kep-result",
    "Kep, round result",
    (c) => {
      const r = (y, kind, label, pts) =>
        `${marble(c, 60, y - 6, kind, { r: 12 })}${text(label, 90, y, { fill: c.ink, size: 17, weight: 700 })}${text(pts, 340, y, { fill: c.ink, size: 20, weight: 800, anchor: "end" })}<line x1="24" y1="${y + 22}" x2="366" y2="${y + 22}" stroke="${c.line}" stroke-opacity="0.4"/>`;
      return `${text("ROUND 2 OF 5", 195, 130, { fill: c.mute, size: 13, weight: 800, anchor: "middle", ls: 3 })}
${text("RESULT", 195, 176, { fill: c.ink, size: 30, weight: 800, anchor: "middle", ls: 3 })}
${r(260, "p2", "IN THE KEP", "+3")}${r(330, "p1", "YOU · 2nd", "+1")}${r(400, "p3", "Third", "0")}
${text("TOTAL  YOU 4 · 8 · 1", 195, 490, { fill: c.mute, size: 14, weight: 700, anchor: "middle", ls: 1 })}
${primaryDisc(c, "NEXT", 195, 630, 52)}${textAction(c, "Surrender", 195, 790)}`;
    },
  ],
  [
    "07-batto-ready",
    "Batto, your turn",
    (c) => `${hud(c, "Batto · leg 2 of 5", "Your turn", "p1", [
      ["p1", "YOU", "H2"],
      ["p2", "", "H1"],
      ["p3", "", "H3"],
    ])}
${routeChips(c, 1)}
${battoBoard(c)}
${marble(c, 140, 410, "p2", { r: 9 })}${marble(c, 250, 330, "p3", { r: 9 })}${marble(c, 200, 520, "p1", { r: 11, active: true })}
${cameraBar(c, "angled")}`,
  ],
  [
    "08-batto-hit",
    "Batto, hit and bonus shot",
    (c) => `${hud(c, "Batto · leg 2 of 5", "Your turn", "p1", [
      ["p1", "YOU", "H2"],
      ["p2", "", "H1"],
      ["p3", "", "H3"],
    ])}
${routeChips(c, 1)}
${battoBoard(c)}
<path d="M205 515 L252 345" stroke="${c.glaze}" stroke-width="3" stroke-dasharray="2 8" stroke-linecap="round"/>
${marble(c, 262, 322, "p2", { r: 9 })}${marble(c, 250, 345, "p3", { r: 9 })}${marble(c, 200, 520, "p1", { r: 11, active: true })}
${banner(c, "HIT · ONE MORE SHOT", 600)}${cameraBar(c, "angled")}`,
  ],
  [
    "09-batto-over",
    "Batto, finishing order",
    (c) => {
      const r = (y, n, kind, label, note) =>
        `${text(String(n), 40, y + 8, { fill: n === 4 ? c.mute : c.ink, size: 34, weight: 800 })}${marble(c, 104, y, kind, { r: 14 })}${text(label, 134, y + 6, { fill: c.ink, size: 18, weight: 800, ls: 1 })}${text(note, 366, y + 6, { fill: c.mute, size: 13, weight: 700, anchor: "end", ls: 1 })}<line x1="24" y1="${y + 30}" x2="366" y2="${y + 30}" stroke="${c.line}" stroke-opacity="0.4"/>`;
      return `${text("MATCH OVER", 195, 130, { fill: c.mute, size: 14, weight: 800, anchor: "middle", ls: 3 })}
${text("YOU WON", 195, 190, { fill: c.ink, size: 36, weight: 800, anchor: "middle", ls: 2 })}
${r(280, 1, "p1", "YOU", "FINISHED")}${r(350, 2, "p3", "", "FINISHED")}${r(420, 3, "p2", "", "FINISHED")}${r(490, 4, "p4", "", "LAST ON THE ROUTE")}
${primaryDisc(c, "REMATCH", 195, 620, 56)}${outlineButton(c, "MODES", 195, 730, 220)}${textAction(c, "Menu", 195, 800)}`;
    },
  ],
  [
    "10-guli-baad",
    "Guli Khela, name the baad",
    (c) => `${hud(c, "Guli Khela · dan 3", "Name the baad", "p1", [
      ["p1", "YOU", 8],
      ["p2", "", 11],
      ["p3", "", 9],
    ])}
${text("POT 9", 330, 138, { fill: c.mute, size: 13, weight: 800, anchor: "end", ls: 1 })}
${ground(c)}${hole(c, 195, 350, "")}${jalla(c, 195, 510)}
${[
  [165, 330],
  [225, 332],
  [150, 372],
  [240, 372],
  [195, 395],
  [175, 420],
  [220, 424],
]
  .map(([x, y]) => marble(c, x, y, "pot", { r: 11 }))
  .join("")}
${marble(c, 195, 478, "p1", { r: 14, active: true })}
${banner(c, "TAP THE BAAD MARBLE", 600)}
${text("The one you must not touch", 195, 690, { fill: c.mute, size: 14, anchor: "middle" })}`,
  ],
  [
    "11-guli-aim",
    "Guli Khela, aiming",
    (c) => `${hud(c, "Guli Khela · dan 3", "Aim", "p1", [
      ["p1", "YOU", 8],
      ["p2", "", 11],
      ["p3", "", 9],
    ])}
${text("POT 9", 330, 138, { fill: c.mute, size: 13, weight: 800, anchor: "end", ls: 1 })}
${ground(c)}${hole(c, 195, 350, "")}${jalla(c, 195, 510)}
${[
  [165, 330],
  [225, 332],
  [150, 372],
  [240, 372],
  [175, 420],
  [220, 424],
]
  .map(([x, y]) => marble(c, x, y, "pot", { r: 11 }))
  .join("")}
${marble(c, 195, 395, "pot", { r: 11, baad: true })}
<path d="M195 525 L195 600" stroke="${c.ink}" stroke-width="3" stroke-dasharray="3 8" stroke-linecap="round"/><circle cx="195" cy="600" r="9" fill="none" stroke="${c.ink}" stroke-width="2"/>
<path d="M186 470 L172 420" stroke="${c.glaze}" stroke-width="6" stroke-linecap="round"/><path d="M158 436 L168 412 L182 434 Z" fill="${c.glaze}"/>
${marble(c, 195, 478, "p1", { r: 14, active: true })}
<rect x="95" y="650" width="200" height="14" rx="7" fill="none" stroke="${c.ink}" stroke-width="2"/><rect x="95" y="650" width="120" height="14" rx="7" fill="${c.glaze}"/>
${text("POWER 60%", 195, 692, { fill: c.ink, size: 14, weight: 800, anchor: "middle", ls: 1.5 })}
${textAction(c, "Cancel", 195, 800)}`,
  ],
  [
    "12-guli-fine",
    "Guli Khela, fine",
    (c) => `${hud(c, "Guli Khela · dan 3", "Next side", "p2", [
      ["p1", "YOU", 7],
      ["p2", "", 11],
      ["p3", "", 9],
    ])}
${text("POT 10", 330, 138, { fill: c.mute, size: 13, weight: 800, anchor: "end", ls: 1 })}
${ground(c)}${hole(c, 195, 350, "")}${jalla(c, 195, 510)}
${[
  [165, 330],
  [225, 332],
  [150, 372],
  [240, 372],
  [175, 420],
  [220, 424],
]
  .map(([x, y]) => marble(c, x, y, "pot", { r: 11 }))
  .join("")}
${marble(c, 195, 395, "pot", { r: 11, baad: true })}${marble(c, 195, 436, "p1", { r: 14 })}${marble(c, 262, 410, "pot", { r: 11 })}
${banner(c, "FINE · TOUCHED THE BAAD MARBLE", 600, 340)}
${text("You add one marble to the pot", 195, 690, { fill: c.mute, size: 14, anchor: "middle" })}`,
  ],
  [
    "13-guli-dan-won",
    "Guli Khela, dan won",
    (c) => {
      const r = (y, kind, label, n, d) =>
        `${marble(c, 60, y - 6, kind, { r: 12 })}${text(label, 90, y, { fill: c.ink, size: 17, weight: 700 })}${text(String(n), 300, y, { fill: c.ink, size: 20, weight: 800, anchor: "end" })}${text(d, 350, y, { fill: c.mute, size: 14, weight: 700, anchor: "end" })}<line x1="24" y1="${y + 22}" x2="366" y2="${y + 22}" stroke="${c.line}" stroke-opacity="0.4"/>`;
      return `${text("DAN 3", 195, 130, { fill: c.mute, size: 13, weight: 800, anchor: "middle", ls: 3 })}
${text("DAN WON", 195, 190, { fill: c.ink, size: 36, weight: 800, anchor: "middle", ls: 2 })}
${text("You take the 10 marbles on the ground", 195, 226, { fill: c.mute, size: 15, anchor: "middle" })}
${r(300, "p1", "YOU", 15, "+7")}${r(370, "p2", "", 8, "−3")}${r(440, "p3", "", 6, "−3")}
${primaryDisc(c, "NEXT DAN", 195, 600, 56)}${textAction(c, "Surrender", 195, 760)}`;
    },
  ],
];

const ALL = [...SCREENS, ...MORE].sort((a, b) => a[0].localeCompare(b[0]));

export const screenSvg = (id, theme) => {
  const c = THEMES[theme];
  const s = ALL.find(([i]) => i === id);
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}"><rect width="${W}" height="${H}" fill="${c.ground}"/>${s[2](c)}</svg>`;
};
export const screenList = ALL.map(([id, name]) => ({ id, name }));
export const screenBody = (id, theme) => ALL.find(([i]) => i === id)[2](THEMES[theme]);

// Camera views of the same Batto board: angled, top-down, low.
export const viewsSvg = (theme) => {
  const c = THEMES[theme];
  const pane = (x, label, body) =>
    `<g transform="translate(${x},0)"><rect x="0" y="0" width="390" height="520" fill="${c.ground}"/>${text(label, 195, 40, { fill: c.ink, size: 16, weight: 800, anchor: "middle", ls: 2 })}${body}</g>`;
  const disc = (x, y, k) =>
    `<circle cx="${x}" cy="${y}" r="12" fill="${{ p1: c.glaze, p2: c.amber, p3: c.jade }[k]}" stroke="${c.ink}" stroke-width="1.5"/>`;
  const top = `<circle cx="195" cy="270" r="150" fill="${c.earthRim}"/><circle cx="195" cy="270" r="143" fill="${c.earth}"/>${[190, 270, 350].map((y) => `<ellipse cx="195" cy="${y}" rx="16" ry="16" fill="${c.hole}"/>`).join("")}<path d="M110 440 H280" stroke="${c.ink}" stroke-opacity="0.6" stroke-width="3" stroke-dasharray="10 7"/>${disc(130, 290, "p2")}${disc(265, 230, "p3")}${disc(205, 420, "p1")}`;
  const low = `<rect x="0" y="260" width="390" height="260" fill="${c.earth}"/><rect x="0" y="250" width="390" height="14" fill="${c.earthRim}"/>${marble(c, 110, 340, "p2", { r: 26 })}${marble(c, 300, 330, "p3", { r: 26 })}${marble(c, 200, 440, "p1", { r: 34 })}`;
  const ang = `<g transform="translate(0,-60)">${battoBoard(c)}${marble(c, 140, 410, "p2", { r: 9 })}${marble(c, 250, 330, "p3", { r: 9 })}${marble(c, 200, 520, "p1", { r: 11, active: true })}</g>`;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1170" height="520" viewBox="0 0 1170 520">${pane(0, "ANGLED", ang)}${pane(390, "TOP-DOWN", top)}${pane(780, "LOW", low)}</svg>`;
};
