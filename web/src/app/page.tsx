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
        <li>Two modes: an adapted pit-and-strike Guli Khela, and a provisional Batto Challenge.</li>
        <li>Plays offline. Progress stays on your device.</li>
      </ul>

      <h2>About the rules</h2>
      <p className="note">
        Guli Khela here is an adaptation of a published description, not a claim of exact
        traditional rules. Batto is a custom mode while we check how people actually play it. If you
        know the game, we would like to hear how you play it.
      </p>
    </main>
  );
}
