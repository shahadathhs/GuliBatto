"use client";

import { useSyncExternalStore } from "react";

type Choice = "system" | "light" | "dark";
const NEXT: Record<Choice, Choice> = { system: "light", light: "dark", dark: "system" };
const EVENT = "themechange";

// The current choice lives on <html data-theme>, which the head script sets before first paint.
const read = (): Choice =>
  (document.documentElement.getAttribute("data-theme") as Choice | null) ?? "system";
const readOnServer = (): Choice | null => null;
const subscribe = (notify: () => void) => {
  window.addEventListener(EVENT, notify);
  return () => window.removeEventListener(EVENT, notify);
};

function choose(next: Choice) {
  if (next === "system") document.documentElement.removeAttribute("data-theme");
  else document.documentElement.setAttribute("data-theme", next);
  try {
    if (next === "system") localStorage.removeItem("theme");
    else localStorage.setItem("theme", next);
  } catch {}
  window.dispatchEvent(new Event(EVENT));
}

// A progressive enhancement: it appears once the page is interactive, and the choice stays on this
// device (localStorage only, never sent anywhere). Without JavaScript the site follows the system.
export function ThemeToggle() {
  const choice = useSyncExternalStore(subscribe, read, readOnServer);
  if (choice === null) return null;
  return (
    <button
      type="button"
      className="theme-toggle"
      aria-label={`Theme: ${choice}. Press to change.`}
      onClick={() => choose(NEXT[choice])}
    >
      {choice.toUpperCase()}
    </button>
  );
}
