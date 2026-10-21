import Link from "next/link";
import { ArenaArt } from "@/components/arena-art";
import { latestRelease } from "@/lib/latest-release";
import { hasPlayBuild } from "@/lib/play-build";

export const revalidate = 3600;

const STEPS = [
  ["Aim", "Press your marble and pull back, like a slingshot. The arrow shows where it will go."],
  ["Release", "A longer pull means more power. Let go and watch the marbles roll."],
  ["Read the result", "Points are judged once everything has stopped, so every shot is clear."],
] as const;

const MODES = [
  ["kep", "Kep", "Toss at the hole. In the hole scores most, then the closest."],
  ["holes", "Batto", "Race along three holes and back. Hit a rival for another shot."],
  ["stake", "Guli Khela", "Name the marble you must not touch, then touch exactly one other."],
  ["stake", "Quick Dan", "One round of Guli Khela, for when you have a few minutes."],
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
            A small 3D marble game for your phone, made from the traditional marble games of
            Bangladesh. No accounts, no ads, no internet needed after install.
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
          label="The arena: three holes in a line, the line to stand behind, and marbles."
        />
      </section>

      <h2>How it works</h2>
      <ol className="steps">
        {STEPS.map(([title, text], i) => (
          <li key={title}>
            <span className="step-number" aria-hidden="true">
              {i + 1}
            </span>
            <h3>{title}</h3>
            <p className="meta" style={{ fontSize: 17 }}>
              {text}
            </p>
          </li>
        ))}
      </ol>

      <h2>The games</h2>
      <ul className="modes">
        {MODES.map(([art, name, text]) => (
          <li key={name} className="mode">
            <ArenaArt variant={art} label={`${name}: a small drawing of its arena.`} />
            <div>
              <h3>{name}</h3>
              <p>{text}</p>
            </div>
          </li>
        ))}
      </ul>
      <p className="meta" style={{ marginTop: 20 }}>
        Playable now: Kep. Batto, Guli Khela and Quick Dan are built next.
      </p>
      <p className="note">
        Nothing here is invented from nothing: each game starts with one people played, and I
        changed some rules to work on a phone.{" "}
        <Link href="/about">Read where the rules come from and what I changed.</Link>
      </p>

      <h2>The short list</h2>
      <ul className="short-list">
        <li>Plays offline. Progress stays on your device.</li>
        <li>Real rolling, friction and collisions, so every shot can be learned.</li>
        <li>Up to four sides, with computer players.</li>
        <li>Light and dark themes.</li>
        <li>No accounts, ads or purchases.</li>
        <li>Made by one person, from memory.</li>
      </ul>

      <section className="band" aria-label="Download">
        <h2>Free for Android.</h2>
        <Link className="btn-primary" href="/download">
          DOWNLOAD FOR ANDROID
        </Link>
      </section>
    </main>
  );
}
