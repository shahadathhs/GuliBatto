import type { Metadata } from "next";
import Link from "next/link";
import { Blocks } from "@/components/blocks";
import { PlayFrame } from "@/components/play-frame";
import { page, sections } from "@/lib/content";
import { hasPlayBuild } from "@/lib/play-build";

export const metadata: Metadata = { title: "Play" };

export default function PlayPage() {
  const available = hasPlayBuild();
  const shot = sections(page("how_to_play").blocks).find((s) => s.title === "Taking a shot");
  return (
    <main className="page">
      <h1>Play in your browser</h1>
      {available ? (
        <div className="play-layout">
          <div>
            <noscript>
              <p>The browser version needs JavaScript.</p>
            </noscript>
            <PlayFrame />
          </div>
          <aside className="aside prose">
            <p className="lede">
              The same game as the Android app. The first load downloads about 40 MB, then your
              browser keeps it.
            </p>
            {shot && (
              <>
                <h2>{shot.title}</h2>
                <Blocks blocks={shot.blocks} />
              </>
            )}
            <p className="meta">
              Settings stay in this browser and nothing is sent anywhere. For the best feel,{" "}
              <Link href="/download">install the Android app</Link>.
            </p>
          </aside>
        </div>
      ) : (
        <p className="lede">
          The browser version is not available right now. You can{" "}
          <Link href="/download">download the Android app</Link> instead.
        </p>
      )}
    </main>
  );
}
