import type { Metadata } from "next";

export const metadata: Metadata = { title: "Privacy" };

export default function PrivacyPage() {
  return (
    <main className="page prose">
      <h1>Privacy</h1>
      <p className="lede">Guli &amp; Batto collects nothing.</p>
      <p>
        There are no accounts, no analytics, no ads and no network calls in the game. Settings and
        match statistics, when they are saved, stay on your device and are removed when you
        uninstall the app or reset them in it.
      </p>
      <h2>This website</h2>
      <p>
        It sets no cookies and uses no trackers. If you choose a light or dark theme, that choice is
        kept in your browser on your device and is never sent anywhere. The download page asks
        GitHub for the latest release; GitHub&apos;s own privacy policy applies when you download
        from it. The browser version of the game runs entirely in your browser and sends nothing.
      </p>
    </main>
  );
}
