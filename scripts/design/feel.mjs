// A concept render of the planned "feel" pass (docs/README_FEEL.md): the same Kep toss as it is
// now, aimed with a flick on a dirt ground with swirled marbles and almost no interface, and
// rolling. Drawn from the colour tokens only: shades come from opacity over the earth colours.
import { THEMES } from "./tokens.mjs";
import { text, iconButton } from "./parts.mjs";
import { screenBody, W, H } from "./screens.mjs";

const rng = (seed) => () => {
  seed |= 0;
  seed = (seed + 0x6d2b79f5) | 0;
  let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const HORIZON = 292;
// How large things are at a screen height: small far away, full size at the bottom.
const scaleAt = (y) => 0.22 + 0.78 * Math.max(0, (y - HORIZON) / (H - HORIZON));

// An open field after harvest, seen from a crouch: a wide sky, a far treeline of palms and
// bamboo, a low earth bund crossing the field, and dry ground with rows of stubble running to the
// horizon. Only an open field: no buildings, people, animals, patterns or writing.
function sky(c) {
  const r = rng(3);
  let s = `<rect width="${W}" height="${HORIZON}" fill="${c.ground}"/><rect y="${HORIZON - 120}" width="${W}" height="120" fill="${c.bone}" opacity="0.28"/>`;
  for (const [x, y, w] of [
    [60, 96, 120],
    [250, 62, 150],
    [330, 150, 90],
    [120, 190, 100],
  ])
    s += `<ellipse cx="${x}" cy="${y}" rx="${w / 2}" ry="${w / 9}" fill="${c.floor}" opacity="0.9"/><ellipse cx="${x - w * 0.18}" cy="${y - w / 11}" rx="${w / 3.2}" ry="${w / 10}" fill="${c.floor}" opacity="0.9"/><ellipse cx="${x + w * 0.2}" cy="${y - w / 12}" rx="${w / 3.6}" ry="${w / 11}" fill="${c.floor}" opacity="0.9"/>`;
  // Far treeline: low and hazy, then a nearer row of palms and bamboo clumps.
  let far = `M0 ${HORIZON}`;
  for (let x = 0; x <= W; x += 10)
    far += ` L${x} ${HORIZON - 8 - r() * 14 - (Math.sin(x / 38) + 1) * 4}`;
  far += ` L${W} ${HORIZON} Z`;
  s += `<path d="${far}" fill="${c.jade}" opacity="0.28"/>`;
  for (const [x, h] of [
    [34, 58],
    [150, 70],
    [286, 62],
    [368, 76],
  ]) {
    const top = HORIZON - h;
    s += `<path d="M${x} ${HORIZON - 4} Q${x + 3} ${top + h * 0.5} ${x + 1} ${top}" fill="none" stroke="${c.ink}" stroke-opacity="0.38" stroke-width="2.4"/>`;
    for (const a of [-1.2, -0.6, 0, 0.6, 1.2])
      s += `<path d="M${x + 1} ${top} q${a * 16} ${-8 + Math.abs(a) * 7} ${a * 30} ${6 + Math.abs(a) * 10}" fill="none" stroke="${c.jade}" stroke-opacity="0.55" stroke-width="2.6" stroke-linecap="round"/>`;
  }
  for (const x of [88, 214, 322]) {
    let clump = `M${x - 26} ${HORIZON}`;
    for (let i = 0; i <= 8; i++) clump += ` L${x - 26 + i * 6.5} ${HORIZON - 16 - r() * 18}`;
    clump += ` L${x + 26} ${HORIZON} Z`;
    s += `<path d="${clump}" fill="${c.jade}" opacity="0.42"/>`;
  }
  return s;
}

function ground(c, id) {
  const r = rng(7);
  let s = `<rect x="0" y="${HORIZON}" width="${W}" height="${H - HORIZON}" fill="${c.earth}"/>`;
  // A low earth bund crossing the field in the distance, with a fringe of grass.
  s += `<path d="M0 ${HORIZON + 26} Q${W / 2} ${HORIZON + 14} ${W} ${HORIZON + 24} L${W} ${HORIZON + 44} Q${W / 2} ${HORIZON + 36} 0 ${HORIZON + 46} Z" fill="${c.earthRim}" opacity="0.85"/>`;
  for (let x = 4; x < W; x += 7)
    s += `<path d="M${x} ${HORIZON + 20 + Math.sin(x / 60) * 4} l${(r() - 0.5) * 3} ${-5 - r() * 5}" stroke="${c.jade}" stroke-opacity="0.7" stroke-width="1.6" stroke-linecap="round"/>`;
  // Rows of stubble running toward the horizon.
  for (let i = -9; i <= 9; i++) {
    const bx = W / 2 + i * 120;
    s += `<line x1="${W / 2 + i * 9}" y1="${HORIZON + 48}" x2="${bx}" y2="${H}" stroke="${c.earthRim}" stroke-opacity="0.45" stroke-width="3"/>`;
    for (let y = HORIZON + 60; y < H; y += 9 + (y - HORIZON) * 0.06) {
      const t = (y - (HORIZON + 48)) / (H - HORIZON - 48);
      const x = W / 2 + i * 9 + (bx - (W / 2 + i * 9)) * t;
      const k = scaleAt(y);
      s += `<path d="M${x} ${y} l${(r() - 0.5) * 6 * k} ${-6 * k - r() * 5 * k}" stroke="${c.bone}" stroke-opacity="0.55" stroke-width="${1.4 * k}" stroke-linecap="round"/>`;
    }
  }
  // Worn patches, grain, pebbles, cracks and scratches.
  for (let i = 0; i < 9; i++) {
    const y = HORIZON + 80 + r() * (H - HORIZON - 100);
    const k = scaleAt(y);
    s += `<ellipse cx="${r() * W}" cy="${y}" rx="${(60 + r() * 90) * k}" ry="${(14 + r() * 22) * k}" fill="${c.earthRim}" opacity="${0.22 + r() * 0.2}"/>`;
  }
  for (let i = 0; i < 480; i++) {
    const y = HORIZON + 52 + r() * (H - HORIZON - 52);
    const k = scaleAt(y);
    const size = (0.8 + r() * 2.6) * k;
    s += `<ellipse cx="${r() * W}" cy="${y}" rx="${size * 1.4}" ry="${size * 0.8}" fill="${r() < 0.7 ? c.earthRim : c.hole}" opacity="${0.25 + r() * 0.4}"/>`;
  }
  for (let i = 0; i < 22; i++) {
    const y = HORIZON + 90 + r() * (H - HORIZON - 100);
    const k = scaleAt(y);
    const x = r() * W;
    s += `<ellipse cx="${x}" cy="${y}" rx="${(4 + r() * 6) * k}" ry="${(2.4 + r() * 2.4) * k}" fill="${c.bone}" opacity="0.55"/><ellipse cx="${x - k}" cy="${y - 0.8 * k}" rx="${(2 + r() * 2) * k}" ry="${k}" fill="${c.highlight}" opacity="0.35"/>`;
  }
  for (let i = 0; i < 7; i++) {
    const y = HORIZON + 520 * 0.55 + r() * 230;
    const k = scaleAt(y);
    let d = `M${r() * W} ${y}`;
    for (let j = 0; j < 5; j++) d += ` l${(r() - 0.5) * 34 * k} ${(r() - 0.3) * 12 * k}`;
    s += `<path d="${d}" fill="none" stroke="${c.hole}" stroke-opacity="0.35" stroke-width="${1.6 * k}" stroke-linecap="round"/>`;
  }
  // Far ground fades toward the sky.
  s += `<rect x="0" y="${HORIZON}" width="${W}" height="90" fill="${c.ground}" opacity="0.2"/>`;
  return `<clipPath id="${id}"><rect width="${W}" height="${H}"/></clipPath><g clip-path="url(#${id})">${sky(c)}${s}</g>`;
}

// The hole: a worn rim, crumbs round it, and a dark well.
function hole(c, x, y) {
  const k = scaleAt(y);
  const r = rng(11);
  let s = `<ellipse cx="${x}" cy="${y + 4 * k}" rx="${78 * k}" ry="${26 * k}" fill="${c.earthRim}" opacity="0.7"/><ellipse cx="${x}" cy="${y}" rx="${64 * k}" ry="${21 * k}" fill="${c.earthRim}"/>`;
  s += `<ellipse cx="${x}" cy="${y + 1.5 * k}" rx="${54 * k}" ry="${17 * k}" fill="${c.hole}"/><ellipse cx="${x + 4 * k}" cy="${y + 5 * k}" rx="${40 * k}" ry="${11 * k}" fill="${c.ink}" opacity="0.35"/>`;
  for (let i = 0; i < 26; i++) {
    const a = r() * Math.PI * 2;
    const d = 1.02 + r() * 0.35;
    s += `<ellipse cx="${x + Math.cos(a) * 62 * k * d}" cy="${y + Math.sin(a) * 20 * k * d}" rx="${(1.2 + r() * 2.2) * k}" ry="${(0.9 + r() * 1.4) * k}" fill="${c.earthRim}" opacity="0.9"/>`;
  }
  return s;
}

// The jalla: a line scratched into the dirt, uneven, with a ridge of loose earth along one side.
function jalla(c, y, x0 = 20, x1 = 370) {
  const r = rng(23);
  let d = `M${x0} ${y}`;
  let ridge = `M${x0} ${y - 5}`;
  for (let x = x0 + 14; x <= x1; x += 14) {
    const wob = (r() - 0.5) * 3.2;
    d += ` L${x} ${y + wob}`;
    ridge += ` L${x} ${y - 5 + wob + (r() - 0.5) * 2}`;
  }
  return `<path d="${d}" fill="none" stroke="${c.hole}" stroke-opacity="0.55" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"/><path d="${ridge}" fill="none" stroke="${c.bone}" stroke-opacity="0.4" stroke-width="2" stroke-linecap="round" stroke-dasharray="${5 + r() * 3} 3"/>`;
}

// A swirled glass marble: the swirl turns with the marble (rot), the mark stays flat on top.
let uid = 0;
function marble(c, x, y, r, kind, o = {}) {
  const id = `m${uid++}`;
  const body = { p1: c.glaze, p2: c.amber, p3: c.jade, p4: c.plum, p5: c.rose, pot: c.bone }[kind];
  const mark = {
    p1: c.onGlaze,
    p2: c.onAmber,
    p3: c.onJade,
    p4: c.onPlum,
    p5: c.onRose,
    pot: c.ink,
  }[kind];
  const rot = o.rot ?? 0;
  const swirl = `<g transform="rotate(${rot} ${x} ${y})"><path d="M${x - r} ${y + r * 0.1} C${x - r * 0.4} ${y - r * 0.9} ${x + r * 0.4} ${y + r * 0.9} ${x + r} ${y - r * 0.1}" fill="none" stroke="${c.highlight}" stroke-opacity="0.55" stroke-width="${r * 0.34}"/><path d="M${x - r * 0.9} ${y + r * 0.55} C${x - r * 0.2} ${y - r * 0.2} ${x + r * 0.3} ${y + r * 0.7} ${x + r * 0.95} ${y + r * 0.25}" fill="none" stroke="${c.ink}" stroke-opacity="0.22" stroke-width="${r * 0.22}"/><circle cx="${x + r * 0.25}" cy="${y + r * 0.3}" r="${r * 0.22}" fill="${c.highlight}" fill-opacity="0.3"/></g>`;
  let badge = "";
  const by = y - r * 0.12;
  if (kind === "p1")
    badge = `<ellipse cx="${x}" cy="${by}" rx="${r * 0.46}" ry="${r * 0.34}" fill="none" stroke="${mark}" stroke-width="${Math.max(2, r * 0.17)}"/>`;
  if (kind === "p2")
    badge = `<ellipse cx="${x}" cy="${by}" rx="${r * 0.22}" ry="${r * 0.16}" fill="${mark}"/>`;
  if (kind === "p3" || kind === "pot")
    badge = `<rect x="${x - r * 0.46}" y="${by - r * 0.1}" width="${r * 0.92}" height="${r * 0.2}" fill="${mark}"/>`;
  if (kind === "p4")
    badge = `<polygon points="${x},${by - r * 0.34} ${x + r * 0.4},${by + r * 0.26} ${x - r * 0.4},${by + r * 0.26}" fill="${mark}"/>`;
  const ring = o.active
    ? `<ellipse cx="${x}" cy="${y + r * 0.78}" rx="${r * 1.6}" ry="${r * 0.55}" fill="none" stroke="${c.ink}" stroke-width="2.5" opacity="0.8"/>`
    : "";
  return `${ring}<ellipse cx="${x + r * 0.55}" cy="${y + r * 0.95}" rx="${r * 1.35}" ry="${r * 0.32}" fill="${c.shadow}"/><ellipse cx="${x + r * 0.2}" cy="${y + r * 0.92}" rx="${r * 0.85}" ry="${r * 0.24}" fill="${c.shadow}"/>
<clipPath id="${id}"><circle cx="${x}" cy="${y}" r="${r}"/></clipPath><circle cx="${x}" cy="${y}" r="${r}" fill="${body}"/><g clip-path="url(#${id})">${swirl}<circle cx="${x + r * 0.15}" cy="${y + r * 0.2}" r="${r * 0.95}" fill="none" stroke="${c.ink}" stroke-opacity="0.2" stroke-width="${r * 0.3}"/></g>
<circle cx="${x}" cy="${y}" r="${r}" fill="none" stroke="${c.ink}" stroke-opacity="0.55" stroke-width="1.2"/>${badge}
<ellipse cx="${x - r * 0.36}" cy="${y - r * 0.42}" rx="${r * 0.26}" ry="${r * 0.16}" fill="${c.highlight}" opacity="0.9" transform="rotate(-30 ${x - r * 0.36} ${y - r * 0.42})"/><circle cx="${x + r * 0.42}" cy="${y + r * 0.3}" r="${r * 0.08}" fill="${c.highlight}" opacity="0.5"/>`;
}

// What is left of the interface: small, quiet, and gone while marbles move.
function quietHud(c, line, fade) {
  const op = fade;
  return `<g opacity="${op}">${text(line, 24, 60, { fill: c.ink, size: 11, weight: 700, ls: 1.5 })}${text("Your toss", 24, 90, { fill: c.ink, size: 20, weight: 800 })}</g>
<g opacity="${op * 0.9}">${iconButton(c, "pause", 350, 66)}</g>`;
}

const panel = (
  c,
  label,
  sub,
  body,
) => `<g>${text(label, 0, -34, { fill: c.ink, size: 14, weight: 800, ls: 2 })}${text(sub, 0, -14, { fill: c.mute, size: 12 })}
<rect x="-2" y="-2" width="${W + 4}" height="${H + 4}" rx="22" fill="none" stroke="${c.line}" stroke-width="2"/>${body}</g>`;

function aiming(c) {
  uid = 100;
  const trace = `<path d="M176 818 C184 760 198 700 236 600" fill="none" stroke="${c.ink}" stroke-opacity="0.28" stroke-width="5" stroke-linecap="round" stroke-dasharray="1 9"/><circle cx="176" cy="818" r="22" fill="${c.mute}" opacity="0.55"/><circle cx="176" cy="818" r="22" fill="none" stroke="${c.ink}" stroke-opacity="0.4" stroke-width="2"/>`;
  return `${ground(c, "g2")}${hole(c, 205, 430)}${marble(c, 140, 408, 12, "p3", { rot: 40 })}${marble(c, 268, 374, 10, "p2", { rot: 160 })}${jalla(c, 668)}${marble(c, 196, 716, 40, "p1", { active: true, rot: 25 })}${trace}${quietHud(c, "KEP · ROUND 2 OF 5", 0.7)}`;
}

function rolling(c) {
  uid = 200;
  const streak = `<ellipse cx="200" cy="580" rx="17" ry="70" fill="${c.ink}" opacity="0.07"/><ellipse cx="204" cy="640" rx="10" ry="44" fill="${c.ink}" opacity="0.06"/>`;
  const dust = [0, 1, 2, 3, 4, 5, 6]
    .map(
      (i) =>
        `<circle cx="${196 + (i % 3) * 7 - 7}" cy="${628 + i * 11}" r="${2.2 - i * 0.14}" fill="${c.bone}" opacity="${0.5 - i * 0.05}"/>`,
    )
    .join("");
  return `${ground(c, "g3")}${hole(c, 205, 430)}${marble(c, 140, 408, 12, "p3", { rot: 40 })}${marble(c, 268, 374, 10, "p2", { rot: 160 })}${jalla(c, 668)}${streak}${dust}${marble(c, 200, 528, 28, "p1", { rot: 205 })}${quietHud(c, "KEP · ROUND 2 OF 5", 0.18)}`;
}

export function feelSvg(theme) {
  const c = THEMES[theme];
  const gap = 34;
  const top = 72;
  const w = gap + 3 * (W + gap);
  const h = top + H + gap + 20;
  const now = `<rect width="${W}" height="${H}" fill="${c.ground}"/><clipPath id="gn"><rect width="${W}" height="${H}"/></clipPath><g clip-path="url(#gn)">${screenBody("05-kep-ready", theme)}</g>`;
  const at = (i, body) => `<g transform="translate(${gap + i * (W + gap)},${top})">${body}</g>`;
  return {
    w,
    h,
    svg: `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}"><rect width="100%" height="100%" fill="${c.sheet}"/>
${at(0, panel(c, "NOW", "A coloured plane, a dashed line, an arrow, a control panel", now))}
${at(1, panel(c, "PLANNED · AIMING WITH A FLICK", "An open field, a scratched line, glass marbles, little interface", aiming(c)))}
${at(2, panel(c, "PLANNED · ROLLING", "The swirl turns, the interface fades, the screen is the field", rolling(c)))}
</svg>`,
  };
}
