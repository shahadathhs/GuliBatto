import type { Metadata } from "next";
import Link from "next/link";
import { PlayFrame } from "@/components/play-frame";
import { hasPlayBuild } from "@/lib/play-build";

export const metadata: Metadata = { title: "Play" };

export default function PlayPage() {
  const available = hasPlayBuild();
  return (
    <main className="page">
      <h1>Play in your browser</h1>
      {available ? (
        <>
          <p className="lede">
            The same game as the Android app. Press your marble, drag back, and release. The first
            load downloads about 40 MB, then your browser keeps it.
          </p>
          <noscript>
            <p>The browser version needs JavaScript.</p>
          </noscript>
          <PlayFrame />
          <p className="meta">
            Nothing is saved or sent anywhere. For the best feel,{" "}
            <Link href="/download">install the Android app</Link>.
          </p>
        </>
      ) : (
        <p className="lede">
          The browser version is not available right now. You can{" "}
          <Link href="/download">download the Android app</Link> instead.
        </p>
      )}
    </main>
  );
}
