// The settings, pause, rules, how-to-play and play-mode screens of the concept renders.
import {
  text,
  marble,
  hole,
  jalla,
  iconButton,
  primaryDisc,
  outlineButton,
  textAction,
  hud,
  arena,
} from "./parts.mjs";

const lines = (c, rows, x, y, o = {}) =>
  rows
    .map((t, i) => text(t, x, y + i * (o.gap ?? 24), { fill: o.fill ?? c.ink, size: o.size ?? 16 }))
    .join("");
const header = (c, title) =>
  `${iconButton(c, "back", 40, 88)}${text(title, 80, 94, { fill: c.ink, size: 20, weight: 800, ls: 1.5 })}`;
const choice = (c, x, y, w, label, on) =>
  `<rect x="${x}" y="${y}" width="${w}" height="44" rx="14" fill="${on ? c.ink : c.ground}" stroke="${on ? c.ink : c.line}" stroke-width="2"/>${text(label, x + w / 2, y + 28, { fill: on ? c.ground : c.ink, size: 13, weight: 800, anchor: "middle", ls: 1 })}`;
const stepper = (c, x, y, n) =>
  `<circle cx="${x}" cy="${y}" r="18" fill="none" stroke="${c.ink}" stroke-width="2"/>${text("−", x, y + 7, { fill: c.ink, size: 22, weight: 700, anchor: "middle" })}${text(String(n), x + 46, y + 9, { fill: c.ink, size: 26, weight: 800, anchor: "middle" })}<circle cx="${x + 92}" cy="${y}" r="18" fill="none" stroke="${c.ink}" stroke-width="2"/>${text("+", x + 92, y + 7, { fill: c.ink, size: 22, weight: 700, anchor: "middle" })}`;

const settings = (c) => `${header(c, "SETTINGS")}
${text("Theme", 24, 160, { fill: c.ink, size: 17, weight: 800 })}${choice(c, 24, 176, 106, "SYSTEM", true)}${choice(c, 142, 176, 106, "LIGHT", false)}${choice(c, 260, 176, 106, "DARK", false)}
${text("Sound", 24, 262, { fill: c.ink, size: 17, weight: 800 })}${choice(c, 24, 278, 163, "ON", true)}${choice(c, 203, 278, 163, "OFF", false)}
${text("Volume", 24, 364, { fill: c.ink, size: 17, weight: 800 })}${choice(c, 24, 380, 106, "LOW", false)}${choice(c, 142, 380, 106, "MEDIUM", true)}${choice(c, 260, 380, 106, "HIGH", false)}
${text("Follow shots", 24, 466, { fill: c.ink, size: 17, weight: 800 })}${text("The camera follows a shot while it rolls.", 24, 490, { fill: c.mute, size: 14 })}${text("Tap to skip it for one shot.", 24, 510, { fill: c.mute, size: 14 })}${choice(c, 24, 528, 163, "ON", true)}${choice(c, 203, 528, 163, "OFF", false)}
${outlineButton(c, "Reset to defaults", 195, 680, 240)}`;

const pause = (
  c,
) => `${text("PAUSED", 195, 180, { fill: c.ink, size: 30, weight: 800, anchor: "middle", ls: 3 })}
${primaryDisc(c, "RESUME", 195, 330, 56)}
${outlineButton(c, "RESTART", 195, 470, 220)}${outlineButton(c, "SURRENDER", 195, 540, 220)}${textAction(c, "Back to menu", 195, 640)}`;

const card = (
  c,
  y,
  h,
  on,
  title,
  sub,
  kinds,
  count,
) => `<rect x="24" y="${y}" width="342" height="${h}" rx="18" fill="${c.ground}" stroke="${on ? c.ink : c.line}" stroke-width="${on ? 4 : 2}"/>
${text(title, 44, y + 40, { fill: c.ink, size: 19, weight: 800, ls: 1 })}${text(sub, 44, y + 66, { fill: c.mute, size: 14 })}
${kinds.map((k, i) => marble(c, 52 + i * 34, y + 104, k, { r: 11 })).join("")}${stepper(c, 236, y + 104, count)}`;

const whoPlays = (c) => `${header(c, "WHO PLAYS?")}
${card(c, 140, 160, true, "AGAINST THE COMPUTER", "You and the computer sides", ["p1", "p2", "p3"], 2)}
${card(c, 324, 160, false, "PASS AND PLAY", "Hand the device round", ["p1", "p2", "p3", "p4", "p5"], 4)}
${text("Computers: 1 to 3. People: 2 to 5.", 195, 540, { fill: c.mute, size: 14, anchor: "middle" })}
${primaryDisc(c, "PLAY", 195, 660, 52)}`;

