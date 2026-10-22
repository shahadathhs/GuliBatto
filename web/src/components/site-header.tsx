import Link from "next/link";
import { hasPlayBuild } from "@/lib/play-build";
import { ThemeToggle } from "./theme-toggle";
import { Wordmark } from "./wordmark";

export function SiteHeader() {
  return (
    <header className="site-header">
      <Wordmark />
      <nav aria-label="Main">
        <Link href="/games">Games</Link>
        <Link href="/how-to-play">How to play</Link>
        {hasPlayBuild() && <Link href="/play">Play</Link>}
        <Link href="/download">Download</Link>
        <Link href="/about">About</Link>
        <ThemeToggle />
      </nav>
    </header>
  );
}
