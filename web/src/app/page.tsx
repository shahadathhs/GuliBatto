import Link from "next/link";
import { ArenaArt } from "@/components/arena-art";
import { SlingshotDemo } from "@/components/slingshot-demo";
import { GameArt } from "@/components/game-art";
import { GAMES, card } from "@/lib/content";
import { latestRelease } from "@/lib/latest-release";
import { hasPlayBuild } from "@/lib/play-build";

export const revalidate = 3600;

const STEPS = [
  ["Aim", "Press your marble and pull back, like a slingshot. The arrow shows where it will go."],
  ["Release", "A longer pull means more power. Let go and watch the marbles roll."],
  ["Read the result", "Points are judged once everything has stopped, so every shot is clear."],
] as const;

const FACTS = [
  ["Offline", "Plays without a connection. Progress stays on your device."],
  ["Real physics", "Rolling, friction and collisions, so every shot can be learned."],
  ["Computer sides", "Play against two computer players, and surrender any time."],
  ["Light and dark", "Both themes, drawn for small screens."],
  ["Nothing to sign up for", "No accounts, ads or purchases."],
  ["By one person", "Made from memory of games played as a child."],
] as const;

export default async function HomePage() {
  const release = await latestRelease();
  const play = hasPlayBuild();
  return (
    <main className="page">
      <section className="hero">
        <div>
          <h1>Line up the shot. Let the marbles roll.</h1>
          <p className="lede">
            A small 3D marble game for your phone and your browser, made from the traditional marble
            games of Bangladesh. Four games, no accounts, no ads.
          </p>
          <div className="cta-row">
            <Link className="btn-primary" href="/download">
              DOWNLOAD FOR ANDROID
            </Link>
            {play && <Link href="/play">Play in your browser</Link>}
          </div>
          {release && (
            <p className="meta">
              Version {release.version} · {release.apk.sizeMb} MB
            </p>
          )}
        </div>
        <ArenaArt
          variant="hero"
          label="The ground: three holes in a line, the line to stand behind, and marbles."
        />
      </section>

      <section className="band-section">
        <h2>How it works</h2>
        <div className="how">
          <ol className="steps">
            {STEPS.map(([title, text], i) => (
              <li key={title}>
                <span className="step-number" aria-hidden="true">
                  {i + 1}
                </span>
                <h3>{title}</h3>
                <p className="meta">{text}</p>
              </li>
            ))}
          </ol>
          <SlingshotDemo />
        </div>
      </section>

      <section className="band-section">
        <h2>The four games</h2>
        <ul className="game-grid">
          {GAMES.map((g) => {
            const c = card(g.card);
            return (
              <li key={g.slug} className="game-tile">
                <div className="art">
                  <GameArt cardId={g.card} />
                </div>
                <h3>{c.title}</h3>
                <p className="meta">{c.lines[0]}</p>
                <p>
                  <Link href={`/games/${g.slug}`}>Rules for {c.title}</Link>
                </p>
              </li>
            );
          })}
        </ul>
      </section>

      <section className="band-section">
        <h2>The short list</h2>
        <dl className="facts">
          {FACTS.map(([term, text]) => (
            <div key={term}>
              <dt>{term}</dt>
              <dd>{text}</dd>
            </div>
          ))}
        </dl>
      </section>

      <section className="band-section two">
        <div>
          <h2>Where to play</h2>
          <p className="meta">The same game in both places, with the same rules.</p>
          <ul className="where">
            <li>
              <h3>Android</h3>
              <p className="meta">A direct download, signed, with a checksum to verify it.</p>
              <Link href="/download">Download the app</Link>
            </li>
            <li>
              <h3>In your browser</h3>
              <p className="meta">Nothing to install. Settings stay in the browser.</p>
              <Link href={play ? "/play" : "/download"}>
                {play ? "Open the game" : "See downloads"}
              </Link>
            </li>
          </ul>
        </div>
        <div>
          <h2>Where it comes from</h2>
          <p className="note">
            Nothing here is invented from nothing: each game starts with one people played, and I
            changed some rules to work on a phone.{" "}
            <Link href="/about">Read where the rules come from and what I changed.</Link>
          </p>
          <p className="meta" style={{ marginTop: 20 }}>
            Played them differently? <Link href="/contact">Tell me how you played.</Link>
          </p>
        </div>
      </section>

      <section className="band" aria-label="Download">
        <h2>Free for Android.</h2>
        <Link className="btn-primary" href="/download">
          DOWNLOAD FOR ANDROID
        </Link>
      </section>
    </main>
  );
}
