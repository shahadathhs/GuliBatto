// Small SVG building blocks for the concept renders.
export const FONT = "'Avenir Next','Helvetica Neue',Arial,sans-serif";

export const text = (t, x, y, o = {}) =>
  `<text x="${x}" y="${y}" font-family="${FONT}" font-size="${o.size ?? 16}" font-weight="${o.weight ?? 500}" fill="${o.fill}" text-anchor="${o.anchor ?? "start"}" letter-spacing="${o.ls ?? 0}"${o.deco ? ` text-decoration="${o.deco}"` : ""}>${t}</text>`;

// Sides: p1 blue ring, p2 amber dot, p3 jade bar, p4 plum triangle, p5 rose diamond; pot = bone with an ink bar (stake marbles).
export function marble(c, x, y, kind, o = {}) {
  const r = o.r ?? 12;
  const fill = { p1: c.glaze, p2: c.amber, p3: c.jade, p4: c.plum, p5: c.rose, pot: c.bone }[kind];
  const mk = { p1: c.onGlaze, p2: c.onAmber, p3: c.onJade, p4: c.onPlum, p5: c.onRose }[kind];
  let m = "";
  if (kind === "p1")
    m = `<circle cx="${x}" cy="${y}" r="${r * 0.48}" fill="none" stroke="${mk}" stroke-width="${Math.max(1.5, r / 6)}"/>`;
  if (kind === "p2") m = `<circle cx="${x}" cy="${y}" r="${r * 0.24}" fill="${mk}"/>`;
  if (kind === "p3")
    m = `<rect x="${x - r * 0.5}" y="${y - r * 0.12}" width="${r}" height="${r * 0.24}" fill="${mk}"/>`;
  if (kind === "p4")
    m = `<polygon points="${x},${y - r * 0.5} ${x + r * 0.5},${y + r * 0.38} ${x - r * 0.5},${y + r * 0.38}" fill="${mk}"/>`;
  if (kind === "p5")
    m = `<polygon points="${x},${y - r * 0.5} ${x + r * 0.42},${y} ${x},${y + r * 0.5} ${x - r * 0.42},${y}" fill="${mk}"/>`;
  if (kind === "pot")
    m = `<rect x="${x - r * 0.5}" y="${y - r * 0.12}" width="${r}" height="${r * 0.24}" fill="${c.ink}"/>`;
  const ring =
    o.active || o.striker
      ? `<ellipse cx="${x}" cy="${y + r * 0.7}" rx="${r * 1.55}" ry="${r * 0.62}" fill="none" stroke="${o.ringColor ?? c.ink}" stroke-width="3"/>`
      : "";
  const baad = o.baad
    ? `<g stroke="${c.ink}" stroke-width="2.5" stroke-linecap="round"><path d="M${x - r * 0.7} ${y + r * 1.15} L${x + r * 0.7} ${y + r * 1.85}"/><path d="M${x + r * 0.7} ${y + r * 1.15} L${x - r * 0.7} ${y + r * 1.85}"/></g>`
    : "";
  return `${ring}${baad}<ellipse cx="${x + r * 0.2}" cy="${y + r * 0.85}" rx="${r * 0.95}" ry="${r * 0.36}" fill="${c.shadow}"/>
<circle cx="${x}" cy="${y}" r="${r}" fill="${fill}" stroke="${c.ink}" stroke-width="1.5"/>${m}
<circle cx="${x - r * 0.38}" cy="${y - r * 0.4}" r="${r * 0.2}" fill="${c.highlight}" opacity="0.75"/>`;
}

// A hole with a lip and an optional small label (H1..H3).
export const hole = (c, x, y, label, o = {}) =>
  `<ellipse cx="${x}" cy="${y}" rx="${o.rx ?? 17}" ry="${o.ry ?? 9}" fill="${c.hole}"/><ellipse cx="${x}" cy="${y - 1}" rx="${o.rx ?? 17}" ry="${o.ry ?? 9}" fill="none" stroke="${c.ink}" stroke-opacity="0.5" stroke-width="2"/>${label ? text(label, x + 26, y + 4, { fill: c.ink, size: 11, weight: 800 }) : ""}`;

