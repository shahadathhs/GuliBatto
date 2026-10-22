"use client";

import { useState } from "react";

// A phone with a Play button first; pressing it replaces the phone with the game itself, which
// needs no frame of its own. Nothing is downloaded until Play is pressed, because the export is
// tens of megabytes. Without JavaScript the page says so (see the <noscript> in the page).
export function PlayFrame() {
  const [started, setStarted] = useState(false);
  if (started) {
    return (
      <iframe
        className="play-frame"
        src="/play-build/index.html"
        title="Guli & Batto"
        allow="fullscreen"
      />
    );
  }
  return (
    <div className="phone">
      <div className="phone-top" aria-hidden="true">
        <span className="phone-speaker" />
        <span className="phone-camera" />
      </div>
      <div className="phone-screen">
        <div className="phone-start">
          <button className="btn-primary phone-play" onClick={() => setStarted(true)}>
            PLAY
          </button>
          <p className="meta">Loads the game, about 40 MB.</p>
        </div>
      </div>
      <span className="phone-bar" aria-hidden="true" />
    </div>
  );
}
