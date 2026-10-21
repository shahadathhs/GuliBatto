import Link from "next/link";

export default function HomePage() {
  return (
    <main>
      <h1>Line up the shot. Let the marbles roll.</h1>
      <p className="lede">
        Guli &amp; Batto is a small 3D marble game for your phone, inspired by the marble games of
        Bangladesh. No accounts, no ads, no internet needed after install.
      </p>
      <p>
        <Link className="button" href="/download">
          Download
        </Link>
      </p>

      <h2>What it is</h2>
      <ul>
        <li>Real rolling, friction and collisions, so every shot can be learned.</li>
        <li>Drag back to aim, release to shoot, and orbit the camera to judge distance.</li>
        <li>
          Four modes, each a modernised version of a game people played: Kep, Batto, Guli Khela and
          Quick Dan.
        </li>
        <li>Plays offline. Progress stays on your device.</li>
      </ul>

      <h2>Childhood games, remembered</h2>
      <p className="note">
        Nothing here is invented from nothing: each mode starts with a game people played, and I
        changed some rules to work on a phone.{" "}
        <Link href="/about">Read where the rules come from and what I changed.</Link>
      </p>
    </main>
  );
}
