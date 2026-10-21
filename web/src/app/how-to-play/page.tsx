import type { Metadata } from "next";

export const metadata: Metadata = { title: "How to play" };

export default function HowToPlayPage() {
  return (
    <main>
      <h1>How to play</h1>
      <h2>Shooting</h2>
      <ol>
        <li>Touch your striker marble and pull back, like a slingshot.</li>
        <li>The arrow shows the direction; the pull length sets the power.</li>
        <li>Release to shoot. Pull back to the start to cancel.</li>
        <li>Wait for every marble to stop. The result is judged once they settle.</li>
      </ol>
      <h2>Camera</h2>
      <p>
        Drag empty ground to orbit, pinch to zoom, and use the reset button any time. The camera
        never changes your shot.
      </p>
      <h2>Modes</h2>
      <p>
        <strong>Kep</strong>: toss a marble from behind the line toward the hole. In the hole or
        closest scores.
      </p>
      <p>
        <strong>Batto</strong>: race along three holes and back. Hit a rival&apos;s marble to earn
        another shot. The last one to finish loses.
      </p>
      <p>
        <strong>Guli Khela</strong>: stake marbles are scattered around the hole. Name one marble as
        baad, then touch exactly one other marble. Touch the baad marble or more than one and you
        pay a fine.
      </p>
      <p>
        <strong>Quick Dan</strong>: one round of Guli Khela.
      </p>
    </main>
  );
}
