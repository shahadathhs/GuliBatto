// The game's sound effects, made from code so there is nothing to download or license.
//   node scripts/sounds.mjs           write game/audio/*.wav
//   node scripts/sounds.mjs --check   fail if a file on disk differs from what this script makes
// Mono, 16-bit, 22 050 Hz. Every sound is deterministic (a seeded noise source), so the files only
// change when this script does. To use recordings instead, replace the .wav files and drop the
// check from the Makefile.
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const outDir = join(root, "game/audio");
const check = process.argv.includes("--check");

const RATE = 22050;
const PEAK = 0.8;

/** A small seeded noise source (a linear congruential generator), -1 to 1. */
function noise(seed) {
  let s = seed >>> 0;
  return () => {
    s = (Math.imul(s, 1664525) + 1013904223) >>> 0;
    return s / 0x80000000 - 1;
  };
}

/** `seconds` of audio from f(t), t in seconds. */
function make(seconds, f) {
  const out = new Float32Array(Math.round(seconds * RATE));
  for (let i = 0; i < out.length; i++) out[i] = f(i / RATE);
  return out;
}

const tone = (hz, t) => Math.sin(2 * Math.PI * hz * t);
const decay = (rate, t) => Math.exp(-rate * t);
/** Adds `part` into `into` starting at `at` seconds. */
function mix(into, part, at) {
  const start = Math.round(at * RATE);
  for (let i = 0; i < part.length && start + i < into.length; i++) into[start + i] += part[i];
}

function wav(samples) {
  let peak = 0;
  for (const v of samples) peak = Math.max(peak, Math.abs(v));
  const gain = peak > 0 ? PEAK / peak : 1;
  const data = Buffer.alloc(samples.length * 2);
  samples.forEach((v, i) =>
    data.writeInt16LE(Math.round(Math.max(-1, Math.min(1, v * gain)) * 32767), i * 2),
  );
  const head = Buffer.alloc(44);
  head.write("RIFF", 0);
  head.writeUInt32LE(36 + data.length, 4);
  head.write("WAVEfmt ", 8);
  head.writeUInt32LE(16, 16);
  head.writeUInt16LE(1, 20); // PCM
  head.writeUInt16LE(1, 22); // mono
  head.writeUInt32LE(RATE, 24);
  head.writeUInt32LE(RATE * 2, 28);
  head.writeUInt16LE(2, 32);
  head.writeUInt16LE(16, 34);
  head.write("data", 36);
  head.writeUInt32LE(data.length, 40);
  return Buffer.concat([head, data]);
}

/** A short glassy click: two high partials and a tick of noise. */
function click(seed, base) {
  const n = noise(seed);
  return make(
    0.13,
    (t) =>
      0.6 * tone(base, t) * decay(55, t) +
      0.35 * tone(base * 1.6, t) * decay(80, t) +
      0.5 * n() * decay(900, t),
  );
}

const sounds = {
  // A soft tick for buttons.
  tap: make(0.05, (t) => tone(1400, t) * decay(70, t)),
  // The thump of a marble leaving the finger.
  shot: (() => {
    const n = noise(7);
    return make(0.11, (t) => tone(170, t) * decay(30, t) + 0.25 * n() * decay(150, t));
  })(),
  // Marble on marble.
  hit: click(11, 2300),
  // Marble on the wall: lower and duller.
  wall: (() => {
    const n = noise(13);
    return make(
      0.16,
      (t) =>
        0.7 * tone(220, t) * decay(28, t) +
        0.3 * tone(330, t) * decay(34, t) +
        0.3 * n() * decay(200, t),
    );
  })(),
  // Down into a hole: a falling note and a little rattle.
  drop: (() => {
    // A note gliding down from 700 Hz to 180 Hz over 0.28 s, then holding at 180 Hz.
    const fall = 0.28;
    const phase = (t) =>
      t <= fall
        ? 700 * t - (520 * t * t) / (2 * fall)
        : 700 * fall - (520 * fall) / 2 + 180 * (t - fall);
    const out = make(0.34, (t) => 0.8 * Math.sin(2 * Math.PI * phase(t)) * decay(9, t));
    for (const [at, seed] of [
      [0.12, 21],
      [0.17, 22],
      [0.22, 23],
    ])
      mix(
        out,
        click(seed, 1700).map((v) => v * 0.35),
        at,
      );
    return out;
  })(),
  // Won the match: four rising notes.
  win: (() => {
    const out = new Float32Array(Math.round(0.65 * RATE));
    [523.25, 659.25, 783.99, 1046.5].forEach((hz, i) =>
      mix(
        out,
        make(0.3, (t) => (tone(hz, t) + 0.3 * tone(hz * 2, t)) * decay(7, t)),
        i * 0.11,
      ),
    );
    return out;
  })(),
  // Lost the match: two falling notes.
  lose: (() => {
    const out = new Float32Array(Math.round(0.6 * RATE));
    [392, 293.66].forEach((hz, i) =>
      mix(
        out,
        make(0.32, (t) => (tone(hz, t) + 0.25 * tone(hz * 2, t)) * decay(6, t)),
        i * 0.2,
      ),
    );
    return out;
  })(),
};

let stale = 0;
mkdirSync(outDir, { recursive: true });
for (const [name, samples] of Object.entries(sounds)) {
  const file = join(outDir, `${name}.wav`);
  const bytes = wav(samples);
  if (check) {
    if (!existsSync(file) || !readFileSync(file).equals(bytes)) {
      console.error(`out of date: game/audio/${name}.wav (run: node scripts/sounds.mjs)`);
      stale++;
    }
  } else {
    writeFileSync(file, bytes);
  }
}
if (check) {
  if (stale) process.exit(1);
  console.log("sounds ok");
} else {
  console.log(`wrote ${Object.keys(sounds).length} sounds to game/audio`);
}
