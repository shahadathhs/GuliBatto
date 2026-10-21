import type { Metadata } from "next";
import { parseRelease, type Release } from "@/lib/release";

export const metadata: Metadata = { title: "Download" };

// Rebuilt when CI publishes a release; also refreshed hourly.
export const revalidate = 3600;

const REPO = process.env.GITHUB_REPOSITORY ?? "shahadathhs/GuliBatto";

async function latestRelease(): Promise<Release | null> {
  try {
    const res = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`, {
      headers: { Accept: "application/vnd.github+json" },
      next: { revalidate: 3600 },
    });
    return res.ok ? parseRelease(await res.json()) : null;
  } catch {
    return null;
  }
}

export default async function DownloadPage() {
  const release = await latestRelease();

  return (
    <main>
      <h1>Download</h1>
      {release ? (
        <>
          <p>
            Version {release.version} for Android ({release.apk.sizeMb} MB).
          </p>
          <p>
            <a className="button" href={release.apk.url}>
              Download APK
            </a>
          </p>
          {release.checksumUrl && (
            <p>
              <a href={release.checksumUrl}>SHA-256 checksum</a>
            </p>
          )}
          <p>
            <a href={release.notesUrl}>Release notes</a>
          </p>
        </>
      ) : (
        <p>No release is published yet. Check back soon.</p>
      )}
      <h2>Installing</h2>
      <p>
        Open the APK on your phone and allow installs from your browser when asked. This is a direct
        download, not a store build, so Android will warn you.
      </p>
    </main>
  );
}
