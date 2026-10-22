import type { Metadata } from "next";

export const metadata: Metadata = { title: "How to play" };

export default function HowToPlayPage() {
  return (
    <main className="page prose">
      <h1>How to play</h1>
      <h2>Shooting</h2>
      <p>
        Press your marble and drag away from where you want it to go, like a slingshot. The arrow
        shows the direction, and a longer pull means more power. Release to shoot. Pull back to the
        start to cancel.
      </p>
      <h2>Camera</h2>
      <p>
        Drag empty ground to turn the view, scroll or pinch to zoom, and use the buttons at the
        bottom to change view or reset it. The camera never changes your shot.
      </p>
      <h2>The games</h2>
      <p>
        <strong>Kep</strong>: toss a marble from behind the line toward the hole. A marble resting
        in the hole scores 3. Of the rest, the closest scores 2 and the next closest 1. After five
        rounds the highest total wins.
      </p>
      <p>
        <strong>Batto</strong>: everyone tosses once toward the first hole, and the closest goes
        first. Then each side shoots its own marble from where it lies (from the edge of the hole,
        if it rests in one), along the first, second and third hole and back to the first. Reach the
        hole you are heading for, or hit a rival&apos;s marble, and you shoot again (up to three
        extra shots in a turn). The last one to finish loses.
      </p>
      <p>
        <strong>Guli Khela</strong>: every side pays a stake of marbles and tosses toward the hole.
        The closest side scatters the stake round the hole, and everyone else gets one attempt in
        turn. First tap the marble you must not touch: the baad. Then throw your marble. Touch
        exactly one other marble, and not the baad, and you win the dan and every marble on the
        ground. Touch the baad, or more than one marble, and you pay a fine of one marble from your
        purse, which stays on the ground. Touch nothing and your attempt is over. If nobody wins in
        three passes, the side that scattered keeps the ground. A side that cannot pay the next
        stake is out. Pause the match to surrender.
      </p>
      <p>
        <strong>Quick Dan</strong>: one dan of Guli Khela, for a few minutes. The same stake,
        scatter, baad and fines, and the match ends when the dan is won.
      </p>
    </main>
  );
}
