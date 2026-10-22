"use client";

import { useEffect } from "react";

// Eases sections in as they scroll into view. Everything below the fold starts hidden only once
// this script runs, so the page is complete without JavaScript, and nothing moves for visitors who
// ask for reduced motion.
const TARGETS =
  ".band-section, .band, .game-row, .game-head, .game-body, .sec, .figure, .split > *";

export function Reveal() {
  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const root = document.documentElement;
    const seen = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (!e.isIntersecting) continue;
          e.target.classList.add("in");
          seen.unobserve(e.target);
        }
      },
      { rootMargin: "0px 0px -8% 0px" },
    );
    root.classList.add("js-reveal");
    for (const el of document.querySelectorAll(TARGETS)) {
      if (el.getBoundingClientRect().top < window.innerHeight) el.classList.add("in");
      else {
        el.classList.add("reveal");
        seen.observe(el);
      }
    }
    return () => {
      seen.disconnect();
      root.classList.remove("js-reveal");
      for (const el of document.querySelectorAll(".reveal")) el.classList.remove("reveal", "in");
    };
  }, []);
  return null;
}