// The jalla: a dashed line to stand behind.
export const jalla = (c, cx, y, half = 100) =>
  `<path d="M${cx - half} ${y} Q${cx} ${y + 12} ${cx + half} ${y}" fill="none" stroke="${c.ink}" stroke-opacity="0.6" stroke-width="3" stroke-dasharray="10 7"/>`;

// Side chips under the HUD title: marble icon plus a value.
export function sideChips(c, chips, y = 134) {
  let x = 24;
  return chips
    .map(([kind, label, value]) => {
      const out = `${marble(c, x + 7, y - 4, kind, { r: 7 })}${text(`${label} ${value}`, x + 20, y, { fill: c.ink, size: 13, weight: 700, ls: 0.5 })}`;
      x += 20 + (label.length + String(value).length + 1) * 9 + 14;
      return out;
    })
    .join("");
}

// Route chips for Batto: five circles H1 H2 H3 H2 H1; the next hole is filled.
export function routeChips(c, active, y = 166) {
  const labels = ["H1", "H2", "H3", "H2", "H1"];
  return labels
    .map((l, i) => {
      const x = 44 + i * 48;
      const done = i < active,
        now = i === active;
      return `<circle cx="${x}" cy="${y}" r="15" fill="${now ? c.ink : done ? c.mute : c.ground}" stroke="${c.ink}" stroke-width="2"/>${text(l, x, y + 4, { fill: now || done ? c.ground : c.ink, size: 11, weight: 800, anchor: "middle" })}${i < 4 ? `<line x1="${x + 17}" y1="${y}" x2="${x + 31}" y2="${y}" stroke="${c.ink}" stroke-width="2"/>` : ""}`;
    })
    .join("");
}

// Angled arena: ground ellipse, drawn ring, optional pit and start line.
export function arena(c, o = {}) {
  const cx = o.cx ?? 195,
    cy = o.cy ?? 420,
    rx = o.rx ?? 178,
    ry = o.ry ?? 132;
  let s = `<ellipse cx="${cx}" cy="${cy + 8}" rx="${rx + 6}" ry="${ry + 6}" fill="${c.earthRim}"/>
<ellipse cx="${cx}" cy="${cy}" rx="${rx}" ry="${ry}" fill="${c.earth}"/>`;
  if (o.ring)
    s += `<ellipse cx="${cx}" cy="${cy}" rx="${rx * 0.82}" ry="${ry * 0.82}" fill="none" stroke="${c.ink}" stroke-opacity="0.55" stroke-width="3"/>`;
  if (o.pit)
    s += `<ellipse cx="${cx}" cy="${cy - ry * 0.45}" rx="17" ry="9" fill="${c.hole}"/><ellipse cx="${cx}" cy="${cy - ry * 0.45 - 1}" rx="17" ry="9" fill="none" stroke="${c.ink}" stroke-opacity="0.5" stroke-width="2"/>`;
  if (o.line)
    s += `<path d="M${cx - rx * 0.55} ${cy + ry * 0.62} Q${cx} ${cy + ry * 0.74} ${cx + rx * 0.55} ${cy + ry * 0.62}" fill="none" stroke="${c.ink}" stroke-opacity="0.55" stroke-width="3" stroke-dasharray="10 7"/>`;
  return s;
}

