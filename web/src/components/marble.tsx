// A marble drawn flat, with the mark that identifies its side (ring, dot, bar, triangle) so colour
// is never the only signal. Colours come from the token CSS variables.

export type Side = 1 | 2 | 3 | 4 | 5 | "pot";

const FILL: Record<string, string> = {
  1: "var(--glaze)",
  2: "var(--amber)",
  3: "var(--jade)",
  4: "var(--plum)",
  5: "var(--rose)",
  pot: "var(--bone)",
};
const MARK: Record<string, string> = {
  1: "var(--on-glaze)",
  2: "var(--on-amber)",
  3: "var(--on-jade)",
  4: "var(--on-plum)",
  5: "var(--on-rose)",
};

export function Marble({
  side,
  x,
  y,
  r = 12,
  ring = false,
}: {
  side: Side;
  x: number;
  y: number;
  r?: number;
  ring?: boolean;
}) {
  const mark = MARK[side];
  return (
    <g>
      {ring && (
        <ellipse
          cx={x}
          cy={y + r * 0.7}
          rx={r * 1.55}
          ry={r * 0.62}
          fill="none"
          stroke="var(--ink)"
          strokeWidth={3}
        />
      )}
      <ellipse
        cx={x + r * 0.2}
        cy={y + r * 0.85}
        rx={r * 0.95}
        ry={r * 0.36}
        style={{ fill: "var(--shadow)" }}
      />
      <circle
        cx={x}
        cy={y}
        r={r}
        style={{ fill: FILL[side] }}
        stroke="var(--ink)"
        strokeWidth={1.5}
      />
      {side === 1 && (
        <circle
          cx={x}
          cy={y}
          r={r * 0.48}
          fill="none"
          style={{ stroke: mark }}
          strokeWidth={Math.max(1.5, r / 6)}
        />
      )}
      {side === 2 && <circle cx={x} cy={y} r={r * 0.24} style={{ fill: mark }} />}
      {side === 3 && (
        <rect x={x - r * 0.5} y={y - r * 0.12} width={r} height={r * 0.24} style={{ fill: mark }} />
      )}
      {side === "pot" && (
        <rect
          x={x - r * 0.5}
          y={y - r * 0.12}
          width={r}
          height={r * 0.24}
          style={{ fill: "var(--ink)" }}
        />
      )}
      {side === 4 && (
        <polygon
          points={`${x},${y - r * 0.5} ${x + r * 0.5},${y + r * 0.38} ${x - r * 0.5},${y + r * 0.38}`}
          style={{ fill: mark }}
        />
      )}
      {side === 5 && (
        <polygon
          points={`${x},${y - r * 0.5} ${x + r * 0.42},${y} ${x},${y + r * 0.5} ${x - r * 0.42},${y}`}
          style={{ fill: mark }}
        />
      )}
      <circle
        cx={x - r * 0.38}
        cy={y - r * 0.4}
        r={r * 0.2}
        style={{ fill: "var(--highlight)" }}
        opacity={0.75}
      />
    </g>
  );
}
