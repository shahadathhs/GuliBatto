"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { Marble } from "./marble";

// A small toy that teaches the one control: pull back from the marble and let go. It rolls and
// slows down; a slow marble drops into the hole and a fast one rolls over it, like the game's kep.
// Without JavaScript it is a still picture of the same ground.

const W = 318;
const H = 380;
const START = { x: 159, y: 310 };
const HOLE = { x: 159, y: 105, r: 26 };
const MARBLE_R = 12;
const MAX_PULL = 100;
const SPEED_PER_PULL = 0.15;
const FRICTION = 0.965;
const DROP_SPEED = 5.5;
const WALL = 18;
const RESET_MS = 1500;

type Roll = { x: number; y: number; vx: number; vy: number };

export function SlingshotDemo() {
  const [at, setAt] = useState(START);
  const [pull, setPull] = useState<{ x: number; y: number } | null>(null);
  const [fell, setFell] = useState(false);
  const [rolling, setRolling] = useState(false);
  const [note, setNote] = useState("Pull back from the marble and let go.");
  const svg = useRef<SVGSVGElement>(null);
  const roll = useRef<Roll | null>(null);
  const frame = useRef(0);
  const timer = useRef(0);

  const reset = useCallback(() => {
    roll.current = null;
    setAt(START);
    setFell(false);
    setRolling(false);
    setNote("Pull back from the marble and let go.");
  }, []);

  useEffect(
    () => () => {
      cancelAnimationFrame(frame.current);
      clearTimeout(timer.current);
    },
    [],
  );

  const toGround = (e: React.PointerEvent): { x: number; y: number } => {
    const box = svg.current!.getBoundingClientRect();
    return {
      x: ((e.clientX - box.left) / box.width) * W,
      y: ((e.clientY - box.top) / box.height) * H,
    };
  };

  const stepRef = useRef<() => void>(() => {});
  const step = useCallback(() => {
    const r = roll.current;
    if (!r) return;
    r.x += r.vx;
    r.y += r.vy;
    if (r.x < WALL || r.x > W - WALL) {
      r.vx *= -0.6;
      r.x = Math.min(W - WALL, Math.max(WALL, r.x));
    }
    if (r.y < WALL || r.y > H - WALL) {
      r.vy *= -0.6;
      r.y = Math.min(H - WALL, Math.max(WALL, r.y));
    }
    const speed = Math.hypot(r.vx, r.vy);
    const inHole = Math.hypot(r.x - HOLE.x, r.y - HOLE.y) < HOLE.r - 4;
    if (inHole && speed < DROP_SPEED) {
      roll.current = null;
      setRolling(false);
      setAt({ x: HOLE.x, y: HOLE.y });
      setFell(true);
      setNote("In the hole. A slow marble drops in.");
      timer.current = window.setTimeout(reset, RESET_MS);
      return;
    }
    r.vx *= FRICTION;
    r.vy *= FRICTION;
    setAt({ x: r.x, y: r.y });
    if (speed < 0.15) {
      roll.current = null;
      setRolling(false);
      setNote(inHole ? "Rolled to a stop." : "Too hard, or too soft. Try again.");
      timer.current = window.setTimeout(reset, RESET_MS);
      return;
    }
    frame.current = requestAnimationFrame(() => stepRef.current());
  }, [reset]);

  useEffect(() => {
    stepRef.current = step;
  }, [step]);

  const onDown = (e: React.PointerEvent) => {
    if (rolling || fell || at.x !== START.x || at.y !== START.y) return;
    e.currentTarget.setPointerCapture(e.pointerId);
    setPull(toGround(e));
  };
  const onMove = (e: React.PointerEvent) => {
    if (pull) setPull(toGround(e));
  };
  const onUp = () => {
    if (!pull) return;
    const dx = START.x - pull.x;
    const dy = START.y - pull.y;
    const len = Math.min(Math.hypot(dx, dy), MAX_PULL);
    setPull(null);
    if (len < 8) return;
    const k = (len / Math.hypot(dx, dy)) * SPEED_PER_PULL;
    roll.current = { x: START.x, y: START.y, vx: dx * k, vy: dy * k };
    setNote("");
    setRolling(true);
    frame.current = requestAnimationFrame(() => stepRef.current());
  };

  // The finger is drawn where it is, the arrow shows where the marble will go.
  const dx = pull ? START.x - pull.x : 0;
  const dy = pull ? START.y - pull.y : 0;
  const len = Math.min(Math.hypot(dx, dy), MAX_PULL);
  const unit =
    len > 0 ? { x: dx / Math.hypot(dx, dy), y: dy / Math.hypot(dx, dy) } : { x: 0, y: -1 };
  const tip = { x: START.x + unit.x * len * 0.9, y: START.y + unit.y * len * 0.9 };

  return (
    <figure className="figure demo">
      <svg
        ref={svg}
        viewBox={`0 0 ${W} ${H}`}
        className="diagram demo-art"
        role="img"
        aria-label="A marble to pull back and release toward a hole."
        onPointerDown={onDown}
        onPointerMove={onMove}
        onPointerUp={onUp}
        onPointerCancel={onUp}
      >
        <rect x={0} y={0} width={W} height={H} rx={4} style={{ fill: "var(--earth-rim)" }} />
        <rect x={5} y={5} width={W - 10} height={H - 10} style={{ fill: "var(--earth)" }} />
        <line
          x1={50}
          y1={START.y + 30}
          x2={W - 50}
          y2={START.y + 30}
          stroke="var(--ink)"
          strokeWidth={3}
          strokeDasharray="12 12"
        />
        <circle cx={HOLE.x} cy={HOLE.y} r={HOLE.r} style={{ fill: "var(--hole)" }} />
        {pull && len > 0 && (
          <>
            <line
              x1={START.x}
              y1={START.y}
              x2={pull.x}
              y2={pull.y}
              stroke="var(--ink)"
              strokeWidth={2}
              strokeDasharray="6 6"
            />
            <circle cx={pull.x} cy={pull.y} r={9} style={{ fill: "var(--mute)" }} />
            <line
              x1={START.x}
              y1={START.y}
              x2={tip.x}
              y2={tip.y}
              stroke="var(--glaze)"
              strokeWidth={3}
              strokeLinecap="round"
            />
          </>
        )}
        <g
          className={fell ? "marble-fell" : undefined}
          style={{ transformOrigin: `${at.x}px ${at.y}px` }}
        >
          <Marble side={1} x={at.x} y={at.y} r={MARBLE_R} ring={!rolling && !fell} />
        </g>
      </svg>
      <figcaption aria-live="polite">{note || " "}</figcaption>
    </figure>
  );
}