const I = {
  pause: (c, x, y) =>
    `<rect x="${x - 6}" y="${y - 7}" width="4" height="14" fill="${c}"/><rect x="${x + 2}" y="${y - 7}" width="4" height="14" fill="${c}"/>`,
  angled: (c, x, y) =>
    `<path d="M${x - 9} ${y + 4} L${x} ${y - 5} L${x + 9} ${y + 4} L${x} ${y + 9} Z" fill="none" stroke="${c}" stroke-width="2"/>`,
  top: (c, x, y) =>
    `<circle cx="${x}" cy="${y}" r="8" fill="none" stroke="${c}" stroke-width="2"/><circle cx="${x}" cy="${y}" r="2" fill="${c}"/>`,
  low: (c, x, y) =>
    `<path d="M${x - 10} ${y + 3} H${x + 10}" stroke="${c}" stroke-width="2"/><circle cx="${x}" cy="${y - 3}" r="4" fill="none" stroke="${c}" stroke-width="2"/>`,
  reset: (c, x, y) =>
    `<path d="M${x + 7} ${y - 3} A8 8 0 1 0 ${x + 7} ${y + 4}" fill="none" stroke="${c}" stroke-width="2"/><path d="M${x + 8} ${y - 9} V${y - 2} H${x + 1}" fill="none" stroke="${c}" stroke-width="2"/>`,
  check: (c, x, y) =>
    `<path d="M${x - 7} ${y} L${x - 2} ${y + 6} L${x + 8} ${y - 6}" fill="none" stroke="${c}" stroke-width="3"/>`,
  back: (c, x, y) =>
    `<path d="M${x + 4} ${y - 8} L${x - 5} ${y} L${x + 4} ${y + 8}" fill="none" stroke="${c}" stroke-width="2.5"/>`,
};

// Round icon control: 44 px target, outlined, ink glyph; "on" fills it with ink.
export function iconButton(c, name, x, y, on = false) {
  return `<circle cx="${x}" cy="${y}" r="22" fill="${on ? c.ink : c.ground}" stroke="${c.ink}" stroke-width="2"/>${I[name](on ? c.ground : c.ink, x, y)}`;
}

// The one primary action: a solid marble-coloured disc with a label.
export function primaryDisc(c, label, x, y, r = 48) {
  return `<circle cx="${x}" cy="${y}" r="${r}" fill="${c.glaze}"/>${text(label, x, y + 6, { fill: c.onGlaze, size: label.length > 6 ? 14 : r > 40 ? 18 : 15, weight: 700, anchor: "middle", ls: 1.5 })}`;
}

export const outlineButton = (c, label, x, y, w = 200, h = 48) =>
  `<rect x="${x - w / 2}" y="${y - h / 2}" width="${w}" height="${h}" rx="14" fill="${c.ground}" stroke="${c.ink}" stroke-width="2"/>${text(label, x, y + 6, { fill: c.ink, size: 15, weight: 700, anchor: "middle", ls: 1.5 })}`;

export const textAction = (c, label, x, y) =>
  text(label, x, y, { fill: c.ink, size: 15, weight: 600, anchor: "middle", deco: "underline" });

export function hud(c, mode, turn, turnKind, chips) {
  const tx = turnKind ? 52 : 24;
  return `${text(mode.toUpperCase(), 24, 76, { fill: c.mute, size: 12, weight: 700, ls: 1.5 })}
${turnKind ? marble(c, 34, 99, turnKind, { r: 9 }) : ""}${text(turn, tx, 108, { fill: c.ink, size: 28, weight: 800 })}
${iconButton(c, "pause", 348, 88)}
${sideChips(c, chips)}`;
}

export const cameraBar = (c, active = "angled") =>
  `${iconButton(c, "angled", 60, 790, active === "angled")}${iconButton(c, "top", 120, 790, active === "top")}${iconButton(c, "low", 180, 790, active === "low")}${iconButton(c, "reset", 330, 790)}`;

export const wordmark = (c, cx, y, size = 40) =>
  `<text x="${cx}" y="${y}" font-family="${FONT}" font-size="${size}" font-weight="800" letter-spacing="2" fill="${c.ink}" text-anchor="middle">GULI<tspan fill="${c.mute}" font-weight="500" letter-spacing="0"> &amp; </tspan>BATTO</text>`;