const passTo = (
  c,
) => `${text("KEP · ROUND 2 OF 5", 195, 120, { fill: c.mute, size: 12, weight: 800, anchor: "middle", ls: 2.5 })}
${text("PASS TO", 195, 250, { fill: c.mute, size: 15, weight: 800, anchor: "middle", ls: 4 })}
${marble(c, 195, 360, "p2", { r: 52, active: true })}
${text("AMBER", 195, 500, { fill: c.ink, size: 44, weight: 800, anchor: "middle", ls: 3 })}
${text("The amber side shoots next.", 195, 540, { fill: c.mute, size: 15, anchor: "middle" })}
${primaryDisc(c, "READY", 195, 660, 52)}`;

const kepFive = (c) => `${hud(c, "Kep · round 2 of 5", "Rose's toss", "p5", [
  ["p1", "", 3],
  ["p2", "", 2],
  ["p3", "", 1],
  ["p4", "", 0],
  ["p5", "", 0],
])}
${arena(c, { cy: 420, rx: 178, ry: 140 })}${hole(c, 195, 360, "", { rx: 22, ry: 11 })}${jalla(c, 195, 500)}
${marble(c, 160, 375, "p2")}${marble(c, 236, 390, "p3")}${marble(c, 195, 345, "p1")}${marble(c, 210, 430, "p4")}
${marble(c, 195, 470, "p5", { r: 14, active: true })}
${iconButton(c, "angled", 60, 790, true)}${iconButton(c, "top", 120, 790)}${iconButton(c, "low", 180, 790)}${iconButton(c, "reset", 330, 790)}`;

const rulesCard = (
  c,
) => `<rect x="24" y="120" width="342" height="610" rx="20" fill="${c.ground}" stroke="${c.ink}" stroke-width="3"/>
${text("KEP", 195, 176, { fill: c.ink, size: 26, weight: 800, anchor: "middle", ls: 3 })}
<circle cx="195" cy="300" r="96" fill="${c.earthRim}"/><circle cx="195" cy="300" r="91" fill="${c.earth}"/>
${hole(c, 195, 270, "", { rx: 16, ry: 16 })}<path d="M130 345 H260" stroke="${c.ink}" stroke-width="3" stroke-dasharray="12 12"/>
${marble(c, 195, 375, "p1", { r: 11 })}
${lines(c, ["Toss from behind the line at the hole.", "In the hole scores 3, closest 2, next 1.", "Five rounds. The highest total wins."], 48, 460, { size: 16, gap: 32 })}
${primaryDisc(c, "PLAY", 195, 640, 48)}`;

const howToPlay = (c) => `${header(c, "HOW TO PLAY")}
${text("Taking a shot", 24, 170, { fill: c.ink, size: 24, weight: 800 })}
${[
  "Press your marble. A ring shows it is your turn.",
  "Drag back, away from where you want it to go.",
  "A short arrow shows the direction and a bar the power.",
  "Release to shoot, or pull back to the start to cancel.",
]
  .map((t, i) => {
    const cut = t.lastIndexOf(" ", 38);
    const [one, two] = t.length > 40 ? [t.slice(0, cut), t.slice(cut + 1)] : [t, ""];
    return `<circle cx="38" cy="${208 + i * 56}" r="14" fill="none" stroke="${c.ink}" stroke-width="2"/>${text(String(i + 1), 38, 213 + i * 56, { fill: c.ink, size: 13, weight: 800, anchor: "middle" })}${text(one, 66, 208 + i * 56, { fill: c.ink, size: 14 })}${text(two, 66, 227 + i * 56, { fill: c.ink, size: 14 })}`;
  })
  .join("")}
<rect x="24" y="450" width="342" height="250" fill="${c.earth}"/>
<path d="M195 560 V500" stroke="${c.glaze}" stroke-width="3"/><path d="M188 512 L195 498 L202 512 Z" fill="${c.glaze}"/>
<path d="M195 590 V650" stroke="${c.ink}" stroke-width="2" stroke-dasharray="6 6"/><circle cx="195" cy="650" r="9" fill="${c.mute}"/>
${marble(c, 195, 580, "p1", { r: 13 })}${text("it goes this way", 40, 520, { fill: c.ink, size: 13, weight: 800 })}${text("pull back", 215, 625, { fill: c.ink, size: 13, weight: 800 })}`;

export const MORE = [
  ["14-pause", "Pause", pause],
  ["15-settings", "Settings", settings],
  ["17-who-plays", "Who plays?", whoPlays],
  ["18-pass-to", "Pass to a side", passTo],
  ["19-kep-five", "Kep, five sides", kepFive],
  ["20-rules-card", "Rules card", rulesCard],
  ["21-how-to-play", "How to play", howToPlay],
];
