import { test } from "node:test";
import assert from "node:assert/strict";
import { parseChecksum, parseRelease } from "./release.ts";

const asset = (name: string, size = 48_000_000) => ({
  name,
  size,
  browser_download_url: `https://github.com/o/r/releases/download/v1.2.3/${name}`,
});
const release = (over: Record<string, unknown> = {}) => ({
  tag_name: "v1.2.3",
  html_url: "https://github.com/o/r/releases/tag/v1.2.3",
  assets: [asset("gulibatto-1.2.3.apk"), asset("gulibatto-1.2.3.apk.sha256", 90)],
  ...over,
});

test("reads a valid release", () => {
  const r = parseRelease(release());
  assert.equal(r?.version, "1.2.3");
  assert.equal(r?.apkName, "gulibatto-1.2.3.apk");
  assert.equal(r?.apk.sizeMb, 48);
  assert.match(r?.apk.url ?? "", /\.apk$/);
  assert.match(r?.checksumUrl ?? "", /\.apk\.sha256$/);
});

test("a release without a checksum still works, with no checksum link", () => {
  const r = parseRelease(release({ assets: [asset("gulibatto-1.2.3.apk")] }));
  assert.equal(r?.checksumUrl, null);
});

test("no APK means no release", () => {
  assert.equal(parseRelease(release({ assets: [asset("notes.txt")] })), null);
});

test("a non-https download link is refused", () => {
  const bad = { name: "x.apk", size: 10, browser_download_url: "http://example.com/x.apk" };
  assert.equal(parseRelease(release({ assets: [bad] })), null);
});

test("an odd tag is refused", () => {
  assert.equal(parseRelease(release({ tag_name: "latest" })), null);
  assert.equal(parseRelease(release({ tag_name: "v1.2" })), null);
});

test("garbage in, null out", () => {
  for (const v of [null, undefined, 42, "x", [], {}, { tag_name: 1 }])
    assert.equal(parseRelease(v), null);
});

test("a zero-byte or missing size is refused", () => {
  assert.equal(parseRelease(release({ assets: [asset("a.apk", 0)] })), null);
});

test("a checksum file is read, and only a real one", () => {
  const hex = "ab".repeat(32);
  assert.equal(parseChecksum(`${hex}  gulibatto-1.2.3.apk\n`), hex);
  assert.equal(parseChecksum(hex.toUpperCase()), hex);
  assert.equal(parseChecksum("not a checksum"), null);
  assert.equal(parseChecksum("abc123  file"), null);
  assert.equal(parseChecksum(""), null);
});
