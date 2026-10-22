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
        first. Then each side shoots its own marble from where it lies, along the first, second and
        third hole and back to the first. Reach the hole you are heading for, or hit a rival&apos;s
        marble, and you shoot again (up to three extra shots in a turn). The last one to finish
        loses.
      </p>
      <p>
        <strong>Guli Khela</strong>: stake marbles are scattered around the hole. Name one marble as
        baad, then touch exactly one other marble. Touch the baad marble or more than one and you
        pay a fine. The winner of a round takes every marble on the ground.
      </p>
      <p>
        <strong>Quick Dan</strong>: one round of Guli Khela.
      </p>
      <p className="meta">Kep and Batto are playable so far; the others are built next.</p>
    </main>
  );
}
