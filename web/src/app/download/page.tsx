import type { Metadata } from "next";
import Link from "next/link";
import { latestRelease } from "@/lib/latest-release";

export const metadata: Metadata = { title: "Download" };
export const revalidate = 3600;

export default async function DownloadPage() {
  const release = await latestRelease();
  return (
    <main className="page">
      <h1>Download</h1>
      <div className="download-layout">
        <div className="prose">
          {release ? (
            <>
              <p className="lede">
                Version {release.version} for Android ({release.apk.sizeMb} MB).
              </p>
              <div className="cta-row">
                <a className="btn-primary" href={release.apk.url}>
                  DOWNLOAD APK
                </a>
                <a href={release.notesUrl}>Release notes</a>
              </div>
              <p className="meta">64-bit ARM. A direct download, not a store build.</p>

              <section className="verify" aria-labelledby="about-apk">
                <h3 id="about-apk">About this APK</h3>
                <dl>
                  <dt>File</dt>
                  <dd>{release.apkName}</dd>
                  <dt>Version</dt>
                  <dd>{release.version}</dd>
                  <dt>Size</dt>
                  <dd>{release.apk.sizeMb} MB</dd>
                  <dt>SHA-256</dt>
                  <dd>
                    {release.sha256 ? (
                      <code>{release.sha256}</code>
                    ) : (
                      "Not published for this release."
                    )}
                  </dd>
                </dl>
                {release.sha256 && (
                  <>
                    <p className="meta" style={{ marginTop: 14 }}>
                      To check the file, compare its checksum with the one above.
                    </p>
                    <pre>
                      <code>shasum -a 256 {release.apkName}</code>
                    </pre>
                    <pre>
                      <code>certutil -hashfile {release.apkName} SHA256</code>
                    </pre>
                  </>
                )}
              </section>
            </>
          ) : (
            <p className="lede">No release is published yet. Check back soon.</p>
          )}

          <h2>In your browser</h2>
          <p>
            No install: the same game runs in your browser. <Link href="/play">Open the game</Link>.
          </p>
        </div>
        <aside className="aside prose">
          <h2>Install</h2>
          <ol className="install">
            <li>
              <div>
                <h3>Download the file</h3>
                <p className="meta">Do it on your phone, from this page.</p>
              </div>
            </li>
            <li>
              <div>
                <h3>Open it</h3>
                <p className="meta">
                  Android asks once to allow installs from your browser. This is normal for a direct
                  download.
                </p>
              </div>
            </li>
            <li>
              <div>
                <h3>Open Guli &amp; Batto</h3>
                <p className="meta">Press Play, choose a game, and drag back from your marble.</p>
              </div>
            </li>
          </ol>

          <h2>Good to know</h2>
          <ul>
            <li>It is not on Google Play and not available for iPhone.</li>
            <li>
              Every build is signed with the same key, so updates install over older versions.
            </li>
            <li>
              It collects nothing. See <Link href="/privacy">privacy</Link>.
            </li>
          </ul>
        </aside>
      </div>
    </main>
  );
}
