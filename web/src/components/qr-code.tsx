import { qrPath } from "@/lib/qr";

const QUIET = 3;

/** A QR code drawn on the server, so nothing is fetched. Dark on light in both themes, which is
 * what scanners read best. */
export function QrCode({ text, label }: { text: string; label: string }) {
  const { d, size } = qrPath(text);
  const side = size + QUIET * 2;
  return (
    <svg viewBox={`0 0 ${side} ${side}`} role="img" aria-label={label} className="qr">
      <rect width={side} height={side} rx={1.2} style={{ fill: "var(--bone)" }} />
      <path
        d={d}
        transform={`translate(${QUIET} ${QUIET})`}
        style={{ fill: "var(--hole)" }}
        shapeRendering="crispEdges"
      />
    </svg>
  );
}
