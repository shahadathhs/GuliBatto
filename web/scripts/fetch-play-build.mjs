// Fetches the game's browser export from a GitHub release into public/play-build, so the site can
// serve /play. Runs before `next build`. It never fails the build: without an export the /play
// page says the browser version is not available.
//   PLAY_BUILD_TAG   release tag to read (default: latest, the rolling build)
//   GITHUB_REPOSITORY  owner/name (default: shahadathhs/GuliBatto)
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { tmpdir } from "node:os";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const dest = join(root, "public", "play-build");
const repo = process.env.GITHUB_REPOSITORY ?? "shahadathhs/GuliBatto";
const tag = process.env.PLAY_BUILD_TAG ?? "latest";

if (existsSync(join(dest, "index.html"))) {
  console.log("play-build: using the export already in public/play-build");
  process.exit(0);
}

try {
  const headers = { Accept: "application/vnd.github+json" };
  const res = await fetch(`https://api.github.com/repos/${repo}/releases/tags/${tag}`, { headers });
  if (!res.ok) throw new Error(`release ${tag} answered ${res.status}`);
  const release = await res.json();
  const asset = release.assets?.find((a) => /^gulibatto-web-.*\.tar\.gz$/.test(a.name));
  if (!asset || !asset.browser_download_url?.startsWith("https://"))
    throw new Error("no web export in the release");
  const file = await fetch(asset.browser_download_url);
  if (!file.ok) throw new Error(`download answered ${file.status}`);
  const archive = join(tmpdir(), asset.name);
  writeFileSync(archive, Buffer.from(await file.arrayBuffer()));
  rmSync(dest, { recursive: true, force: true });
  mkdirSync(dest, { recursive: true });
  execFileSync("tar", ["-xzf", archive, "-C", dest]);
  console.log(`play-build: fetched ${asset.name} from ${repo}@${tag}`);
} catch (e) {
  console.log(
    `play-build: not fetched (${e instanceof Error ? e.message : e}); /play will say it is unavailable`,
  );
}
