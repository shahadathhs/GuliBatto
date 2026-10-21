import { ImageResponse } from "next/og";
import { LIGHT } from "@/lib/token-colors.generated";

export const alt = "Guli & Batto: marble games from childhood";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

// The share card: the wordmark, one line, and the arena with a few marbles. Colours are the
// light-theme tokens.
export default function Image() {
  const c = LIGHT;
  const marble = (x: number, y: number, fill: string, r = 26) => (
    <g>
      <ellipse cx={x + 5} cy={y + r * 0.85} rx={r * 0.95} ry={r * 0.36} fill={c.shadow} />
      <circle cx={x} cy={y} r={r} fill={fill} stroke={c.ink} strokeWidth={3} />
      <circle cx={x - r * 0.38} cy={y - r * 0.4} r={r * 0.2} fill={c.highlight} opacity={0.75} />
    </g>
  );
  return new ImageResponse(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        background: c.ground,
        color: c.ink,
        padding: 72,
      }}
    >
      <div style={{ display: "flex", flexDirection: "column", justifyContent: "center", flex: 1 }}>
        <div style={{ fontSize: 88, fontWeight: 800, letterSpacing: 4 }}>GULI &amp; BATTO</div>
        <div style={{ fontSize: 34, color: c.mute, marginTop: 16 }}>
          Marble games from childhood
        </div>
        <div
          style={{
            display: "flex",
            marginTop: 48,
            alignSelf: "flex-start",
            background: c.glaze,
            color: c["on-glaze"],
            fontSize: 30,
            fontWeight: 800,
            letterSpacing: 3,
            padding: "18px 40px",
            borderRadius: 999,
          }}
        >
          DOWNLOAD FOR ANDROID
        </div>
      </div>
      <svg width="460" height="486" viewBox="0 0 460 486" style={{ alignSelf: "center" }}>
        <ellipse cx="230" cy="250" rx="226" ry="190" fill={c["earth-rim"]} />
        <ellipse cx="230" cy="236" rx="220" ry="184" fill={c.earth} />
        <ellipse cx="230" cy="170" rx="30" ry="16" fill={c.hole} />
        {marble(150, 250, c.amber)}
        {marble(320, 220, c.jade)}
        {marble(230, 340, c.glaze, 30)}
      </svg>
    </div>,
    size,
  );
}
