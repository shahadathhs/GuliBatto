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
        <strong>Guli Khela</strong> (adapted): get target marbles to rest in the pit, or strike them
        cleanly. A miss ends the turn.
      </p>
      <p>
        <strong>Batto Challenge</strong> (provisional): knock the other side&apos;s marbles out of
        the ring while keeping yours in.
      </p>
    </main>
  );
}
