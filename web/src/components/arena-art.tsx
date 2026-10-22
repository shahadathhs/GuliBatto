import { Marble } from "./marble";

// Flat illustrations of the arena, drawn from the same shapes as the game: the ground, a rim, the
// hole (kep), the jalla (the line to stand behind) and marbles. Not screenshots.

type Variant = "hero" | "kep" | "holes" | "stake";

function Ground({
  cx = 195,
  cy = 140,
  rx = 176,
  ry = 118,
}: {
  cx?: number;
  cy?: number;
  rx?: number;
  ry?: number;
}) {
  return (
    <>
      <ellipse cx={cx} cy={cy + 8} rx={rx + 6} ry={ry + 6} style={{ fill: "var(--earth-rim)" }} />
      <ellipse cx={cx} cy={cy} rx={rx} ry={ry} style={{ fill: "var(--earth)" }} />
    </>
  );
}

const Hole = ({
  x,
  y,
  rx = 17,
  ry = 9,
  label,
}: {
  x: number;
  y: number;
  rx?: number;
  ry?: number;
  label?: string;
}) => (
  <g>
    <ellipse cx={x} cy={y} rx={rx} ry={ry} style={{ fill: "var(--hole)" }} />
    <ellipse
      cx={x}
      cy={y - 1}
      rx={rx}
      ry={ry}
      fill="none"
      stroke="var(--ink)"
      strokeOpacity={0.5}
      strokeWidth={2}
    />
    {label && (
      <text x={x + 26} y={y + 4} fontSize={11} fontWeight={800} style={{ fill: "var(--ink)" }}>
        {label}
      </text>
    )}
  </g>
);

const Jalla = ({ y, half = 100 }: { y: number; half?: number }) => (
  <path
    d={`M${195 - half} ${y} Q195 ${y + 12} ${195 + half} ${y}`}
    fill="none"
    stroke="var(--ink)"
    strokeOpacity={0.6}
    strokeWidth={3}
    strokeDasharray="10 7"
  />
);

export function ArenaArt({ variant = "hero", label }: { variant?: Variant; label: string }) {
  return (
    <svg viewBox="0 0 390 300" role="img" aria-label={label} className="arena-art">
      <Ground />
      {variant === "hero" && (
        <>
          <Hole x={195} y={70} label="H3" />
          <Hole x={195} y={110} label="H2" />
          <Hole x={195} y={150} label="H1" />
          <Jalla y={232} half={90} />
          <Marble side={2} x={120} y={120} />
          <Marble side={3} x={270} y={90} />
          <Marble side="pot" x={250} y={175} />
          <g className="hero-shot">
            <Marble side={1} x={195} y={205} r={14} ring />
          </g>
        </>
      )}
      {variant === "kep" && (
        <>
          <Hole x={195} y={95} rx={26} ry={14} />
          <Jalla y={225} />
          <Marble side={2} x={150} y={125} />
          <Marble side={1} x={195} y={200} r={14} ring />
        </>
      )}
      {variant === "holes" && (
        <>
          <Hole x={195} y={70} label="H3" />
          <Hole x={195} y={110} label="H2" />
          <Hole x={195} y={150} label="H1" />
          <Jalla y={225} />
          <Marble side={1} x={195} y={198} r={14} ring />
        </>
      )}
      {variant === "stake" && (
        <>
          <Hole x={195} y={100} rx={22} ry={12} />
          {[
            [160, 78],
            [232, 82],
            [150, 125],
            [240, 125],
            [175, 150],
            [215, 152],
          ].map(([x, y]) => (
            <Marble key={`${x}-${y}`} side="pot" x={x} y={y} r={11} />
          ))}
          <Jalla y={225} />
          <Marble side={1} x={195} y={200} r={14} ring />
        </>
      )}
    </svg>
  );
}
