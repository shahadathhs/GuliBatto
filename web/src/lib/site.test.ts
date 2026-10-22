import { test } from "node:test";
import assert from "node:assert/strict";
import { resolveSiteUrl } from "./site.ts";

test("SITE_URL wins, without a trailing slash", () => {
  const env = { SITE_URL: "https://example.org/", VERCEL_PROJECT_PRODUCTION_URL: "x.vercel.app" };
  assert.equal(resolveSiteUrl(env), "https://example.org");
});

test("without SITE_URL the Vercel production address is used, over https", () => {
  assert.equal(
    resolveSiteUrl({ VERCEL_PROJECT_PRODUCTION_URL: "playgulibatto.vercel.app" }),
    "https://playgulibatto.vercel.app",
  );
});

test("with neither, development falls back to localhost", () => {
  assert.equal(resolveSiteUrl({}), "http://localhost:3000");
  assert.equal(resolveSiteUrl({ SITE_URL: "" }), "http://localhost:3000");
});
