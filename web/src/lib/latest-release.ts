import { parseChecksum, parseRelease, type Release } from "./release";

const REPO = process.env.GITHUB_REPOSITORY ?? "shahadathhs/GuliBatto";
// Only for testing the page against a stand-in server. Leave it unset in production.
const API = process.env.GITHUB_API_URL ?? "https://api.github.com";

export type LatestRelease = (Release & { sha256: string | null }) | null;

// The newest versioned release, read when the site is built and refreshed hourly. Any problem
// gives null, so pages fall back to "no release yet" and never show a bad link.
export async function latestRelease(): Promise<LatestRelease> {
  try {
    const res = await fetch(`${API}/repos/${REPO}/releases/latest`, {
      headers: { Accept: "application/vnd.github+json" },
      next: { revalidate: 3600 },
    });
    if (!res.ok) return null;
    const release = parseRelease(await res.json());
    if (!release) return null;
    let sha256: string | null = null;
    if (release.checksumUrl) {
      const sum = await fetch(release.checksumUrl, { next: { revalidate: 3600 } });
      if (sum.ok) sha256 = parseChecksum(await sum.text());
    }
    return { ...release, sha256 };
  } catch {
    return null;
  }
}
