import Link from "next/link";
import { GAMES, card } from "@/lib/content";

export function SiteFooter() {
  return (
    <footer className="site-footer">
      <div>
        <p className="caption">Guli &amp; Batto</p>
        <p>
          Inspired by the traditional marble games of Bangladesh.{" "}
          <Link href="/about">About these games</Link>
        </p>
      </div>
      <nav aria-label="Games">
        <p className="caption">Games</p>
        <ul>
          {GAMES.map((g) => (
            <li key={g.slug}>
              <Link href={`/games/${g.slug}`}>{card(g.card).title}</Link>
            </li>
          ))}
        </ul>
      </nav>
      <nav aria-label="More">
        <p className="caption">More</p>
        <ul>
          <li>
            <Link href="/how-to-play">How to play</Link>
          </li>
          <li>
            <Link href="/download">Download</Link>
          </li>
          <li>
            <Link href="/contact">Contact</Link>
          </li>
          <li>
            <Link href="/privacy">Privacy</Link>
          </li>
        </ul>
      </nav>
    </footer>
  );
}
