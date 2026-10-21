import { existsSync } from "node:fs";
import { join } from "node:path";

// The browser export of the game, copied into public/play-build by `make web-play` or fetched from
// the latest release at build time (scripts/fetch-play-build.mjs). Absent until one exists.
export const PLAY_BUILD_DIR = join(process.cwd(), "public", "play-build");

export function hasPlayBuild(): boolean {
  return existsSync(join(PLAY_BUILD_DIR, "index.html"));
}
