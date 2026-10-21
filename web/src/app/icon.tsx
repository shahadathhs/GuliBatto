import { ImageResponse } from "next/og";
import { LIGHT } from "@/lib/token-colors.generated";

export const size = { width: 64, height: 64 };
export const contentType = "image/png";

// The favicon: a blue marble with its ring mark, on the ground colour.
export default function Icon() {
  const c = LIGHT;
  return new ImageResponse(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: c.ground,
      }}
    >
      <svg width="56" height="56" viewBox="0 0 56 56">
        <circle cx="28" cy="28" r="25" fill={c.glaze} stroke={c.ink} strokeWidth="3" />
        <circle cx="28" cy="28" r="12" fill="none" stroke={c["on-glaze"]} strokeWidth="4" />
      </svg>
    </div>,
    size,
  );
}
