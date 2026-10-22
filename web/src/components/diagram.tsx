import type { DiagramData, DiagramItem } from "@/lib/content";
import { Marble, type Side } from "./marble";

// One diagram from content/diagrams.json, drawn the way the game draws it (DiagramView in the app):
// metres on the ground, x to the right and z down the picture. Never a screenshot.

const WIDTH = 318;
const MAX_HEIGHT = 380;
const MIN_MARBLE = 7;

const sideOf = (side: number): Side => (side < 0 ? "pot" : ((side + 1) as Side));

export function Diagram({ data, label }: { data: DiagramData; label: string }) {
  const [hx, hy] = data.half;
  const s = Math.min(WIDTH / (2 * hx), MAX_HEIGHT / (2 * hy));
  const w = 2 * hx * s;
  const h = 2 * hy * s;
  const p = (at: [number, number]): [number, number] => [w / 2 + at[0] * s, h / 2 + at[1] * s];
  return (
    <svg viewBox={`0 0 ${w} ${h}`} role="img" aria-label={label} className="diagram">
      {data.items.map((item, i) => (
        <Item key={i} item={item} p={p} s={s} />
      ))}
    </svg>
  );
}

function Item({
  item,
  p,
  s,
}: {
  item: DiagramItem;
  p: (at: [number, number]) => [number, number];
  s: number;
}) {
  switch (item.kind) {
    case "arena": {
      if (item.shape === "circle") {
        const r = (item.r ?? 1) * s;
        return (
          <>
            <circle
              cx={p([0, 0])[0]}
              cy={p([0, 0])[1]}
              r={r + 5}
              style={{ fill: "var(--earth-rim)" }}
            />
            <circle cx={p([0, 0])[0]} cy={p([0, 0])[1]} r={r} style={{ fill: "var(--earth)" }} />
          </>
        );
      }
      const [ax, ay] = item.half ?? [1, 1];
      const [x, y] = p([-ax, -ay]);
      return (
        <>
          <rect
            x={x - 5}
            y={y - 5}
            width={2 * ax * s + 10}
            height={2 * ay * s + 10}
            style={{ fill: "var(--earth-rim)" }}
          />
          <rect
            x={x}
            y={y}
            width={2 * ax * s}
            height={2 * ay * s}
            style={{ fill: "var(--earth)" }}
          />
        </>
      );
    }
    case "line": {
      const [x1, y1] = p(item.from!);
      const [x2, y2] = p(item.to!);
      const pull = item.style === "pull";
      return (
        <line
          x1={x1}
          y1={y1}
          x2={x2}
          y2={y2}
          stroke="var(--ink)"
          strokeWidth={pull ? 2 : 3}
          strokeDasharray={pull ? "6 6" : "12 12"}
        />
      );
    }
    case "hole": {
      const [x, y] = p(item.at!);
      const r = (item.r ?? 0.3) * s;
      return (
        <>
          <circle cx={x} cy={y} r={r} style={{ fill: "var(--hole)" }} />
          {item.label && (
            <text
              x={x + r + 8}
              y={y + 5}
              fontSize={15}
              fontWeight={800}
              style={{ fill: "var(--ink)" }}
            >
              {item.label}
            </text>
          )}
        </>
      );
    }
    case "marble": {
      const [x, y] = p(item.at!);
      const r = Math.max((item.r ?? 0.2) * s, MIN_MARBLE);
      return (
        <>
          <Marble side={sideOf(item.side ?? 0)} x={x} y={y} r={r} />
          {item.label && (
            <text
              x={x}
              y={y + r + 15}
              textAnchor="middle"
              fontSize={13}
              fontWeight={800}
              style={{ fill: "var(--ink)" }}
            >
              {item.label}
            </text>
          )}
        </>
      );
    }
    case "arrow": {
      const [x1, y1] = p(item.from!);
      const [x2, y2] = p(item.to!);
      const away = item.style === "away" || item.style === "route_back";
      const thin = item.style === "route" || item.style === "route_back";
      const colour = away ? "var(--ink)" : "var(--glaze)";
      const len = Math.hypot(x2 - x1, y2 - y1) || 1;
      const dx = (x2 - x1) / len;
      const dy = (y2 - y1) / len;
      const tip = (k: number, side: number): string =>
        `${x2 - dx * k - dy * side},${y2 - dy * k + dx * side}`;
      return (
        <>
          <line
            x1={x1}
            y1={y1}
            x2={x2 - dx * 6}
            y2={y2 - dy * 6}
            stroke={colour}
            strokeWidth={thin ? 2.5 : 3}
            strokeDasharray={away ? "8 8" : undefined}
            strokeLinecap="round"
          />
          <polygon points={`${x2},${y2} ${tip(13, 6.5)} ${tip(13, -6.5)}`} fill={colour} />
        </>
      );
    }
    case "cross": {
      const [x, y0] = p(item.at!);
      const y = y0 - 2;
      return (
        <path
          d={`M${x - 9} ${y - 9}L${x + 9} ${y + 9}M${x - 9} ${y + 9}L${x + 9} ${y - 9}`}
          stroke="var(--hole)"
          strokeWidth={3}
          strokeLinecap="round"
        />
      );
    }
    case "finger": {
      const [x, y] = p(item.at!);
      return <circle cx={x} cy={y} r={9} style={{ fill: "var(--mute)" }} />;
    }
    case "label": {
      const [x, y] = p(item.at!);
      return (
        <text x={x} y={y} fontSize={13} fontWeight={800} style={{ fill: "var(--ink)" }}>
          {item.text}
        </text>
      );
    }
  }
}
