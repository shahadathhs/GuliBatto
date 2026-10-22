import assert from "node:assert/strict";
import { test } from "node:test";
import { qrPath } from "./qr.ts";

test("a QR code is a square of modules with finder patterns in three corners", () => {
  const { d, size } = qrPath("https://example.com/download");
  assert.ok(size >= 21 && (size - 21) % 4 === 0);
  assert.ok(d.startsWith("M0 0h1v1h-1z"), "top-left finder pattern starts at the corner");
  assert.ok(d.includes(`M${size - 1} 0h1v1h-1z`), "top-right finder pattern");
  assert.ok(d.includes(`M0 ${size - 1}h1v1h-1z`), "bottom-left finder pattern");
});

test("the same text gives the same code", () => {
  assert.equal(qrPath("a").d, qrPath("a").d);
});
