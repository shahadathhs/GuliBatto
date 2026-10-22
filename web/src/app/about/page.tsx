import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "About these games",
  description:
    "Where the rules of Guli & Batto come from, and what the author changed for play on a phone.",
};

// The text mirrors docs/README_ABOUT.md and content/pages/about.json (which the game shows); change
// all three together. `make content-check` fails when the doc and the content differ.
export default function AboutPage() {
  return (
    <main className="page prose">
      <h1>About these games</h1>

      <h2>These are childhood games</h2>
      <p>
        I grew up playing marble games on bare ground: a line drawn with a stick, a small hole, a
        handful of marbles, and no rulebook. The rules lived in our heads and changed a little from
        street to street. I made this game to bring those afternoons back.
      </p>

      <h2>Where the rules come from</h2>
      <p>
        Nothing here is invented from nothing. Each mode starts with a game people really played:
      </p>
      <ul>
        <li>
          <strong>Kep</strong> is the toss at the hole that decided who went first.
        </li>
        <li>
          <strong>Batto</strong> is the three-hole race as I remember it: along the holes and back,
          hitting a rival&apos;s marble to earn another shot.
        </li>
        <li>
          <strong>Guli Khela</strong> is the game of the line, the hole, the stake, and the marble
          you must not touch. It follows a written Bangla account of the <em>jalla</em>, the{" "}
          <em>kep</em>, the <em>dan</em>, the <em>baad</em> marble and the fine, and it agrees with
          the short description in Banglapedia.
        </li>
        <li>
          <strong>Quick Dan</strong> is one round of Guli Khela, for when you have a few minutes.
        </li>
      </ul>
      <p>
        I use the words those accounts use. Where you grew up, the line, the hole or the game itself
        may have another name.
      </p>

      <h2>What I changed</h2>
      <p>
        I changed some rules so the games work well on a phone. These are my decisions, not the
        tradition&apos;s:
      </p>
      <ul>
        <li>The game scatters the marbles around the hole for you.</li>
        <li>A marble that leaves the play area is put back where it left.</li>
        <li>Bonus shots and turns have limits, so a game always ends.</li>
        <li>
          In Batto, a marble that finishes the route leaves the ground, a first toss that lands in
          the first hole counts as reaching it, and a marble resting in a hole is shot from the edge
          of the hole.
        </li>
        <li>
          The number of marbles in a stake, the size of a fine, and the number of rounds are set to
          make a good game on a small screen.
        </li>
        <li>
          In Guli Khela, every side including the scatterer pays the stake, a fine is one marble
          that the game sets down by the hole, and giving up ends the match with you last.
        </li>
        <li>You can play against computer players, and you can surrender.</li>
      </ul>

      <h2>What this is not</h2>
      <p>
        It is not an official or complete rulebook, and it does not claim to be how the game was
        played everywhere. If you remember it differently, you are not wrong. Your way might be the
        one I never saw.
      </p>

      <h2>Tell me how you played</h2>
      <p>
        If you know these games, I would like to hear how you played them: the names you used, the
        distances, what happened when someone missed. I will keep learning from you, and the rules
        will change as I do.
      </p>
    </main>
  );
}
