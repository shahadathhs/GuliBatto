"use client";

import { useState } from "react";

// Loads nothing until Play is pressed: the export is tens of megabytes. Without JavaScript the
// page says so (see the <noscript> in the page).
export function PlayFrame() {
  const [started, setStarted] = useState(false);

  if (!started) {
    return (
      <p>
        <button className="btn-primary" onClick={() => setStarted(true)}>
          PLAY
        </button>
      </p>
    );
  }
  return (
    <iframe
      className="play-frame"
      src="/play-build/index.html"
      title="Guli & Batto"
      allow="fullscreen"
    />
  );
}
