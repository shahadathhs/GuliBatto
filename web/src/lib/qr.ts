import qrcode from "qrcode-generator";

/** A QR code as one SVG path in module units, plus its side length (without the quiet zone). */
export function qrPath(text: string): { d: string; size: number } {
  const qr = qrcode(0, "M");
  qr.addData(text);
  qr.make();
  const size = qr.getModuleCount();
  let d = "";
  for (let row = 0; row < size; row++) {
    for (let col = 0; col < size; col++) {
      if (qr.isDark(row, col)) d += `M${col} ${row}h1v1h-1z`;
    }
  }
  return { d, size };
}
