import type { Metadata } from "next";

export const metadata: Metadata = { title: "Download" };

// Rebuilt when CI publishes a release; also refreshed hourly.
export const revalidate = 3600;

const REPO = process.env.GITHUB_REPOSITORY ?? "shahadathhs/GuliBatto";

type Asset = { name: string; browser_download_url: string; size: number };
type Release = { tag_name: string; html_url: string; assets: Asset[] };

async function latestRelease(): Promise<Release | null> {
  try {
    const res = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`, {
      headers: { Accept: "application/vnd.github+json" },
      next: { revalidate: 3600 },
    });
    return res.ok ? ((await res.json()) as Release) : null;
  } catch {
    return null;
  }
}

export default async function DownloadPage() {
  const release = await latestRelease();
  const apk = release?.assets.find((a) => a.name.endsWith(".apk"));
  const sum = release?.assets.find((a) => a.name.endsWith(".apk.sha256"));

  return (
    <main>
      <h1>Download</h1>
      {apk && release ? (
        <>
          <p>
            Version {release.tag_name.replace(/^v/, "")} for Android ({(apk.size / 1e6).toFixed(0)}{" "}
            MB).
          </p>
          <p>
            <a className="button" href={apk.browser_download_url}>
              Download APK
            </a>
          </p>
          {sum && (
            <p>
              <a href={sum.browser_download_url}>SHA-256 checksum</a>
            </p>
          )}
          <p>
            <a href={release.html_url}>Release notes</a>
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
