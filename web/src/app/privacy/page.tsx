import type { Metadata } from "next";

export const metadata: Metadata = { title: "Privacy" };

export default function PrivacyPage() {
  return (
    <main>
      <h1>Privacy</h1>
      <p>
        Guli &amp; Batto collects nothing. There are no accounts, no analytics, no ads and no
        network calls in the game. Settings and match statistics are stored only on your device and
        are removed when you uninstall or reset them in the game.
      </p>
      <p>
        This website sets no cookies and uses no trackers. Its download page asks GitHub for the
        latest release; GitHub&apos;s own privacy policy applies when you download from it.
      </p>
    </main>
  );
}
