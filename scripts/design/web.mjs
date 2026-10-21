// Concept renders of the marketing site. Values (version, size, hash) are placeholders.
import { THEMES } from "./tokens.mjs";
import { arena, marble, hole, jalla } from "./parts.mjs";

const hero = (c) =>
  `<svg viewBox="0 0 390 300" xmlns="http://www.w3.org/2000/svg" style="width:100%;height:auto">${arena(c, { cx: 195, cy: 140, rx: 176, ry: 118 })}${hole(c, 195, 70, "H3")}${hole(c, 195, 110, "H2")}${hole(c, 195, 150, "H1")}${jalla(c, 195, 232, 90)}${[
    [120, 120, "p2"],
    [270, 90, "p3"],
    [250, 175, "pot"],
  ]
    .map(([x, y, k]) => marble(c, x, y, k))
    .join("")}${marble(c, 195, 205, "p1", { r: 14, active: true })}</svg>`;

const css = (c, mobile) => `
*{box-sizing:border-box;margin:0}html{width:${mobile ? 500 : 1280}px}body{width:${mobile ? 500 : 1280}px;background:${c.ground};color:${c.ink};font:${mobile ? 16 : 18}px/1.55 'Avenir Next','Helvetica Neue',Arial,sans-serif}
header{display:flex;justify-content:space-between;align-items:center;padding:${mobile ? "18px 20px" : "24px 64px"}}
.brand{font-weight:800;letter-spacing:2px}.brand i{font-style:normal;font-weight:500;color:${c.mute}}
nav a{margin-left:${mobile ? 14 : 28}px;color:${c.ink};font-size:${mobile ? 14 : 16}px}
main{padding:${mobile ? "8px 20px 40px" : "24px 64px 64px"}}
.grid{display:${mobile ? "block" : "grid"};grid-template-columns:1.1fr 1fr;gap:56px;align-items:center}
h1{font-size:${mobile ? 36 : 56}px;line-height:1.05;font-weight:800;margin:${mobile ? "16px 0 12px" : "0 0 18px"}}
.lede{color:${c.mute};font-size:${mobile ? 17 : 20}px;max-width:32em}
.cta{display:inline-flex;align-items:center;justify-content:center;margin:${mobile ? "22px 0" : "28px 0 12px"};min-width:200px;padding:0 28px;height:60px;border-radius:30px;background:${c.glaze};color:${c.onGlaze};font-weight:800;letter-spacing:1.5px}
.meta{color:${c.mute};font-size:14px}
h2{font-size:${mobile ? 22 : 28}px;font-weight:800;margin:${mobile ? "36px 0 12px" : "64px 0 16px"}}
ul{padding-left:1.2em}li{margin:6px 0}
.note{border-left:3px solid ${c.amber};padding-left:14px;color:${c.mute};margin-top:14px}
.steps{display:${mobile ? "block" : "grid"};grid-template-columns:repeat(3,1fr);gap:32px}.steps div{margin-bottom:${mobile ? 16 : 0}px}
.steps b{display:inline-flex;width:34px;height:34px;border-radius:17px;border:2px solid ${c.ink};align-items:center;justify-content:center;margin-bottom:8px}
.box{border:2px solid ${c.ink};border-radius:16px;padding:18px 20px;margin:16px 0}
code{font:13px ui-monospace,Menlo,monospace;color:${c.mute};word-break:break-all}
footer{padding:${mobile ? "20px" : "24px 64px"};color:${c.mute};font-size:14px;border-top:1px solid ${c.line}}`;

const head = `<header><span class="brand">GULI <i>&amp;</i> BATTO</span><nav><a>How to play</a><a>About</a><a>Download</a><a>Privacy</a></nav></header>`;
const foot = `<footer>Inspired by the traditional marble games of Bangladesh. About these games.</footer>`;

export const landing = (theme, mobile) => {
  const c = THEMES[theme];
  return `<html><style>${css(c, mobile)}</style><body>${head}<main>
<div class="grid"><div><h1>Line up the shot. Let the marbles roll.</h1><p class="lede">A small 3D marble game for your phone, made from the traditional marble games of Bangladesh. No accounts, no ads, no internet needed after install.</p><div class="cta">DOWNLOAD FOR ANDROID</div><div class="meta">Version 0.1.0 · 48 MB · Android 8 or newer</div></div><div>${hero(c)}</div></div>
<h2>How it works</h2><div class="steps"><div><b>1</b><br><strong>Aim.</strong> Pull back from your marble. The arrow shows where it will go.</div><div><b>2</b><br><strong>Release.</strong> Longer pull, more power. Then watch the marbles roll.</div><div><b>3</b><br><strong>Read the result.</strong> Points are judged once everything stops.</div></div>
<h2>Four modes</h2><ul><li><strong>Kep</strong>: toss at the hole; closest scores.</li><li><strong>Batto</strong>: race three holes and back; hit a rival for another shot.</li><li><strong>Guli Khela</strong>: name the baad marble and touch exactly one other.</li><li><strong>Quick Dan</strong>: one round of Guli Khela.</li></ul><p class="note">Nothing here is invented from nothing: each mode starts with a game people played, and I changed some rules to work on a phone. <u>Read where the rules come from.</u></p>
<h2>The short list</h2><ul><li>Plays offline. Progress stays on your device.</li><li>Real rolling, friction and collisions.</li><li>Light and dark themes.</li></ul>
</main>${foot}</body></html>`;
};

export const download = (theme, mobile) => {
  const c = THEMES[theme];
  return `<html><style>${css(c, mobile)}</style><body>${head}<main>
<h1>Download</h1><p class="lede">Version 0.1.0 for Android (48 MB).</p><div class="cta">DOWNLOAD APK</div><div class="meta">64-bit ARM · release notes · SHA-256 checksum</div>
<h2>Install</h2><div class="steps"><div><b>1</b><br>Download the file.</div><div><b>2</b><br>Open it. Allow installs from your browser when asked, once.</div><div><b>3</b><br>Open Guli &amp; Batto.</div></div>
<div class="box"><strong>Verify the file</strong><br><code>sha256: 9f2c…e41a</code></div>
<p class="note">This is a direct download, not a store build, so Android will warn you. Not available for iPhone.</p>
</main>${foot}</body></html>`;
};
